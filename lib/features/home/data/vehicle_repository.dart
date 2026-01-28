import 'package:ceygo_app/features/home/domain/models/car.dart';
import 'package:ceygo_app/core/network/services/vehicle_service.dart';
import 'package:ceygo_app/core/network/api_exception.dart';

// Re-export VehicleSearchParams for convenience
export 'package:ceygo_app/core/network/services/vehicle_service.dart' show VehicleSearchParams;

abstract class VehicleRepository {
  Future<List<Car>> getCars();
  Future<List<Car>> searchVehicles(VehicleSearchParams params);
  Future<Car> getVehicleDetails(String id);
}

class ApiVehicleRepository implements VehicleRepository {
  final VehicleService _vehicleService = VehicleService();

  @override
  Future<List<Car>> getCars() async {
    try {
      final response = await _vehicleService.searchVehicles(VehicleSearchParams());
      final data = response.data;
      
      if (data is Map<String, dynamic> && data['data'] != null) {
        final vehicles = data['data'] as List<dynamic>;
        return vehicles.map((v) => Car.fromJson(v as Map<String, dynamic>)).toList();
      } else if (data is List) {
        return data.map((v) => Car.fromJson(v as Map<String, dynamic>)).toList();
      }
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch vehicles: ${e.toString()}');
    }
  }

  @override
  Future<List<Car>> searchVehicles(VehicleSearchParams params) async {
    try {
      final response = await _vehicleService.searchVehicles(params);
      final data = response.data;
      
      if (data is Map<String, dynamic> && data['data'] != null) {
        final vehicles = data['data'] as List<dynamic>;
        return vehicles.map((v) => Car.fromJson(v as Map<String, dynamic>)).toList();
      } else if (data is List) {
        return data.map((v) => Car.fromJson(v as Map<String, dynamic>)).toList();
      }
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to search vehicles: ${e.toString()}');
    }
  }

  @override
  Future<Car> getVehicleDetails(String id) async {
    try {
      final response = await _vehicleService.getVehicleDetails(id);
      return Car.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch vehicle details: ${e.toString()}');
    }
  }
}
