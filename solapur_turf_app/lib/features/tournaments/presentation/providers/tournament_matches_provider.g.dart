// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_matches_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tournamentMatchesHash() => r'ad5471a4fd3080bfa691f34e2410b3fbd4282445';

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

/// See also [tournamentMatches].
@ProviderFor(tournamentMatches)
const tournamentMatchesProvider = TournamentMatchesFamily();

/// See also [tournamentMatches].
class TournamentMatchesFamily
    extends Family<AsyncValue<List<TournamentMatch>>> {
  /// See also [tournamentMatches].
  const TournamentMatchesFamily();

  /// See also [tournamentMatches].
  TournamentMatchesProvider call(
    String tournamentId,
  ) {
    return TournamentMatchesProvider(
      tournamentId,
    );
  }

  @override
  TournamentMatchesProvider getProviderOverride(
    covariant TournamentMatchesProvider provider,
  ) {
    return call(
      provider.tournamentId,
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
  String? get name => r'tournamentMatchesProvider';
}

/// See also [tournamentMatches].
class TournamentMatchesProvider
    extends AutoDisposeFutureProvider<List<TournamentMatch>> {
  /// See also [tournamentMatches].
  TournamentMatchesProvider(
    String tournamentId,
  ) : this._internal(
          (ref) => tournamentMatches(
            ref as TournamentMatchesRef,
            tournamentId,
          ),
          from: tournamentMatchesProvider,
          name: r'tournamentMatchesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tournamentMatchesHash,
          dependencies: TournamentMatchesFamily._dependencies,
          allTransitiveDependencies:
              TournamentMatchesFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
        );

  TournamentMatchesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
  }) : super.internal();

  final String tournamentId;

  @override
  Override overrideWith(
    FutureOr<List<TournamentMatch>> Function(TournamentMatchesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TournamentMatchesProvider._internal(
        (ref) => create(ref as TournamentMatchesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TournamentMatch>> createElement() {
    return _TournamentMatchesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentMatchesProvider &&
        other.tournamentId == tournamentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TournamentMatchesRef
    on AutoDisposeFutureProviderRef<List<TournamentMatch>> {
  /// The parameter `tournamentId` of this provider.
  String get tournamentId;
}

class _TournamentMatchesProviderElement
    extends AutoDisposeFutureProviderElement<List<TournamentMatch>>
    with TournamentMatchesRef {
  _TournamentMatchesProviderElement(super.provider);

  @override
  String get tournamentId => (origin as TournamentMatchesProvider).tournamentId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
