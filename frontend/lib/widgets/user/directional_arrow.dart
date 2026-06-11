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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _glowController;

  double? _initialDistance;
  int _lastDurationMs = 2500;

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

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
  }

  void _adjustGlowSpeed(double distance) {
    if (_initialDistance == null || _initialDistance == 0) return;

    double ratio = (distance / _initialDistance!).clamp(0.0, 1.0);

    int maxDuration = 2500;
    int minDuration = 200;

    int newDurationMs = (minDuration + (maxDuration - minDuration) * ratio)
        .toInt();

    if ((newDurationMs - _lastDurationMs).abs() > 20) {
      _lastDurationMs = newDurationMs;
      _glowController.duration = Duration(milliseconds: newDurationMs);

      if (_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(userLocationProvider);
    final compassAsync = ref.watch(webCompassProvider);

    final heading = ref.watch(relativeHeadingProvider);
    final distance = ref.watch(distanceToDestinationProvider);

    if (_initialDistance == null && distance != null) {
      _initialDistance = distance;
    }

    if (distance != null) {
      _adjustGlowSpeed(distance);
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    }

    ref.listen<double?>(relativeHeadingProvider, (previous, next) {
      if (next == null) return;

      double targetTurns = next / 360;
      double currentTurns = _controller.value;
      double delta = (targetTurns - currentTurns) % 1.0;

      if (delta > 0.5) {
        delta -= 1.0;
      } else if (delta < -0.5) {
        delta += 1.0;
      }

      _controller.animateTo(currentTurns + delta, curve: Curves.easeOut);
    });

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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      "assets/monolit.png",
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    FadeTransition(
                      opacity: _glowController,
                      child: Image.asset(
                        "assets/monolit_glow.png",
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
