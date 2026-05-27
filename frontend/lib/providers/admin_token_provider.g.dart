// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminToken)
final adminTokenProvider = AdminTokenProvider._();

final class AdminTokenProvider extends $NotifierProvider<AdminToken, String?> {
  AdminTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminTokenHash();

  @$internal
  @override
  AdminToken create() => AdminToken();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$adminTokenHash() => r'd3e9760c8a0bf63333ed0cb81c9b5b945e880581';

abstract class _$AdminToken extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
