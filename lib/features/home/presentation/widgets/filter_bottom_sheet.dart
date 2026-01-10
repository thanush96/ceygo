import 'package:flutter/material.dart';
import 'package:ceygo_app/features/home/data/mock_car_repository.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Selected brand (null means "All")
  String? _selectedBrand;

  // Radius slider value (in km)
  double _radius = 25.0;

  // Price range
  RangeValues _priceRange = const RangeValues(5000, 30000);

  // Price text controllers
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  // Transmission
  String _selectedTransmission = 'All';
  final List<String> _transmissionOptions = ['All', 'Automatic', 'Manual'];

  // Number of seats
  String _selectedSeats = 'All';
  final List<String> _seatsOptions = ['All', '2', '4', '5', '7', '15+'];

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: _priceRange.start.toInt().toString(),
    );
    _maxPriceController = TextEditingController(
      text: _priceRange.end.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _updatePriceRange() {
    final minPrice = double.tryParse(_minPriceController.text) ?? 1000;
    final maxPrice = double.tryParse(_maxPriceController.text) ?? 50000;
    setState(() {
      _priceRange = RangeValues(
        minPrice.clamp(1000, 50000),
        maxPrice.clamp(1000, 50000),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brands = MockCarRepository.getBrands();

    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, color: Colors.black87, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // All Brands Section
                const Text(
                  'Brands',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    // "All" chip
                    _buildBrandChip(
                      name: 'All',
                      logo: null,
                      isSelected: _selectedBrand == null,
                      onTap: () => setState(() => _selectedBrand = null),
                      theme: theme,
                    ),
                    // Brand chips
                    ...brands.map(
                      (brand) => _buildBrandChip(
                        name: brand['name']!,
                        logo: brand['logo'],
                        isSelected: _selectedBrand == brand['name'],
                        onTap:
                            () =>
                                setState(() => _selectedBrand = brand['name']),
                        theme: theme,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Radius Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Radius',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_radius.toInt()} km',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.primaryColor,
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: theme.primaryColor,
                    overlayColor: theme.primaryColor.withOpacity(0.2),
                    trackHeight: 10,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: _radius,
                    min: 5,
                    max: 100,
                    // divisions: 10,
                    onChanged: (value) => setState(() => _radius = value),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '5 km',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '100 km',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Rental / Hire Price Section
                const Text(
                  'Price (Rs.)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Minimum',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _minPriceController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onChanged: (_) => _updatePriceRange(),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          final current =
                                              int.tryParse(
                                                _minPriceController.text,
                                              ) ??
                                              0;
                                          _minPriceController.text =
                                              (current + 100).toString();
                                          _updatePriceRange();
                                        },
                                        child: Icon(
                                          Icons.keyboard_arrow_up,
                                          size: 18,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          final current =
                                              int.tryParse(
                                                _minPriceController.text,
                                              ) ??
                                              0;
                                          if (current >= 100) {
                                            _minPriceController.text =
                                                (current - 100).toString();
                                            _updatePriceRange();
                                          }
                                        },
                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 18,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Maximum',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _maxPriceController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onChanged: (_) => _updatePriceRange(),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          final current =
                                              int.tryParse(
                                                _maxPriceController.text,
                                              ) ??
                                              0;
                                          _maxPriceController.text =
                                              (current + 100).toString();
                                          _updatePriceRange();
                                        },
                                        child: Icon(
                                          Icons.keyboard_arrow_up,
                                          size: 18,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          final current =
                                              int.tryParse(
                                                _maxPriceController.text,
                                              ) ??
                                              0;
                                          if (current >= 100) {
                                            _maxPriceController.text =
                                                (current - 100).toString();
                                            _updatePriceRange();
                                          }
                                        },
                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 18,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Other Preferences Section
                const Text(
                  'Other Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transmission',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedTransmission,
                                  isExpanded: true,
                                  isDense: false,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey[400],
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items:
                                      _transmissionOptions
                                          .map(
                                            (option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (value) => setState(
                                        () => _selectedTransmission = value!,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Number of Seats',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSeats,
                                  isExpanded: true,
                                  isDense: false,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey[400],
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items:
                                      _seatsOptions
                                          .map(
                                            (option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (value) => setState(
                                        () => _selectedSeats = value!,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Apply Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 0,
              top: 10,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filter',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandChip({
    required String name,
    required String? logo,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (logo != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  logo,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (ctx, _, __) => Icon(
                        Icons.directions_car,
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                ),
              ),
              const SizedBox(width: 8),
            ] else ...[
              Icon(
                Icons.apps,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 8),
            ],
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedBrand = null;
      _radius = 25.0;
      _priceRange = const RangeValues(5000, 30000);
      _minPriceController.text = '5000';
      _maxPriceController.text = '30000';
      _selectedTransmission = 'All';
      _selectedSeats = 'All';
    });
  }

  void _applyFilters() {
    // TODO: Pass filter values back to home screen
    Navigator.pop(context, {
      'brand': _selectedBrand,
      'radius': _radius,
      'priceRange': _priceRange,
      'transmission': _selectedTransmission,
      'seats': _selectedSeats,
    });
  }
}

/// Show the filter bottom sheet
Future<Map<String, dynamic>?> showFilterBottomSheet(BuildContext context) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => Container(
          margin: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          child: const FilterBottomSheet(),
        ),
  );
}
