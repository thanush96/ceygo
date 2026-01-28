import 'package:ceygo_app/features/booking/domain/models/booking.dart';
import 'package:ceygo_app/core/network/services/booking_service.dart';
import 'package:ceygo_app/core/network/api_exception.dart';

abstract class BookingRepository {
  Future<Booking> createBooking(CreateBookingRequest request);
  Future<List<Booking>> getBookings({String? type});
  Future<Booking> getBookingDetails(String id);
  Future<Booking> cancelBooking(String id, {String? reason});
  Future<Booking> completeBooking(String id);
}

class ApiBookingRepository implements BookingRepository {
  final BookingService _bookingService = BookingService();

  @override
  Future<Booking> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _bookingService.createBooking(request);
      return Booking.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create booking: ${e.toString()}');
    }
  }

  @override
  Future<List<Booking>> getBookings({String? type}) async {
    try {
      final response = await _bookingService.getBookings(type: type);
      final data = response.data;
      
      if (data is List) {
        return data.map((b) => Booking.fromJson(b as Map<String, dynamic>)).toList();
      }
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch bookings: ${e.toString()}');
    }
  }

  @override
  Future<Booking> getBookingDetails(String id) async {
    try {
      final response = await _bookingService.getBookingDetails(id);
      return Booking.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch booking details: ${e.toString()}');
    }
  }

  @override
  Future<Booking> cancelBooking(String id, {String? reason}) async {
    try {
      final response = await _bookingService.cancelBooking(id, reason: reason);
      return Booking.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to cancel booking: ${e.toString()}');
    }
  }

  @override
  Future<Booking> completeBooking(String id) async {
    try {
      final response = await _bookingService.completeBooking(id);
      return Booking.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to complete booking: ${e.toString()}');
    }
  }
}
