class Car {
  final String id;
  final String name;
  final String brand;
  final String brandLogo;
  final String imageUrl;
  final double pricePerDay;
  final int seats;
  final String transmission;
  final String fuelType;
  final double rating;
  final int tripCount;
  final String? location;
  final List<String> images;
  final String? ownerId;
  final String? ownerName;
  final String verificationStatus;
  final bool? isVerified;

  const Car({
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
    this.location,
    this.images = const [],
    this.ownerId,
    this.ownerName,
    this.verificationStatus = '',
    this.isVerified,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'];
    String? ownerId;
    String? ownerName;
    if (owner is Map<String, dynamic>) {
      ownerId = owner['id'] as String?;
      ownerName = owner['name'] as String?;
    } else if (owner is String) {
      ownerId = owner;
    }

    return Car(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      brandLogo: (json['brandLogo'] ?? json['brand_logo'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '') as String,
      pricePerDay:
          (json['pricePerDay'] ?? json['price_per_day'] ?? 0).toDouble(),
      seats: (json['seats'] ?? 0) as int,
      transmission: (json['transmission'] ?? '') as String,
      fuelType: (json['fuelType'] ?? json['fuel_type'] ?? '') as String,
      rating: (json['rating'] ?? 0).toDouble(),
      tripCount: (json['tripCount'] ?? json['trip_count'] ?? 0) as int,
      location: json['location'] as String?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ownerId: ownerId,
      ownerName: ownerName,
      verificationStatus:
          (json['verificationStatus'] ?? json['verification_status'] ?? '')
              .toString(),
      isVerified:
          json['isVerified'] is bool
              ? json['isVerified'] as bool
              : json['is_verified'] is bool
              ? json['is_verified'] as bool
              : null,
    );
  }
}
