import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';
import 'package:ceygo_app/features/home/data/vehicle_repository.dart';

final carListProvider = FutureProvider<List<Car>>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getVehicles();
});

final brandsProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getBrands();
});

final carDetailProvider = FutureProvider.family<Car, String>((ref, id) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getVehicleById(id);
});

// Favorites provider
class FavoritesNotifier extends Notifier<List<Car>> {
  @override
  List<Car> build() {
    return [];
  }

  void toggleFavorite(Car car) {
    final isFavorite = state.any((c) => c.id == car.id);
    if (isFavorite) {
      state = state.where((c) => c.id != car.id).toList();
    } else {
      state = [...state, car];
    }
  }

  bool isFavorite(String carId) {
    return state.any((c) => c.id == carId);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<Car>>(
  () => FavoritesNotifier(),
);
