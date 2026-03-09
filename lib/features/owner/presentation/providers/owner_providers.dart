import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/features/owner/data/owner_repository.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';
import 'package:ceygo_app/features/booking/domain/models/booking.dart';

// Owner stats
final ownerStatsProvider = AsyncNotifierProvider<OwnerStatsNotifier, Map<String, dynamic>>(
  OwnerStatsNotifier.new,
);

class OwnerStatsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final repo = ref.watch(ownerRepositoryProvider);
    return repo.getOwnerStats();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(ownerRepositoryProvider).getOwnerStats());
  }
}

// My vehicles list
final myVehiclesProvider = AsyncNotifierProvider<MyVehiclesNotifier, List<Car>>(
  MyVehiclesNotifier.new,
);

class MyVehiclesNotifier extends AsyncNotifier<List<Car>> {
  @override
  Future<List<Car>> build() async {
    final repo = ref.watch(ownerRepositoryProvider);
    return repo.getMyVehicles();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(ownerRepositoryProvider).getMyVehicles());
  }

  Future<void> deleteVehicle(String id) async {
    final repo = ref.read(ownerRepositoryProvider);
    await repo.deleteVehicle(id);
    state = AsyncData((state.value ?? []).where((v) => v.id != id).toList());
  }
}

// Owner bookings
final ownerBookingsProvider = AsyncNotifierProvider<OwnerBookingsNotifier, List<Booking>>(
  OwnerBookingsNotifier.new,
);

class OwnerBookingsNotifier extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() async {
    final repo = ref.watch(ownerRepositoryProvider);
    return repo.getOwnerBookings();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(ownerRepositoryProvider).getOwnerBookings());
  }
}
