// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityFeedHash() => r'a3b330d19d6d502dc240d74d317a972f8264e996';

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

abstract class _$CommunityFeed
    extends BuildlessAutoDisposeAsyncNotifier<List<CommunityPost>> {
  late final String filterType;

  FutureOr<List<CommunityPost>> build(
    String filterType,
  );
}

/// See also [CommunityFeed].
@ProviderFor(CommunityFeed)
const communityFeedProvider = CommunityFeedFamily();

/// See also [CommunityFeed].
class CommunityFeedFamily extends Family<AsyncValue<List<CommunityPost>>> {
  /// See also [CommunityFeed].
  const CommunityFeedFamily();

  /// See also [CommunityFeed].
  CommunityFeedProvider call(
    String filterType,
  ) {
    return CommunityFeedProvider(
      filterType,
    );
  }

  @override
  CommunityFeedProvider getProviderOverride(
    covariant CommunityFeedProvider provider,
  ) {
    return call(
      provider.filterType,
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
  String? get name => r'communityFeedProvider';
}

/// See also [CommunityFeed].
class CommunityFeedProvider extends AutoDisposeAsyncNotifierProviderImpl<
    CommunityFeed, List<CommunityPost>> {
  /// See also [CommunityFeed].
  CommunityFeedProvider(
    String filterType,
  ) : this._internal(
          () => CommunityFeed()..filterType = filterType,
          from: communityFeedProvider,
          name: r'communityFeedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$communityFeedHash,
          dependencies: CommunityFeedFamily._dependencies,
          allTransitiveDependencies:
              CommunityFeedFamily._allTransitiveDependencies,
          filterType: filterType,
        );

  CommunityFeedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filterType,
  }) : super.internal();

  final String filterType;

  @override
  FutureOr<List<CommunityPost>> runNotifierBuild(
    covariant CommunityFeed notifier,
  ) {
    return notifier.build(
      filterType,
    );
  }

