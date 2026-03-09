import 'package:flutter/material.dart';

class OwnerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const OwnerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = [
      _NavItem(Icons.dashboard_outlined, Icons.dashboard),
      _NavItem(Icons.directions_car_outlined, Icons.directions_car),
      _NavItem(Icons.calendar_today_outlined, Icons.calendar_today),
      _NavItem(Icons.chat_bubble_outline, Icons.chat_bubble),
      _NavItem(Icons.person_outline, Icons.person),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? items[index].activeIcon : items[index].icon,
                color: Colors.white,
                size: 25,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  const _NavItem(this.icon, this.activeIcon);
}
