// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Tournament {
  String get tournamentId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get sportType => throw _privateConstructorUsedError;
  String get format => throw _privateConstructorUsedError;
  double get entryFee => throw _privateConstructorUsedError;
  double? get prizePool => throw _privateConstructorUsedError;
  int get maxTeams => throw _privateConstructorUsedError;
  int get registeredTeams => throw _privateConstructorUsedError;
  TournamentStatus get status => throw _privateConstructorUsedError;
  String get startDate => throw _privateConstructorUsedError;
  String get endDate => throw _privateConstructorUsedError;
  String? get turfId => throw _privateConstructorUsedError;
  String? get turfName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Create a copy of Tournament
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TournamentCopyWith<Tournament> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TournamentCopyWith<$Res> {
  factory $TournamentCopyWith(
          Tournament value, $Res Function(Tournament) then) =
      _$TournamentCopyWithImpl<$Res, Tournament>;
  @useResult
  $Res call(
      {String tournamentId,
      String name,
      String sportType,
      String format,
      double entryFee,
      double? prizePool,
      int maxTeams,
      int registeredTeams,
      TournamentStatus status,
      String startDate,
      String endDate,
      String? turfId,
      String? turfName,
      String? description});
}

/// @nodoc
class _$TournamentCopyWithImpl<$Res, $Val extends Tournament>
    implements $TournamentCopyWith<$Res> {
  _$TournamentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tournament
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tournamentId = null,
    Object? name = null,
    Object? sportType = null,
    Object? format = null,
    Object? entryFee = null,
    Object? prizePool = freezed,
    Object? maxTeams = null,
    Object? registeredTeams = null,
    Object? status = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? turfId = freezed,
    Object? turfName = freezed,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      tournamentId: null == tournamentId
          ? _value.tournamentId
          : tournamentId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sportType: null == sportType
          ? _value.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      entryFee: null == entryFee
          ? _value.entryFee
          : entryFee // ignore: cast_nullable_to_non_nullable
              as double,
      prizePool: freezed == prizePool
          ? _value.prizePool
          : prizePool // ignore: cast_nullable_to_non_nullable
              as double?,
      maxTeams: null == maxTeams
          ? _value.maxTeams
          : maxTeams // ignore: cast_nullable_to_non_nullable
              as int,
      registeredTeams: null == registeredTeams
          ? _value.registeredTeams
          : registeredTeams // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TournamentStatus,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      turfId: freezed == turfId
          ? _value.turfId
          : turfId // ignore: cast_nullable_to_non_nullable
              as String?,
      turfName: freezed == turfName
          ? _value.turfName
          : turfName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TournamentImplCopyWith<$Res>
    implements $TournamentCopyWith<$Res> {
  factory _$$TournamentImplCopyWith(
          _$TournamentImpl value, $Res Function(_$TournamentImpl) then) =
      __$$TournamentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tournamentId,
      String name,
      String sportType,
      String format,
      double entryFee,
      double? prizePool,
      int maxTeams,
      int registeredTeams,
      TournamentStatus status,
      String startDate,
      String endDate,
      String? turfId,
      String? turfName,
      String? description});
}

