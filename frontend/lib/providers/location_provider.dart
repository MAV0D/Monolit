import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
part 'location_provider.g.dart';

@riverpod
class TrackingEnabled extends _$TrackingEnabled {
  @override
  bool build() => false;

  void enable() => state = true;
  void disable() => state = false;
}

@riverpod
Stream<Position> userLocation(Ref ref) {
  // Sledujeme náš nový jistič
  final isTrackingEnabled = ref.watch(trackingEnabledProvider);

  // Pokud sledování není povolené, vrátíme prázdný stream a vůbec nesaháme na Geolocator!
  if (!isTrackingEnabled) {
    return const Stream.empty();
  }

  // Teprve když je povolené, nastartuje se skutečné vyžadování GPS dat:
  return Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    ),
  );
}

Future<void> requestWebSensorPermission() async {
  try {
    final window = web.window;

    // Use js_interop_unsafe to safely look up JS properties
    if (window.has('DeviceOrientationEvent')) {
      final jsClass = window['DeviceOrientationEvent'] as JSObject?;

      // Check if it's an iOS device requiring permission
      if (jsClass != null && jsClass.has('requestPermission')) {
        final promise =
            jsClass.callMethod('requestPermission'.toJS) as JSPromise?;

        if (promise != null) {
          final result = await promise.toDart;
          print("Permission result: $result");
        }
      }
    }
  } catch (e) {}
}
