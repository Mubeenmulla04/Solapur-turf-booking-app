// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_matches_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tournamentMatchesHash() => r'1e27e49c8abf53ac22cba392a9476568e48b2df4';

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

abstract class _$TournamentMatches
    extends BuildlessAutoDisposeAsyncNotifier<List<TournamentMatch>> {
  late final String tournamentId;

  FutureOr<List<TournamentMatch>> build(
    String tournamentId,
  );
}

/// See also [TournamentMatches].
@ProviderFor(TournamentMatches)
const tournamentMatchesProvider = TournamentMatchesFamily();

/// See also [TournamentMatches].
class TournamentMatchesFamily
    extends Family<AsyncValue<List<TournamentMatch>>> {
  /// See also [TournamentMatches].
  const TournamentMatchesFamily();

  /// See also [TournamentMatches].
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

/// See also [TournamentMatches].
class TournamentMatchesProvider extends AutoDisposeAsyncNotifierProviderImpl<
    TournamentMatches, List<TournamentMatch>> {
  /// See also [TournamentMatches].
  TournamentMatchesProvider(
    String tournamentId,
  ) : this._internal(
          () => TournamentMatches()..tournamentId = tournamentId,
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
  FutureOr<List<TournamentMatch>> runNotifierBuild(
    covariant TournamentMatches notifier,
  ) {
    return notifier.build(
      tournamentId,
    );
  }

  @override
  Override overrideWith(TournamentMatches Function() create) {
    return ProviderOverride(
      origin: this,
      override: TournamentMatchesProvider._internal(
        () => create()..tournamentId = tournamentId,
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
  AutoDisposeAsyncNotifierProviderElement<TournamentMatches,
      List<TournamentMatch>> createElement() {
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
    on AutoDisposeAsyncNotifierProviderRef<List<TournamentMatch>> {
  /// The parameter `tournamentId` of this provider.
  String get tournamentId;
}

class _TournamentMatchesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TournamentMatches,
        List<TournamentMatch>> with TournamentMatchesRef {
  _TournamentMatchesProviderElement(super.provider);

  @override
  String get tournamentId => (origin as TournamentMatchesProvider).tournamentId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
