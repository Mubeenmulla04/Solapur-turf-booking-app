import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/dynamic_pricing_rule.dart';

part 'pricing_provider.g.dart';

@riverpod
class PricingRules extends _$PricingRules {
  @override
  FutureOr<List<DynamicPricingRule>> build(String turfId) async {
    final dio = ref.watch(apiClientProvider);
    try {
      final res = await dio.get('/turfs/$turfId/pricing-rules');
      final list = res.data['data'] as List<dynamic>;
      return list.map((e) => DynamicPricingRule.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load pricing rules: ${e.message}');
    }
  }

  Future<void> addRule(DynamicPricingRule rule) async {
    final dio = ref.read(apiClientProvider);
    try {
      await dio.post('/turfs/$turfId/pricing-rules', data: rule.toJson());
      ref.invalidateSelf();
    } on DioException catch (e) {
      throw Exception('Failed to add rule: ${e.message}');
    }
  }

  Future<void> deleteRule(String ruleId) async {
    final dio = ref.read(apiClientProvider);
    try {
      await dio.delete('/turfs/$turfId/pricing-rules/$ruleId');
      ref.invalidateSelf();
    } on DioException catch (e) {
      throw Exception('Failed to delete rule: ${e.message}');
    }
  }
}
