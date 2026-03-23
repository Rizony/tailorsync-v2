// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$publicProfileHash() => r'994e913cd455c4652d0740d0673898c66ddaee70';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [publicProfile].
@ProviderFor(publicProfile)
const publicProfileProvider = PublicProfileFamily();

/// See also [publicProfile].
class PublicProfileFamily extends Family<AsyncValue<AppUser?>> {
  /// See also [publicProfile].
  const PublicProfileFamily();

  /// See also [publicProfile].
  PublicProfileProvider call(
    String userId,
  ) {
    return PublicProfileProvider(
      userId,
    );
  }

  @override
  PublicProfileProvider getProviderOverride(
    covariant PublicProfileProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publicProfileProvider';
}

/// See also [publicProfile].
class PublicProfileProvider extends AutoDisposeFutureProvider<AppUser?> {
  /// See also [publicProfile].
  PublicProfileProvider(
    String userId,
  ) : this._internal(
          (ref) => publicProfile(
            ref as PublicProfileRef,
            userId,
          ),
          from: publicProfileProvider,
          name: r'publicProfileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$publicProfileHash,
          dependencies: PublicProfileFamily._dependencies,
          allTransitiveDependencies:
              PublicProfileFamily._allTransitiveDependencies,
          userId: userId,
        );

  PublicProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<AppUser?> Function(PublicProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublicProfileProvider._internal(
        (ref) => create(ref as PublicProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AppUser?> createElement() {
    return _PublicProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicProfileProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublicProfileRef on AutoDisposeFutureProviderRef<AppUser?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _PublicProfileProviderElement
    extends AutoDisposeFutureProviderElement<AppUser?> with PublicProfileRef {
  _PublicProfileProviderElement(super.provider);

  @override
  String get userId => (origin as PublicProfileProvider).userId;
}

String _$profileNotifierHash() => r'95d90f60af34eeb6ecc1ec1ee84a37d7b145ea80';

/// See also [ProfileNotifier].
@ProviderFor(ProfileNotifier)
final profileNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ProfileNotifier, AppUser?>.internal(
  ProfileNotifier.new,
  name: r'profileNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileNotifier = AutoDisposeAsyncNotifier<AppUser?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
