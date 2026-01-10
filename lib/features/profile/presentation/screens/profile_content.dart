import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44), // Balance the back button
                  ],
                ),
              ),

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
                            const Text(
                              'Albert Warren',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Email
                            Text(
                              'albertwarren@example.com',
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
                              icon: Icons.payment_outlined,
                              title: 'Payment Methods',
                              onTap: () {},
                            ),
                            _Divider(),
                            _ProfileMenuItem(
                              icon: Icons.calendar_today_outlined,
                              title: 'My Booking',
                              onTap: () {},
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
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
