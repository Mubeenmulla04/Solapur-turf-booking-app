import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'owner_dynamic_pricing_screen.dart';
import 'owner_analytics_screen.dart';
import 'owner_settlement_screen.dart';

// ── Owner Stats Provider ─────────────────────────────────────────────────────

final _ownerStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    // Fetch live data directly from the owner profile
    final res = await dio.get('/owners/me');
    if (res.data != null && res.data['data'] is Map) {
      final data = res.data['data'] as Map<String, dynamic>;
      final turfIds = data['turfIds'] as List?;
      return {
        'turfId': (turfIds != null && turfIds.isNotEmpty) ? turfIds.first : null,
        'todayRevenue': data['totalEarnings'] ?? 0,
        // Mock remaining KPIs until full analytic endpoint is implemented
        'weeklyRevenue': (data['totalEarnings'] ?? 0) * 0.8, 
        'occupancyRate': 85,
        'pendingSettlements': data['pendingSettlement'] ?? 0,
      };
    }
    throw Exception('No data');
  } catch (e) {
    return {
      'todayRevenue': 0,
      'weeklyRevenue': 0,
      'occupancyRate': 0,
      'pendingSettlements': 0,
    };
  }
});

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final statsAsync = ref.watch(_ownerStatsProvider);
    final authState = ref.watch(authNotifierProvider);
    final ownerName = authState.valueOrNull?.user?.fullName.split(' ').first ?? 'Partner';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(_ownerStatsProvider),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── 1. Top Bar & Greeting ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Owner Portal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.primary,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Welcome back, $ownerName',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      // Removed redundant logout button as it exists in profile section
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(16)),

              // ── 2. KPI Hero Cards ──
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
                  child: statsAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (stats) => ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _KPIHeroCard(
                          title: "Today's Revenue",
                          value: AppFormatters.formatCurrency(
                              stats['todayRevenue']?.toDouble() ?? 0),
                          growth: '+12% from yesterday',
                          icon: Icons.currency_rupee_rounded,
                          color: AppColors.primary,
                        ),
                        const Gap(16),
                        _KPIHeroCard(
                          title: "Occupancy Rate",
                          value: "${stats['occupancyRate'] ?? 0}%",
                          growth: 'Peak hours tracked',
                          icon: Icons.data_usage_rounded,
                          color: AppColors.warning,
                        ),
                        const Gap(16),
                        _KPIHeroCard(
                          title: "Pending Settlement",
                          value: (stats['pendingSettlements'] ?? 0).toString(),
                          growth: 'Requires attention',
                          icon: Icons.account_balance_rounded,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(32)),

              // ── 3. Operations Ledger ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Operations',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight),
                      ),
                      const Gap(16),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.dividerLight),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _QuickActionTile(
                              icon: Icons.book_online_outlined,
                              title: 'Manage Bookings',
                              subtitle: 'View, approve or cancel booked slots',
                              iconBg: AppColors.primaryContainer,
                              iconColor: AppColors.primary,
                              onTap: () => context.go('/owner/bookings'),
                            ),
                            const Divider(height: 1, indent: 64),
                            _QuickActionTile(
                              icon: Icons.edit_calendar_outlined,
                              title: 'Dynamic Pricing',
                              subtitle: 'Adjust slot rates and freeze maintenance times',
                              iconBg: AppColors.warning.withOpacity(0.1),
                              iconColor: AppColors.warning,
                              onTap: () {
                                final turfId = statsAsync.valueOrNull?['turfId'];
                                if (turfId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OwnerDynamicPricingScreen(turfId: turfId),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No turf associated with this account')),
                                  );
                                }
                              },
                            ),
                            const Divider(height: 1, indent: 64),
                            _QuickActionTile(
                              icon: Icons.bar_chart_rounded,
                              title: 'Revenue Analytics',
                              subtitle: 'Top slots, sport breakdown & traffic heatmap',
                              iconBg: AppColors.primaryContainer,
                              iconColor: AppColors.primaryDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OwnerAnalyticsScreen(),
                                ),
                              ),
                            ),
                            const Divider(height: 1, indent: 64),
                            _QuickActionTile(
                              icon: Icons.account_balance_rounded,
                              title: 'Payout Settlements',
                              subtitle: 'View pending & processed payout history',
                              iconBg: AppColors.success.withOpacity(0.1),
                              iconColor: AppColors.success,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const OwnerSettlementScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(32)),

              // ── 4a. Register Turf Property Block ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.go('/owner/turfs/create'),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.15)),
                                    ),
                                    child: const Icon(Icons.stadium_rounded, color: Color(0xFF0284C7), size: 32),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('GROW', style: TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                                  ),
                                ],
                              ),
                              const Gap(20),
                              const Text('List New Turf', style: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                              const Gap(8),
                              const Text(
                                'Expand your business footprint. Register a new playground to the platform and start accepting bookings instantly.',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                              ),
                              const Gap(24),
                              Row(
                                children: [
                                  const Text('Register Property', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w800, fontSize: 15)),
                                  const Gap(8),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withOpacity(0.1), shape: BoxShape.circle),
                                    child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0EA5E9), size: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(24)),

              // ── 4. Host Tournament Block (Clean & Modern) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.go('/owner/tournaments/create'),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.15)),
                                    ),
                                    child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFD97706), size: 32),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('NEW', style: TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                                  ),
                                ],
                              ),
                              const Gap(20),
                              const Text('Host a Tournament', style: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                              const Gap(8),
                              const Text(
                                'Create massive scale events, block out your turf, and dramatically boost your weekend revenue.',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                              ),
                              const Gap(24),
                              Row(
                                children: [
                                  const Text('Create Event', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 15)),
                                  const Gap(8),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
                                    child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF10B981), size: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(32)),

              // ── 4. Analytics Snapshot (live, tappable) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Traffic Snapshot',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const OwnerAnalyticsScreen()),
                            ),
                            child: const Text('Full Report',
                                style:
                                    TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                      const Gap(8),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const OwnerAnalyticsScreen()),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryContainer,
                                AppColors.primaryContainer.withOpacity(0.5)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                    Icons.bar_chart_rounded,
                                    color: Colors.white,
                                    size: 28),
                              ),
                              const Gap(16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'View Full Analytics',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    Gap(4),
                                    Text(
                                      'Heatmap, Top Slots & Sport Breakdown',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppColors.primaryDark),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(40)),
            ],
          ),
        ),
      ),
    );
  }
}

class _KPIHeroCard extends StatelessWidget {
  final String title;
  final String value;
  final String growth;
  final IconData icon;
  final Color color;

  const _KPIHeroCard({
    required this.title,
    required this.value,
    required this.growth,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const Gap(12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: color,
            ),
          ),
          const Gap(4),
          Text(
            growth,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}


