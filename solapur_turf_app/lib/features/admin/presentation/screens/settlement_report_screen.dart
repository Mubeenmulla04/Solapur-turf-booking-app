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

final _settlementProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/settlement/pending');
    final list = (res.data is Map ? res.data['data'] : res.data) as List;
    return list.cast<Map<String, dynamic>>();
  } on DioException catch (e) {
    throw AppException.fromDioException(e);
  }
});

class SettlementReportScreen extends ConsumerWidget {
  const SettlementReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final settlementsAsync = ref.watch(_settlementProvider);

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
              iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                title: const Text(
                  'Payout Settlement',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ],
          body: settlementsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => AppErrorWidget(
              message: e is Failure ? e.userMessage : e.toString(),
              onRetry: () => ref.invalidate(_settlementProvider),
            ),
            data: (list) => list.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Ledgers Clear',
                    subtitle: 'No pending settlements requiring authorization.',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(_settlementProvider),
                    color: AppColors.primary,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _SettlementCard(
                                  data: list[i],
                                  onProcess: () => _processSettlement(context, ref, list[i]),
                                ),
                              ),
                              childCount: list.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _processSettlement(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> settlement,
  ) async {
    HapticFeedback.lightImpact();
    final txnCtrl = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surfaceLight,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security_rounded, color: AppColors.primary),
                  ),
                  const Gap(16),
                  const Expanded(
                    child: Text('Process Escrow', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                  )
                ],
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Transfer:', style: TextStyle(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
                  Text(
                    AppFormatters.formatCurrency(double.tryParse((settlement['amount'] ?? 0).toString()) ?? 0),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ],
              ),
              const Gap(24),
              TextField(
                controller: txnCtrl,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Bank Transaction UTR / ID',
                  labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.dividerLight)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.dividerLight)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                ),
              ),
              const Gap(32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: AppColors.dividerLight),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Authorize', style: TextStyle(color: AppColors.backgroundLight, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      final id = settlement['settlement_id'] as String? ?? settlement['settlementId'] as String? ?? '';
      await ref.read(apiClientProvider).post('/settlement/$id/mark-processed', data: {
        'bankTransactionId': txnCtrl.text.trim(),
      });
      ref.invalidate(_settlementProvider);
      
      if (context.mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settlement Executed successfully ✓'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _SettlementCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onProcess;

  const _SettlementCard({required this.data, required this.onProcess});

  @override
  Widget build(BuildContext context) {
    final owner = data['turf_owner'] as Map<String, dynamic>? ?? data['turfOwner'] as Map<String, dynamic>? ?? {};
    final ownerName = (owner['user'] as Map?)?['full_name'] as String? ?? (owner['user'] as Map?)?['fullName'] as String? ?? 'Owner';
    final amount = double.tryParse((data['amount'] ?? 0).toString()) ?? 0;
    final commission = double.tryParse((data['commission_amount'] ?? data['commissionAmount'] ?? 0).toString()) ?? 0;
    final status = data['status'] as String? ?? 'PENDING';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Segment ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_rounded, size: 16, color: AppColors.primary),
                    ),
                    const Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ownerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimaryLight),
                        ),
                        const Text(
                          'TURF OWNER ENTITY',
                          style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.toUpperCase() == 'PROCESSED' ? AppColors.success : AppColors.warning,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppFormatters.toTitleCase(status),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: AppColors.dividerLight),

          // ── Finance Blocks ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('To Transfer', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.bold)),
                        const Gap(4),
                        Text(
                          AppFormatters.formatCurrency(amount),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariantLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('System Cut', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.bold)),
                        const Gap(4),
                        Text(
                          AppFormatters.formatCurrency(commission),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Action ──
          if (status.toUpperCase() != 'PROCESSED') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onProcess,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppColors.primary),
                    backgroundColor: AppColors.primaryContainer.withOpacity(0.2),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_rounded, size: 18, color: AppColors.primary),
                      Gap(8),
                      Text('Initiate Transfer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
