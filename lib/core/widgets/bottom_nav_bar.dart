import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavBarItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            isSelected: currentIndex == 0,
            primaryColor: theme.primaryColor,
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            isSelected: currentIndex == 1,
            primaryColor: theme.primaryColor,
            onTap: () => onTap(1),
          ),
          _NavBarItem(
            icon: Icons.favorite_outline,
            selectedIcon: Icons.favorite,
            isSelected: currentIndex == 2,
            primaryColor: theme.primaryColor,
            onTap: () => onTap(2),
          ),
          _NavBarItem(
            icon: Icons.chat_bubble_outline,
            selectedIcon: Icons.chat_bubble,
            isSelected: currentIndex == 3,
            primaryColor: theme.primaryColor,
            onTap: () => onTap(3),
          ),
          _NavBarItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            isSelected: currentIndex == 4,
            primaryColor: theme.primaryColor,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor : const Color.fromARGB(159, 81, 81, 81),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }
}
