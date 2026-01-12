class Booking {
  final String id;
  final dynamic car;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupTime;
  final String pickupLocation;
  final String paymentMethod;
  final double totalPrice;
  final DateTime bookingDate;
  final String status; // 'active', 'completed', 'cancelled'

  Booking({
    required this.id,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.pickupTime,
    required this.pickupLocation,
    required this.paymentMethod,
    required this.totalPrice,
    required this.bookingDate,
    this.status = 'active',
  });

  int get totalDays {
    return endDate.difference(startDate).inDays;
  }
}
