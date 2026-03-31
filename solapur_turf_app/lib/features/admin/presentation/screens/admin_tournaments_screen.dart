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

final _adminTournamentsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/tournaments', queryParameters: {'limit': 50});
    final list = (res.data is Map ? res.data['data'] : res.data) as List;
    return list.cast<Map<String, dynamic>>();
  } on DioException catch (e) {
    throw AppException.fromDioException(e);
  }
});

class AdminTournamentsScreen extends ConsumerWidget {
  const AdminTournamentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final tAsync = ref.watch(_adminTournamentsProvider);

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
                  'Event Infrastructure',
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
                      icon: const Icon(Icons.settings_suggest_rounded, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ],
          body: tAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => AppErrorWidget(
              message: e is Failure ? e.userMessage : e.toString(),
              onRetry: () => ref.invalidate(_adminTournamentsProvider),
            ),
            data: (list) => list.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.emoji_events_outlined,
                    title: 'No System Events',
                    subtitle: 'Create tournaments under the admin/owner portal.',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(_adminTournamentsProvider),
                    color: AppColors.primary,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _AdminTournamentTile(j: list[i]),
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
}

class _AdminTournamentTile extends StatelessWidget {
  final Map<String, dynamic> j;
  const _AdminTournamentTile({required this.j});

  @override
  Widget build(BuildContext context) {
    final name = j['name'] as String? ?? '';
    final sport = j['sport_type'] as String? ?? j['sportType'] as String? ?? '';
    final status = j['status'] as String? ?? 'UPCOMING';
    final fee = double.tryParse((j['entry_fee'] ?? j['entryFee'] ?? 0).toString()) ?? 0;
    final registered = (j['registered_teams'] as int?) ?? (j['registeredTeams'] as int?) ?? 0;
    final max = (j['max_teams'] as int?) ?? (j['maxTeams'] as int?) ?? 0;
    final start = j['start_date'] as String? ?? j['startDate'] as String? ?? '';

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
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.warning),
                    ),
                    const Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimaryLight),
                        ),
                        Text(
                          AppFormatters.toTitleCase(sport),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.toUpperCase() == 'UPCOMING'
                        ? AppColors.primary
                        : status.toUpperCase() == 'ONGOING'
                            ? AppColors.statusInProgress
                            : AppColors.statusCompleted,
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

          // ── Data Matrix ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _DataRow(Icons.calendar_month, 'Start Date', _fmt(start))),
                    Container(width: 1, height: 30, color: AppColors.dividerLight),
                    const Gap(16),
                    Expanded(child: _DataRow(Icons.payments_rounded, 'Entry Fee', AppFormatters.formatCurrency(fee))),
                  ],
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.groups_rounded, size: 20, color: AppColors.primary),
                      const Gap(12),
                      const Text(
                        'Team Capacity Fill Rate',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                      ),
                      const Spacer(),
                      Text(
                        '$registered / $max',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(String d) {
    try { return AppFormatters.formatDate(DateTime.parse(d)); } catch (_) { return d; }
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DataRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textHint),
            const Gap(4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
          ],
        ),
        const Gap(4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
      ],
    );
  }
}
