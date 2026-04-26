import 'dart:math';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sensors_plus/sensors_plus.dart';
part 'compass_provider.g.dart';

@riverpod
Stream<double> compassHeading(Ref ref) {
  return magnetometerEvents.map((event) {
    return ((atan2(event.y, event.x) * 180 / pi));
  });
}

  // [MagnetometerEvent (x: -23.6, y: 6.2, z: -34.9)]