class VehicleImage {
  final String id;
  final String url;
  final String? s3Key;
  final bool isPrimary;

  VehicleImage({
    required this.id,
    required this.url,
    this.s3Key,
    required this.isPrimary,
  });

  factory VehicleImage.fromJson(Map<String, dynamic> json) {
    return VehicleImage(
      id: json['id'] as String,
      url: json['url'] as String,
      s3Key: json['s3Key'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

class Car {
  final String id;
  final String name;
  final String brand;
  final String brandLogo;
  final String imageUrl;
  final double pricePerDay;
  final int seats;
  final String transmission; // Manual, Auto
  final String fuelType; // Petrol, Diesel, Electric, Hybrid
  final double rating;
  final int tripCount;
  
  // Additional fields from backend
  final String? city;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<VehicleImage>? images;
  final String? status;
  final bool isAvailable;
  final String? description;
  final int? year;
  final String? color;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.brandLogo,
    required this.imageUrl,
    required this.pricePerDay,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    this.rating = 0.0,
    this.tripCount = 0,
    this.city,
    this.location,
    this.latitude,
    this.longitude,
    this.images,
    this.status,
    this.isAvailable = true,
    this.description,
    this.year,
    this.color,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    // Map backend 'make' to 'brand' and 'model' to 'name' for UI compatibility
    final make = json['make'] as String? ?? '';
    final model = json['model'] as String? ?? '';
    
    // Get primary image or first image
    final imagesList = json['images'] as List<dynamic>?;
    VehicleImage? primaryImage;
    String imageUrl = '';
    
    if (imagesList != null && imagesList.isNotEmpty) {
      final imageData = imagesList.map((e) => VehicleImage.fromJson(e as Map<String, dynamic>)).toList();
      primaryImage = imageData.firstWhere((img) => img.isPrimary, orElse: () => imageData.first);
      imageUrl = primaryImage.url;
    }
    
    // Get brand logo (would need to be mapped from make or stored separately)
    final brandLogo = json['brandLogo'] as String? ?? '';

    return Car(
      id: json['id'] as String,
      name: model,
      brand: make,
      brandLogo: brandLogo,
      imageUrl: imageUrl,
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      seats: json['seats'] as int,
      transmission: json['transmission'] as String,
      fuelType: json['fuelType'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      tripCount: json['tripCount'] as int? ?? 0,
      city: json['city'] as String?,
      location: json['location'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      images: imagesList?.map((e) => VehicleImage.fromJson(e as Map<String, dynamic>)).toList(),
      status: json['status'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      description: json['description'] as String?,
      year: json['year'] as int?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': brand,
      'model': name,
      'pricePerDay': pricePerDay,
      'seats': seats,
      'transmission': transmission,
      'fuelType': fuelType,
      'rating': rating,
      'tripCount': tripCount,
      'city': city,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'isAvailable': isAvailable,
      'description': description,
      'year': year,
      'color': color,
    };
  }
}
