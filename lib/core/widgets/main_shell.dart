import 'package:flutter/material.dart';
import 'package:ceygo_app/core/widgets/bottom_nav_bar.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/features/home/presentation/screens/home_content.dart';
import 'package:ceygo_app/features/booking/presentation/screens/history_content.dart';
import 'package:ceygo_app/features/home/presentation/screens/favorites_content.dart';
import 'package:ceygo_app/features/booking/presentation/screens/chat_content.dart';
import 'package:ceygo_app/features/profile/presentation/screens/profile_content.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeContent(),
    HistoryContent(),
    FavoritesContent(),
    ChatContent(),
    ProfileContent(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            // Content screens
            IndexedStack(index: _currentIndex, children: _screens),
            // Floating navigation bar
            Positioned(
              left: 0,
              right: 0,
              bottom: -18,
              child: BottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
