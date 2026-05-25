import '../providers/direction_provider.dart';
import '../providers/location_provider.dart';
import '../providers/web_compass_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

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

    final heading = ref.watch(relativeHeadingProvider);
    final isInTargetZone = ref.watch(targetZoneStatusProvider);

    ref.listen<double?>(relativeHeadingProvider, (previous, next) {
      if (next == null) return;

      // degrees to num
      double targetTurns = next / 360;
      double currentTurns = _controller.value;

      // distance to new heading
      double delta = (targetTurns - currentTurns) % 1.0;

      // choosing shortest path
      if (delta > 0.5) {
        delta -= 1.0;
      } else if (delta < -0.5) {
        delta += 1.0;
      }

      _controller.animateTo(currentTurns + delta, curve: Curves.easeOut);
    });

    // loading state
    if (heading == null || locationAsync.isLoading || compassAsync.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              heading != null || compassAsync.isLoading
                  ? "Kompas se načítá"
                  : "",
            ),
            const SizedBox(height: 10),
            Text(locationAsync.isLoading ? "GPS se načítá" : ""),
          ],
        ),
      );
    }

    if (isInTargetZone) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                "Puf, jsi na místě.",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Jakmile najdeš fyzicky umístěný monolit zhmotníš se v reálném světe, monolit je označeny XXXYYY.",
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: const Text("Pokračovat")),
            ],
          ),
        ),
      );
    }

    return Center(
      child: RotationTransition(
        turns: _controller,
        child: Image.asset(
          "assets/monolit.png",
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
