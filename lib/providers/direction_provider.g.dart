// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(relativeHeading)
final relativeHeadingProvider = RelativeHeadingProvider._();

final class RelativeHeadingProvider
    extends $FunctionalProvider<double?, double?, double?>
    with $Provider<double?> {
  RelativeHeadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'relativeHeadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$relativeHeadingHash();

  @$internal
  @override
  $ProviderElement<double?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double? create(Ref ref) {
    return relativeHeading(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }
}

String _$relativeHeadingHash() => r'79da05d82859a5d1e2707166a0db8f827a9da542';

@ProviderFor(distanceToDestination)
final distanceToDestinationProvider = DistanceToDestinationProvider._();

final class DistanceToDestinationProvider
    extends $FunctionalProvider<double?, double?, double?>
    with $Provider<double?> {
  DistanceToDestinationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'distanceToDestinationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$distanceToDestinationHash();

  @$internal
  @override
  $ProviderElement<double?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double? create(Ref ref) {
    return distanceToDestination(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }
}

String _$distanceToDestinationHash() =>
    r'ce130127c3aafc545283a276c3eba4401d652793';

@ProviderFor(Destination)
final destinationProvider = DestinationProvider._();

final class DestinationProvider
    extends $NotifierProvider<Destination, LatLon?> {
  DestinationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'destinationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$destinationHash();

  @$internal
  @override
  Destination create() => Destination();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LatLon? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LatLon?>(value),
    );
  }
}

String _$destinationHash() => r'bb20f1fe37216e25065d1168986385f25d8ff5c8';

abstract class _$Destination extends $Notifier<LatLon?> {
  LatLon? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LatLon?, LatLon?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LatLon?, LatLon?>,
              LatLon?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TargetZoneStatus)
final targetZoneStatusProvider = TargetZoneStatusProvider._();

final class TargetZoneStatusProvider
    extends $NotifierProvider<TargetZoneStatus, bool> {
  TargetZoneStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'targetZoneStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$targetZoneStatusHash();

  @$internal
  @override
  TargetZoneStatus create() => TargetZoneStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$targetZoneStatusHash() => r'999f6268ba9aee702a523128e1cf7fad7625f180';

abstract class _$TargetZoneStatus extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
