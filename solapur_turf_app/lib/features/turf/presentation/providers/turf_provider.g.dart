// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turf_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$turfRepositoryHash() => r'f3699074d65f993ca22c77efbc7c538ef0c22562';

/// See also [turfRepository].
@ProviderFor(turfRepository)
final turfRepositoryProvider = AutoDisposeProvider<TurfRepository>.internal(
  turfRepository,
  name: r'turfRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$turfRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TurfRepositoryRef = AutoDisposeProviderRef<TurfRepository>;
String _$turfsHash() => r'67a5b11982c3632327e0dce61ba8289b5f137771';

/// See also [turfs].
@ProviderFor(turfs)
final turfsProvider = AutoDisposeFutureProvider<List<TurfListing>>.internal(
  turfs,
  name: r'turfsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$turfsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TurfsRef = AutoDisposeFutureProviderRef<List<TurfListing>>;
String _$turfDetailHash() => r'70389527d90744765dc36b213311078190cd0392';

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

/// See also [turfDetail].
@ProviderFor(turfDetail)
const turfDetailProvider = TurfDetailFamily();

/// See also [turfDetail].
class TurfDetailFamily extends Family<AsyncValue<TurfListing>> {
  /// See also [turfDetail].
  const TurfDetailFamily();

  /// See also [turfDetail].
  TurfDetailProvider call(
    String turfId,
  ) {
    return TurfDetailProvider(
      turfId,
    );
  }

  @override
  TurfDetailProvider getProviderOverride(
    covariant TurfDetailProvider provider,
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
  String? get name => r'turfDetailProvider';
}

/// See also [turfDetail].
class TurfDetailProvider extends AutoDisposeFutureProvider<TurfListing> {
  /// See also [turfDetail].
  TurfDetailProvider(
    String turfId,
  ) : this._internal(
          (ref) => turfDetail(
            ref as TurfDetailRef,
            turfId,
          ),
          from: turfDetailProvider,
          name: r'turfDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$turfDetailHash,
          dependencies: TurfDetailFamily._dependencies,
          allTransitiveDependencies:
              TurfDetailFamily._allTransitiveDependencies,
          turfId: turfId,
        );

  TurfDetailProvider._internal(
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
  Override overrideWith(
    FutureOr<TurfListing> Function(TurfDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TurfDetailProvider._internal(
        (ref) => create(ref as TurfDetailRef),
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
  AutoDisposeFutureProviderElement<TurfListing> createElement() {
    return _TurfDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TurfDetailProvider && other.turfId == turfId;
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
mixin TurfDetailRef on AutoDisposeFutureProviderRef<TurfListing> {
  /// The parameter `turfId` of this provider.
  String get turfId;
}

class _TurfDetailProviderElement
    extends AutoDisposeFutureProviderElement<TurfListing> with TurfDetailRef {
  _TurfDetailProviderElement(super.provider);

  @override
  String get turfId => (origin as TurfDetailProvider).turfId;
}

String _$availableSlotsHash() => r'036b6b92d5f0c7ca5c996e390d06c441da1da7d6';

/// See also [availableSlots].
@ProviderFor(availableSlots)
const availableSlotsProvider = AvailableSlotsFamily();

/// See also [availableSlots].
class AvailableSlotsFamily extends Family<AsyncValue<List<AvailabilitySlot>>> {
  /// See also [availableSlots].
  const AvailableSlotsFamily();

  /// See also [availableSlots].
  AvailableSlotsProvider call({
    required String turfId,
    required String date,
  }) {
    return AvailableSlotsProvider(
      turfId: turfId,
      date: date,
    );
  }

  @override
  AvailableSlotsProvider getProviderOverride(
    covariant AvailableSlotsProvider provider,
  ) {
    return call(
      turfId: provider.turfId,
      date: provider.date,
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
  String? get name => r'availableSlotsProvider';
}

/// See also [availableSlots].
class AvailableSlotsProvider
    extends AutoDisposeFutureProvider<List<AvailabilitySlot>> {
  /// See also [availableSlots].
  AvailableSlotsProvider({
    required String turfId,
    required String date,
  }) : this._internal(
          (ref) => availableSlots(
            ref as AvailableSlotsRef,
            turfId: turfId,
            date: date,
          ),
          from: availableSlotsProvider,
          name: r'availableSlotsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableSlotsHash,
          dependencies: AvailableSlotsFamily._dependencies,
          allTransitiveDependencies:
              AvailableSlotsFamily._allTransitiveDependencies,
          turfId: turfId,
          date: date,
        );

  AvailableSlotsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.turfId,
    required this.date,
  }) : super.internal();

  final String turfId;
  final String date;

  @override
  Override overrideWith(
    FutureOr<List<AvailabilitySlot>> Function(AvailableSlotsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailableSlotsProvider._internal(
        (ref) => create(ref as AvailableSlotsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        turfId: turfId,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AvailabilitySlot>> createElement() {
    return _AvailableSlotsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableSlotsProvider &&
        other.turfId == turfId &&
        other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, turfId.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailableSlotsRef
    on AutoDisposeFutureProviderRef<List<AvailabilitySlot>> {
  /// The parameter `turfId` of this provider.
  String get turfId;

  /// The parameter `date` of this provider.
  String get date;
}

class _AvailableSlotsProviderElement
    extends AutoDisposeFutureProviderElement<List<AvailabilitySlot>>
    with AvailableSlotsRef {
  _AvailableSlotsProviderElement(super.provider);

  @override
  String get turfId => (origin as AvailableSlotsProvider).turfId;
  @override
  String get date => (origin as AvailableSlotsProvider).date;
}

String _$turfFilterHash() => r'7ccab4ff4d37366728d065a5cb2b9d0ff4da8902';

/// See also [TurfFilter].
@ProviderFor(TurfFilter)
final turfFilterProvider =
    AutoDisposeNotifierProvider<TurfFilter, TurfFilterState>.internal(
  TurfFilter.new,
  name: r'turfFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$turfFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TurfFilter = AutoDisposeNotifier<TurfFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
