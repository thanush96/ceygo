import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';
import 'package:ceygo_app/features/home/data/vehicle_repository.dart';
import 'package:ceygo_app/core/network/services/vehicle_service.dart' show VehicleSearchParams;

final carRepositoryProvider = Provider<VehicleRepository>((ref) {
  return ApiVehicleRepository();
});

final carListProvider = FutureProvider<List<Car>>((ref) async {
  final repository = ref.watch(carRepositoryProvider);
  return repository.getCars();
});

// Search vehicles provider
final searchVehiclesProvider = FutureProvider.family<List<Car>, VehicleSearchParams>((ref, params) async {
  final repository = ref.watch(carRepositoryProvider);
  return repository.searchVehicles(params);
});

// Vehicle details provider
final vehicleDetailsProvider = FutureProvider.family<Car, String>((ref, id) async {
  final repository = ref.watch(carRepositoryProvider);
  return repository.getVehicleDetails(id);
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
