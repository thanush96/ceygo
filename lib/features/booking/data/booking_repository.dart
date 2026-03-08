import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/core/services/api_service.dart';
import 'package:ceygo_app/features/booking/domain/models/booking.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(dioProvider));
});

class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio);

  Future<Map<String, dynamic>> createBooking({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
    required String pickupLocation,
    required String dropoffLocation,
    String? flightNumber,
  }) async {
    try {
      final response = await _dio.post('/bookings', data: {
        'vehicleId': vehicleId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'pickupLocation': pickupLocation,
        'dropoffLocation': dropoffLocation,
        if (flightNumber != null) 'flightNumber': flightNumber,
      });

      final data = response.data;
      return {
        'booking': Booking.fromJson(data['booking']),
        'paymentLink': data['paymentLink'] as String?,
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _dio.get('/bookings');
      final list = response.data as List;
      return list.map((json) => Booking.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Booking> getBookingById(String id) async {
    try {
      final response = await _dio.get('/bookings/$id');
      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      await _dio.patch('/bookings/$id/cancel');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
