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
  String? get registrationDeadline => throw _privateConstructorUsedError;
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
      String? registrationDeadline,
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
    Object? registrationDeadline = freezed,
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
      registrationDeadline: freezed == registrationDeadline
          ? _value.registrationDeadline
          : registrationDeadline // ignore: cast_nullable_to_non_nullable
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
      String? registrationDeadline,
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
    Object? registrationDeadline = freezed,
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
      registrationDeadline: freezed == registrationDeadline
          ? _value.registrationDeadline
          : registrationDeadline // ignore: cast_nullable_to_non_nullable
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
      this.registrationDeadline,
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
  final String? registrationDeadline;
  @override
  final String? turfName;
  @override
  final String? description;

  @override
  String toString() {
    return 'Tournament(tournamentId: $tournamentId, name: $name, sportType: $sportType, format: $format, entryFee: $entryFee, prizePool: $prizePool, maxTeams: $maxTeams, registeredTeams: $registeredTeams, status: $status, startDate: $startDate, endDate: $endDate, registrationDeadline: $registrationDeadline, turfName: $turfName, description: $description)';
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
            (identical(other.registrationDeadline, registrationDeadline) ||
                other.registrationDeadline == registrationDeadline) &&
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
      registrationDeadline,
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
      final String? registrationDeadline,
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
  String? get registrationDeadline;
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
