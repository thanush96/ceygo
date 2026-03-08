import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/core/services/api_service.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository(dio: ref.watch(dioProvider));
});

class FavoriteRepository {
  final Dio _dio;

  FavoriteRepository({required Dio dio}) : _dio = dio;

  Future<List<Car>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      final List data = response.data as List;
      return data.map((e) => Car.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<String>> getFavoriteIds() async {
    try {
      final response = await _dio.get('/favorites/ids');
      final List data = response.data as List;
      return data.map((e) => e.toString()).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> addFavorite(String vehicleId) async {
    try {
      await _dio.post('/favorites/$vehicleId');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> removeFavorite(String vehicleId) async {
    try {
      await _dio.delete('/favorites/$vehicleId');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
