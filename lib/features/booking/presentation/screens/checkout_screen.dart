import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';

class CheckoutScreen extends StatefulWidget {
  final dynamic car;

  const CheckoutScreen({super.key, required this.car});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _pickupOption = 0; // 0 = dealership, 1 = deliver
  int _paymentOption = 0; // 0 = visa
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _pickupTime;

  void _presentDateTimePicker() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _CustomDateTimePicker(
            onDateTimeSelected: (startDate, endDate, time) {
              setState(() {
                _startDate = startDate;
                _endDate = endDate;
                _pickupTime = time;
              });
            },
            initialStartDate: _startDate,
            initialEndDate: _endDate,
            initialTime: _pickupTime,
          ),
    );
  }

  String _formatDateTime() {
    if (_startDate == null || _endDate == null) {
      return 'Select Date & Time';
    }
    final start = '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}';
    final end = '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
    final time =
        _pickupTime != null ? ' at ${_pickupTime!.format(context)}' : '';
    return '$start - $end$time';
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Custom App Bar
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.chevron_left, size: 28),
                    ),
                    const Expanded(
                      child: Text(
                        'Checkout',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 28), // Balance the back button
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Car Image
                          Image.asset(
                            widget.car.imageUrl,
                            height: 120,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.directions_car,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                          ),
                          const SizedBox(height: 16),
                          // Car Details Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.car.transmission ?? "Automatic"} • ${widget.car.seats ?? 2} Seats',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.car.brand} ${widget.car.name}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text:
                                          '\$${widget.car.pricePerDay.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: '/day',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pickup & Drop-off Location Section
                    _SectionCard(
                      title: 'Pickup & Drop-off Location',
                      child: Column(
                        children: [
                          _RadioOption(
                            label: 'Pickup from the dealership',
                            selected: _pickupOption == 0,
                            onTap: () => setState(() => _pickupOption = 0),
                          ),
                          const SizedBox(height: 12),
                          _RadioOption(
                            label: 'Deliver to my location',
                            selected: _pickupOption == 1,
                            onTap: () => setState(() => _pickupOption = 1),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date & Time Section
                    _SectionCard(
                      title: 'Date & Time',
                      child: GestureDetector(
                        onTap: _presentDateTimePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDateTime(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color:
                                      _startDate != null
                                          ? Colors.black
                                          : Colors.grey.shade600,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Payment Method Section
                    _SectionCard(
                      title: 'Payment Method',
                      child: _PaymentOption(
                        icon: 'assets/images/visa.png',
                        label: 'Visa ending in 1111',
                        selected: _paymentOption == 0,
                        onTap: () => setState(() => _paymentOption = 0),
                      ),
                    ),

                    const SizedBox(height: 100), // Space for button
                  ],
                ),
              ),
            ),
          ],
        ),

        // Bottom Confirm Button
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.transparent),
          child: SafeArea(
            top: false,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Booking Successful!")),
                );
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Confirm Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Section Card Widget
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// Radio Option Widget
class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              selected
                  ? const Color(0xFF2563EB).withOpacity(0.05)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border:
              selected
                  ? Border.all(color: const Color(0xFF2563EB), width: 1.5)
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                color: selected ? const Color(0xFF2563EB) : Colors.black,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF2563EB) : Colors.transparent,
                border: Border.all(
                  color:
                      selected ? const Color(0xFF2563EB) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child:
                  selected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Payment Option Widget
class _PaymentOption extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Visa Icon Placeholder
            Container(
              width: 50,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F71),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'VISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF2563EB) : Colors.transparent,
                border: Border.all(
                  color:
                      selected ? const Color(0xFF2563EB) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child:
                  selected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Date Time Picker Widget
class _CustomDateTimePicker extends StatefulWidget {
  final Function(DateTime startDate, DateTime endDate, TimeOfDay time)
  onDateTimeSelected;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final TimeOfDay? initialTime;

  const _CustomDateTimePicker({
    required this.onDateTimeSelected,
    this.initialStartDate,
    this.initialEndDate,
    this.initialTime,
  });

  @override
  State<_CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<_CustomDateTimePicker> {
  late int _selectedTab; // 0 = Date, 1 = Time
  late DateTime _currentMonth;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late TimeOfDay? _selectedTime;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  // Cache for days optimization
  final Map<String, List<DateTime>> _daysCache = {};

  @override
  void initState() {
    super.initState();
    _selectedTab = 0;
    _currentMonth = DateTime.now();

    // Set default range: today and tomorrow
    _startDate = widget.initialStartDate ?? DateTime.now();
    _endDate =
        widget.initialEndDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedTime = widget.initialTime ?? TimeOfDay.now();

    // Initialize scroll controllers for time picker with FixedExtentScrollController
    _hourController = FixedExtentScrollController(
      initialItem: _selectedTime!.hour,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedTime!.minute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _daysCache.clear();
    super.dispose();
  }

  List<DateTime> _getDaysInMonth(DateTime date) {
    final cacheKey = '${date.year}-${date.month}';

    // Return cached days if available
    if (_daysCache.containsKey(cacheKey)) {
      return _daysCache[cacheKey]!;
    }

    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    final days = <DateTime>[];

    for (int i = 0; i < firstDay.weekday - 1; i++) {
      days.add(firstDay.subtract(Duration(days: firstDay.weekday - 1 - i)));
    }

    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(date.year, date.month, i));
    }

    // Cache the result
    _daysCache[cacheKey] = days;
    return days;
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    final dateOnly = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
    );
    final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
    return dateOnly.isAfter(start) && dateOnly.isBefore(end);
  }

  bool _isStartDate(DateTime date) {
    if (_startDate == null) return false;
    return date.year == _startDate!.year &&
        date.month == _startDate!.month &&
        date.day == _startDate!.day;
  }

  bool _isEndDate(DateTime date) {
    if (_endDate == null) return false;
    return date.year == _endDate!.year &&
        date.month == _endDate!.month &&
        date.day == _endDate!.day;
  }

  void _selectDate(DateTime date) {
    if (_startDate == null) {
      setState(() {
        _startDate = date;
      });
    } else if (_endDate == null) {
      if (date.isAfter(_startDate!)) {
        setState(() {
          _endDate = date;
        });
      } else {
        setState(() {
          _endDate = _startDate;
          _startDate = date;
        });
      }
    } else {
      setState(() {
        _startDate = date;
        _endDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date & Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade900,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Date',
                    isActive: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabButton(
                    label: 'Time',
                    isActive: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child:
                _selectedTab == 0
                    ? _DatePickerContent(
                      currentMonth: _currentMonth,
                      startDate: _startDate,
                      endDate: _endDate,
                      getDaysInMonth: _getDaysInMonth,
                      isDateInRange: _isDateInRange,
                      isStartDate: _isStartDate,
                      isEndDate: _isEndDate,
                      selectDate: _selectDate,
                      onMonthChanged:
                          (date) => setState(() => _currentMonth = date),
                    )
                    : _TimePickerContent(
                      selectedTime: _selectedTime!,
                      onTimeChanged: (hours, minutes) {
                        setState(() {
                          _selectedTime = TimeOfDay(
                            hour: hours,
                            minute: minutes,
                          );
                        });
                      },
                    ),
          ),
          // Confirm Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_startDate != null &&
                      _endDate != null &&
                      _selectedTime != null) {
                    widget.onDateTimeSelected(
                      _startDate!,
                      _endDate!,
                      _selectedTime!,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tab Button Widget
class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

// Date Picker Content
class _DatePickerContent extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<DateTime> Function(DateTime) getDaysInMonth;
  final bool Function(DateTime) isDateInRange;
  final bool Function(DateTime) isStartDate;
  final bool Function(DateTime) isEndDate;
  final Function(DateTime) selectDate;
  final Function(DateTime) onMonthChanged;

  const _DatePickerContent({
    required this.currentMonth,
    required this.startDate,
    required this.endDate,
    required this.getDaysInMonth,
    required this.isDateInRange,
    required this.isStartDate,
    required this.isEndDate,
    required this.selectDate,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final days = getDaysInMonth(currentMonth);
    const weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_monthName(currentMonth.month)} ${currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _NavButton(
                      icon: Icons.chevron_left,
                      onTap:
                          () => onMonthChanged(
                            DateTime(currentMonth.year, currentMonth.month - 1),
                          ),
                    ),
                    const SizedBox(width: 8),
                    _NavButton(
                      icon: Icons.chevron_right,
                      onTap:
                          () => onMonthChanged(
                            DateTime(currentMonth.year, currentMonth.month + 1),
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Week Days Header
            const _WeekDaysHeader(weekDays: weekDays),
            const SizedBox(height: 12),
            // Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isCurrentMonth = day.month == currentMonth.month;
                final isStart = isStartDate(day);
                final isEnd = isEndDate(day);
                final isInRange = isDateInRange(day);

                return RepaintBoundary(
                  child: _DateTile(
                    day: day,
                    isCurrentMonth: isCurrentMonth,
                    isStart: isStart,
                    isEnd: isEnd,
                    isInRange: isInRange,
                    onTap: isCurrentMonth ? () => selectDate(day) : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

// Navigation Button Widget - Const for better optimization
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

// Week Days Header - Const widget
class _WeekDaysHeader extends StatelessWidget {
  final List<String> weekDays;

  const _WeekDaysHeader({required this.weekDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          weekDays
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

// Date Tile Widget - Optimized with const where possible
class _DateTile extends StatelessWidget {
  final DateTime day;
  final bool isCurrentMonth;
  final bool isStart;
  final bool isEnd;
  final bool isInRange;
  final VoidCallback? onTap;

  const _DateTile({
    required this.day,
    required this.isCurrentMonth,
    required this.isStart,
    required this.isEnd,
    required this.isInRange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background for range dates
          if (isInRange && !isStart && !isEnd)
            Container(
              width: double.infinity,
              height: 40,
              color: const Color(0xFF2563EB).withOpacity(0.15),
            ),
          // Right half background for start date
          if (isStart)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: double.infinity,
                height: 40,
                margin: const EdgeInsets.only(left: 20),
                color: const Color(0xFF2563EB).withOpacity(0.15),
              ),
            ),
          // Left half background for end date
          if (isEnd)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: double.infinity,
                height: 40,
                margin: const EdgeInsets.only(right: 20),
                color: const Color(0xFF2563EB).withOpacity(0.15),
              ),
            ),
          // Circular background for start and end dates
          if (isStart || isEnd)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          // Date text
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color:
                  isCurrentMonth
                      ? (isStart || isEnd ? Colors.white : Colors.black)
                      : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// Time Picker Content
class _TimePickerContent extends StatefulWidget {
  final TimeOfDay selectedTime;
  final Function(int hours, int minutes) onTimeChanged;

  const _TimePickerContent({
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  State<_TimePickerContent> createState() => _TimePickerContentState();
}

class _TimePickerContentState extends State<_TimePickerContent> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(
      initialItem: widget.selectedTime.hour,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: widget.selectedTime.minute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hours Picker
          RepaintBoundary(
            child: SizedBox(
              width: 100,
              height: 200,
              child: ListWheelScrollView.useDelegate(
                controller: _hourController,
                itemExtent: 50,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  widget.onTimeChanged(index, _minuteController.selectedItem);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 24,
                  builder:
                      (context, index) => _TimePickerItem(
                        value: index.toString().padLeft(2, '0'),
                        isSelected: index == _hourController.selectedItem,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Colon Separator
          const Text(
            ':',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          // Minutes Picker
          RepaintBoundary(
            child: SizedBox(
              width: 100,
              height: 200,
              child: ListWheelScrollView.useDelegate(
                controller: _minuteController,
                itemExtent: 50,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  widget.onTimeChanged(_hourController.selectedItem, index);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 60,
                  builder:
                      (context, index) => _TimePickerItem(
                        value: index.toString().padLeft(2, '0'),
                        isSelected: index == _minuteController.selectedItem,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Time Picker Item Widget - Optimized
class _TimePickerItem extends StatelessWidget {
  final String value;
  final bool isSelected;

  const _TimePickerItem({required this.value, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color:
            isSelected
                ? const Color(0xFF2563EB).withOpacity(0.1)
                : Colors.transparent,
        border:
            isSelected
                ? Border(
                  bottom: BorderSide(color: const Color(0xFF2563EB), width: 2),
                )
                : null,
      ),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
