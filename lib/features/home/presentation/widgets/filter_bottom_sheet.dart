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

  // Transmission
  String _selectedTransmission = 'All';
  final List<String> _transmissionOptions = ['All', 'Automatic', 'Manual'];

  // Number of seats
  String _selectedSeats = 'All';
  final List<String> _seatsOptions = ['All', '2', '4', '5', '7', '15+'];

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
              const Text(
                'Filters',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.primaryColor,
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: theme.primaryColor,
                    overlayColor: theme.primaryColor.withOpacity(0.2),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: _radius,
                    min: 5,
                    max: 100,
                    divisions: 19,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rental Price (per day)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Rs. ${_priceRange.start.toInt()} - ${_priceRange.end.toInt()}',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.primaryColor,
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: theme.primaryColor,
                    overlayColor: theme.primaryColor.withOpacity(0.2),
                    trackHeight: 6,
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: RangeSlider(
                    values: _priceRange,
                    min: 1000,
                    max: 50000,
                    divisions: 49,
                    onChanged: (values) => setState(() => _priceRange = values),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. 1,000',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      'Rs. 50,000',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Other Options Section
                const Text(
                  'Other Options',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                // Transmission Dropdown
                _buildDropdown(
                  label: 'Transmission',
                  value: _selectedTransmission,
                  options: _transmissionOptions,
                  onChanged:
                      (value) => setState(() => _selectedTransmission = value!),
                  theme: theme,
                ),

                const SizedBox(height: 16),

                // Number of Seats Dropdown
                _buildDropdown(
                  label: 'Number of Seats',
                  value: _selectedSeats,
                  options: _seatsOptions,
                  onChanged: (value) => setState(() => _selectedSeats = value!),
                  theme: theme,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Apply Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                  'Apply Filters',
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            label == 'Transmission'
                ? Icons.settings_outlined
                : Icons.event_seat_outlined,
            color: Colors.grey[600],
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    isDense: true,
                    icon: const SizedBox.shrink(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    items:
                        options
                            .map(
                              (option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedBrand = null;
      _radius = 25.0;
      _priceRange = const RangeValues(5000, 30000);
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
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const FilterBottomSheet(),
        ),
  );
}
