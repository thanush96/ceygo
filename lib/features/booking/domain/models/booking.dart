import 'package:ceygo_app/features/home/domain/models/car.dart';

class Booking {
  final String id;
  final dynamic car;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupTime;
  final String pickupLocation;
  final String? dropoffLocation;
  final String paymentMethod;
  final double totalPrice;
  final DateTime bookingDate;
  final String status; // pending, confirmed, paid, completed, cancelled

  Booking({
    required this.id,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.pickupTime,
    required this.pickupLocation,
    this.dropoffLocation,
    required this.paymentMethod,
    required this.totalPrice,
    required this.bookingDate,
    this.status = 'pending',
  });

  int get totalDays {
    final days = endDate.difference(startDate).inDays;
    return days > 0 ? days : 1;
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parse vehicle - can be full object or just ID
    dynamic car;
    final vehicle = json['vehicle'];
    if (vehicle is Map<String, dynamic>) {
      car = Car.fromJson(vehicle);
    }

    // Parse payment method
    String paymentMethod = 'PayHere';
    final payment = json['payment'];
    if (payment is Map<String, dynamic>) {
      paymentMethod = payment['method'] as String? ?? 'PayHere';
    }

    return Booking(
      id: json['id'] as String,
      car: car,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      pickupTime: '', // Backend doesn't have separate pickup time
      pickupLocation: json['pickupLocation'] as String? ?? '',
      dropoffLocation: json['dropoffLocation'] as String?,
      paymentMethod: paymentMethod,
      totalPrice: _parseDouble(json['totalPrice']),
      bookingDate: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Booking copyWith({String? status}) {
    return Booking(
      id: id,
      car: car,
      startDate: startDate,
      endDate: endDate,
      pickupTime: pickupTime,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      paymentMethod: paymentMethod,
      totalPrice: totalPrice,
      bookingDate: bookingDate,
      status: status ?? this.status,
    );
  }
}
