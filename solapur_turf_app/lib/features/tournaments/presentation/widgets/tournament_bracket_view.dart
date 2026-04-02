import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tournament.dart';
import 'bracket_match_card.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'update_score_modal.dart';

class TournamentBracketView extends ConsumerWidget {
  final List<TournamentMatch> matches;
  final Future<void> Function() onRefresh;

  const TournamentBracketView({
    super.key,
    required this.matches,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_outlined, size: 64, color: AppColors.textSecondaryLight.withOpacity(0.5)),
            const Gap(16),
            const Text('Bracket not generated yet', style: TextStyle(color: AppColors.textSecondaryLight)),
          ],
        ),
      );
    }

    final userRole = ref.watch(authNotifierProvider).value?.role;
    final isManager = userRole == 'OWNER' || userRole == 'ADMIN';

    // Group matches by round
    final groupedMatches = <int, List<TournamentMatch>>{};
    for (var m in matches) {
      groupedMatches.putIfAbsent(m.round, () => []).add(m);
    }
    
    final rounds = groupedMatches.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rounds.map((round) {
            final roundMatches = groupedMatches[round]!;
            return Padding(
              padding: const EdgeInsets.only(right: 48),
              child: Column(
                children: [
                  Text(
                    _getRoundName(round, rounds.length),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const Gap(24),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: roundMatches.map((m) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: _getVerticalPadding(round, rounds.length),
                        ),
                        child: BracketMatchCard(
                          match: m,
                          onTap: isManager ? () => _showUpdateScore(context, m) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUpdateScore(BuildContext context, TournamentMatch match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateScoreModal(
        tournamentId: match.tournamentId,
        match: match,
      ),
    );
  }

  String _getRoundName(int round, int totalRounds) {
    if (round == totalRounds) return 'FINAL';
    if (round == totalRounds - 1) return 'SEMI-FINAL';
    if (round == totalRounds - 2) return 'QUARTER-FINAL';
    return 'ROUND $round';
  }

  double _getVerticalPadding(int round, int totalRounds) {
    // Basic logic to space out matches dynamically by round
    if (round == 1) return 8;
    if (round == 2) return 40;
    if (round == 3) return 80;
    return 120;
  }
}
