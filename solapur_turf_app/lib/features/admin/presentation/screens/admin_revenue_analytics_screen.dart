import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminRevenueAnalyticsScreen extends ConsumerWidget {
  const AdminRevenueAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(adminRevenueProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Revenue Analytics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminRevenueProvider),
          ),
        ],
      ),
      body: revenueAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.success)),
        error: (_, __) => _ErrorState(
          onRetry: () => ref.invalidate(adminRevenueProvider),
        ),
        data: (data) {
          final chartData =
              (data['chartData'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final totalRevenue = _parseNum(data['totalRevenue']);
          final avgMonthly = _parseNum(data['averageMonthly']);

          // Find max revenue for bar scaling
          double maxVal = chartData.fold(
              0.0, (m, e) => _parseNum(e['revenue']) > m ? _parseNum(e['revenue']) : m);
          if (maxVal == 0) maxVal = 1;

          return RefreshIndicator(
            color: AppColors.success,
            onRefresh: () async => ref.invalidate(adminRevenueProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── KPI Summary Cards ──
                  Row(
                    children: [
                      Expanded(
                        child: _KpiBox(
                          label: 'Total Revenue',
                          value: '₹${_formatNum(totalRevenue)}',
                          icon: Icons.currency_rupee_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: _KpiBox(
                          label: 'Avg / Month',
                          value: '₹${_formatNum(avgMonthly)}',
                          icon: Icons.show_chart_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(28),

                  // ── Bar Chart ──
                  const Text(
                    'MONTHLY REVENUE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondaryLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Gap(16),
                  if (chartData.isEmpty)
                    _EmptyChart()
                  else
                    _BarChart(chartData: chartData, maxVal: maxVal),
                  const Gap(28),

                  // ── Breakdown Table ──
                  const Text(
                    'MONTH-BY-MONTH BREAKDOWN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondaryLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Gap(12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.08),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                  child: Text('Month',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: AppColors.textSecondaryLight))),
                              Text('Revenue',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: AppColors.textSecondaryLight)),
                            ],
                          ),
                        ),
                        ...chartData.asMap().entries.map((entry) {
                          final i = entry.key;
                          final row = entry.value;
                          final rev = _parseNum(row['revenue']);
                          return Column(
                            children: [
                              if (i > 0)
                                const Divider(
                                    height: 1, color: AppColors.dividerLight),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                          row['month']?.toString() ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: AppColors.textPrimaryLight)),
                                    ),
                                    Text(
                                      '₹${_formatNum(rev)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: rev > 0
                                            ? AppColors.success
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _parseNum(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  String _formatNum(double val) {
    if (val >= 100000) return '${(val / 100000).toStringAsFixed(1)}L';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}K';
    return val.toStringAsFixed(0);
  }
}

class _BarChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  final double maxVal;
  const _BarChart({required this.chartData, required this.maxVal});

  double _parseNum(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.map((entry) {
          final rev = _parseNum(entry['revenue']);
          final heightRatio = maxVal > 0 ? (rev / maxVal) : 0.0;
          final month = (entry['month'] as String? ?? '').split(' ').first;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (rev > 0)
                    Text(
                      '₹${rev >= 1000 ? '${(rev / 1000).toStringAsFixed(0)}K' : rev.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success),
                    ),
                  const Gap(4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    height: (160 * heightRatio).clamp(2.0, 160.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success,
                          AppColors.success.withOpacity(0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ),
                  const Gap(6),
                  Text(month,
                      style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600)),
                  const Gap(8),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bar_chart_rounded,
              size: 48, color: AppColors.textSecondaryLight.withOpacity(0.3)),
          const Gap(8),
          const Text('No revenue data yet',
              style: TextStyle(color: AppColors.textSecondaryLight)),
        ]),
      ),
    );
  }
}

class _KpiBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiBox(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Gap(12),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.5)),
          const Gap(4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.error),
          const Gap(12),
          const Text('Failed to load analytics'),
          const Gap(8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