/// @nodoc
class __$$TournamentImplCopyWithImpl<$Res>
    extends _$TournamentCopyWithImpl<$Res, _$TournamentImpl>
    implements _$$TournamentImplCopyWith<$Res> {
  __$$TournamentImplCopyWithImpl(
      _$TournamentImpl _value, $Res Function(_$TournamentImpl) _then)
      : super(_value, _then);

  /// Create a copy of Tournament
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tournamentId = null,
    Object? name = null,
    Object? sportType = null,
    Object? format = null,
    Object? entryFee = null,
    Object? prizePool = freezed,
    Object? maxTeams = null,
    Object? registeredTeams = null,
    Object? status = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? turfId = freezed,
    Object? turfName = freezed,
    Object? description = freezed,
  }) {
    return _then(_$TournamentImpl(
      tournamentId: null == tournamentId
          ? _value.tournamentId
          : tournamentId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sportType: null == sportType
          ? _value.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      entryFee: null == entryFee
          ? _value.entryFee
          : entryFee // ignore: cast_nullable_to_non_nullable
              as double,
      prizePool: freezed == prizePool
          ? _value.prizePool
          : prizePool // ignore: cast_nullable_to_non_nullable
              as double?,
      maxTeams: null == maxTeams
          ? _value.maxTeams
          : maxTeams // ignore: cast_nullable_to_non_nullable
              as int,
      registeredTeams: null == registeredTeams
          ? _value.registeredTeams
          : registeredTeams // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TournamentStatus,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      turfId: freezed == turfId
          ? _value.turfId
          : turfId // ignore: cast_nullable_to_non_nullable
              as String?,
      turfName: freezed == turfName
          ? _value.turfName
          : turfName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TournamentImpl implements _Tournament {
  const _$TournamentImpl(
      {required this.tournamentId,
      required this.name,
      required this.sportType,
      required this.format,
      required this.entryFee,
      this.prizePool,
      required this.maxTeams,
      required this.registeredTeams,
      required this.status,
      required this.startDate,
      required this.endDate,
      this.turfId,
      this.turfName,
      this.description});

  @override
  final String tournamentId;
  @override
  final String name;
  @override
  final String sportType;
  @override
  final String format;
  @override
  final double entryFee;
  @override
  final double? prizePool;
  @override
  final int maxTeams;
  @override
  final int registeredTeams;
  @override
  final TournamentStatus status;
  @override
  final String startDate;
  @override
  final String endDate;
  @override
  final String? turfId;
  @override
  final String? turfName;
  @override
  final String? description;

  @override
  String toString() {
    return 'Tournament(tournamentId: $tournamentId, name: $name, sportType: $sportType, format: $format, entryFee: $entryFee, prizePool: $prizePool, maxTeams: $maxTeams, registeredTeams: $registeredTeams, status: $status, startDate: $startDate, endDate: $endDate, turfId: $turfId, turfName: $turfName, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TournamentImpl &&
            (identical(other.tournamentId, tournamentId) ||
                other.tournamentId == tournamentId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.entryFee, entryFee) ||
                other.entryFee == entryFee) &&
            (identical(other.prizePool, prizePool) ||
                other.prizePool == prizePool) &&
            (identical(other.maxTeams, maxTeams) ||
                other.maxTeams == maxTeams) &&
            (identical(other.registeredTeams, registeredTeams) ||
                other.registeredTeams == registeredTeams) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.turfId, turfId) || other.turfId == turfId) &&
            (identical(other.turfName, turfName) ||
                other.turfName == turfName) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      tournamentId,
      name,
      sportType,
      format,
      entryFee,
      prizePool,
      maxTeams,
      registeredTeams,
      status,
      startDate,
      endDate,
      turfId,
      turfName,
      description);

  /// Create a copy of Tournament
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TournamentImplCopyWith<_$TournamentImpl> get copyWith =>
      __$$TournamentImplCopyWithImpl<_$TournamentImpl>(this, _$identity);
}

abstract class _Tournament implements Tournament {
  const factory _Tournament(
      {required final String tournamentId,
      required final String name,
      required final String sportType,
      required final String format,
      required final double entryFee,
      final double? prizePool,
      required final int maxTeams,
      required final int registeredTeams,
      required final TournamentStatus status,
      required final String startDate,
      required final String endDate,
      final String? turfId,
      final String? turfName,
      final String? description}) = _$TournamentImpl;

  @override
  String get tournamentId;
  @override
  String get name;
  @override
  String get sportType;
  @override
  String get format;
  @override
  double get entryFee;
  @override
  double? get prizePool;
  @override
  int get maxTeams;
  @override
  int get registeredTeams;
  @override
  TournamentStatus get status;
  @override
  String get startDate;
  @override
  String get endDate;
  @override
  String? get turfId;
  @override
  String? get turfName;
  @override
  String? get description;

