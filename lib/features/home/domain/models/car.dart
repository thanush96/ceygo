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
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      brandLogo: (json['brandLogo'] ?? json['brand_logo'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '') as String,
      pricePerDay: (json['pricePerDay'] ?? json['price_per_day'] ?? 0).toDouble(),
      seats: (json['seats'] ?? 0) as int,
      transmission: (json['transmission'] ?? '') as String,
      fuelType: (json['fuelType'] ?? json['fuel_type'] ?? '') as String,
      rating: (json['rating'] ?? 0).toDouble(),
      tripCount: (json['tripCount'] ?? json['trip_count'] ?? 0) as int,
      location: json['location'] as String?,
    );
  }
}
