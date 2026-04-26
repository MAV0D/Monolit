import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'compass_provider.dart';
import 'location_provider.dart';
import 'package:geolocator/geolocator.dart';
part 'direction_provider.g.dart';

double lat = 54.89974982961843;
double lon = 23.96724556922512;

@riverpod
double relativeHeading(Ref ref) {
  final userLocation = ref.watch(userLocationProvider).value;
  final userHeading = ref.watch(compassHeadingProvider).value;

  if (userLocation == null || userHeading == null) return 0.0;

  final targetHeading = Geolocator.bearingBetween(
    userLocation.latitude,
    userLocation.longitude,
    lat,
    lon,
  );

  final relativeHeading = ((targetHeading + 360) - userHeading) % 360;

  return relativeHeading;
}
