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

String _$relativeHeadingHash() => r'44e335dfe0387322448c9c34009700f061a72e75';
