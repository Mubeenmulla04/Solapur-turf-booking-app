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
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'owner_dynamic_pricing_screen.dart';
import 'owner_analytics_screen.dart';
import 'owner_settlement_screen.dart';

// ── Owner Stats Provider ─────────────────────────────────────────────────────

final ownerStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    // Fetch live profile and actual backend stats in parallel
    final resList = await Future.wait([
      dio.get('/owners/me'),
      dio.get('/bookings/owner-stats'),
    ]);
    
    final meRes = resList[0];
    final statsRes = resList[1];

    if (meRes.data != null && meRes.data['data'] is Map) {
      final meData = meRes.data['data'] as Map<String, dynamic>;
      final statsData = statsRes.data['data'] as Map<String, dynamic>? ?? {};
      final turfIds = meData['turfIds'] as List?;
      
      return {
        'turfId': (turfIds != null && turfIds.isNotEmpty) ? turfIds.first : null,
        'todayRevenue': statsData['todayRevenue'] ?? 0,
        'weeklyRevenue': statsData['weeklyRevenue'] ?? 0,
        'occupancyRate': statsData['occupancyRate'] ?? 0,
        'pendingSettlements': statsData['pendingSettlements'] ?? 0,
        'subscriptionStatus': meData['subscriptionStatus'] ?? 'TRIAL',
        'trialEndsAt': meData['trialEndsAt'],
        'subscriptionExpiresAt': meData['subscriptionExpiresAt'],
      };
    }
    throw Exception('No data');
  } catch (e) {
    return {
      'todayRevenue': 0,
      'weeklyRevenue': 0,
      'occupancyRate': 0,
      'pendingSettlements': 0,
      'subscriptionStatus': 'TRIAL',
    };
  }
});

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/owners/me/renew', data: {
        'razorpayPaymentId': response.paymentId,
        'razorpayOrderId': response.orderId,
        'razorpaySignature': response.signature,
      });
      ref.invalidate(ownerStatsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Subscription renewed successfully! Your listings are now active.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activation failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${response.message}'), backgroundColor: AppColors.error),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> _openSubscriptionPayment() async {
    try {
      final dio = ref.read(apiClientProvider);
      final res = await dio.post('/owners/me/subscription/order');
      final data = res.data['data'] as Map<String, dynamic>;
      final options = {
        'key': data['keyId'] ?? 'rzp_test_1DP5mmOlF5G5ag',
        'amount': data['amount'] ?? 69900,
        'name': 'Solapur Turf Platform',
        'description': 'Monthly Subscription — ₹699/month',
        'order_id': data['orderId'],
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#4CAF50'},
      };
      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not initiate payment: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final statsAsync = ref.watch(ownerStatsProvider);
    final authState = ref.watch(authNotifierProvider);
    final ownerName = authState.valueOrNull?.user?.fullName.split(' ').first ?? 'Partner';

    if (statsAsync.valueOrNull != null) {
      final stats = statsAsync.valueOrNull!;
      final subStatus = stats['subscriptionStatus'] ?? 'TRIAL';
      
      if (subStatus == 'EXPIRED') {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.block_rounded, size: 64, color: AppColors.error),
                  ),
                  const Gap(24),
                  const Text(
                    'Subscription Expired',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                  ),
                  const Gap(12),
                  const Text(
                    'Your free trial has completed. To reactivate your turf listings and continue receiving bookings, please renew your monthly subscription.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight, height: 1.5),
                  ),
                  const Gap(32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Monthly Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('₹699 / month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const Gap(32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _openSubscriptionPayment(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Renew Subscription (₹699)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Gap(16),
                  TextButton(
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).logout();
                      context.go('/login');
                    },
                    child: const Text('Logout', style: TextStyle(color: AppColors.textSecondaryLight)),
                  )
                ],
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(ownerStatsProvider),
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

              if (statsAsync.valueOrNull != null) ...[
                _buildTrialBanner(context, ref, statsAsync.valueOrNull!),
              ],

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
                              icon: Icons.stadium_rounded,
                              title: 'Manage Turfs',
                              subtitle: 'View, update, or remove your listed turfs',
                              iconBg: AppColors.primaryContainer,
                              iconColor: AppColors.primary,
                              onTap: () => context.go('/owner/turfs'),
                            ),
                            const Divider(height: 1, indent: 64),
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
                              iconBg: AppColors.secondaryContainer,
                              iconColor: AppColors.secondary,
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
                              iconColor: AppColors.primary,
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
                              iconBg: AppColors.primaryContainer,
                              iconColor: AppColors.primary,
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
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
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.stadium_rounded, color: Colors.white, size: 32),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('GROW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                                  ),
                                ],
                              ),
                              const Gap(20),
                              const Text('List New Turf', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                              const Gap(8),
                              const Text(
                                'Expand your business footprint. Register a new playground to the platform and start accepting bookings instantly.',
                                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                              ),
                              const Gap(24),
                              Row(
                                children: [
                                  const Text('Register Property', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                                  const Gap(8),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
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
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.dividerLight, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
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
                                      color: AppColors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.emoji_events_rounded, color: AppColors.secondary, size: 32),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariantLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('NEW', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                                  ),
                                ],
                              ),
                              const Gap(20),
                              const Text('Host a Tournament', style: TextStyle(color: AppColors.textPrimaryLight, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                              const Gap(8),
                              const Text(
                                'Create massive scale events, block out your turf, and dramatically boost your weekend revenue.',
                                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                              ),
                              const Gap(24),
                              Row(
                                children: [
                                  const Text('Create Event', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)),
                                  const Gap(8),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                                    child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 16),
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

  Widget _buildTrialBanner(BuildContext context, WidgetRef ref, Map<String, dynamic> stats) {
    final subStatus = stats['subscriptionStatus'] ?? 'TRIAL';
    final trialEndsAtStr = stats['trialEndsAt'];
    if (subStatus != 'TRIAL' || trialEndsAtStr == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    try {
      final trialEndsAt = DateTime.parse(trialEndsAtStr);
      final daysLeft = trialEndsAt.difference(DateTime.now()).inDays;
      if (daysLeft < 0 || daysLeft > 10) return const SliverToBoxAdapter(child: SizedBox.shrink());

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Your free trial ends in $daysLeft days. Renew now to avoid any booking interruption.',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
                  ),
                ),
                TextButton(
                  onPressed: () => _openSubscriptionPayment(),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: const Text('Activate', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (_) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
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


