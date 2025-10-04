import 'package:flutter/material.dart';

// This is the exact same reusable GradientBackground widget from your practice app.
// It gives a consistent style to all our screens.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 28, 27, 41), // A cool dark blue
            Color.fromARGB(255, 41, 2, 52), // A deep purple
          ],
        ),
      ),
      child: child,
    );
  }
}
