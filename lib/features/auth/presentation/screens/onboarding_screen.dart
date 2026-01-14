import 'package:ceygo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/slide_action.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Placeholder)
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboard.jpg',
              fit: BoxFit.cover,
              errorBuilder:
                  (ctx, _, __) => Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: const Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SafeArea(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Top and Bottom alignment
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20), // Spacing from top
                      Text(
                        l10n.onboardingTitle,
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          fontSize: 52,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.onboardingSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Content
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: SlideAction(
                      text: "Get Started",
                      onSubmit: () {
                        context.push('/login');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
