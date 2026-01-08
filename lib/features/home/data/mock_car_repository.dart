import 'package:ceygo_app/features/home/domain/models/car.dart';

class MockCarRepository {
  // Brand logo URLs from car_manufacturers.json
  static const String _toyotaLogo =
      'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/toyota.png';
  static const String _bmwLogo =
      'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/bmw.png';
  static const String _benzLogo =
      'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/mercedes-benz.png';
  static const String _hyundaiLogo =
      'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/hyundai.png';
  static const String _jeepLogo =
      'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/jeep.png';

  static const List<Car> cars = [
    // Toyota
    Car(
      id: '1',
      name: 'Corolla',
      brand: 'Toyota',
      brandLogo: _toyotaLogo,
      imageUrl: 'assets/cars/toyota.png',
      pricePerDay: 8000.0,
      seats: 5,
      transmission: 'Automatic',
      fuelType: 'Hybrid',
      rating: 4.5,
      tripCount: 120,
    ),
    Car(
      id: '2',
      name: 'Coaster',
      brand: 'Toyota',
      brandLogo: _toyotaLogo,
      imageUrl: 'assets/cars/coaster.png',
      pricePerDay: 25000.0,
      seats: 29,
      transmission: 'Manual',
      fuelType: 'Diesel',
      rating: 4.7,
      tripCount: 45,
    ),
    Car(
      id: '3',
      name: 'KDH Van',
      brand: 'Toyota',
      brandLogo: _toyotaLogo,
      imageUrl: 'assets/cars/kdh.png',
      pricePerDay: 15000.0,
      seats: 15,
      transmission: 'Automatic',
      fuelType: 'Diesel',
      rating: 4.6,
      tripCount: 89,
    ),
    // BMW
    Car(
      id: '4',
      name: '3 Series',
      brand: 'BMW',
      brandLogo: _bmwLogo,
      imageUrl: 'assets/cars/bmw.png',
      pricePerDay: 18000.0,
      seats: 5,
      transmission: 'Automatic',
      fuelType: 'Petrol',
      rating: 4.8,
      tripCount: 67,
    ),
    Car(
      id: '5',
      name: '5 Series',
      brand: 'BMW',
      brandLogo: _bmwLogo,
      imageUrl: 'assets/cars/bmw2.png',
      pricePerDay: 22000.0,
      seats: 5,
      transmission: 'Automatic',
      fuelType: 'Petrol',
      rating: 4.9,
      tripCount: 34,
    ),
    Car(
      id: '6',
      name: 'X5',
      brand: 'BMW',
      brandLogo: _bmwLogo,
      imageUrl: 'assets/cars/bmw3.png',
      pricePerDay: 28000.0,
      seats: 7,
      transmission: 'Automatic',
      fuelType: 'Diesel',
      rating: 4.8,
      tripCount: 28,
    ),
    // Mercedes-Benz
    Car(
      id: '7',
      name: 'E-Class',
      brand: 'Mercedes-Benz',
      brandLogo: _benzLogo,
      imageUrl: 'assets/cars/benz.png',
      pricePerDay: 25000.0,
      seats: 5,
      transmission: 'Automatic',
      fuelType: 'Petrol',
      rating: 4.9,
      tripCount: 52,
    ),
    // Hyundai
    Car(
      id: '8',
      name: 'Tucson',
      brand: 'Hyundai',
      brandLogo: _hyundaiLogo,
      imageUrl: 'assets/cars/hundai.png',
      pricePerDay: 12000.0,
      seats: 5,
      transmission: 'Automatic',
      fuelType: 'Diesel',
      rating: 4.5,
      tripCount: 156,
    ),
    // Jeep
    Car(
      id: '9',
      name: 'Wrangler',
      brand: 'Jeep',
      brandLogo: _jeepLogo,
      imageUrl: 'assets/cars/jeep.png',
      pricePerDay: 20000.0,
      seats: 5,
      transmission: 'Automatic',
      fuelType: 'Petrol',
      rating: 4.7,
      tripCount: 73,
    ),
  ];

  Future<List<Car>> getCars() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    return cars;
  }

  /// Get unique brands with their logos
  static List<Map<String, String>> getBrands() {
    final Map<String, String> brandMap = {};
    for (final car in cars) {
      if (!brandMap.containsKey(car.brand)) {
        brandMap[car.brand] = car.brandLogo;
      }
    }
    return brandMap.entries
        .map((e) => {'name': e.key, 'logo': e.value})
        .toList();
  }
}
