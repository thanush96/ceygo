import 'package:ceygo_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/core/widgets/bottom_nav_bar.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/core/providers/navigation_provider.dart';
// import 'package:ceygo_app/features/home/presentation/screens/home_content.dart';
import 'package:ceygo_app/features/booking/presentation/screens/history_content.dart';
import 'package:ceygo_app/features/home/presentation/screens/favorites_content.dart';
import 'package:ceygo_app/features/booking/presentation/screens/chat_content.dart';
import 'package:ceygo_app/features/profile/presentation/screens/profile_content.dart';

class MainShell extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
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
    // Set initial index after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentTabIndexProvider.notifier).setIndex(widget.initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentTabIndexProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            // Content screens
            IndexedStack(index: currentIndex, children: _screens),
            // Floating navigation bar
            Positioned(
              left: 0,
              right: 0,
              bottom: -18,
              child: BottomNavBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  ref.read(currentTabIndexProvider.notifier).setIndex(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
