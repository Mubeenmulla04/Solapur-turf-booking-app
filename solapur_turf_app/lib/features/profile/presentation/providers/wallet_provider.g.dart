// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletTransactionsHash() =>
    r'518b4fe4d876c1821eba75dc5497ea850eaaae55';

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
String _$walletTopUpHash() => r'663722a68363471c9442b503f673ab57e04c41a2';

/// See also [WalletTopUp].
@ProviderFor(WalletTopUp)
final walletTopUpProvider =
    AutoDisposeNotifierProvider<WalletTopUp, AsyncValue<void>>.internal(
  WalletTopUp.new,
  name: r'walletTopUpProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$walletTopUpHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WalletTopUp = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
