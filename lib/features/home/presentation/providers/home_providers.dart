import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';
import 'package:ceygo_app/features/home/data/vehicle_repository.dart';
import 'package:ceygo_app/features/home/data/favorite_repository.dart';

// Selected brand filter state (null = "All")
final selectedBrandProvider = StateProvider<String?>((ref) => null);

final carListProvider = FutureProvider<List<Car>>((ref) async {
  final brand = ref.watch(selectedBrandProvider);
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getVehicles(brand: brand);
});

final brandsProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getBrands();
});

final carDetailProvider = FutureProvider.family<Car, String>((ref, id) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getVehicleById(id);
});

// Favorites — backed by API
final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Car>>(FavoritesNotifier.new);

class FavoritesNotifier extends AsyncNotifier<List<Car>> {
  @override
  Future<List<Car>> build() async {
    final repository = ref.watch(favoriteRepositoryProvider);
    return repository.getFavorites();
  }

  Future<void> toggleFavorite(Car car) async {
    final repository = ref.read(favoriteRepositoryProvider);
    final currentList = state.value ?? [];
    final isFav = currentList.any((c) => c.id == car.id);

    // Optimistic update
    if (isFav) {
      state = AsyncData(currentList.where((c) => c.id != car.id).toList());
    } else {
      state = AsyncData([car, ...currentList]);
    }

    try {
      if (isFav) {
        await repository.removeFavorite(car.id);
      } else {
        await repository.addFavorite(car.id);
      }
    } catch (e) {
      // Revert on failure
      ref.invalidateSelf();
    }
  }
}

// Favorite IDs for quick lookup (derived locally to avoid an extra API call)
final favoriteIdsProvider = Provider<Set<String>>((ref) {
  final favorites = ref.watch(favoritesProvider).maybeWhen(
    data: (items) => items,
    orElse: () => const <Car>[],
  );
  return favorites.map((car) => car.id).toSet();
});
