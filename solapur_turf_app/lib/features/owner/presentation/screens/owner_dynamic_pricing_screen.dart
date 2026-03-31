import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dynamic_pricing_rule.dart';
import '../providers/pricing_provider.dart';

class OwnerDynamicPricingScreen extends ConsumerWidget {
  final String turfId;
  const OwnerDynamicPricingScreen({super.key, required this.turfId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(pricingRulesProvider(turfId));
    final notifier = ref.read(pricingRulesProvider(turfId).notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dynamic Pricing',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showAddRuleSheet(context, notifier),
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.warning,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.white, size: 18),
                  Gap(10),
                  Expanded(
                    child: Text(
                      'Multipliers increase the base hourly rate (e.g., 1.2x = 20% extra). '
                      'Rules apply when a booking overlaps includes the specified time window.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: rulesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.warning)),
              error: (e, __) => Center(child: Text('Error: $e')),
              data: (rules) => rules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_calendar_outlined,
                              size: 64,
                              color: AppColors.textSecondaryLight.withOpacity(0.3)),
                          const Gap(12),
                          const Text('No pricing rules set',
                              style: TextStyle(color: AppColors.textSecondaryLight)),
                          const Gap(8),
                          ElevatedButton.icon(
                            onPressed: () => _showAddRuleSheet(context, notifier),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Rule'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                                foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(pricingRulesProvider(turfId)),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        itemCount: rules.length,
                        separatorBuilder: (_, __) => const Gap(12),
                        itemBuilder: (_, i) => _RuleCard(
                          rule: rules[i],
                          onDelete: () => notifier.deleteRule(rules[i].id!),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Refresh', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          ref.invalidate(pricingRulesProvider(turfId));
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }

  void _showAddRuleSheet(BuildContext context, PricingRules notifier) {
    final startCtrl = TextEditingController(text: '17:00');
    final endCtrl = TextEditingController(text: '22:00');
    final multiplierCtrl = TextEditingController(text: '1.2');
    final descCtrl = TextEditingController();
    int? selectedDay;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24, left: 24, right: 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Peak-Hour Rule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(20),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. Evening Peak',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const Gap(12),
              Row(children: [
                Expanded(child: _sheetField(startCtrl, 'Start Time', '17:00', Icons.schedule_rounded)),
                const Gap(12),
                Expanded(child: _sheetField(endCtrl, 'End Time', '22:00', Icons.timer_off_outlined)),
              ]),
              const Gap(12),
              _sheetField(multiplierCtrl, 'Rate Multiplier', '1.2', Icons.trending_up_rounded, inputType: TextInputType.number),
              const Gap(12),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Day of Week (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                ),
                value: selectedDay,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Days')),
                  const DropdownMenuItem(value: 1, child: Text('Monday')),
                  const DropdownMenuItem(value: 2, child: Text('Tuesday')),
                  const DropdownMenuItem(value: 3, child: Text('Wednesday')),
                  const DropdownMenuItem(value: 4, child: Text('Thursday')),
                  const DropdownMenuItem(value: 5, child: Text('Friday')),
                  const DropdownMenuItem(value: 6, child: Text('Saturday')),
                  const DropdownMenuItem(value: 7, child: Text('Sunday')),
                ],
                onChanged: (v) => setSheet(() => selectedDay = v),
              ),
              const Gap(20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    try {
                      final m = double.tryParse(multiplierCtrl.text.trim()) ?? 1.0;
                      await notifier.addRule(DynamicPricingRule(
                        startTime: '${startCtrl.text.trim()}:00',
                        endTime: '${endCtrl.text.trim()}:00',
                        multiplier: m,
                        dayOfWeek: selectedDay,
                        description: descCtrl.text.trim(),
                      ));
                      Navigator.pop(ctx);
                    } catch (e) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Save Rule', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String label, String hint, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondaryLight, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final DynamicPricingRule rule;
  final VoidCallback onDelete;

  const _RuleCard({required this.rule, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    String dayLabel = 'Daily';
    if (rule.dayOfWeek != null) {
      const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      dayLabel = days[rule.dayOfWeek!];
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.trending_up_rounded, color: AppColors.warning, size: 24),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rule.description ?? 'Pricing Rule', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                  const Gap(4),
                  Text('${rule.startTime.substring(0, 5)} - ${rule.endTime.substring(0, 5)} · $dayLabel',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${rule.multiplier}x', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.warning)),
                const Gap(4),
                IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22), onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
