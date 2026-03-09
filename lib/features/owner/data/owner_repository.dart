import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/core/services/api_service.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';
import 'package:ceygo_app/features/booking/domain/models/booking.dart';

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) {
  return OwnerRepository(ref.watch(dioProvider));
});

class OwnerRepository {
  final Dio _dio;
  OwnerRepository(this._dio);

  Future<Map<String, dynamic>> switchRole(String role) async {
    try {
      final response = await _dio.patch('/users/me/role', data: {'role': role});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Car>> getMyVehicles() async {
    try {
      final response = await _dio.get('/vehicles/owner/me');
      final list = response.data as List;
      return list.map((e) => Car.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getOwnerStats() async {
    try {
      final response = await _dio.get('/vehicles/owner/stats');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Car> addVehicle({
    required String name,
    required String brand,
    String? brandLogo,
    String? imageUrl,
    required double pricePerDay,
    required int seats,
    required String transmission,
    required String fuelType,
    required String plateNo,
    bool airportPickupAvailable = false,
    String? location,
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await _dio.post('/vehicles', data: {
        'name': name,
        'brand': brand,
        if (brandLogo != null) 'brandLogo': brandLogo,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'pricePerDay': pricePerDay,
        'seats': seats,
        'transmission': transmission,
        'fuelType': fuelType,
        'plateNo': plateNo,
        'airportPickupAvailable': airportPickupAvailable,
        if (location != null) 'location': location,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      });
      return Car.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Car> updateVehicle(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/vehicles/$id', data: data);
      return Car.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      await _dio.delete('/vehicles/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Booking>> getOwnerBookings() async {
    try {
      final response = await _dio.get('/bookings/owner');
      final list = response.data as List;
      return list.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
