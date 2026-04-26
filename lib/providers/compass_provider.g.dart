// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compass_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(compassHeading)
final compassHeadingProvider = CompassHeadingProvider._();

final class CompassHeadingProvider
    extends $FunctionalProvider<AsyncValue<double>, double, Stream<double>>
    with $FutureModifier<double>, $StreamProvider<double> {
  CompassHeadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'compassHeadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$compassHeadingHash();

  @$internal
  @override
  $StreamProviderElement<double> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<double> create(Ref ref) {
    return compassHeading(ref);
  }
}

String _$compassHeadingHash() => r'5fd3147bca73d4144f2903ccea722e5590ea5663';
