import 'dart:ui';
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
import '../../domain/entities/team.dart';

// ── Provider ──

final _teamDetailProvider =
    FutureProvider.autoDispose.family<Team, String>((ref, teamId) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/teams/$teamId');
    final j = res.data as Map<String, dynamic>;
    final members = (j['members'] as List<dynamic>? ?? []).map((m) {
      final mu = m as Map<String, dynamic>;
      return TeamMember(
        userId: mu['user_id'] as String? ?? mu['userId'] as String? ?? '',
        fullName: mu['full_name'] as String? ?? mu['fullName'] as String? ?? '',
        email: mu['email'] as String? ?? '',
        role: (mu['role'] as String?) == 'ADMIN'
            ? TeamMemberRole.admin
            : TeamMemberRole.member,
      );
    }).toList();
    return Team(
      teamId: j['team_id'] as String? ?? j['teamId'] as String? ?? '',
      teamName: j['team_name'] as String? ?? j['teamName'] as String? ?? '',
      teamCode: j['team_code'] as String? ?? j['teamCode'] as String? ?? '',
      sportType: j['sport_type'] as String? ?? j['sportType'] as String? ?? '',
      description: j['description'] as String?,
      logoUrl: j['logo_url'] as String?,
      homeCity: j['home_city'] as String? ?? j['homeCity'] as String?,
      memberCount: members.length,
      members: members,
    );
  } on DioException catch (e) {
    throw AppException.fromDioException(e);
  }
});

class TeamDetailScreen extends ConsumerWidget {
  final String teamId;
  const TeamDetailScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final teamAsync = ref.watch(_teamDetailProvider(teamId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          )
        ],
      ),
      body: teamAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => AppErrorWidget(
          message: e is Failure ? e.userMessage : e.toString(),
          onRetry: () => ref.invalidate(_teamDetailProvider(teamId)),
        ),
        data: (team) => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Team Crest & Main Info ──
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      team.teamName.isNotEmpty ? team.teamName[0].toUpperCase() : 'T',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Gap(24),
                  Text(
                    team.teamName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    AppFormatters.toTitleCase(team.sportType),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                      letterSpacing: 2,
                    ),
                  ),
                  const Gap(24),

                  // ── Action Grid ──
                  Row(
                    children: [
                      Expanded(
                        child: _TeamActionCard(
                          icon: Icons.qr_code_rounded,
                          label: 'Share Join Code',
                          color: AppColors.textPrimaryLight,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Team Code ${team.teamCode} copied!')),
                            );
                          },
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: _TeamActionCard(
                          icon: Icons.emoji_events_rounded,
                          label: 'View Stats',
                          color: AppColors.primaryDark,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  
                  const Gap(32),

                  // ── Description Box ──
                  if (team.description?.isNotEmpty == true || (team.homeCity != null && team.homeCity!.isNotEmpty)) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('About the Club', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const Gap(12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.dividerLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (team.homeCity != null && team.homeCity!.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.location_city, size: 16, color: AppColors.textSecondaryLight),
                                const Gap(8),
                                Text(
                                  'Based in ${team.homeCity}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
                                ),
                              ],
                            ),
                            if (team.description?.isNotEmpty == true) const Gap(16),
                          ],
                          if (team.description?.isNotEmpty == true)
                            Text(
                              team.description!,
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight, height: 1.5),
                            ),
                        ],
                      ),
                    ),
                    const Gap(32),
                  ],

                  // ── Team Roster ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Roster', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariantLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${team.memberCount} Mates',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  
                  if (team.members != null)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.dividerLight),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: team.members!.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, indent: 70, color: AppColors.dividerLight),
                        itemBuilder: (context, index) {
                          final member = team.members![index];
                          final isAdmin = member.role == TeamMemberRole.admin;
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isAdmin ? AppColors.primaryContainer : AppColors.surfaceVariantLight,
                                  child: Text(
                                    member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : 'P',
                                    style: TextStyle(
                                      color: isAdmin ? AppColors.primary : AppColors.textSecondaryLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Gap(16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.fullName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        member.email,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isAdmin)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                    ),
                                    child: const Text('CAPTAIN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 1.1)),
                                  )
                                else
                                  const Icon(Icons.more_horiz, color: AppColors.textHint, size: 20),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                  const Gap(120), // Padding for Add Member Button
                ],
              ),
            ),
            
            // ── Sticky Floating Action Bar ──
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                      },
                      icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                      label: const Text('Invite Player', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TeamActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Gap(12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
