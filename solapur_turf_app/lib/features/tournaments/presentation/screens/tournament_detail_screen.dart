import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../../teams/presentation/providers/team_provider.dart';
import '../../../teams/domain/entities/team.dart';

// ── Provider ──

final _tournamentDetailProvider =
    FutureProvider.autoDispose.family<Tournament, String>(
  (ref, id) async {
    final dio = ref.watch(apiClientProvider);
    try {
      final res = await dio.get('/tournaments/$id');
      final j = res.data as Map<String, dynamic>;
      return Tournament(
        tournamentId: j['tournament_id'] as String? ?? j['tournamentId'] as String? ?? '',
        name: j['name'] as String? ?? '',
        sportType: j['sport_type'] as String? ?? j['sportType'] as String? ?? '',
        format: j['format'] as String? ?? '',
        entryFee: double.tryParse((j['entry_fee'] ?? j['entryFee'] ?? 0).toString()) ?? 0,
        prizePool: j['prize_pool'] != null ? double.tryParse(j['prize_pool'].toString()) : null,
        maxTeams: (j['max_teams'] as int?) ?? (j['maxTeams'] as int?) ?? 0,
        registeredTeams: (j['registered_teams'] as int?) ?? (j['registeredTeams'] as int?) ?? 0,
        status: TournamentStatusX.fromString(j['status'] as String? ?? 'UPCOMING'),
        startDate: (j['start_date'] as String?) ?? (j['startDate'] as String?) ?? '',
        endDate: (j['end_date'] as String?) ?? (j['endDate'] as String?) ?? '',
        turfName: (j['turf'] as Map?)?['turf_name'] as String?,
        description: j['description'] as String?,
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  },
);

class TournamentDetailScreen extends ConsumerWidget {
  final String tournamentId;
  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final tAsync = ref.watch(_tournamentDetailProvider(tournamentId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: tAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
          ),
          body: AppErrorWidget(
            message: e is Failure ? e.userMessage : e.toString(),
            onRetry: () => ref.invalidate(_tournamentDetailProvider(tournamentId)),
          ),
        ),
        data: (t) {
          final isUpcoming = t.status == TournamentStatus.upcoming;
          final spotsLeft = t.maxTeams - t.registeredTeams;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ── Hero Banner ──
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: AppColors.surfaceLight,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -40,
                              top: 40,
                              child: Icon(Icons.emoji_events, size: 240, color: Colors.white.withOpacity(0.05)),
                            ),
                            Positioned(
                              left: 24,
                              bottom: 40,
                              right: 24,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      t.status.label.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  const Gap(12),
                                  Text(
                                    t.name,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Gradient fade at bottom
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.backgroundLight,
                                      AppColors.backgroundLight.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  // ── Detail Blocks ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(8),

                          // Prize Pool Block (Highlight)
                          if (t.prizePool != null && t.prizePool! > 0)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.warning.withOpacity(0.15),
                                    AppColors.warning.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.warning.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.military_tech, color: AppColors.warning, size: 32),
                                  ),
                                  const Gap(20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Grand Prize Pool',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimaryLight),
                                      ),
                                      Text(
                                        AppFormatters.formatCurrency(t.prizePool!),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.warning,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),

                          if (t.prizePool != null && t.prizePool! > 0) const Gap(24),

                          // Rules / Stats Box
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.dividerLight),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _StatWidget(icon: Icons.sports, label: 'Sport', value: AppFormatters.toTitleCase(t.sportType))),
                                    Container(width: 1, height: 40, color: AppColors.dividerLight),
                                    Expanded(child: _StatWidget(icon: Icons.hub, label: 'Format', value: AppFormatters.toTitleCase(t.format))),
                                  ],
                                ),
                                const Gap(16),
                                const Divider(color: AppColors.dividerLight, height: 1),
                                const Gap(16),
                                Row(
                                  children: [
                                    Expanded(child: _StatWidget(icon: Icons.calendar_today, label: 'Timeline', value: '${_formatDateStr(t.startDate)} - ${_formatDateStr(t.endDate)}')),
                                    Container(width: 1, height: 40, color: AppColors.dividerLight),
                                    Expanded(child: _StatWidget(icon: Icons.groups_2, label: 'Slots', value: isUpcoming ? '$spotsLeft left' : 'Full')),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Gap(24),

                          // Venue
                          const Text('Venue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                          const Gap(12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.dividerLight),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.location_on, color: AppColors.primary),
                                ),
                                const Gap(16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.turfName ?? 'Multiple Associated Venues',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                                      ),
                                      const Gap(4),
                                      const Text('Tap to view map', style: TextStyle(fontSize: 12, color: AppColors.primary, decoration: TextDecoration.underline)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          const Gap(32),

                          // About
                          if (t.description?.isNotEmpty == true) ...[
                            const Text('Rules & Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                            const Gap(12),
                            Text(
                              t.description!,
                              style: const TextStyle(fontSize: 15, color: AppColors.textSecondaryLight, height: 1.6),
                            ),
                          ],

                          const Gap(120), // Padding for Sticky Bar
                        ],
                      ),
                    ),
                  )
                ],
              ),

              // ── Sticky Join Bottom Bar ──
              if (isUpcoming)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight.withOpacity(0.85),
                          border: const Border(top: BorderSide(color: AppColors.dividerLight, width: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Team Entry Fee',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      t.entryFee == 0 ? 'FREE' : AppFormatters.formatCurrency(t.entryFee),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: t.entryFee == 0 ? AppColors.success : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                _showTeamPicker(context, ref, t);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                              ),
                              child: const Text('Enter Team', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showTeamPicker(BuildContext context, WidgetRef ref, Tournament t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Your Team', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Gap(16),
            ref.watch(myTeamsProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Text('Error loading teams: $e'),
              data: (teams) => teams.isEmpty 
                ? const Text('You are not captain of any team')
                : Column(
                    children: teams.map((team) => ListTile(
                      leading: CircleAvatar(backgroundColor: AppColors.primary, child: const Icon(Icons.group, color: Colors.white)),
                      title: Text(team.teamName),
                      subtitle: Text('${team.members?.length ?? 0} members'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        Navigator.pop(context);
                        await _handleRegistration(context, ref, t, team);
                      },
                    )).toList(),
                  ),
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegistration(BuildContext context, WidgetRef ref, Tournament t, Team team) async {
    final dio = ref.read(apiClientProvider);
    try {
      await dio.post('/tournaments/register', data: {
        'tournamentId': t.tournamentId,
        'teamId': team.teamId,
      });
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! 🎉'), backgroundColor: AppColors.success),
      );
      ref.invalidate(_tournamentDetailProvider(tournamentId));
    } on DioException catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.response?.data['message'] ?? e.message}'), backgroundColor: AppColors.error),
      );
    }
  }

  String _formatDateStr(String d) {
    try {
      return DateFormat('MMM d').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }
}

class _StatWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatWidget({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const Gap(8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
        ),
        const Gap(2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
        ),
      ],
    );
  }
}
