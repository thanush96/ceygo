import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/features/booking/domain/models/booking.dart';
import 'package:ceygo_app/features/booking/data/booking_repository.dart';

// Async provider for fetching bookings from API
final bookingHistoryProvider = AsyncNotifierProvider<BookingHistoryNotifier, List<Booking>>(
  BookingHistoryNotifier.new,
);

class BookingHistoryNotifier extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() async {
    final repo = ref.watch(bookingRepositoryProvider);
    return repo.getMyBookings();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final repo = ref.read(bookingRepositoryProvider);
      return repo.getMyBookings();
    });
  }

  Future<Map<String, dynamic>> createBooking({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
    required String pickupLocation,
    required String dropoffLocation,
    String? flightNumber,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.createBooking(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      flightNumber: flightNumber,
    );
    // Refresh the list after creating
    await refresh();
    return result;
  }

  Future<void> cancelBooking(String bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.cancelBooking(bookingId);
    // Update local state
    final current = state.value ?? [];
    state = AsyncData(
      current.map((b) => b.id == bookingId ? b.copyWith(status: 'cancelled') : b).toList(),
    );
  }
}

// Single booking detail provider
final bookingDetailProvider = FutureProvider.family<Booking, String>((ref, id) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBookingById(id);
});
