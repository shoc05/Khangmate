/// Listing model for property listings
class Listing {
  final String id;
  final String title;
  final String description;
  final String imageUrl; // primary image URL (first image)
  final List<String> imageUrls; // all image URLs
  final double price;
  final String username; // owner username (for display)
  final String ownerId; // owner user_id from auth.users
  final String? ownerAvatarUrl; // owner avatar URL
  final int rooms;
  final String location; // dzongkhag
  final double lat;
  final double lng;
  final String? locationPoint; // Store as WKT (Well-Known Text) format
  final bool published;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? category;
  final List<String>? tags;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
    this.imageUrls = const [],
    required this.price,
    required this.username,
    required this.ownerId,
    this.ownerAvatarUrl,
    required this.rooms,
    required this.location,
    required this.lat,
    required this.lng,
    this.locationPoint,
    this.published = true,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.tags,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    // Get image URLs from processed data (already converted from file_path to URLs)
    final imageUrls = (json['image_urls'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((url) => url.isNotEmpty)
            .toList() ?? 
        [];
    
    // Get primary image URL
    final primaryImageUrl = json['image_url'] as String? ?? 
                           (imageUrls.isNotEmpty ? imageUrls.first : '');
    
    // Get profile data (owner info) if available
    final profile = json['profiles'] as Map<String, dynamic>?;
    
    return Listing(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: primaryImageUrl,
      imageUrls: imageUrls.cast<String>(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      username: json['owner_username']?.toString() ?? 
                profile?['username']?.toString() ?? 
                profile?['full_name']?.toString() ?? 
                'Unknown',
      ownerId: json['owner_id']?.toString() ?? '',
      ownerAvatarUrl: json['owner_avatar_url']?.toString() ??
                     profile?['avatar_url']?.toString(),
      rooms: (json['rooms'] as num?)?.toInt() ?? 1,
      location: json['location']?.toString() ?? 
                json['dzongkhag']?.toString() ?? 
                'Unknown',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      locationPoint: json['location_point']?.toString(),
      published: json['published'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      category: json['category']?.toString(),
      tags: json['tags'] != null
          ? (json['tags'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'owner_id': ownerId,
      'rooms': rooms,
      'location': location,
      'dzongkhag': location,
      'lat': lat,
      'lng': lng,
      if (locationPoint != null) 'location_point': locationPoint,
      'published': published,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category': category,
      'tags': tags,
    };
  }
}


