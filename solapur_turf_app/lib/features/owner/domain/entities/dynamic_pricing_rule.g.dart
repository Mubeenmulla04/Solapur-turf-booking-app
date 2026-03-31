// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_pricing_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DynamicPricingRuleImpl _$$DynamicPricingRuleImplFromJson(
        Map<String, dynamic> json) =>
    _$DynamicPricingRuleImpl(
      id: json['id'] as String?,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      active: json['active'] as bool? ?? true,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$DynamicPricingRuleImplToJson(
        _$DynamicPricingRuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'dayOfWeek': instance.dayOfWeek,
      'multiplier': instance.multiplier,
      'active': instance.active,
      'description': instance.description,
    };
