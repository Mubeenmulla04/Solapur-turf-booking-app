import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

// ── Provider ───────────────────────────────────────────────────────────────────

final _ownerAnalyticsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/bookings/owner-analytics');
    return res.data['data'] as Map<String, dynamic>;
  } on DioException catch (e) {
    throw Exception('Failed to load analytics: ${e.message}');
  }
});

// ── Screen ─────────────────────────────────────────────────────────────────────

class OwnerAnalyticsScreen extends ConsumerWidget {
  const OwnerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(_ownerAnalyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Revenue Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(_ownerAnalyticsProvider),
          ),
        ],
      ),
      body: analyticsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const Gap(12),
              const Text('Failed to load analytics'),
              const Gap(8),
              TextButton(
                onPressed: () => ref.invalidate(_ownerAnalyticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          final heatmap = (data['heatmap'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          final topSlots = (data['topSlots'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          final popularSports = (data['popularSports'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          final totalBookings = data['totalBookings'] ?? 0;
          final totalRevenue =
              double.tryParse(data['totalRevenue'].toString()) ?? 0;

          double maxBookings = heatmap.fold(
              0.0,
              (m, e) => (_parseNum(e['bookings']) > m
                  ? _parseNum(e['bookings'])
                  : m));
          if (maxBookings == 0) maxBookings = 1;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(_ownerAnalyticsProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── KPI Row ──
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          label: 'Total Bookings',
                          value: totalBookings.toString(),
                          icon: Icons.confirmation_num_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: _KpiCard(
                          label: 'Total Revenue',
                          value: AppFormatters.formatCurrency(totalRevenue),
                          icon: Icons.currency_rupee_rounded,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const Gap(28),

                  // ── 7-Day Heatmap ──
                  _SectionLabel('TRAFFIC HEATMAP — LAST 7 DAYS'),
                  const Gap(14),
                  _HeatmapChart(heatmap: heatmap, maxBookings: maxBookings),
                  const Gap(28),

                  // ── Top Performing Slots ──
                  _SectionLabel('TOP PERFORMING SLOTS'),
                  const Gap(14),
                  topSlots.isEmpty
                      ? _EmptyCard('No slot data yet')
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: AppColors.dividerLight),
                          ),
                          child: Column(
                            children: topSlots.asMap().entries.map((entry) {
                              final i = entry.key;
                              final slot = entry.value;
                              final count =
                                  _parseNum(slot['bookings']).toInt();
                              final max = (_parseNum(
                                          topSlots.first['bookings']))
                                      .toInt()
                                      .toDouble();
                              return Column(
                                children: [
                                  if (i > 0)
                                    const Divider(
                                        height: 1,
                                        color: AppColors.dividerLight),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text('${i + 1}',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color:
                                                        AppColors.primary)),
                                          ),
                                        ),
                                        const Gap(12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                slot['slot']?.toString() ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: AppColors
                                                        .textPrimaryLight),
                                              ),
                                              const Gap(5),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        4),
                                                child: LinearProgressIndicator(
                                                  value: max > 0
                                                      ? count / max
                                                      : 0,
                                                  backgroundColor: AppColors
                                                      .primary
                                                      .withOpacity(0.1),
                                                  valueColor:
                                                      const AlwaysStoppedAnimation(
                                                          AppColors.primary),
                                                  minHeight: 6,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Gap(12),
                                        Text(
                                          '$count bookings',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                  const Gap(28),

                  // ── Popular Sports ──
                  _SectionLabel('POPULAR SPORTS'),
                  const Gap(14),
                  popularSports.isEmpty
                      ? _EmptyCard('No sport data yet')
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: popularSports.map((s) {
                            final sport = s['sport']?.toString() ?? '';
                            final count = _parseNum(s['bookings']).toInt();
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.primary
                                        .withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.sports_score_rounded,
                                      size: 16, color: AppColors.primary),
                                  const Gap(8),
                                  Text(
                                    sport,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark),
                                  ),
                                  const Gap(8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text('$count',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

// ── Heatmap Chart ─────────────────────────────────────────────────────────────

class _HeatmapChart extends StatelessWidget {
  final List<Map<String, dynamic>> heatmap;
  final double maxBookings;
  const _HeatmapChart(
      {required this.heatmap, required this.maxBookings});

  double _parseNum(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: heatmap.map((day) {
                final bookings = _parseNum(day['bookings']);
                final revenue = _parseNum(day['revenue']);
                final ratio =
                    maxBookings > 0 ? bookings / maxBookings : 0.0;
                final isHighest = bookings == maxBookings && bookings > 0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (bookings > 0) ...[
                          Text(
                            bookings.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isHighest
                                  ? AppColors.primary
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const Gap(2),
                        ],
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          height: (150 * ratio).clamp(3.0, 150.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isHighest
                                  ? [AppColors.primary, AppColors.primaryDark]
                                  : [
                                      AppColors.primary.withOpacity(0.5),
                                      AppColors.primary.withOpacity(0.3),
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ),
                        const Gap(6),
                        Text(
                          day['label']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isHighest
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isHighest
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Gap(12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights_rounded,
                    color: AppColors.primary, size: 16),
                const Gap(8),
                Expanded(
                  child: Text(
                    heatmap.isEmpty
                        ? 'No data yet'
                        : 'Weekends show the highest traffic. Consider enabling Peak Pricing Friday–Sunday.',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondaryLight,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
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
                  fontSize: 20,
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

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondaryLight),
      ),
    );
  }
}
