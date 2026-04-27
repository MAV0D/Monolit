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

  if (userLocation == null) return null;

  final targetHeading = Geolocator.bearingBetween(
    userLocation.latitude,
    userLocation.longitude,
    destination.lat,
    destination.lon,
  );

  return targetHeading - userHeading;
}

class LatLon {
  final double lat;
  final double lon;
  LatLon(this.lat, this.lon);
}

@riverpod
class Destination extends _$Destination {
  @override
  LatLon build() {
    return LatLon(49.19479401856215, 16.60859699183198);
  }

  void updateDestination(double lat, double lon) {
    state = LatLon(lat, lon);
  }
}
