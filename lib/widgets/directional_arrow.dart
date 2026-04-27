import '../providers/direction_provider.dart';
import '../providers/location_provider.dart';
import '../providers/web_compass_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DirectionalArrow extends ConsumerStatefulWidget {
  const DirectionalArrow({super.key});
  @override
  ConsumerState<DirectionalArrow> createState() => _DirectionalArrowState();
}

class _DirectionalArrowState extends ConsumerState<DirectionalArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0.0,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(userLocationProvider);
    final compassAsync = ref.watch(webCompassProvider);

    // Watch the heading to trigger UI changes based on null
    final heading = ref.watch(relativeHeadingProvider);

    // Update listen to expect double? to prevent crashes before GPS lock

    ref.listen<double?>(relativeHeadingProvider, (previous, next) {
      if (next == null) return;

      // 1. Convert degrees to turns (e.g., 90 deg = 0.25 turns)
      double targetTurns = next / 360;
      double currentTurns = _controller.value;

      // 2. Find the shortest path (the delta)
      // This calculates how much we need to move from where we are right now
      double delta = (targetTurns - currentTurns) % 1.0;

      // 3. Adjust the delta so it's always between -0.5 and 0.5
      // This ensures the arrow never spins more than 180 degrees to get to the target
      if (delta > 0.5) {
        delta -= 1.0;
      } else if (delta < -0.5) {
        delta += 1.0;
      }

      // 4. Animate to the new absolute position (current + shortest gap)
      _controller.animateTo(currentTurns + delta, curve: Curves.easeOut);
    });

    // Check heading == null alongside your loading states
    if (heading == null || locationAsync.isLoading || compassAsync.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text("Calibrating Sensors..."),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: const Icon(Icons.navigation, size: 200, color: Colors.red),
          ),
          const SizedBox(height: 20),
          const Text("Point phone towards target"),
        ],
      ),
    );
  }
}
