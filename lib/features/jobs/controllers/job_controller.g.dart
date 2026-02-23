// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jobControllerHash() => r'8f843026a5d0e5f57c9cff9d3aebb2e5ce674d74';

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

abstract class _$JobController
    extends BuildlessAutoDisposeAsyncNotifier<JobModel?> {
  late final String jobId;

  FutureOr<JobModel?> build(
    String jobId,
  );
}

/// See also [JobController].
@ProviderFor(JobController)
const jobControllerProvider = JobControllerFamily();

/// See also [JobController].
class JobControllerFamily extends Family<AsyncValue<JobModel?>> {
  /// See also [JobController].
  const JobControllerFamily();

  /// See also [JobController].
  JobControllerProvider call(
    String jobId,
  ) {
    return JobControllerProvider(
      jobId,
    );
  }

  @override
  JobControllerProvider getProviderOverride(
    covariant JobControllerProvider provider,
  ) {
    return call(
      provider.jobId,
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
  String? get name => r'jobControllerProvider';
}

/// See also [JobController].
class JobControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<JobController, JobModel?> {
  /// See also [JobController].
  JobControllerProvider(
    String jobId,
  ) : this._internal(
          () => JobController()..jobId = jobId,
          from: jobControllerProvider,
          name: r'jobControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$jobControllerHash,
          dependencies: JobControllerFamily._dependencies,
          allTransitiveDependencies:
              JobControllerFamily._allTransitiveDependencies,
          jobId: jobId,
        );

  JobControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jobId,
  }) : super.internal();

  final String jobId;

  @override
  FutureOr<JobModel?> runNotifierBuild(
    covariant JobController notifier,
  ) {
    return notifier.build(
      jobId,
    );
  }

  @override
  Override overrideWith(JobController Function() create) {
    return ProviderOverride(
      origin: this,
      override: JobControllerProvider._internal(
        () => create()..jobId = jobId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jobId: jobId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<JobController, JobModel?>
      createElement() {
    return _JobControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JobControllerProvider && other.jobId == jobId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JobControllerRef on AutoDisposeAsyncNotifierProviderRef<JobModel?> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _JobControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<JobController, JobModel?>
    with JobControllerRef {
  _JobControllerProviderElement(super.provider);

  @override
  String get jobId => (origin as JobControllerProvider).jobId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
