import 'package:ceygo_app/core/widgets/custom_app_bar.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/providers/auth_provider.dart';
import 'package:ceygo_app/core/network/services/user_service.dart';
import 'package:ceygo_app/core/widgets/error_dialog.dart';

class ProfileContent extends ConsumerStatefulWidget {
  const ProfileContent({super.key});

  @override
  ConsumerState<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<ProfileContent> {
  final UserService _userService = UserService();
  bool _isLoadingWallet = false;
  double? _walletBalance;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      setState(() {
        _isLoadingWallet = true;
      });
      final response = await _userService.getWallet();
      final wallet = response.data as Map<String, dynamic>;
      setState(() {
        _walletBalance = (wallet['balance'] as num).toDouble();
        _isLoadingWallet = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWallet = false;
      });
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   title: const Text("Profile"),
        //   automaticallyImplyLeading: false,
        appBar: const CustomAppBar(title: "Profile"),

        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              // Padding(
              //   padding: const EdgeInsets.all(16),
              //   child: Row(
              //     children: [
              //       // GestureDetector(
              //       //   onTap: () => context.pop(),
              //       //   child: Container(
              //       //     padding: const EdgeInsets.all(12),
              //       //     decoration: BoxDecoration(
              //       //       color: Colors.white,
              //       //       borderRadius: BorderRadius.circular(12),
              //       //     ),
              //       //     child: const Icon(Icons.arrow_back_ios_new, size: 20),
              //       //   ),
              //       // ),
              //       const Expanded(
              //         child: Text(
              //           'Profile',
              //           textAlign: TextAlign.center,
              //           style: TextStyle(
              //             fontSize: 20,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ),
              //       // const SizedBox(width: 44), // Balance the back button
              //     ],
              //   ),
              // ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 24,
                        ),
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
                            // Profile Picture
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.shade50,
                                border: Border.all(
                                  color: Colors.blue.shade100,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/user.png',
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.blue.shade300,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Name
                            Text(
                              user?.fullName ?? 'User',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Email/Phone
                            Text(
                              user?.email ?? user?.phone ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Menu Items Card
                      Container(
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
                            _ProfileMenuItem(
                              icon: Icons.person_outline,
                              title: 'Edit Profile',
                              onTap: () {},
                            ),
                            _Divider(),
                            _ProfileMenuItem(
                              icon: Icons.account_balance_wallet,
                              title: 'Wallet',
                              subtitle: _isLoadingWallet
                                  ? 'Loading...'
                                  : _walletBalance != null
                                      ? 'Rs. ${_walletBalance!.toStringAsFixed(2)}'
                                      : null,
                              onTap: () {
                                // Navigate to wallet screen if needed
                              },
                            ),
                            _Divider(),
                            _ProfileMenuItem(
                              icon: Icons.payment_outlined,
                              title: 'Payment Methods',
                              onTap: () {},
                            ),
                            _Divider(),
                            _ProfileMenuItem(
                              icon: Icons.calendar_today_outlined,
                              title: 'My Booking',
                              onTap: () {
                                context.go('/history');
                              },
                            ),
                            _Divider(),
                            _ProfileMenuItem(
                              icon: Icons.favorite_outline,
                              title: 'Saved',
                              onTap: () {},
                            ),
                            _Divider(),
                            _ProfileMenuItem(
                              icon: Icons.notifications_outlined,
                              title: 'Notification',
                              onTap: () {},
                            ),
                            _Divider(),
                            _ProfileMenuItem(
                              icon: Icons.logout,
                              title: 'Logout',
                              onTap: _logout,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Divider Widget
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
    );
  }
}

// Profile Menu Item Widget
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    217,
                    239,
                    255,
                    // ignore: deprecated_member_use
                  ).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Icon(icon, size: 22, color: Colors.black),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
