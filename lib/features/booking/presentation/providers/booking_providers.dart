import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/features/booking/domain/models/booking.dart';

// Booking History provider
class BookingHistoryNotifier extends Notifier<List<Booking>> {
  @override
  List<Booking> build() {
    return [];
  }

  void addBooking(Booking booking) {
    state = [...state, booking];
  }

  void removeBooking(String bookingId) {
    state = state.where((b) => b.id != bookingId).toList();
  }

  void updateBookingStatus(String bookingId, String status) {
    state = [
      for (final booking in state)
        if (booking.id == bookingId)
          Booking(
            id: booking.id,
            car: booking.car,
            startDate: booking.startDate,
            endDate: booking.endDate,
            pickupTime: booking.pickupTime,
            pickupLocation: booking.pickupLocation,
            paymentMethod: booking.paymentMethod,
            totalPrice: booking.totalPrice,
            bookingDate: booking.bookingDate,
            status: status,
          )
        else
          booking,
    ];
  }
}

final bookingHistoryProvider =
    NotifierProvider<BookingHistoryNotifier, List<Booking>>(
      () => BookingHistoryNotifier(),
    );
