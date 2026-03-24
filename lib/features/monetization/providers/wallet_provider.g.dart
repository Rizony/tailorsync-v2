// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletTransactionsHash() =>
    r'26f32d988993aed9d95e0898625341fdcf081690';

/// See also [walletTransactions].
@ProviderFor(walletTransactions)
final walletTransactionsProvider =
    AutoDisposeFutureProvider<List<WalletTransaction>>.internal(
  walletTransactions,
  name: r'walletTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletTransactionsRef
    = AutoDisposeFutureProviderRef<List<WalletTransaction>>;
String _$walletStateHash() => r'bcc7ba049eec9731d9d213ea0f9fa431c687df6d';

/// See also [WalletState].
@ProviderFor(WalletState)
final walletStateProvider =
    AutoDisposeAsyncNotifierProvider<WalletState, Wallet?>.internal(
  WalletState.new,
  name: r'walletStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$walletStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WalletState = AutoDisposeAsyncNotifier<Wallet?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
