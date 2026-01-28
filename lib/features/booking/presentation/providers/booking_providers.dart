import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/features/booking/domain/models/booking.dart';
import 'package:ceygo_app/features/booking/data/booking_repository.dart';
import 'package:ceygo_app/core/network/services/booking_service.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return ApiBookingRepository();
});

// Booking History provider - fetches from API
class BookingHistoryNotifier extends Notifier<AsyncValue<List<Booking>>> {
  @override
  Future<List<Booking>> build() async {
    final repository = ref.read(bookingRepositoryProvider);
    return repository.getBookings();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bookingRepositoryProvider);
      return repository.getBookings();
    });
  }

  Future<void> addBooking(Booking booking) async {
    // Optimistically add to list
    final currentBookings = state.value ?? [];
    state = AsyncValue.data([booking, ...currentBookings]);
  }

  Future<void> removeBooking(String bookingId) async {
    final repository = ref.read(bookingRepositoryProvider);
    await repository.cancelBooking(bookingId);
    await refresh();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await refresh();
  }
}

final bookingHistoryProvider =
    NotifierProvider<BookingHistoryNotifier, AsyncValue<List<Booking>>>(
      () => BookingHistoryNotifier(),
    );

// Create booking provider
final createBookingProvider = FutureProvider.family<Booking, CreateBookingRequest>((ref, request) async {
  final repository = ref.read(bookingRepositoryProvider);
  return repository.createBooking(request);
});

// Cancel booking provider
final cancelBookingProvider = FutureProvider.family<Booking, Map<String, String>>((ref, params) async {
  final repository = ref.read(bookingRepositoryProvider);
  return repository.cancelBooking(params['id']!, reason: params['reason']);
});
