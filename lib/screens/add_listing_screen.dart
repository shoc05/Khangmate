import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/listing.dart';
import '../services/listing_service.dart';
import '../services/supabase_service.dart';
import '../widgets/image_picker_widget.dart';
import '../utils/image_utils.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final titleC = TextEditingController();
  final priceC = TextEditingController();
  final roomsC = TextEditingController();
  final descC = TextEditingController();
  final _supabase = SupabaseService().client;
  
  String? selectedDzongkhag;
  List<File> images = [];

  LatLng? selectedPoint;

  final List<String> dzongkhags = [
    'Thimphu', 'Paro', 'Punakha', 'Wangdue Phodrang', 'Haa', 'Chhukha',
    'Dagana', 'Tsirang', 'Sarpang', 'Zhemgang', 'Trongsa', 'Bumthang',
    'Mongar', 'Lhuentse', 'Trashigang', 'Trashiyangtse', 'Pemagatshel',
    'Samdrup Jongkhar', 'Samtse', 'Gasa'
  ];

  final _listingService = ListingService();
  bool _submitting = false;

  // Updated image selection handler
  void _onImagesSelected(List<File> images) {
    setState(() {
      this.images = images;
    });
  }

  Future<void> submit() async {
    if (selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pin location on map')),
      );
      return;
    }

    if (titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await _listingService.createListing(
        title: titleC.text.trim(),
        description: descC.text.trim(),
        price: double.tryParse(priceC.text) ?? 0,
        rooms: int.tryParse(roomsC.text) ?? 1,
        location: selectedDzongkhag ?? 'Unknown',
        lat: selectedPoint!.latitude,
        lng: selectedPoint!.longitude,
        images: images,
        category: 'apartment',
      );

    if (mounted) {
      Navigator.of(context).pop(true); // Return success
    }
  } catch (e) {
    if (mounted) {
      setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating listing: $e')),
        );
      }
    }
}

  @override
  void dispose() {
    titleC.dispose();
    priceC.dispose();
    roomsC.dispose();
    descC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),

            // Description
            TextField(
              controller: descC,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),

            // Price
            TextField(
              controller: priceC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (Nu)'),
            ),
            const SizedBox(height: 8),

            // Rooms
            TextField(
              controller: roomsC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of Rooms'),
            ),
            const SizedBox(height: 8),

            // Dzongkhag Dropdown
            DropdownButtonFormField<String>(
              value: selectedDzongkhag,
              hint: const Text('Select Dzongkhag'),
              items: dzongkhags
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => selectedDzongkhag = val),
            ),
            const SizedBox(height: 12),

            // Image Picker Section
            const Text('Upload Images', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ImagePickerWidget(
              selectedImages: images,
              onImagesSelected: _onImagesSelected,
              height: 120,
              width: 150,
            ),
            const SizedBox(height: 16),

            // Map Picker
            const Text('Pin Location on Map', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(27.4728, 89.6390),
                  initialZoom: 8.5,
                  onTap: (tapPos, point) {
                    setState(() => selectedPoint = point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.khangmate_ui',
                  ),
                  if (selectedPoint != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: selectedPoint!,
                          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                        )
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit button
            Center(
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_submitting ? 'Creating...' : 'Add Listing'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