  @override
  Override overrideWith(CommunityFeed Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommunityFeedProvider._internal(
        () => create()..filterType = filterType,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filterType: filterType,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CommunityFeed, List<CommunityPost>>
      createElement() {
    return _CommunityFeedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityFeedProvider && other.filterType == filterType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filterType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityFeedRef
    on AutoDisposeAsyncNotifierProviderRef<List<CommunityPost>> {
  /// The parameter `filterType` of this provider.
  String get filterType;
}

class _CommunityFeedProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CommunityFeed,
        List<CommunityPost>> with CommunityFeedRef {
  _CommunityFeedProviderElement(super.provider);

  @override
  String get filterType => (origin as CommunityFeedProvider).filterType;
}

String _$postCommentsHash() => r'74aa00e287dc6580d31075a2d6b9c69a2d2f8d5b';

abstract class _$PostComments
    extends BuildlessAutoDisposeAsyncNotifier<List<CommunityComment>> {
  late final String postId;

  FutureOr<List<CommunityComment>> build(
    String postId,
  );
}

/// See also [PostComments].
@ProviderFor(PostComments)
const postCommentsProvider = PostCommentsFamily();

/// See also [PostComments].
class PostCommentsFamily extends Family<AsyncValue<List<CommunityComment>>> {
  /// See also [PostComments].
  const PostCommentsFamily();

  /// See also [PostComments].
  PostCommentsProvider call(
    String postId,
  ) {
    return PostCommentsProvider(
      postId,
    );
  }

  @override
  PostCommentsProvider getProviderOverride(
    covariant PostCommentsProvider provider,
  ) {
    return call(
      provider.postId,
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
  String? get name => r'postCommentsProvider';
}

/// See also [PostComments].
class PostCommentsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PostComments, List<CommunityComment>> {
  /// See also [PostComments].
  PostCommentsProvider(
    String postId,
  ) : this._internal(
          () => PostComments()..postId = postId,
          from: postCommentsProvider,
          name: r'postCommentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$postCommentsHash,
          dependencies: PostCommentsFamily._dependencies,
          allTransitiveDependencies:
              PostCommentsFamily._allTransitiveDependencies,
          postId: postId,
        );

  PostCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  FutureOr<List<CommunityComment>> runNotifierBuild(
    covariant PostComments notifier,
  ) {
    return notifier.build(
      postId,
    );
  }

  @override
  Override overrideWith(PostComments Function() create) {
    return ProviderOverride(
      origin: this,
      override: PostCommentsProvider._internal(
        () => create()..postId = postId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PostComments, List<CommunityComment>>
      createElement() {
    return _PostCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCommentsProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostCommentsRef
    on AutoDisposeAsyncNotifierProviderRef<List<CommunityComment>> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _PostCommentsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PostComments,
        List<CommunityComment>> with PostCommentsRef {
  _PostCommentsProviderElement(super.provider);

  @override
  String get postId => (origin as PostCommentsProvider).postId;
}

String _$postApplicationsHash() => r'f237fef1329ff7810232e91bbaf07eb0ea22454a';

abstract class _$PostApplications
    extends BuildlessAutoDisposeAsyncNotifier<List<CommunityApplication>> {
  late final String postId;

  FutureOr<List<CommunityApplication>> build(
    String postId,
  );
}

/// See also [PostApplications].
@ProviderFor(PostApplications)
const postApplicationsProvider = PostApplicationsFamily();

/// See also [PostApplications].
class PostApplicationsFamily
    extends Family<AsyncValue<List<CommunityApplication>>> {
  /// See also [PostApplications].
  const PostApplicationsFamily();

  /// See also [PostApplications].
  PostApplicationsProvider call(
    String postId,
  ) {
    return PostApplicationsProvider(
      postId,
    );
  }

  @override
  PostApplicationsProvider getProviderOverride(
    covariant PostApplicationsProvider provider,
  ) {
    return call(
      provider.postId,
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
  String? get name => r'postApplicationsProvider';
}

/// See also [PostApplications].
class PostApplicationsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PostApplications, List<CommunityApplication>> {
  /// See also [PostApplications].
  PostApplicationsProvider(
    String postId,
  ) : this._internal(
          () => PostApplications()..postId = postId,
          from: postApplicationsProvider,
          name: r'postApplicationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$postApplicationsHash,
          dependencies: PostApplicationsFamily._dependencies,
          allTransitiveDependencies:
              PostApplicationsFamily._allTransitiveDependencies,
          postId: postId,
        );

  PostApplicationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  FutureOr<List<CommunityApplication>> runNotifierBuild(
    covariant PostApplications notifier,
  ) {
    return notifier.build(
      postId,
    );
  }

  @override
  Override overrideWith(PostApplications Function() create) {
    return ProviderOverride(
      origin: this,
      override: PostApplicationsProvider._internal(
        () => create()..postId = postId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PostApplications,
      List<CommunityApplication>> createElement() {
    return _PostApplicationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostApplicationsProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostApplicationsRef
    on AutoDisposeAsyncNotifierProviderRef<List<CommunityApplication>> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _PostApplicationsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PostApplications,
        List<CommunityApplication>> with PostApplicationsRef {
  _PostApplicationsProviderElement(super.provider);

  @override
  String get postId => (origin as PostApplicationsProvider).postId;
}

String _$userRatingsHash() => r'b784649316fd3ef1b9e8fff88f29fbaec44d2dff';

abstract class _$UserRatings
    extends BuildlessAutoDisposeAsyncNotifier<List<CommunityRating>> {
  late final String userId;

  FutureOr<List<CommunityRating>> build(
    String userId,
  );
}

/// See also [UserRatings].
@ProviderFor(UserRatings)
const userRatingsProvider = UserRatingsFamily();

/// See also [UserRatings].
class UserRatingsFamily extends Family<AsyncValue<List<CommunityRating>>> {
  /// See also [UserRatings].
  const UserRatingsFamily();

  /// See also [UserRatings].
  UserRatingsProvider call(
    String userId,
  ) {
    return UserRatingsProvider(
      userId,
    );
  }

  @override
  UserRatingsProvider getProviderOverride(
    covariant UserRatingsProvider provider,
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
  String? get name => r'userRatingsProvider';
}

/// See also [UserRatings].
class UserRatingsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    UserRatings, List<CommunityRating>> {
  /// See also [UserRatings].
  UserRatingsProvider(
    String userId,
  ) : this._internal(
          () => UserRatings()..userId = userId,
          from: userRatingsProvider,
          name: r'userRatingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userRatingsHash,
          dependencies: UserRatingsFamily._dependencies,
          allTransitiveDependencies:
              UserRatingsFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserRatingsProvider._internal(
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
  FutureOr<List<CommunityRating>> runNotifierBuild(
    covariant UserRatings notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(UserRatings Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserRatingsProvider._internal(
        () => create()..userId = userId,
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
  AutoDisposeAsyncNotifierProviderElement<UserRatings, List<CommunityRating>>
      createElement() {
    return _UserRatingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserRatingsProvider && other.userId == userId;
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
mixin UserRatingsRef
    on AutoDisposeAsyncNotifierProviderRef<List<CommunityRating>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserRatingsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<UserRatings,
        List<CommunityRating>> with UserRatingsRef {
  _UserRatingsProviderElement(super.provider);

  @override
  String get userId => (origin as UserRatingsProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
