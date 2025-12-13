// lib/screens/booking_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/notification_service.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  _BookingRequestsScreenState createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen>
    with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  final NotificationService _notificationService = NotificationService();
  late TabController _tabController;

  List<Booking> _receivedBookings = [];
  List<Booking> _sentBookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final received = await _bookingService.getBookingsForMyListings();
      final sent = await _bookingService.getMyBookings();

      if (mounted) {
        setState(() {
          _receivedBookings = received;
          _sentBookings = sent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load bookings. Please try again.';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _updateBookingStatus(Booking? booking, String status) async {
    if (booking == null) return;

    try {
      final updatedBooking = await _bookingService.updateBookingStatus(
        bookingId: booking.id,
        status: status,
        responseMessage: 'Your booking has been $status',
      );

      if (updatedBooking != null && mounted) {
        // Update the booking in the list
        setState(() {
          if (_tabController.index == 0) {
            final index = _receivedBookings.indexWhere((b) => b.id == booking.id);
            if (index != -1) {
              _receivedBookings[index] = updatedBooking;
            }
          } else {
            final index = _sentBookings.indexWhere((b) => b.id == booking.id);
            if (index != -1) {
              _sentBookings[index] = updatedBooking;
            }
          }
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking $status successfully')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update booking: No data returned')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update booking: $e')),
        );
      }
    }
  }

  Widget _buildBookingCard(Booking booking, {bool isReceived = true}) {
    final user = isReceived ? booking.renter : booking.owner;
    final dateRange = '${_formatDate(booking.startDate)} - ${_formatDate(booking.endDate)}';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: user?.avatarUrl != null 
              ? NetworkImage(user!.avatarUrl!) as ImageProvider
              : null,
          backgroundColor: Colors.blueGrey[200],
          child: user?.avatarUrl == null 
              ? Text(
                  user?.fullName?.isNotEmpty == true 
                      ? user!.fullName![0].toUpperCase() 
                      : '?',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          isReceived 
              ? booking.listingTitle ?? 'Unknown Listing'
              : 'Booking for ${booking.listingTitle ?? 'Unknown Listing'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.fullName ?? 'Unknown User'),
            const SizedBox(height: 2),
            Text(dateRange),
            if (booking.visitDate != null && booking.visitTime != null) ...[
              const SizedBox(height: 2),
              Text('Visit: ${_formatDate(booking.visitDate)} at ${booking.visitTime!.format(context)}'),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.status[0].toUpperCase() + booking.status.substring(1),
                style: TextStyle(
                  color: _getStatusColor(booking.status),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            if (isReceived && booking.status == 'pending') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateBookingStatus(booking, 'approved'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateBookingStatus(booking, 'rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        onTap: () => _showBookingDetails(booking),
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${_formatStatus(booking.status)}'),
              const SizedBox(height: 8),
              Text('From: ${_formatDate(booking.startDate)}'),
              Text('To: ${_formatDate(booking.endDate)}'),
              if (booking.message != null) ...[
                const SizedBox(height: 8),
                Text('Message: ${booking.message}'),
              ],
              if (booking.responseMessage != null) ...[
                const SizedBox(height: 8),
                Text('Response: ${booking.responseMessage}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return DateFormat('MMM d, y').format(date);
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Received Bookings Tab
                      _receivedBookings.isEmpty
                          ? const Center(child: Text('No received bookings'))
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 8),
                              itemCount: _receivedBookings.length,
                              itemBuilder: (context, index) {
                                return _buildBookingCard(
                                  _receivedBookings[index],
                                  isReceived: true,
                                );
                              },
                            ),

                      // Sent Bookings Tab
                      _sentBookings.isEmpty
                          ? const Center(child: Text('No sent bookings'))
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 8),
                              itemCount: _sentBookings.length,
                              itemBuilder: (context, index) {
                                return _buildBookingCard(
                                  _sentBookings[index],
                                  isReceived: false,
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }
}