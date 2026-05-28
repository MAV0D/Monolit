import '../../providers/direction_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/web_compass_provider.dart';
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
    final distance = ref.watch(distanceToDestinationProvider);

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

    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: RepaintBoundary(
              child: RotationTransition(
                turns: _controller,
                child: Image.asset(
                  "assets/monolit.png",
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${distance!.toStringAsFixed(0)} m",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
