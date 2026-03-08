import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/custom_app_bar.dart';
import 'package:ceygo_app/features/booking/presentation/providers/booking_providers.dart';
import 'package:ceygo_app/features/booking/domain/models/booking.dart';
import 'package:intl/intl.dart';

// --- Providers ---

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

class SelectedStatusFilterNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void setFilter(String filter) => state = filter;
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime?>(
  SelectedDateNotifier.new,
);

final selectedMonthYearProvider =
    NotifierProvider<SelectedMonthYearNotifier, DateTime>(
  SelectedMonthYearNotifier.new,
);

final selectedStatusFilterProvider =
    NotifierProvider<SelectedStatusFilterNotifier, String>(
  SelectedStatusFilterNotifier.new,
);

// --- Main Widget ---

class HistoryContent extends ConsumerWidget {
  const HistoryContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingHistoryProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedMonthYear = ref.watch(selectedMonthYearProvider);
    final statusFilter = ref.watch(selectedStatusFilterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(title: "Booking History"),
      body: Column(
        children: [
          // Month/Year Header with navigation
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    final prev = DateTime(
                      selectedMonthYear.year,
                      selectedMonthYear.month - 1,
                    );
                    ref
                        .read(selectedMonthYearProvider.notifier)
                        .setMonthYear(prev);
                    ref.read(selectedDateProvider.notifier).setDate(null);
                  },
                  icon: const Icon(Icons.chevron_left, size: 28),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(selectedMonthYear),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final next = DateTime(
                      selectedMonthYear.year,
                      selectedMonthYear.month + 1,
                    );
                    ref
                        .read(selectedMonthYearProvider.notifier)
                        .setMonthYear(next);
                    ref.read(selectedDateProvider.notifier).setDate(null);
                  },
                  icon: const Icon(Icons.chevron_right, size: 28),
                ),
              ],
            ),
          ),

          // Horizontal Date Selector
          SizedBox(
            height: 80,
            child: _DateSelector(
              selectedMonthYear: selectedMonthYear,
              selectedDate: selectedDate,
              bookings: bookingsAsync.maybeWhen(
                data: (bookings) => bookings,
                orElse: () => [],
              ),
              onDateSelected: (date) {
                ref.read(selectedDateProvider.notifier).setDate(date);
              },
            ),
          ),

          const SizedBox(height: 8),

          // Status Filter Chips
          _StatusFilterBar(
            selected: statusFilter,
            onSelected: (filter) {
              ref.read(selectedStatusFilterProvider.notifier).setFilter(filter);
            },
          ),

          const SizedBox(height: 4),

          // Bookings List
          Expanded(
            child: bookingsAsync.when(
              data: (allBookings) {
                var bookings = allBookings;

                // Filter by selected date — match if the date falls within the booking range
                if (selectedDate != null) {
                  bookings = bookings.where((b) {
                    final dateOnly = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                    );
                    final start = DateTime(
                      b.startDate.year,
                      b.startDate.month,
                      b.startDate.day,
                    );
                    final end = DateTime(
                      b.endDate.year,
                      b.endDate.month,
                      b.endDate.day,
                    );
                    return !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
                  }).toList();
                } else {
                  // Filter by selected month
                  bookings = bookings.where((b) {
                    return (b.startDate.year == selectedMonthYear.year &&
                            b.startDate.month == selectedMonthYear.month) ||
                        (b.endDate.year == selectedMonthYear.year &&
                            b.endDate.month == selectedMonthYear.month);
                  }).toList();
                }

                // Filter by status
                if (statusFilter != 'all') {
                  bookings = bookings.where((b) {
                    switch (statusFilter) {
                      case 'active':
                        return ['pending', 'confirmed', 'paid', 'active']
                            .contains(b.status.toLowerCase());
                      case 'completed':
                        return b.status.toLowerCase() == 'completed';
                      case 'cancelled':
                        return b.status.toLowerCase() == 'cancelled';
                      default:
                        return true;
                    }
                  }).toList();
                }

                // Sort: newest first
                bookings.sort((a, b) => b.startDate.compareTo(a.startDate));

                if (bookings.isEmpty) {
                  return _EmptyState(hasDateFilter: selectedDate != null);
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(bookingHistoryProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return _BookingCard(booking: bookings[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load bookings',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(bookingHistoryProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Date Selector ---

class _DateSelector extends StatefulWidget {
  final DateTime selectedMonthYear;
  final DateTime? selectedDate;
  final List<Booking> bookings;
  final Function(DateTime?) onDateSelected;

  const _DateSelector({
    required this.selectedMonthYear,
    required this.selectedDate,
    required this.bookings,
    required this.onDateSelected,
  });

  @override
  State<_DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<_DateSelector> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  @override
  void didUpdateWidget(covariant _DateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonthYear != widget.selectedMonthYear) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  void _scrollToToday() {
    final now = DateTime.now();
    if (widget.selectedMonthYear.year == now.year &&
        widget.selectedMonthYear.month == now.month &&
        _scrollController.hasClients) {
      final offset = (now.day - 1) * 58.0; // item width + margin
      _scrollController.animateTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _hasBookingOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return widget.bookings.any((b) {
      final start =
          DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
      final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
      return !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(
      widget.selectedMonthYear.year,
      widget.selectedMonthYear.month + 1,
      0,
    ).day;
    final now = DateTime.now();

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final date = DateTime(
          widget.selectedMonthYear.year,
          widget.selectedMonthYear.month,
          day,
        );
        final isSelected = widget.selectedDate?.day == day &&
            widget.selectedDate?.month == widget.selectedMonthYear.month &&
            widget.selectedDate?.year == widget.selectedMonthYear.year;
        final isToday = now.day == day &&
            now.month == widget.selectedMonthYear.month &&
            now.year == widget.selectedMonthYear.year;
        final hasBooking = _hasBookingOnDate(date);

        return GestureDetector(
          onTap: () =>
              widget.onDateSelected(isSelected ? null : date),
          child: Container(
            width: 52,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isToday
                      ? Theme.of(context).primaryColor.withOpacity(0.08)
                      : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isToday && !isSelected
                  ? Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date).substring(0, 2),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white70 : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Booking indicator dot
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasBooking
                        ? (isSelected
                            ? Colors.white
                            : Theme.of(context).primaryColor)
                        : Colors.transparent,
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

// --- Status Filter Bar ---

class _StatusFilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _StatusFilterBar({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('all', 'All'),
      ('active', 'Active'),
      ('completed', 'Completed'),
      ('cancelled', 'Cancelled'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (key, label) = filters[index];
          final isActive = selected == key;
          return GestureDetector(
            onTap: () => onSelected(key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Empty State ---

class _EmptyState extends StatelessWidget {
  final bool hasDateFilter;

  const _EmptyState({required this.hasDateFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            hasDateFilter ? "No bookings on this date" : "No bookings found",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasDateFilter
                ? "Try selecting a different date"
                : "Your bookings will appear here",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// --- Booking Card (original design, bugs fixed) ---

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final car = booking.car;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () => context.push('/booking-details', extra: booking),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: car != null
                        ? Image.network(
                            car.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.directions_car,
                              size: 40,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.directions_car,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Car Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car != null
                              ? '${car.brand} ${car.name}'
                              : 'Unknown Vehicle',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (car != null)
                          Text(
                            '${car.transmission} \u2022 ${car.seats} Seats',
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
              if (booking.pickupTime.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BookingDetailRow(
                    icon: Icons.access_time,
                    label: 'Pickup Time',
                    value: booking.pickupTime,
                  ),
                ),
              if (booking.pickupLocation.isNotEmpty)
                _BookingDetailRow(
                  icon: Icons.location_on,
                  label: 'Pickup Location',
                  value: booking.pickupLocation,
                ),
              const SizedBox(height: 16),
              // Total Price Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Rs ${booking.totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        " ${booking.totalDays} days",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
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
      case 'confirmed':
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
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
