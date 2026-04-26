import '../providers/direction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
  Widget build(BuildContext context) {
    ref.listen<double>(relativeHeadingProvider, (previous, next) {
      double newTurns = next / 360;

      double currentTurns = _controller.value;

      double fullCircles = (currentTurns).floorToDouble();
      newTurns += fullCircles;
      if (newTurns - currentTurns > 0.5) {
        newTurns -= 1.0;
      } else if (newTurns - currentTurns < -0.5) {
        newTurns += 1.0;
      }

      _controller.animateTo(newTurns, curve: Curves.easeOut);
    });

    return Center(
      child: RotationTransition(
        turns: _controller, // The controller now 'drives' the icon
        child: const Icon(Icons.navigation, size: 200, color: Colors.red),
      ),
    );
  }
}
