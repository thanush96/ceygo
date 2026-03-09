import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/features/owner/presentation/widgets/owner_bottom_nav_bar.dart';
import 'package:ceygo_app/features/owner/presentation/screens/owner_dashboard.dart';
import 'package:ceygo_app/features/owner/presentation/screens/my_vehicles_screen.dart';
import 'package:ceygo_app/features/owner/presentation/screens/owner_bookings_screen.dart';
import 'package:ceygo_app/features/booking/presentation/screens/chat_screen.dart';
import 'package:ceygo_app/features/profile/presentation/screens/profile_content.dart';

final ownerTabIndexProvider = StateProvider<int>((ref) => 0);

class OwnerShell extends ConsumerWidget {
  final int initialIndex;

  const OwnerShell({super.key, this.initialIndex = 0});

  static const _screens = [
    OwnerDashboard(),
    MyVehiclesScreen(),
    OwnerBookingsScreen(),
    ChatScreen(),
    ProfileContent(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set initial index on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(ownerTabIndexProvider) != initialIndex &&
          initialIndex != 0) {
        ref.read(ownerTabIndexProvider.notifier).state = initialIndex;
      }
    });

    final currentIndex = ref.watch(ownerTabIndexProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            IndexedStack(index: currentIndex, children: _screens),
            Positioned(
              left: 0,
              right: 0,
              bottom: -18,
              child: OwnerBottomNavBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  ref.read(ownerTabIndexProvider.notifier).state = index;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
