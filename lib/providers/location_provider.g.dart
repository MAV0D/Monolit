// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userLocation)
final userLocationProvider = UserLocationProvider._();

final class UserLocationProvider
    extends
        $FunctionalProvider<AsyncValue<Position>, Position, Stream<Position>>
    with $FutureModifier<Position>, $StreamProvider<Position> {
  UserLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userLocationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userLocationHash();

  @$internal
  @override
  $StreamProviderElement<Position> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Position> create(Ref ref) {
    return userLocation(ref);
  }
}

String _$userLocationHash() => r'dc14d6607253fe829c8b1a86dad8250bff2c8eba';
