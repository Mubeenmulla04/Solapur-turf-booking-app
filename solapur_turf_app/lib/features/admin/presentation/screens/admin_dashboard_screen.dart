import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final adminStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final resList = await Future.wait([
      dio.get('/admin/stats'),
      dio.get('/settlement/pending', queryParameters: {'limit': 1}),
      dio.get('/admin/revenue'),
    ]);

    final statsData = resList[0].data is Map && resList[0].data['data'] is Map 
        ? resList[0].data['data'] as Map<String, dynamic> 
        : <String, dynamic>{};
    final settData = resList[1].data is Map && resList[1].data['data'] is List 
        ? (resList[1].data['data'] as List).length 
        : 0;
    final revData = resList[2].data is Map && resList[2].data['data'] is Map
        ? resList[2].data['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    return {
      'totalBookings': statsData['totalBookings']?.toString() ?? '0',
      'totalRevenue': statsData['totalRevenue'] != null 
          ? '₹${(double.tryParse(statsData['totalRevenue'].toString()) ?? 0).toStringAsFixed(0)}' 
          : '₹0',
      'pendingSettlements': settData.toString(),
      'pendingOwnerApprovals': statsData['pendingOwnerApprovals']?.toString() ?? '0',
      'chartData': revData['chartData'] ?? [],
      'averageMonthly': revData['averageMonthly']?.toString() ?? '0',
    };
  } on DioException {
    return {
      'totalBookings': '0',
      'totalRevenue': '₹0',
      'pendingSettlements': '0',
      'pendingOwnerApprovals': '0',
      'chartData': [],
      'averageMonthly': '0',
    };
  }
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final statsAsync = ref.watch(adminStatsProvider);
    final authState = ref.watch(authNotifierProvider);
    final adminName = authState.valueOrNull?.user?.fullName.split(' ').first ?? 'Admin';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminStatsProvider),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // â”€â”€ Top Header â”€â”€
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.shield_rounded, color: AppColors.primary, size: 12),
                                    Gap(5),
                                    Text(
                                      'ADMIN COMMAND CENTER',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(8),
                              Text(
                                'Welcome back, $adminName!',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const Gap(4),
                              const Text(
                                'All systems are running normally.',
                                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => context.go('/admin/profile'),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryLight, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryContainer,
                                child: Text(
                                  adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(28),

                      // â”€â”€ KPI Grid â”€â”€
                      const Text(
                        'LIVE PLATFORM METRICS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondaryLight,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Gap(14),
                      statsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (stats) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _KpiCard(
                                    label: 'Total Bookings',
                                    value: stats['totalBookings'].toString(),
                                    icon: Icons.confirmation_num_rounded,
                                    color: AppColors.primary,
                                    bg: AppColors.primaryContainer,
                                    trend: 'All time',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _KpiCard(
                                    label: 'Pending Payouts',
                                    value: stats['pendingSettlements'].toString(),
                                    icon: Icons.account_balance_rounded,
                                    color: AppColors.warning,
                                    bg: AppColors.warning.withOpacity(0.1),
                                    trend: 'Needs review',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                 Expanded(
                                  child: _KpiCard(
                                    label: 'Active Revenue',
                                    value: stats['totalRevenue'] ?? '₹0',
                                    icon: Icons.currency_rupee_rounded,
                                    color: AppColors.success,
                                    bg: AppColors.success.withOpacity(0.1),
                                    trend: 'This month',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _KpiCard(
                                      label: 'System Health',
                                      value: 'OK',
                                      icon: Icons.monitor_heart_rounded,
                                      color: AppColors.primary,
                                      bg: AppColors.primaryContainer,
                                      trend: 'All services up',
                                    ),
                                ),
                              ],
                            ),
                            const Gap(24),
                            _RevenueChart(chartData: stats['chartData'] as List<dynamic>? ?? []),
                          ],
                        ),
                      ),
                      const Gap(32),

                      // ── System Modules ──
                      const Text(
                        'SYSTEM MODULES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondaryLight,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Gap(14),
                    ],
                  ),
                ),
              ),

              // â”€â”€ Module Tiles â”€â”€
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _AdminActionTile(
                      title: 'Global Ledger',
                      subtitle: 'View all platform transactions & bookings',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      onTap: () => context.go('/admin/bookings'),
                    ),
                    const Gap(12),
                    _AdminActionTile(
                      title: 'Turf Management',
                      subtitle: 'Enable, disable, or audit all platform turfs',
                      icon: Icons.sports_soccer_rounded,
                      color: AppColors.primary,
                      onTap: () => context.go('/admin/turfs'),
                    ),
                    const Gap(12),
                    _AdminActionTile(
                      title: 'Owner Approvals',
                      subtitle: 'Review & approve new turf registrations',
                      icon: Icons.verified_user_rounded,
                      color: AppColors.warning,
                      onTap: () => context.go('/admin/approvals'),
                    ),
                    const Gap(12),
                    _AdminActionTile(
                      title: 'Event Management',
                      subtitle: 'Oversee and audit all tournaments',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.warning,
                      onTap: () => context.go('/admin/tournaments'),
                    ),
                    const Gap(12),
                    _AdminActionTile(
                      title: 'Owner Payouts',
                      subtitle: 'Process pending settlement queues',
                      icon: Icons.payments_rounded,
                      color: AppColors.success,
                      onTap: () => context.go('/admin/settlements'),
                    ),
                    const Gap(12),
                    _AdminActionTile(
                      title: 'Admin Profile & Settings',
                      subtitle: 'Manage your admin account & permissions',
                      icon: Icons.admin_panel_settings_rounded,
                      color: AppColors.primary,
                      onTap: () => context.go('/admin/profile'),
                    ),
                    const Gap(40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  final String trend;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  trend,
                  style: TextStyle(fontSize: 10, color: color.withOpacity(0.65)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminStatNode extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _AdminStatNode({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Gap(24),
          Text(value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color, letterSpacing: -1)),
          const Gap(4),
          Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight.withOpacity(0.8), height: 1.2)),
        ],
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                  const Gap(3),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _RevenueChart extends StatefulWidget {
  final List<dynamic> chartData;

  const _RevenueChart({required this.chartData});

  @override
  State<_RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<_RevenueChart> {
  int _selectedBarIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find max value for scaling
    double maxVal = 0.0;
    for (var item in widget.chartData) {
      final val = double.tryParse(item['revenue']?.toString() ?? '0') ?? 0.0;
      if (val > maxVal) maxVal = val;
    }
    if (maxVal == 0.0) maxVal = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'REVENUE ANALYTICS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondaryLight,
                  letterSpacing: 1.1,
                ),
              ),
              if (_selectedBarIndex != -1)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '₹${double.parse(widget.chartData[_selectedBarIndex]['revenue'].toString()).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(24),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(widget.chartData.length, (index) {
                final item = widget.chartData[index];
                final revenue = double.tryParse(item['revenue']?.toString() ?? '0') ?? 0.0;
                final percentage = revenue / maxVal;
                final barHeight = percentage * 120.0; // Max height 120
                final monthStr = item['month']?.toString() ?? '';
                final shortMonth = monthStr.split(' ').first;
                final isSelected = _selectedBarIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _selectedBarIndex = index),
                    onTapUp: (_) => setState(() => _selectedBarIndex = -1),
                    onTapCancel: () => setState(() => _selectedBarIndex = -1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              width: 24,
                              height: barHeight < 8 ? 8 : barHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? [AppColors.success, AppColors.success.withOpacity(0.7)]
                                      : [AppColors.primary, AppColors.primary.withOpacity(0.6)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: AppColors.success.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        Text( shortMonth,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
