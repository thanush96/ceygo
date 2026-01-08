import 'package:ceygo_app/features/home/domain/models/car.dart';

class MockCarRepository {
  static const List<Car> cars = [
    Car(
      id: '1',
      name: 'Model 3',
      brand: 'Tesla',
      imageUrl: 'assets/images/car.png', // Placeholder
      pricePerDay: 15000.0,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Electric',
      rating: 4.8,
      tripCount: 42,
    ),
    Car(
      id: '2',
      name: 'Corolla',
      brand: 'Toyota',
      imageUrl: 'assets/images/car.png',
      pricePerDay: 8000.0,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Hybrid',
      rating: 4.5,
      tripCount: 120,
    ),
    Car(
      id: '3',
      name: 'Premio',
      brand: 'Toyota',
      imageUrl: 'assets/images/car.png',
      pricePerDay: 9000.0,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Petrol',
      rating: 4.6,
      tripCount: 85,
    ),
    Car(
      id: '4',
      name: 'Wagon R',
      brand: 'Suzuki',
      imageUrl: 'assets/images/car.png',
      pricePerDay: 5000.0,
      seats: 4,
      transmission: 'Auto',
      fuelType: 'Hybrid',
      rating: 4.2,
      tripCount: 300,
    ),
     Car(
      id: '5',
      name: 'Land Cruiser',
      brand: 'Toyota',
      imageUrl: 'assets/images/car.png',
      pricePerDay: 25000.0,
      seats: 7,
      transmission: 'Auto',
      fuelType: 'Diesel',
      rating: 4.9,
      tripCount: 15,
    ),
  ];

  Future<List<Car>> getCars() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    return cars;
  }
}
