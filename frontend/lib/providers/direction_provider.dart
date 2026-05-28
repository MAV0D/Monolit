import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'web_compass_provider.dart';
import 'location_provider.dart';
import 'package:geolocator/geolocator.dart';
part 'direction_provider.g.dart';

double lat = 54.89974982961843;
double lon = 23.96724556922512;

@riverpod
double? relativeHeading(Ref ref) {
  final userLocation = ref.watch(userLocationProvider).value;
  final userHeading = ref.watch(webCompassProvider).value ?? 0.0;
  final destination = ref.watch(destinationProvider);

  if (userLocation == null || destination == null) return null;

  final targetHeading = Geolocator.bearingBetween(
    userLocation.latitude,
    userLocation.longitude,
    destination.lat,
    destination.lon,
  );

  return targetHeading - userHeading;
}

@riverpod
double? distanceToDestination(Ref ref) {
  final userLocation = ref.watch(userLocationProvider).value;
  final destination = ref.watch(destinationProvider);

  if (userLocation == null || destination == null) return null;

  return Geolocator.distanceBetween(
    userLocation.latitude,
    userLocation.longitude,
    destination.lat,
    destination.lon,
  );
}

class LatLon {
  final double lat;
  final double lon;
  LatLon(this.lat, this.lon);
}

@riverpod
class Destination extends _$Destination {
  @override
  LatLon? build() {
    return null;
  }

  void updateDestination(double lat, double lon) {
    state = LatLon(lat, lon);
  }

  void clearDestination() {
    state = null;
  }
}

@riverpod
class TargetZoneStatus extends _$TargetZoneStatus {
  @override
  bool build() {
    ref.listen<double?>(distanceToDestinationProvider, (previous, next) {
      if (next == null) return;

      if (!state && next <= 15.0) {
        state = true;
      } else if (state && next > 25.0) {
        state = false;
      }
    });

    return false;
  }

  void resetZone() {
    state = false;
  }
}
