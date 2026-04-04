import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tournament.dart';

class BracketMatchCard extends StatelessWidget {
  final TournamentMatch match;
  final VoidCallback? onTap;

  const BracketMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLive = match.status == TournamentMatchStatus.live;
    final bool isCompleted = match.status == TournamentMatchStatus.completed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLive ? AppColors.primary : AppColors.dividerLight,
            width: isLive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Status / Match #
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Match #${match.matchNumber}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(8),

            // Team A
            _buildTeamRow(
              match.teamA?.teamName ?? 'TBD',
              match.scoreA,
              match.winnerId == match.teamA?.teamId && isCompleted,
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Divider(height: 1, thickness: 0.5),
            ),

            // Team B
            _buildTeamRow(
              match.teamB?.teamName ?? 'TBD',
              match.scoreB,
              match.winnerId == match.teamB?.teamId && isCompleted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(String name, int? score, bool isWinner) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isWinner ? FontWeight.w900 : FontWeight.w600,
              color: isWinner ? AppColors.primary : AppColors.textPrimaryLight,
            ),
          ),
        ),
        Text(
          score?.toString() ?? '-',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isWinner ? AppColors.primary : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
