import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFdde9f8), // Top half
            Colors.white,      // Bottom half
          ],
          stops: [0.0, 1.0], // You can adjust stops if "half" implies hard line, but usually gradient implies smooth.
          // User said "top half ... bottom half ...", gradient usually means smooth transition.
        ),
      ),
      child: child,
    );
  }
}
