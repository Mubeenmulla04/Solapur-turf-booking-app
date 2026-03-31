import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/tournament.dart';

// ── Provider & Data Mapping ──

final _tournamentsProvider =
    FutureProvider.autoDispose<List<Tournament>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/tournaments');
    final list = (res.data is Map ? res.data['data'] : res.data) as List;
    return list.map((j) => _map(j as Map<String, dynamic>)).toList();
  } on DioException catch (e) {
    throw AppException.fromDioException(e);
  }
});

Tournament _map(Map<String, dynamic> j) => Tournament(
      tournamentId: j['tournament_id'] as String? ??
          j['tournamentId'] as String? ?? '',
      name: j['name'] as String? ?? '',
      sportType: j['sport_type'] as String? ?? j['sportType'] as String? ?? '',
      format: j['format'] as String? ?? '',
      entryFee:
          double.tryParse((j['entry_fee'] ?? j['entryFee'] ?? 0).toString()) ??
              0,
      prizePool: j['prize_pool'] != null
          ? double.tryParse(j['prize_pool'].toString())
          : null,
      maxTeams: (j['max_teams'] as int?) ?? (j['maxTeams'] as int?) ?? 0,
      registeredTeams:
          (j['registered_teams'] as int?) ?? (j['registeredTeams'] as int?) ?? 0,
      status: TournamentStatusX.fromString(
          j['status'] as String? ?? 'UPCOMING'),
      startDate: (j['start_date'] as String?) ??
          (j['startDate'] as String?) ?? '',
      endDate:
          (j['end_date'] as String?) ?? (j['endDate'] as String?) ?? '',
      turfName: (j['turf'] as Map?)?['turf_name'] as String?,
      description: j['description'] as String?,
    );

class TournamentListScreen extends ConsumerStatefulWidget {
  const TournamentListScreen({super.key});

  @override
  ConsumerState<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends ConsumerState<TournamentListScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final tournsAsync = ref.watch(_tournamentsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(_tournamentsProvider),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Compete & Win',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.primary,
                            ),
                          ),
                          const Gap(4),
                          const Text(
                            'Tournaments',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.dividerLight),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.stars_rounded, color: AppColors.warning),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(children: [
                                  Icon(Icons.stars_rounded, color: AppColors.warning),
                                  Gap(10),
                                  Text('Leaderboard feature coming soon!'),
                                ]),
                                backgroundColor: AppColors.primaryDark,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // ── Filters Widget ──
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Upcoming', 'Ongoing', 'High Prize']
                        .map(
                          (filter) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _FilterPill(
                              label: filter,
                              isSelected: _selectedFilter == filter,
                              onTap: () => setState(() => _selectedFilter = filter),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(24)),

              // ── Tournament List ──
              tournsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: AppErrorWidget(
                    message: e is Failure ? e.userMessage : e.toString(),
                    onRetry: () => ref.invalidate(_tournamentsProvider),
                  ),
                ),
                data: (list) {
                  // Basic client side filtering for demo
                  var filteredList = list;
                  if (_selectedFilter == 'Upcoming') {
                    filteredList = list.where((t) => t.status == TournamentStatus.upcoming).toList();
                  } else if (_selectedFilter == 'Ongoing') {
                    filteredList = list.where((t) => t.status == TournamentStatus.ongoing).toList();
                  } else if (_selectedFilter == 'High Prize') {
                    filteredList = list.where((t) => (t.prizePool ?? 0) >= 5000).toList();
                  }

                  if (filteredList.isEmpty) {
                    return const SliverFillRemaining(
                      child: EmptyStateWidget(
                        icon: Icons.emoji_events_outlined,
                        title: 'No Tournaments Found',
                        subtitle: 'Check back later or try changing filters.',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _PremiumTournamentCard(tournament: filteredList[i]),
                        ),
                        childCount: filteredList.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: Gap(40)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared UI Widgets ──

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimaryLight : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.textPrimaryLight : AppColors.dividerLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.textPrimaryLight.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}

class _PremiumTournamentCard extends StatelessWidget {
  final Tournament tournament;
  const _PremiumTournamentCard({required this.tournament});

  Color get _statusColor => switch (tournament.status) {
        TournamentStatus.upcoming => AppColors.primary,
        TournamentStatus.ongoing => AppColors.warning,
        TournamentStatus.completed => AppColors.textSecondaryLight,
        TournamentStatus.cancelled => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final isUpcoming = tournament.status == TournamentStatus.upcoming;
    final spotsLeft = tournament.maxTeams - tournament.registeredTeams;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.go('/user/tournaments/${tournament.tournamentId}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Upper Graphic Banner ──
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Stack(
                  children: [
                    // Faint background graphic
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Icon(Icons.emoji_events, size: 160, color: Colors.white.withOpacity(0.1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  AppFormatters.toTitleCase(tournament.sportType),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tournament.status.label.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tournament.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.white70),
                                  const Gap(4),
                                  Expanded(
                                    child: Text(
                                      tournament.turfName ?? 'Multiple Venues',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Details Section ──
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DetailMetric(
                          icon: Icons.calendar_month,
                          title: 'Starts',
                          value: _formatDate(tournament.startDate),
                        ),
                        _DetailMetric(
                          icon: Icons.groups,
                          title: 'Spots Left',
                          value: isUpcoming ? '$spotsLeft / ${tournament.maxTeams}' : 'Closed',
                        ),
                        _DetailMetric(
                          icon: Icons.payments,
                          title: 'Entry Fee',
                          value: tournament.entryFee == 0 
                              ? 'FREE' 
                              : AppFormatters.formatCurrency(tournament.entryFee),
                          valueColor: tournament.entryFee == 0 ? AppColors.success : null,
                        ),
                      ],
                    ),
                    if (tournament.prizePool != null && tournament.prizePool! > 0) ...[
                      const Gap(20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.military_tech, color: AppColors.warning),
                            const Gap(8),
                            const Text(
                              'Prize Pool: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              AppFormatters.formatCurrency(tournament.prizePool!),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return dateStr.isNotEmpty ? dateStr : 'TBA';
    }
  }
}

class _DetailMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _DetailMetric({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textHint),
            const Gap(4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const Gap(6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
