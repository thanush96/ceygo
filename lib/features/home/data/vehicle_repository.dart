import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/core/services/api_service.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository(dio: ref.watch(dioProvider));
});

class VehicleRepository {
  final Dio _dio;

  VehicleRepository({required Dio dio}) : _dio = dio;

  Future<List<Car>> getVehicles({String? brand, String? q}) async {
    try {
      final params = <String, dynamic>{};
      if (brand != null) params['brand'] = brand;
      if (q != null && q.isNotEmpty) params['q'] = q;

      final response = await _dio.get('/vehicles', queryParameters: params);
      final data = response.data;

      // API returns { items: [...], meta: {...} }
      final List items = data['items'] as List? ?? [];
      return items.map((e) => Car.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Car> getVehicleById(String id) async {
    try {
      final response = await _dio.get('/vehicles/$id');
      return Car.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, String>>> getBrands() async {
    try {
      final response = await _dio.get('/vehicles/brands');
      final List data = response.data as List;
      return data
          .map((e) => {
                'name': (e['name'] ?? '') as String,
                'logo': (e['logo'] ?? '') as String,
              })
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
