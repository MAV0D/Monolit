import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe'; // The official library for dynamic JS checks
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;

@JS()
extension type DeviceOrientationEvent(web.Event _) implements web.Event {
  external double? get alpha;
  external double? get webkitCompassHeading;
}

final webCompassProvider = StreamProvider<double>((ref) {
  final controller = StreamController<double>();
  final window = web.window;

  void handleOrientation(web.Event event) {
    final e = event as DeviceOrientationEvent;
    double heading = 0;

    if (e.webkitCompassHeading != null) {
      heading = e.webkitCompassHeading!;
    } else if (e.alpha != null) {
      heading = 360.0 - e.alpha!;
    }
    controller.add(heading);
  }

  final jsHandler = handleOrientation.toJS;

  // Modern, safe dynamic check using js_interop_unsafe
  if (window.has('ondeviceorientationabsolute')) {
    window.addEventListener('deviceorientationabsolute', jsHandler);
  } else {
    window.addEventListener('deviceorientation', jsHandler);
  }

  ref.onDispose(() {
    window.removeEventListener('deviceorientationabsolute', jsHandler);
    window.removeEventListener('deviceorientation', jsHandler);
    controller.close();
  });

  return controller.stream;
});
