import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';

// ── Provider ───────────────────────────────────────────────────────────────────

final _ownerSettlementsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('settlement/owner');
    final data = res.data is Map ? res.data['data'] : res.data;
    final list = (data is List ? data : []) as List;
    return list.cast<Map<String, dynamic>>();
  } on DioException catch (e) {
    throw AppException.fromDioException(e);
  }
});

// ── Screen ─────────────────────────────────────────────────────────────────────

class OwnerSettlementScreen extends ConsumerWidget {
  const OwnerSettlementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final settlementsAsync = ref.watch(_ownerSettlementsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              backgroundColor: AppColors.backgroundLight,
              elevation: 0,
              pinned: true,
              expandedHeight: 120,
              iconTheme:
                  const IconThemeData(color: AppColors.textPrimaryLight),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                title: const Text(
                  'Payout History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
          ],
          body: settlementsAsync.when(
            loading: () => const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => AppErrorWidget(
              message: e is Failure ? e.userMessage : e.toString(),
              onRetry: () => ref.invalidate(_ownerSettlementsProvider),
            ),
            data: (list) => list.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'No settlements yet',
                    subtitle:
                        'Your payouts from the platform will appear here.',
                  )
                : _SettlementBody(list: list, ref: ref),
          ),
        ),
      ),
    );
  }
}

// ── Body with summary header + list ───────────────────────────────────────────

class _SettlementBody extends StatelessWidget {
  final List<Map<String, dynamic>> list;
  final WidgetRef ref;
  const _SettlementBody({required this.list, required this.ref});

  @override
  Widget build(BuildContext context) {
    final totalEarned = list.fold<double>(
        0,
        (acc, s) =>
            acc +
            (double.tryParse(
                    (s['settlementAmount'] ?? 0).toString()) ??
                0));
    final pending = list
        .where((s) =>
            (s['status'] as String?)?.toUpperCase() == 'PENDING')
        .length;
    final processed = list
        .where((s) =>
            (s['status'] as String?)?.toUpperCase() == 'COMPLETED')
        .length;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(_ownerSettlementsProvider),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Summary Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // Total Earnings Hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primary
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Paid Out',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          AppFormatters.formatCurrency(totalEarned),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const Gap(16),
                        Row(
                          children: [
                            _MiniChip(
                                '$processed processed', AppColors.success),
                            const Gap(10),
                            _MiniChip(
                                '$pending pending', AppColors.warning),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'STATEMENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondaryLight,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const Gap(12),
                ],
              ),
            ),
          ),

          // ── Settlement Cards ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _OwnerSettlementCard(data: list[i]),
                ),
                childCount: list.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String text;
  final Color color;
  const _MiniChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Settlement Card ───────────────────────────────────────────────────────────

class _OwnerSettlementCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OwnerSettlementCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(
            (data['settlementAmount'] ?? 0).toString()) ??
        0;
    final commission =
        double.tryParse((data['commissionAmount'] ?? 0).toString()) ??
            0;
    final status = (data['status'] as String?)?.toUpperCase() ?? 'PENDING';
    final isProcessed = status == 'COMPLETED';
    final accent = isProcessed ? AppColors.success : AppColors.warning;

    // Period
    String period = '';
    try {
      final start = data['periodStart']?.toString() ?? '';
      final end = data['periodEnd']?.toString() ?? '';
      if (start.isNotEmpty && end.isNotEmpty) {
        period =
            '${AppFormatters.formatDate(DateTime.parse(start))} – ${AppFormatters.formatDate(DateTime.parse(end))}';
      }
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isProcessed
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    color: accent,
                    size: 18,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isProcessed
                            ? 'Payout Processed'
                            : 'Pending Settlement',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      if (period.isNotEmpty) ...[
                        const Gap(2),
                        Text(
                          period,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isProcessed ? 'PAID' : 'PENDING',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
              height: 20,
              indent: 16,
              endIndent: 16,
              color: AppColors.dividerLight),

          // ── Finance Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _MoneyBlock('Your Payout', amount, AppColors.success),
                ),
                const Gap(12),
                Expanded(
                  child: _MoneyBlock(
                      'Platform Fee', commission, AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),

          // ── Bank ref if available ──
          if (data['bankReference'] != null &&
              data['bankReference'].toString().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      size: 14, color: AppColors.textHint),
                  const Gap(8),
                  Text(
                    'Ref: ${data['bankReference']}',
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoneyBlock extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _MoneyBlock(this.label, this.amount, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                  letterSpacing: 0.5)),
          const Gap(5),
          Text(AppFormatters.formatCurrency(amount),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color)),
        ],
      ),
    );
  }
}
