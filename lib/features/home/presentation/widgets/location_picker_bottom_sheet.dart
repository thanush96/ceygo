import 'package:flutter/material.dart';

class LocationPickerBottomSheet extends StatelessWidget {
  final String currentLocation;
  final Function(String) onLocationSelected;

  const LocationPickerBottomSheet({
    super.key,
    required this.currentLocation,
    required this.onLocationSelected,
  });

  static const List<Map<String, String>> _locations = [
    {'name': 'Colombo', 'country': 'Sri Lanka'},
    {'name': 'Kandy', 'country': 'Sri Lanka'},
    {'name': 'Galle', 'country': 'Sri Lanka'},
    {'name': 'Jaffna', 'country': 'Sri Lanka'},
    {'name': 'Negombo', 'country': 'Sri Lanka'},
    {'name': 'Anuradhapura', 'country': 'Sri Lanka'},
    {'name': 'Trincomalee', 'country': 'Sri Lanka'},
    {'name': 'Batticaloa', 'country': 'Sri Lanka'},
    {'name': 'Matara', 'country': 'Sri Lanka'},
    {'name': 'Kurunegala', 'country': 'Sri Lanka'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75,
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.width * 0.04,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Location',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.shade200),

          // Location List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                final isSelected =
                    currentLocation ==
                    '${location['name']}, ${location['country']}';

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      onLocationSelected(
                        '${location['name']}, ${location['country']}',
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade400,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location['name']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.black,
                                  ),
                                ),
                                Text(
                                  location['country']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

void showLocationPicker(
  BuildContext context, {
  required String currentLocation,
  required Function(String) onLocationSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder:
        (context) => LocationPickerBottomSheet(
          currentLocation: currentLocation,
          onLocationSelected: onLocationSelected,
        ),
  );
}
