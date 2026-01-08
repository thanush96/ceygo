import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/car_manufacturer.dart';

class CarManufacturerRepository {
  static const String _assetPath = 'assets/data/car_manufacturers.json';

  Future<List<CarManufacturer>> getCarManufacturers() async {
    final String jsonString = await rootBundle.loadString(_assetPath);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    return jsonList
        .map((json) => CarManufacturer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<CarManufacturer?> getManufacturerBySlug(String slug) async {
    final manufacturers = await getCarManufacturers();
    try {
      return manufacturers.firstWhere((m) => m.slug == slug);
    } catch (e) {
      return null;
    }
  }

  Future<List<CarManufacturer>> searchManufacturers(String query) async {
    final manufacturers = await getCarManufacturers();
    final lowerQuery = query.toLowerCase();

    return manufacturers
        .where((m) => m.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
