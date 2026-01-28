import 'package:dio/dio.dart';
import '../api_client.dart';

class CreateBookingRequest {
  final String vehicleId;
  final String startDate;
  final String endDate;
  final String? pickupTime;
  final String pickupLocation;
  final String? dropoffLocation;
  final String? notes;

  CreateBookingRequest({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    this.pickupTime,
    required this.pickupLocation,
    this.dropoffLocation,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'startDate': startDate,
      'endDate': endDate,
      if (pickupTime != null) 'pickupTime': pickupTime,
      'pickupLocation': pickupLocation,
      if (dropoffLocation != null) 'dropoffLocation': dropoffLocation,
      if (notes != null) 'notes': notes,
    };
  }
}

class BookingService {
  final ApiClient _apiClient = ApiClient();

  Future<Response> createBooking(CreateBookingRequest request) async {
    return await _apiClient.post('/bookings', data: request.toJson());
  }

  Future<Response> getBookings({String? type}) async {
    return await _apiClient.get('/bookings', queryParameters: type != null ? {'type': type} : null);
  }

  Future<Response> getBookingDetails(String id) async {
    return await _apiClient.get('/bookings/$id');
  }

  Future<Response> cancelBooking(String id, {String? reason}) async {
    return await _apiClient.put('/bookings/$id/cancel', data: reason != null ? {'reason': reason} : null);
  }

  Future<Response> completeBooking(String id) async {
    return await _apiClient.put('/bookings/$id/complete');
  }
}