  /// Create a copy of Tournament
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TournamentImplCopyWith<_$TournamentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TournamentMatch {
  String get matchId => throw _privateConstructorUsedError;
  String get tournamentId => throw _privateConstructorUsedError;
  int get round => throw _privateConstructorUsedError;
  int get matchNumber => throw _privateConstructorUsedError;
  Team? get teamA => throw _privateConstructorUsedError;
  Team? get teamB => throw _privateConstructorUsedError;
  String? get winnerId => throw _privateConstructorUsedError;
  int? get scoreA => throw _privateConstructorUsedError;
  int? get scoreB => throw _privateConstructorUsedError;
  TournamentMatchStatus get status => throw _privateConstructorUsedError;
  String? get scheduledStartTime => throw _privateConstructorUsedError;

  /// Create a copy of TournamentMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TournamentMatchCopyWith<TournamentMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TournamentMatchCopyWith<$Res> {
  factory $TournamentMatchCopyWith(
          TournamentMatch value, $Res Function(TournamentMatch) then) =
      _$TournamentMatchCopyWithImpl<$Res, TournamentMatch>;
  @useResult
  $Res call(
      {String matchId,
      String tournamentId,
      int round,
      int matchNumber,
      Team? teamA,
      Team? teamB,
      String? winnerId,
      int? scoreA,
      int? scoreB,
      TournamentMatchStatus status,
      String? scheduledStartTime});

  $TeamCopyWith<$Res>? get teamA;
  $TeamCopyWith<$Res>? get teamB;
}

/// @nodoc
class _$TournamentMatchCopyWithImpl<$Res, $Val extends TournamentMatch>
    implements $TournamentMatchCopyWith<$Res> {
  _$TournamentMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TournamentMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchId = null,
    Object? tournamentId = null,
    Object? round = null,
    Object? matchNumber = null,
    Object? teamA = freezed,
    Object? teamB = freezed,
    Object? winnerId = freezed,
    Object? scoreA = freezed,
    Object? scoreB = freezed,
    Object? status = null,
    Object? scheduledStartTime = freezed,
  }) {
    return _then(_value.copyWith(
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      tournamentId: null == tournamentId
          ? _value.tournamentId
          : tournamentId // ignore: cast_nullable_to_non_nullable
              as String,
      round: null == round
          ? _value.round
          : round // ignore: cast_nullable_to_non_nullable
              as int,
      matchNumber: null == matchNumber
          ? _value.matchNumber
          : matchNumber // ignore: cast_nullable_to_non_nullable
              as int,
      teamA: freezed == teamA
          ? _value.teamA
          : teamA // ignore: cast_nullable_to_non_nullable
              as Team?,
      teamB: freezed == teamB
          ? _value.teamB
          : teamB // ignore: cast_nullable_to_non_nullable
              as Team?,
      winnerId: freezed == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      scoreA: freezed == scoreA
          ? _value.scoreA
          : scoreA // ignore: cast_nullable_to_non_nullable
              as int?,
      scoreB: freezed == scoreB
          ? _value.scoreB
          : scoreB // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TournamentMatchStatus,
      scheduledStartTime: freezed == scheduledStartTime
          ? _value.scheduledStartTime
          : scheduledStartTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of TournamentMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamCopyWith<$Res>? get teamA {
    if (_value.teamA == null) {
      return null;
    }

    return $TeamCopyWith<$Res>(_value.teamA!, (value) {
      return _then(_value.copyWith(teamA: value) as $Val);
    });
  }

  /// Create a copy of TournamentMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamCopyWith<$Res>? get teamB {
    if (_value.teamB == null) {
      return null;
    }

    return $TeamCopyWith<$Res>(_value.teamB!, (value) {
      return _then(_value.copyWith(teamB: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TournamentMatchImplCopyWith<$Res>
    implements $TournamentMatchCopyWith<$Res> {
  factory _$$TournamentMatchImplCopyWith(_$TournamentMatchImpl value,
          $Res Function(_$TournamentMatchImpl) then) =
      __$$TournamentMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String matchId,
      String tournamentId,
      int round,
      int matchNumber,
      Team? teamA,
      Team? teamB,
      String? winnerId,
      int? scoreA,
      int? scoreB,
      TournamentMatchStatus status,
      String? scheduledStartTime});

  @override
  $TeamCopyWith<$Res>? get teamA;
  @override
  $TeamCopyWith<$Res>? get teamB;
}

/// @nodoc
class __$$TournamentMatchImplCopyWithImpl<$Res>
    extends _$TournamentMatchCopyWithImpl<$Res, _$TournamentMatchImpl>
    implements _$$TournamentMatchImplCopyWith<$Res> {
  __$$TournamentMatchImplCopyWithImpl(
      _$TournamentMatchImpl _value, $Res Function(_$TournamentMatchImpl) _then)
      : super(_value, _then);

  /// Create a copy of TournamentMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchId = null,
    Object? tournamentId = null,
    Object? round = null,
    Object? matchNumber = null,
    Object? teamA = freezed,
    Object? teamB = freezed,
    Object? winnerId = freezed,
    Object? scoreA = freezed,
    Object? scoreB = freezed,
    Object? status = null,
    Object? scheduledStartTime = freezed,
  }) {
    return _then(_$TournamentMatchImpl(
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      tournamentId: null == tournamentId
          ? _value.tournamentId
          : tournamentId // ignore: cast_nullable_to_non_nullable
              as String,
      round: null == round
          ? _value.round
          : round // ignore: cast_nullable_to_non_nullable
              as int,
      matchNumber: null == matchNumber
          ? _value.matchNumber
          : matchNumber // ignore: cast_nullable_to_non_nullable
              as int,
      teamA: freezed == teamA
          ? _value.teamA
          : teamA // ignore: cast_nullable_to_non_nullable
              as Team?,
      teamB: freezed == teamB
          ? _value.teamB
          : teamB // ignore: cast_nullable_to_non_nullable
              as Team?,
      winnerId: freezed == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      scoreA: freezed == scoreA
          ? _value.scoreA
          : scoreA // ignore: cast_nullable_to_non_nullable
              as int?,
      scoreB: freezed == scoreB
          ? _value.scoreB
          : scoreB // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TournamentMatchStatus,
      scheduledStartTime: freezed == scheduledStartTime
          ? _value.scheduledStartTime
          : scheduledStartTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TournamentMatchImpl implements _TournamentMatch {
  const _$TournamentMatchImpl(
      {required this.matchId,
      required this.tournamentId,
      required this.round,
      required this.matchNumber,
      this.teamA,
      this.teamB,
      this.winnerId,
      this.scoreA,
      this.scoreB,
      required this.status,
      this.scheduledStartTime});

  @override
  final String matchId;
  @override
  final String tournamentId;
  @override
  final int round;
  @override
  final int matchNumber;
  @override
  final Team? teamA;
  @override
  final Team? teamB;
  @override
  final String? winnerId;
  @override
  final int? scoreA;
  @override
  final int? scoreB;
  @override
  final TournamentMatchStatus status;
  @override
  final String? scheduledStartTime;

  @override
  String toString() {
    return 'TournamentMatch(matchId: $matchId, tournamentId: $tournamentId, round: $round, matchNumber: $matchNumber, teamA: $teamA, teamB: $teamB, winnerId: $winnerId, scoreA: $scoreA, scoreB: $scoreB, status: $status, scheduledStartTime: $scheduledStartTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TournamentMatchImpl &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.tournamentId, tournamentId) ||
                other.tournamentId == tournamentId) &&
            (identical(other.round, round) || other.round == round) &&
            (identical(other.matchNumber, matchNumber) ||
                other.matchNumber == matchNumber) &&
            (identical(other.teamA, teamA) || other.teamA == teamA) &&
            (identical(other.teamB, teamB) || other.teamB == teamB) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            (identical(other.scoreA, scoreA) || other.scoreA == scoreA) &&
            (identical(other.scoreB, scoreB) || other.scoreB == scoreB) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scheduledStartTime, scheduledStartTime) ||
                other.scheduledStartTime == scheduledStartTime));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      matchId,
      tournamentId,
      round,
      matchNumber,
      teamA,
      teamB,
      winnerId,
      scoreA,
      scoreB,
      status,
      scheduledStartTime);

  /// Create a copy of TournamentMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TournamentMatchImplCopyWith<_$TournamentMatchImpl> get copyWith =>
      __$$TournamentMatchImplCopyWithImpl<_$TournamentMatchImpl>(
          this, _$identity);
}

abstract class _TournamentMatch implements TournamentMatch {
  const factory _TournamentMatch(
      {required final String matchId,
      required final String tournamentId,
      required final int round,
      required final int matchNumber,
      final Team? teamA,
      final Team? teamB,
      final String? winnerId,
      final int? scoreA,
      final int? scoreB,
      required final TournamentMatchStatus status,
      final String? scheduledStartTime}) = _$TournamentMatchImpl;

  @override
  String get matchId;
  @override
  String get tournamentId;
  @override
  int get round;
  @override
  int get matchNumber;
  @override
  Team? get teamA;
  @override
  Team? get teamB;
  @override
  String? get winnerId;
  @override
  int? get scoreA;
  @override
  int? get scoreB;
  @override
  TournamentMatchStatus get status;
  @override
  String? get scheduledStartTime;

  /// Create a copy of TournamentMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TournamentMatchImplCopyWith<_$TournamentMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
