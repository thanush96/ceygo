import 'package:dio/dio.dart';
import '../api_client.dart';

class VehicleSearchParams {
  final String? make;
  final String? model;
  final String? location;
  final String? transmission;
  final String? fuelType;
  final double? minPrice;
  final double? maxPrice;
  final int? seats;
  final String? startDate;
  final String? endDate;
  final int? page;
  final int? limit;

  VehicleSearchParams({
    this.make,
    this.model,
    this.location,
    this.transmission,
    this.fuelType,
    this.minPrice,
    this.maxPrice,
    this.seats,
    this.startDate,
    this.endDate,
    this.page,
    this.limit,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (make != null) map['make'] = make;
    if (model != null) map['model'] = model;
    if (location != null) map['location'] = location;
    if (transmission != null) map['transmission'] = transmission;
    if (fuelType != null) map['fuelType'] = fuelType;
    if (minPrice != null) map['minPrice'] = minPrice;
    if (maxPrice != null) map['maxPrice'] = maxPrice;
    if (seats != null) map['seats'] = seats;
    if (startDate != null) map['startDate'] = startDate;
    if (endDate != null) map['endDate'] = endDate;
    if (page != null) map['page'] = page;
    if (limit != null) map['limit'] = limit;
    return map;
  }
}

class VehicleService {
  final ApiClient _apiClient = ApiClient();

  Future<Response> searchVehicles(VehicleSearchParams params) async {
    return await _apiClient.get('/vehicles', queryParameters: params.toJson());
  }

  Future<Response> getVehicleDetails(String id) async {
    return await _apiClient.get('/vehicles/$id');
  }
}
