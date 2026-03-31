// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pricingRulesHash() => r'2a593f9a1956df5d1a5648453885b8e562ee21fe';

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

abstract class _$PricingRules
    extends BuildlessAutoDisposeAsyncNotifier<List<DynamicPricingRule>> {
  late final String turfId;

  FutureOr<List<DynamicPricingRule>> build(
    String turfId,
  );
}

/// See also [PricingRules].
@ProviderFor(PricingRules)
const pricingRulesProvider = PricingRulesFamily();

/// See also [PricingRules].
class PricingRulesFamily extends Family<AsyncValue<List<DynamicPricingRule>>> {
  /// See also [PricingRules].
  const PricingRulesFamily();

  /// See also [PricingRules].
  PricingRulesProvider call(
    String turfId,
  ) {
    return PricingRulesProvider(
      turfId,
    );
  }

  @override
  PricingRulesProvider getProviderOverride(
    covariant PricingRulesProvider provider,
  ) {
    return call(
      provider.turfId,
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
  String? get name => r'pricingRulesProvider';
}

/// See also [PricingRules].
class PricingRulesProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PricingRules, List<DynamicPricingRule>> {
  /// See also [PricingRules].
  PricingRulesProvider(
    String turfId,
  ) : this._internal(
          () => PricingRules()..turfId = turfId,
          from: pricingRulesProvider,
          name: r'pricingRulesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pricingRulesHash,
          dependencies: PricingRulesFamily._dependencies,
          allTransitiveDependencies:
              PricingRulesFamily._allTransitiveDependencies,
          turfId: turfId,
        );

  PricingRulesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.turfId,
  }) : super.internal();

  final String turfId;

  @override
  FutureOr<List<DynamicPricingRule>> runNotifierBuild(
    covariant PricingRules notifier,
  ) {
    return notifier.build(
      turfId,
    );
  }

  @override
  Override overrideWith(PricingRules Function() create) {
    return ProviderOverride(
      origin: this,
      override: PricingRulesProvider._internal(
        () => create()..turfId = turfId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        turfId: turfId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PricingRules,
      List<DynamicPricingRule>> createElement() {
    return _PricingRulesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PricingRulesProvider && other.turfId == turfId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, turfId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PricingRulesRef
    on AutoDisposeAsyncNotifierProviderRef<List<DynamicPricingRule>> {
  /// The parameter `turfId` of this provider.
  String get turfId;
}

class _PricingRulesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PricingRules,
        List<DynamicPricingRule>> with PricingRulesRef {
  _PricingRulesProviderElement(super.provider);

  @override
  String get turfId => (origin as PricingRulesProvider).turfId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
