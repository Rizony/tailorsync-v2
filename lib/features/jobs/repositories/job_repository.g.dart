// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jobRepositoryHash() => r'd51732ebd2f2d8b1e9d2ae4488ba478995f2b986';

/// See also [jobRepository].
@ProviderFor(jobRepository)
final jobRepositoryProvider = AutoDisposeProvider<JobRepository>.internal(
  jobRepository,
  name: r'jobRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jobRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JobRepositoryRef = AutoDisposeProviderRef<JobRepository>;
String _$recentJobsHash() => r'c6463842d8bd895f90edb977c4360a9cf026f57c';

/// See also [recentJobs].
@ProviderFor(recentJobs)
final recentJobsProvider = AutoDisposeFutureProvider<List<JobModel>>.internal(
  recentJobs,
  name: r'recentJobsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$recentJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentJobsRef = AutoDisposeFutureProviderRef<List<JobModel>>;
String _$jobsByStatusesHash() => r'62dfb52f0441e470d226ebf62f7b94f6fb3f0840';

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

/// See also [jobsByStatuses].
@ProviderFor(jobsByStatuses)
const jobsByStatusesProvider = JobsByStatusesFamily();

/// See also [jobsByStatuses].
class JobsByStatusesFamily extends Family<AsyncValue<List<JobModel>>> {
  /// See also [jobsByStatuses].
  const JobsByStatusesFamily();

  /// See also [jobsByStatuses].
  JobsByStatusesProvider call(
    List<String> statuses,
  ) {
    return JobsByStatusesProvider(
      statuses,
    );
  }

  @override
  JobsByStatusesProvider getProviderOverride(
    covariant JobsByStatusesProvider provider,
  ) {
    return call(
      provider.statuses,
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
  String? get name => r'jobsByStatusesProvider';
}

/// See also [jobsByStatuses].
class JobsByStatusesProvider extends AutoDisposeFutureProvider<List<JobModel>> {
  /// See also [jobsByStatuses].
  JobsByStatusesProvider(
    List<String> statuses,
  ) : this._internal(
          (ref) => jobsByStatuses(
            ref as JobsByStatusesRef,
            statuses,
          ),
          from: jobsByStatusesProvider,
          name: r'jobsByStatusesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$jobsByStatusesHash,
          dependencies: JobsByStatusesFamily._dependencies,
          allTransitiveDependencies:
              JobsByStatusesFamily._allTransitiveDependencies,
          statuses: statuses,
        );

  JobsByStatusesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.statuses,
  }) : super.internal();

  final List<String> statuses;

  @override
  Override overrideWith(
    FutureOr<List<JobModel>> Function(JobsByStatusesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JobsByStatusesProvider._internal(
        (ref) => create(ref as JobsByStatusesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        statuses: statuses,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<JobModel>> createElement() {
    return _JobsByStatusesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JobsByStatusesProvider && other.statuses == statuses;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, statuses.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JobsByStatusesRef on AutoDisposeFutureProviderRef<List<JobModel>> {
  /// The parameter `statuses` of this provider.
  List<String> get statuses;
}

class _JobsByStatusesProviderElement
    extends AutoDisposeFutureProviderElement<List<JobModel>>
    with JobsByStatusesRef {
  _JobsByStatusesProviderElement(super.provider);

  @override
  List<String> get statuses => (origin as JobsByStatusesProvider).statuses;
}

String _$jobsByCustomerHash() => r'74327edf19f6e2ae3abc4b7156a669800f694a02';

/// See also [jobsByCustomer].
@ProviderFor(jobsByCustomer)
const jobsByCustomerProvider = JobsByCustomerFamily();

/// See also [jobsByCustomer].
class JobsByCustomerFamily extends Family<AsyncValue<List<JobModel>>> {
  /// See also [jobsByCustomer].
  const JobsByCustomerFamily();

  /// See also [jobsByCustomer].
  JobsByCustomerProvider call(
    String customerId,
  ) {
    return JobsByCustomerProvider(
      customerId,
    );
  }

  @override
  JobsByCustomerProvider getProviderOverride(
    covariant JobsByCustomerProvider provider,
  ) {
    return call(
      provider.customerId,
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
  String? get name => r'jobsByCustomerProvider';
}

/// See also [jobsByCustomer].
class JobsByCustomerProvider extends AutoDisposeFutureProvider<List<JobModel>> {
  /// See also [jobsByCustomer].
  JobsByCustomerProvider(
    String customerId,
  ) : this._internal(
          (ref) => jobsByCustomer(
            ref as JobsByCustomerRef,
            customerId,
          ),
          from: jobsByCustomerProvider,
          name: r'jobsByCustomerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$jobsByCustomerHash,
          dependencies: JobsByCustomerFamily._dependencies,
          allTransitiveDependencies:
              JobsByCustomerFamily._allTransitiveDependencies,
          customerId: customerId,
        );

  JobsByCustomerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customerId,
  }) : super.internal();

  final String customerId;

  @override
  Override overrideWith(
    FutureOr<List<JobModel>> Function(JobsByCustomerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JobsByCustomerProvider._internal(
        (ref) => create(ref as JobsByCustomerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customerId: customerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<JobModel>> createElement() {
    return _JobsByCustomerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JobsByCustomerProvider && other.customerId == customerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JobsByCustomerRef on AutoDisposeFutureProviderRef<List<JobModel>> {
  /// The parameter `customerId` of this provider.
  String get customerId;
}

class _JobsByCustomerProviderElement
    extends AutoDisposeFutureProviderElement<List<JobModel>>
    with JobsByCustomerRef {
  _JobsByCustomerProviderElement(super.provider);

  @override
  String get customerId => (origin as JobsByCustomerProvider).customerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
