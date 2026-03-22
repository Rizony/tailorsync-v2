// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderRepositoryHash() => r'693f7dff83c435cc6d4f21ba9da9bd7d19a32fd8';

/// See also [orderRepository].
@ProviderFor(orderRepository)
final orderRepositoryProvider = AutoDisposeProvider<OrderRepository>.internal(
  orderRepository,
  name: r'orderRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrderRepositoryRef = AutoDisposeProviderRef<OrderRepository>;
String _$recentOrdersHash() => r'9144675e38269f084d16beea2126fa7d0dbc708a';

/// See also [recentOrders].
@ProviderFor(recentOrders)
final recentOrdersProvider =
    AutoDisposeFutureProvider<List<OrderModel>>.internal(
  recentOrders,
  name: r'recentOrdersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$recentOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentOrdersRef = AutoDisposeFutureProviderRef<List<OrderModel>>;
String _$ordersByStatusesHash() => r'b838729b3677e9a2fb6425cdf5243b9c4892edb0';

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

/// See also [ordersByStatuses].
@ProviderFor(ordersByStatuses)
const ordersByStatusesProvider = OrdersByStatusesFamily();

/// See also [ordersByStatuses].
class OrdersByStatusesFamily extends Family<AsyncValue<List<OrderModel>>> {
  /// See also [ordersByStatuses].
  const OrdersByStatusesFamily();

  /// See also [ordersByStatuses].
  OrdersByStatusesProvider call(
    List<String> statuses,
  ) {
    return OrdersByStatusesProvider(
      statuses,
    );
  }

  @override
  OrdersByStatusesProvider getProviderOverride(
    covariant OrdersByStatusesProvider provider,
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
  String? get name => r'ordersByStatusesProvider';
}

/// See also [ordersByStatuses].
class OrdersByStatusesProvider
    extends AutoDisposeFutureProvider<List<OrderModel>> {
  /// See also [ordersByStatuses].
  OrdersByStatusesProvider(
    List<String> statuses,
  ) : this._internal(
          (ref) => ordersByStatuses(
            ref as OrdersByStatusesRef,
            statuses,
          ),
          from: ordersByStatusesProvider,
          name: r'ordersByStatusesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ordersByStatusesHash,
          dependencies: OrdersByStatusesFamily._dependencies,
          allTransitiveDependencies:
              OrdersByStatusesFamily._allTransitiveDependencies,
          statuses: statuses,
        );

  OrdersByStatusesProvider._internal(
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
    FutureOr<List<OrderModel>> Function(OrdersByStatusesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrdersByStatusesProvider._internal(
        (ref) => create(ref as OrdersByStatusesRef),
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
  AutoDisposeFutureProviderElement<List<OrderModel>> createElement() {
    return _OrdersByStatusesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersByStatusesProvider && other.statuses == statuses;
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
mixin OrdersByStatusesRef on AutoDisposeFutureProviderRef<List<OrderModel>> {
  /// The parameter `statuses` of this provider.
  List<String> get statuses;
}

class _OrdersByStatusesProviderElement
    extends AutoDisposeFutureProviderElement<List<OrderModel>>
    with OrdersByStatusesRef {
  _OrdersByStatusesProviderElement(super.provider);

  @override
  List<String> get statuses => (origin as OrdersByStatusesProvider).statuses;
}

String _$ordersByCustomerHash() => r'877dc109b859fe89aa8e27c822aed3ef53cf39e0';

/// See also [ordersByCustomer].
@ProviderFor(ordersByCustomer)
const ordersByCustomerProvider = OrdersByCustomerFamily();

/// See also [ordersByCustomer].
class OrdersByCustomerFamily extends Family<AsyncValue<List<OrderModel>>> {
  /// See also [ordersByCustomer].
  const OrdersByCustomerFamily();

  /// See also [ordersByCustomer].
  OrdersByCustomerProvider call(
    String customerId,
  ) {
    return OrdersByCustomerProvider(
      customerId,
    );
  }

  @override
  OrdersByCustomerProvider getProviderOverride(
    covariant OrdersByCustomerProvider provider,
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
  String? get name => r'ordersByCustomerProvider';
}

/// See also [ordersByCustomer].
class OrdersByCustomerProvider
    extends AutoDisposeFutureProvider<List<OrderModel>> {
  /// See also [ordersByCustomer].
  OrdersByCustomerProvider(
    String customerId,
  ) : this._internal(
          (ref) => ordersByCustomer(
            ref as OrdersByCustomerRef,
            customerId,
          ),
          from: ordersByCustomerProvider,
          name: r'ordersByCustomerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ordersByCustomerHash,
          dependencies: OrdersByCustomerFamily._dependencies,
          allTransitiveDependencies:
              OrdersByCustomerFamily._allTransitiveDependencies,
          customerId: customerId,
        );

  OrdersByCustomerProvider._internal(
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
    FutureOr<List<OrderModel>> Function(OrdersByCustomerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrdersByCustomerProvider._internal(
        (ref) => create(ref as OrdersByCustomerRef),
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
  AutoDisposeFutureProviderElement<List<OrderModel>> createElement() {
    return _OrdersByCustomerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersByCustomerProvider && other.customerId == customerId;
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
mixin OrdersByCustomerRef on AutoDisposeFutureProviderRef<List<OrderModel>> {
  /// The parameter `customerId` of this provider.
  String get customerId;
}

class _OrdersByCustomerProviderElement
    extends AutoDisposeFutureProviderElement<List<OrderModel>>
    with OrdersByCustomerRef {
  _OrdersByCustomerProviderElement(super.provider);

  @override
  String get customerId => (origin as OrdersByCustomerProvider).customerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
