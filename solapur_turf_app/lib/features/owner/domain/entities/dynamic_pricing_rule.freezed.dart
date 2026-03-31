// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dynamic_pricing_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DynamicPricingRule _$DynamicPricingRuleFromJson(Map<String, dynamic> json) {
  return _DynamicPricingRule.fromJson(json);
}

/// @nodoc
mixin _$DynamicPricingRule {
  String? get id => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError; // "HH:mm:ss"
  String get endTime => throw _privateConstructorUsedError;
  int? get dayOfWeek => throw _privateConstructorUsedError; // 1-7
  double get multiplier => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this DynamicPricingRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DynamicPricingRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DynamicPricingRuleCopyWith<DynamicPricingRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DynamicPricingRuleCopyWith<$Res> {
  factory $DynamicPricingRuleCopyWith(
          DynamicPricingRule value, $Res Function(DynamicPricingRule) then) =
      _$DynamicPricingRuleCopyWithImpl<$Res, DynamicPricingRule>;
  @useResult
  $Res call(
      {String? id,
      String startTime,
      String endTime,
      int? dayOfWeek,
      double multiplier,
      bool active,
      String? description});
}

/// @nodoc
class _$DynamicPricingRuleCopyWithImpl<$Res, $Val extends DynamicPricingRule>
    implements $DynamicPricingRuleCopyWith<$Res> {
  _$DynamicPricingRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DynamicPricingRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? startTime = null,
    Object? endTime = null,
    Object? dayOfWeek = freezed,
    Object? multiplier = null,
    Object? active = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: freezed == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int?,
      multiplier: null == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DynamicPricingRuleImplCopyWith<$Res>
    implements $DynamicPricingRuleCopyWith<$Res> {
  factory _$$DynamicPricingRuleImplCopyWith(_$DynamicPricingRuleImpl value,
          $Res Function(_$DynamicPricingRuleImpl) then) =
      __$$DynamicPricingRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String startTime,
      String endTime,
      int? dayOfWeek,
      double multiplier,
      bool active,
      String? description});
}

/// @nodoc
class __$$DynamicPricingRuleImplCopyWithImpl<$Res>
    extends _$DynamicPricingRuleCopyWithImpl<$Res, _$DynamicPricingRuleImpl>
    implements _$$DynamicPricingRuleImplCopyWith<$Res> {
  __$$DynamicPricingRuleImplCopyWithImpl(_$DynamicPricingRuleImpl _value,
      $Res Function(_$DynamicPricingRuleImpl) _then)
      : super(_value, _then);

  /// Create a copy of DynamicPricingRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? startTime = null,
    Object? endTime = null,
    Object? dayOfWeek = freezed,
    Object? multiplier = null,
    Object? active = null,
    Object? description = freezed,
  }) {
    return _then(_$DynamicPricingRuleImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: freezed == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int?,
      multiplier: null == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DynamicPricingRuleImpl implements _DynamicPricingRule {
  const _$DynamicPricingRuleImpl(
      {this.id,
      required this.startTime,
      required this.endTime,
      this.dayOfWeek,
      this.multiplier = 1.0,
      this.active = true,
      this.description});

  factory _$DynamicPricingRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$DynamicPricingRuleImplFromJson(json);

  @override
  final String? id;
  @override
  final String startTime;
// "HH:mm:ss"
  @override
  final String endTime;
  @override
  final int? dayOfWeek;
// 1-7
  @override
  @JsonKey()
  final double multiplier;
  @override
  @JsonKey()
  final bool active;
  @override
  final String? description;

  @override
  String toString() {
    return 'DynamicPricingRule(id: $id, startTime: $startTime, endTime: $endTime, dayOfWeek: $dayOfWeek, multiplier: $multiplier, active: $active, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DynamicPricingRuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.multiplier, multiplier) ||
                other.multiplier == multiplier) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, startTime, endTime,
      dayOfWeek, multiplier, active, description);

  /// Create a copy of DynamicPricingRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DynamicPricingRuleImplCopyWith<_$DynamicPricingRuleImpl> get copyWith =>
      __$$DynamicPricingRuleImplCopyWithImpl<_$DynamicPricingRuleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DynamicPricingRuleImplToJson(
      this,
    );
  }
}

abstract class _DynamicPricingRule implements DynamicPricingRule {
  const factory _DynamicPricingRule(
      {final String? id,
      required final String startTime,
      required final String endTime,
      final int? dayOfWeek,
      final double multiplier,
      final bool active,
      final String? description}) = _$DynamicPricingRuleImpl;

  factory _DynamicPricingRule.fromJson(Map<String, dynamic> json) =
      _$DynamicPricingRuleImpl.fromJson;

  @override
  String? get id;
  @override
  String get startTime; // "HH:mm:ss"
  @override
  String get endTime;
  @override
  int? get dayOfWeek; // 1-7
  @override
  double get multiplier;
  @override
  bool get active;
  @override
  String? get description;

  /// Create a copy of DynamicPricingRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DynamicPricingRuleImplCopyWith<_$DynamicPricingRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
