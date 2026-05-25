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

  final distance = Geolocator.distanceBetween(
    userLocation.latitude,
    userLocation.longitude,
    destination.lat,
    destination.lon,
  );

  ref.read(targetZoneStatusProvider.notifier).updateStatus(distance);

  return distance;
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
    // Výchozí stav je, že hráč v cíli není
    return false;
  }

  void updateStatus(double distance) {
    // 1. Pokud je hráč venku a přiblíží se pod 15 metrů -> Vstoupil do cíle
    if (!state && distance <= 15.0) {
      state = true;
    }
    // 2. Pokud už je v cíli, ale vzdálí se nad 25 metrů -> Opustil cíl
    else if (state && distance > 25.0) {
      state = false;
    }
  }

  void resetZone() {
    state = false;
  }
}

Map<String, LatLon> larpDatabase = {
  "0123": LatLon(54.89686701139079, 23.969021499723920),
  "4567": LatLon(54.88202643885115, 23.969924360645024),
  "89AB": LatLon(54.90588721480218, 23.964222218679830),
};
