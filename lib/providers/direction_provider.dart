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
    // 1. Zaregistrujeme posluchače na provider vzdálenosti.
    // Tento posluchač se spustí POKAŽDÉ, když se vzdálenost změní,
    // ale spustí se až PO TOM, co se dokončí buildování okolních elementů.
    ref.listen<double?>(distanceToDestinationProvider, (previous, next) {
      if (next == null) return;

      // Pokud jsme doteď byli VENKU (false) a přiblížili jsme se pod 15m -> jsme UVNITŘ
      if (!state && next <= 15.0) {
        state = true;
      }
      // Pokud jsme doteď byli UVNITŘ (true) a vzdálili jsme se nad 25m -> jsme VENKU
      else if (state && next > 25.0) {
        state = false;
      }
    });

    // 2. Výchozí stav při prvním spuštění hry je false (hráč není v cíli)
    return false;
  }

  // Tuto metodu zavoláme v main.dart, když hráč klikne na tlačítko "Zadat další kód"
  void resetZone() {
    state = false;
  }
}

Map<String, LatLon> larpDatabase = {
  "111111111111": LatLon(54.89686701139079, 23.969021499723920),
  "333333333333": LatLon(54.88202643885115, 23.969924360645024),
  "222222222222": LatLon(54.90588721480218, 23.964222218679830),
};
