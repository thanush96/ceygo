import '../../home/domain/models/car.dart';
import '../../../core/models/payment.dart';

class Booking {
  final String id;
  final String userId;
  final String vehicleId;
  final dynamic car; // Vehicle/Car object
  final DateTime startDate;
  final DateTime endDate;
  final String? pickupTime;
  final String pickupLocation;
  final String? dropoffLocation;
  final String? paymentMethod;
  final double totalPrice;
  final double? commission;
  final double? driverEarnings;
  final DateTime bookingDate;
  final String status; // 'pending', 'confirmed', 'active', 'completed', 'cancelled'
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final String? notes;
  final Payment? payment;

  Booking({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.car,
    required this.startDate,
    required this.endDate,
    this.pickupTime,
    required this.pickupLocation,
    this.dropoffLocation,
    this.paymentMethod,
    required this.totalPrice,
    this.commission,
    this.driverEarnings,
    required this.bookingDate,
    this.status = 'pending',
    this.cancellationReason,
    this.cancelledAt,
    this.notes,
    this.payment,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parse vehicle/car from nested object
    dynamic carData;
    if (json['vehicle'] != null) {
      carData = Car.fromJson(json['vehicle'] as Map<String, dynamic>);
    } else if (json['car'] != null) {
      carData = json['car'];
    }

    // Parse payment from nested object
    Payment? paymentData;
    if (json['payment'] != null) {
      paymentData = Payment.fromJson(json['payment'] as Map<String, dynamic>);
    }

    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vehicleId: json['vehicleId'] as String,
      car: carData,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      pickupTime: json['pickupTime'] as String?,
      pickupLocation: json['pickupLocation'] as String,
      dropoffLocation: json['dropoffLocation'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      commission: json['commission'] != null ? (json['commission'] as num).toDouble() : null,
      driverEarnings: json['driverEarnings'] != null ? (json['driverEarnings'] as num).toDouble() : null,
      bookingDate: DateTime.parse(json['createdAt'] as String? ?? json['bookingDate'] as String? ?? DateTime.now().toIso8601String()),
      status: json['status'] as String? ?? 'pending',
      cancellationReason: json['cancellationReason'] as String?,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt'] as String) : null,
      notes: json['notes'] as String?,
      payment: paymentData,
    );
  }

  int get totalDays {
    return endDate.difference(startDate).inDays;
  }

  bool get isActive => status == 'active' || status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPending => status == 'pending';
}
