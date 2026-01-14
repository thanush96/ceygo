import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/features/booking/domain/models/booking.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/core/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            CustomAppBar(
              title: 'Booking Details',
              useCustomStyle: true,
              leftIcon: Icons.arrow_back,
              onLeftPressed: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Ticket Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Top Section with QR Code
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      booking.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    booking.status.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(booking.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // QR Code
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 2,
                                    ),
                                  ),
                                  child: QrImageView(
                                    data: booking.id,
                                    version: QrVersions.auto,
                                    size: 200.0,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Scan this on the spot when you\nare in the parking lot',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Dotted Divider
                          _buildDottedDivider(),

                          // Booking Details Section
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Car Information
                                _buildDetailRow(
                                  'Vehicle',
                                  '${booking.car.brand} ${booking.car.name}',
                                  Icons.directions_car,
                                ),
                                const SizedBox(height: 20),

                                // Location
                                _buildDetailRow(
                                  'Location',
                                  booking.pickupLocation,
                                  Icons.location_on,
                                ),
                                const SizedBox(height: 20),

                                // Date Range
                                _buildDetailRow(
                                  'Duration',
                                  '${DateFormat('MMM dd, yyyy').format(booking.startDate)} - ${DateFormat('MMM dd, yyyy').format(booking.endDate)}',
                                  Icons.calendar_today,
                                ),
                                const SizedBox(height: 20),

                                // Time
                                _buildDetailRow(
                                  'Pickup Time',
                                  booking.pickupTime,
                                  Icons.access_time,
                                ),
                                const SizedBox(height: 20),

                                // Total Days
                                _buildDetailRow(
                                  'Total Days',
                                  '${booking.totalDays} ${booking.totalDays == 1 ? 'day' : 'days'}',
                                  Icons.event_note,
                                ),
                                const SizedBox(height: 20),

                                // Booking Date
                                _buildDetailRow(
                                  'Booked On',
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(booking.bookingDate),
                                  Icons.book_online,
                                ),
                                const SizedBox(height: 20),

                                // Payment Method
                                _buildDetailRow(
                                  'Payment Method',
                                  booking.paymentMethod,
                                  Icons.payment,
                                ),
                              ],
                            ),
                          ),

                          // Dotted Divider
                          _buildDottedDivider(),

                          // Price Section
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Rs ${booking.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    if (booking.status == 'active') ...[
                      // Cancel Booking Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigator.of(context).pop();
                            // // TODO: Implement cancel booking functionality
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(
                            //     content: Text('Booking cancelled successfully'),
                            //     backgroundColor: Colors.red,
                            //   ),
                            // );
                            // context.pop();
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            side: const BorderSide(
                              color: Colors.red,
                              width: 0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Cancel Booking',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDottedDivider() {
    return Row(
      children: [
        // Left semicircle cutout
        Container(
          width: 20,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F4FF),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        // Dotted line
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = constraints.constrainWidth();
              const dashWidth = 5.0;
              const dashSpace = 5.0;
              final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(dashCount, (_) {
                  return Container(
                    width: dashWidth,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        // Right semicircle cutout
        Container(
          width: 20,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F4FF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
