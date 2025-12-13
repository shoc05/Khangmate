import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserProfile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? email;

  UserProfile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? json['fullName'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email': email,
    };
  }
}

class Listing {
  final String id;
  final String title;
  final String? description;
  final double? price;
  final List<String>? imageUrls;

  Listing({
    required this.id,
    required this.title,
    this.description,
    this.price,
    this.imageUrls,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_urls': imageUrls,
    };
  }
}

class Booking {
  final String id;
  final String listingId;
  final String? listingTitle;
  final String? listingDescription;
  final double? listingPrice;
  final String? coverImagePath;
  final List<String> imagePaths;
  final String renterId;
  final String ownerId;
  final String? renterName;
  final String? renterProfilePic;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? message;
  final String? responseMessage;
  final DateTime? visitDate;
  final TimeOfDay? visitTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;
  final Listing? listing;
  final UserProfile? renter;
  final UserProfile? owner;

  Booking({
    required this.id,
    required this.listingId,
    this.listingTitle,
    this.listingDescription,
    this.listingPrice,
    this.coverImagePath,
    List<String>? imagePaths,
    required this.renterId,
    required this.ownerId,
    this.renterName,
    this.renterProfilePic,
    required this.startDate,
    required this.endDate,
    this.status = 'pending',
    this.message,
    this.responseMessage,
    this.visitDate,
    this.visitTime,
    required this.createdAt,
    required this.updatedAt,
    this.isRead = false,
    this.listing,
    this.renter,
    this.owner,
  }) : imagePaths = imagePaths ?? [];

  Booking copyWith({
    String? id,
    String? listingId,
    String? listingTitle,
    String? listingDescription,
    double? listingPrice,
    String? coverImagePath,
    List<String>? imagePaths,
    String? renterId,
    String? ownerId,
    String? renterName,
    String? renterProfilePic,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? message,
    String? responseMessage,
    DateTime? visitDate,
    TimeOfDay? visitTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRead,
    Listing? listing,
    UserProfile? renter,
    UserProfile? owner,
  }) {
    return Booking(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      listingDescription: listingDescription ?? this.listingDescription,
      listingPrice: listingPrice ?? this.listingPrice,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      imagePaths: imagePaths ?? this.imagePaths,
      renterId: renterId ?? this.renterId,
      ownerId: ownerId ?? this.ownerId,
      renterName: renterName ?? this.renterName,
      renterProfilePic: renterProfilePic ?? this.renterProfilePic,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      message: message ?? this.message,
      responseMessage: responseMessage ?? this.responseMessage,
      visitDate: visitDate ?? this.visitDate,
      visitTime: visitTime ?? this.visitTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      listing: listing ?? this.listing,
      renter: renter ?? this.renter,
      owner: owner ?? this.owner,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    final listing = json['listing'] as Map<String, dynamic>? ?? {};
    final images = json['listing_images'] as List<dynamic>? ?? [];
    return Booking(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      listingTitle: listing['title'] as String?,
      listingDescription: listing['description'] as String?,
      listingPrice: (listing['price'] as num?)?.toDouble(),
      coverImagePath: listing['cover_image_path'] as String?,
      imagePaths: images.map((img) => img['file_path'] as String).toList(),
      renterId: json['renter_id'] as String,
      ownerId: json['owner_id'] as String,
      renterName: json['renter_name'] as String?,
      renterProfilePic: json['renter_profile_pic'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String?,
      responseMessage: json['response_message'] as String?,
      visitDate: json['visit_date'] != null 
          ? DateTime.parse(json['visit_date'] as String) 
          : null,
      visitTime: json['visit_time'] != null 
          ? _parseTime(json['visit_time'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      listing: json['listing'] != null 
          ? Listing.fromJson(json['listing'] is Map ? 
              json['listing'] as Map<String, dynamic> : 
              Map<String, dynamic>.from(json['listing'] as Map)) 
          : null,
      renter: json['renter'] != null 
          ? UserProfile.fromJson(json['renter'] is Map ? 
              json['renter'] as Map<String, dynamic> : 
              Map<String, dynamic>.from(json['renter'] as Map)) 
          : null,
      owner: json['owner'] != null 
          ? UserProfile.fromJson(json['owner'] is Map ? 
              json['owner'] as Map<String, dynamic> : 
              Map<String, dynamic>.from(json['owner'] as Map)) 
          : null,
    );
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'listing_title': listingTitle,
      'listing_description': listingDescription,
      'listing_price': listingPrice,
      'cover_image_path': coverImagePath,
      'image_paths': imagePaths,
      'renter_id': renterId,
      'owner_id': ownerId,
      'renter_name': renterName,
      'renter_profile_pic': renterProfilePic,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'message': message,
      'response_message': responseMessage,
      'visit_date': visitDate?.toIso8601String(),
      'visit_time': visitTime != null 
          ? '${visitTime!.hour}:${visitTime!.minute.toString().padLeft(2, '0')}' 
          : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_read': isRead,
      'listing': listing?.toJson(),
      'renter': renter?.toJson(),
      'owner': owner?.toJson(),
    };
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';

  // Get status color
  Color get statusColor {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Format date range
  String formatDateRange(BuildContext context) {
    final start = DateFormat('MMM d, y').format(startDate);
    final end = DateFormat('MMM d, y').format(endDate);
    return '$start - $end';
  }

  // Format visit date and time
  String? formatVisitDateTime(BuildContext context) {
    if (visitDate == null) return null;
    final date = DateFormat('MMM d, y').format(visitDate!);
    final time = visitTime?.format(context) ?? '';
    return '$date at $time';
  }
}