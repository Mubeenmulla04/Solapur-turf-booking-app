import 'package:freezed_annotation/freezed_annotation.dart';

part 'dynamic_pricing_rule.freezed.dart';
part 'dynamic_pricing_rule.g.dart';

@freezed
class DynamicPricingRule with _$DynamicPricingRule {
  const factory DynamicPricingRule({
    String? id,
    required String startTime, // "HH:mm:ss"
    required String endTime,
    int? dayOfWeek, // 1-7
    @Default(1.0) double multiplier,
    @Default(true) bool active,
    String? description,
  }) = _DynamicPricingRule;

  factory DynamicPricingRule.fromJson(Map<String, dynamic> json) =>
      _$DynamicPricingRuleFromJson(json);
}
