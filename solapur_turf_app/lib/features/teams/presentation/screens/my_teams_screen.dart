import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/team.dart';

// ── Remote Data & Provider ──

final _teamsProvider = FutureProvider.autoDispose<List<Team>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/teams/my-teams');
    final list = (res.data is Map ? res.data['data'] : res.data) as List;
    return list.map((j) => _mapTeam(j as Map<String, dynamic>)).toList();
  } on DioException catch (e) {
    throw AppException.fromDioException(e);
  }
});

Team _mapTeam(Map<String, dynamic> j) => Team(
      teamId: j['team_id'] as String? ?? j['teamId'] as String? ?? '',
      teamName: j['team_name'] as String? ?? j['teamName'] as String? ?? '',
      teamCode: j['team_code'] as String? ?? j['teamCode'] as String? ?? '',
      sportType: j['sport_type'] as String? ?? j['sportType'] as String? ?? '',
      description: j['description'] as String?,
      logoUrl: j['logo_url'] as String?,
      homeCity: j['home_city'] as String? ?? j['homeCity'] as String?,
      memberCount: (j['member_count'] as int?) ??
          (j['memberCount'] as int?) ??
          (j['members'] as List?)?.length ??
          0,
    );

class MyTeamsScreen extends ConsumerWidget {
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final teamsAsync = ref.watch(_teamsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: AppColors.backgroundLight,
              elevation: 0,
              pinned: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                title: const Text(
                  'My Squads',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.group_add_rounded, color: AppColors.primary),
                      tooltip: 'Join Team',
                      onPressed: () => context.go('/user/teams/join'),
                    ),
                  ),
                ),
              ],
            ),
          ],
          body: teamsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => AppErrorWidget(
              message: e is Failure ? e.userMessage : e.toString(),
              onRetry: () => ref.invalidate(_teamsProvider),
            ),
            data: (teams) => teams.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.dividerLight),
                          ),
                          child: const Icon(Icons.groups_rounded,
                              size: 64, color: AppColors.textHint),
                        ),
                        const Gap(24),
                        const Text(
                          'No active squads',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const Gap(8),
                        const Text(
                          'Create your own club or join an existing one.',
                          style: TextStyle(color: AppColors.textSecondaryLight),
                        ),
                        const Gap(32),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/user/teams/create'),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Squad', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        )
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(_teamsProvider),
                    color: AppColors.primary,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _TeamCard(team: teams[i]),
                              ),
                              childCount: teams.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
      floatingActionButton: teamsAsync.maybeWhen(
        data: (teams) => teams.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => context.go('/user/teams/create'),
                label: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                icon: const Icon(Icons.add, color: Colors.white),
                backgroundColor: AppColors.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final Team team;
  const _TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            context.go('/user/teams/${team.teamId}');
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Team Crest/Logo Map
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Center(
                    child: Text(
                      team.teamName.isNotEmpty ? team.teamName[0].toUpperCase() : 'T',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                
                // Team Meta Data
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              team.teamName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariantLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.dividerLight),
                            ),
                            child: Text(
                              team.teamCode,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        AppFormatters.toTitleCase(team.sportType),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people_rounded, size: 14, color: AppColors.textHint),
                                const Gap(6),
                                Text(
                                  '${team.memberCount} Mates',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (team.homeCity != null && team.homeCity!.isNotEmpty) ...[
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_city_rounded, size: 14, color: AppColors.textHint),
                                  const Gap(6),
                                  Text(
                                    team.homeCity!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
