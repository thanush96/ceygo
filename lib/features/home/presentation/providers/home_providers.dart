import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';
import 'package:ceygo_app/features/home/data/mock_car_repository.dart';

final carRepositoryProvider = Provider((ref) => MockCarRepository());

final carListProvider = FutureProvider<List<Car>>((ref) async {
  final repository = ref.watch(carRepositoryProvider);
  return repository.getCars();
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
