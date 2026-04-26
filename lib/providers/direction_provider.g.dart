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
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
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
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return relativeHeading(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$relativeHeadingHash() => r'fab4523e9413fcf30ecd5bc7f2044d7895cc9f33';
