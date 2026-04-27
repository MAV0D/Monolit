import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
part 'location_provider.g.dart';

Future<bool> _getPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  return true;
}

@riverpod
Stream<Position> userLocation(Ref ref) async* {
  // 1. Wait for permission
  final permission = await _getPermission();
  // 2. If granted, yield* the geolocator stream
  if (permission) {
    yield* Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    );
  }
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
  } catch (e) {
    print("Sensor permission error: $e");
  }
}
