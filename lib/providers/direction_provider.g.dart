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

String _$relativeHeadingHash() => r'1dc0ef06285e03ecd24d2bb5a9454b03b698ba64';

@ProviderFor(Destination)
final destinationProvider = DestinationProvider._();

final class DestinationProvider extends $NotifierProvider<Destination, LatLon> {
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
  Override overrideWithValue(LatLon value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LatLon>(value),
    );
  }
}

String _$destinationHash() => r'9b052785e3516b03e08c9dd07f716ca71bd3418b';

abstract class _$Destination extends $Notifier<LatLon> {
  LatLon build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LatLon, LatLon>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LatLon, LatLon>,
              LatLon,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
