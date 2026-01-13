import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/custom_app_bar.dart';
import 'package:ceygo_app/features/booking/presentation/providers/booking_providers.dart';
import 'package:intl/intl.dart';

class SelectedDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setDate(DateTime? date) => state = date;
}

class SelectedMonthYearNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setMonthYear(DateTime date) => state = date;
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime?>(
  SelectedDateNotifier.new,
);

final selectedMonthYearProvider =
    NotifierProvider<SelectedMonthYearNotifier, DateTime>(
      SelectedMonthYearNotifier.new,
    );

class HistoryContent extends ConsumerWidget {
  const HistoryContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookings = ref.watch(bookingHistoryProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedMonthYear = ref.watch(selectedMonthYearProvider);

    // Filter bookings by selected date if any
    final bookings =
        selectedDate == null
            ? allBookings
            : allBookings.where((booking) {
              return booking.startDate.year == selectedDate.year &&
                  booking.startDate.month == selectedDate.month &&
                  booking.startDate.day == selectedDate.day;
            }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(title: "Booking History"),
      body: Column(
        children: [
          // Month/Year Header with Edit button
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM yyyy').format(selectedMonthYear),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // TextButton(
                //   onPressed: () => _showMonthYearPicker(context, ref),
                //   style: TextButton.styleFrom(
                //     backgroundColor: Theme.of(context).primaryColor,
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 8,
                //     ),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //   ),
                //   child: const Text('Edit'),
                // ),
              ],
            ),
          ),

          // Horizontal Date Selector
          Container(
            color: Colors.transparent,
            height: 100,
            child: _DateSelector(
              selectedMonthYear: selectedMonthYear,
              selectedDate: selectedDate,
              onDateSelected: (date) {
                ref.read(selectedDateProvider.notifier).setDate(date);
              },
            ),
          ),

          const SizedBox(height: 8),

          // Bookings List Header
          if (allBookings.isNotEmpty)
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       const Text(
            //         'Bookings',
            //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            //       ),
            //       // Icon(Icons.more_horiz, color: Colors.grey.shade600),
            //     ],
            //   ),
            // ),
            // Bookings List
            Expanded(
              child:
                  bookings.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedDate == null
                                  ? "No booking history"
                                  : "No bookings on this date",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedDate == null
                                  ? "Your past bookings will appear here"
                                  : "Try selecting a different date",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[bookings.length - 1 - index];
                          return _CompactBookingCard(
                            booking: booking,
                            index: index,
                          );
                        },
                      ),
            ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime selectedMonthYear;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;

  const _DateSelector({
    required this.selectedMonthYear,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(selectedMonthYear.year, selectedMonthYear.month + 1, 0).day;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final date = DateTime(
          selectedMonthYear.year,
          selectedMonthYear.month,
          day,
        );
        final isSelected =
            selectedDate?.day == day &&
            selectedDate?.month == selectedMonthYear.month &&
            selectedDate?.year == selectedMonthYear.year;
        final isToday =
            DateTime.now().day == day &&
            DateTime.now().month == selectedMonthYear.month &&
            DateTime.now().year == selectedMonthYear.year;

        return GestureDetector(
          onTap: () => onDateSelected(isSelected ? null : date),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Theme.of(context).primaryColor
                      : isToday
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date).substring(0, 2),
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected
                            ? Colors.white
                            : isToday
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompactBookingCard extends StatelessWidget {
  final dynamic booking;
  final int index;

  const _CompactBookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final car = booking.car;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () => context.push('/car-details/${car.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with car image and basic info
              Row(
                children: [
                  // Car Image
                  Container(
                    width: 100,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      car.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            Icons.directions_car,
                            size: 40,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Car Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${car.brand} ${car.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${car.transmission} • ${car.seats} Seats',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              booking.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            booking.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(booking.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              // Booking Details
              _BookingDetailRow(
                icon: Icons.calendar_today,
                label: 'Rental Period',
                value:
                    '${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}',
              ),
              const SizedBox(height: 8),
              _BookingDetailRow(
                icon: Icons.access_time,
                label: 'Pickup Time',
                value: booking.pickupTime,
              ),
              const SizedBox(height: 8),
              _BookingDetailRow(
                icon: Icons.location_on,
                label: 'Pickup Location',
                value: booking.pickupLocation,
              ),
              const SizedBox(height: 8),
              // _BookingDetailRow(
              //   icon: Icons.payment,
              //   label: 'Payment',
              //   value: booking.paymentMethod,
              // ),
              // const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              // Total Price Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "Rs.${booking.totalPrice.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        " ${booking.totalDays} days",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      // TextSpan(
                      //     text: " (${booking.totalDays} days)",
                      //     style: TextStyle(
                      //       color: Colors.grey.shade600,
                      //       fontSize: 14,
                      //     ),
                      //   ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

class _BookingDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BookingDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _BookingDetailsSheet extends StatelessWidget {
  final dynamic booking;

  const _BookingDetailsSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final car = booking.car;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Booking Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _DetailRow(
            icon: Icons.directions_car,
            label: 'Vehicle',
            value: '${car.brand} ${car.name}',
          ),
          _DetailRow(
            icon: Icons.settings,
            label: 'Transmission',
            value: '${car.transmission} • ${car.seats} Seats',
          ),
          _DetailRow(
            icon: Icons.calendar_today,
            label: 'Rental Period',
            value:
                '${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}',
          ),
          _DetailRow(
            icon: Icons.access_time,
            label: 'Pickup Time',
            value: booking.pickupTime,
          ),
          _DetailRow(
            icon: Icons.location_on,
            label: 'Location',
            value: booking.pickupLocation,
          ),
          _DetailRow(
            icon: Icons.payment,
            label: 'Payment',
            value: booking.paymentMethod,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${booking.totalDays} days)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rs.${booking.totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
