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
      if (next == null) return; // Do not animate if we don't have a bearing

      double targetTurns = next / 360;
      double currentTurns = _controller.value;

      double fullCircles = (currentTurns).floorToDouble();
      targetTurns += fullCircles;

      if (targetTurns - currentTurns > 0.5) {
        targetTurns -= 1.0;
      } else if (targetTurns - currentTurns < -0.5) {
        targetTurns += 1.0;
      }

      _controller.animateTo(targetTurns, curve: Curves.easeOut);
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
            StreamBuilder<MagnetometerEvent>(
              stream: magnetometerEvents,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    "Raw Mag: x:${snapshot.data!.x.toStringAsFixed(1)} y:${snapshot.data!.y.toStringAsFixed(1)}",
                  );
                }
                return const Text("Magnetometer stream: No Data");
              },
            ),
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
