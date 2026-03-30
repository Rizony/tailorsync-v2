// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderControllerHash() => r'03961170ee57b22cda7af3a0969f2e4fd31b88f3';

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

abstract class _$OrderController
    extends BuildlessAutoDisposeAsyncNotifier<OrderModel?> {
  late final String orderId;

  FutureOr<OrderModel?> build(
    String orderId,
  );
}

/// See also [OrderController].
@ProviderFor(OrderController)
const orderControllerProvider = OrderControllerFamily();

/// See also [OrderController].
class OrderControllerFamily extends Family<AsyncValue<OrderModel?>> {
  /// See also [OrderController].
  const OrderControllerFamily();

  /// See also [OrderController].
  OrderControllerProvider call(
    String orderId,
  ) {
    return OrderControllerProvider(
      orderId,
    );
  }

  @override
  OrderControllerProvider getProviderOverride(
    covariant OrderControllerProvider provider,
  ) {
    return call(
      provider.orderId,
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
  String? get name => r'orderControllerProvider';
}

/// See also [OrderController].
class OrderControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<OrderController, OrderModel?> {
  /// See also [OrderController].
  OrderControllerProvider(
    String orderId,
  ) : this._internal(
          () => OrderController()..orderId = orderId,
          from: orderControllerProvider,
          name: r'orderControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$orderControllerHash,
          dependencies: OrderControllerFamily._dependencies,
          allTransitiveDependencies:
              OrderControllerFamily._allTransitiveDependencies,
          orderId: orderId,
        );

  OrderControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  FutureOr<OrderModel?> runNotifierBuild(
    covariant OrderController notifier,
  ) {
    return notifier.build(
      orderId,
    );
  }

  @override
  Override overrideWith(OrderController Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrderControllerProvider._internal(
        () => create()..orderId = orderId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<OrderController, OrderModel?>
      createElement() {
    return _OrderControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderControllerProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderControllerRef on AutoDisposeAsyncNotifierProviderRef<OrderModel?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<OrderController,
        OrderModel?> with OrderControllerRef {
  _OrderControllerProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderControllerProvider).orderId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
