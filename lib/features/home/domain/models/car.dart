class Car {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final double pricePerDay;
  final int seats;
  final String transmission; // Manual, Auto
  final String fuelType; // Petrol, Diesel, Electric, Hybrid
  final double rating;
  final int tripCount;

  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.pricePerDay,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    this.rating = 0.0,
    this.tripCount = 0,
  });
}
