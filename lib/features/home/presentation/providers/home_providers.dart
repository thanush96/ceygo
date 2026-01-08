import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';
import 'package:ceygo_app/features/home/data/mock_car_repository.dart';

final carRepositoryProvider = Provider((ref) => MockCarRepository());

final carListProvider = FutureProvider<List<Car>>((ref) async {
  final repository = ref.watch(carRepositoryProvider);
  return repository.getCars();
});
