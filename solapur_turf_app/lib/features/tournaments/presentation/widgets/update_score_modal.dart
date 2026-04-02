import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tournament.dart';
import '../providers/tournament_matches_provider.dart';

class UpdateScoreModal extends ConsumerStatefulWidget {
  final String tournamentId;
  final TournamentMatch match;

  const UpdateScoreModal({
    super.key,
    required this.tournamentId,
    required this.match,
  });

  @override
  ConsumerState<UpdateScoreModal> createState() => _UpdateScoreModalState();
}

class _UpdateScoreModalState extends ConsumerState<UpdateScoreModal> {
  late final TextEditingController _scoreAController;
  late final TextEditingController _scoreBController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _scoreAController = TextEditingController(text: (widget.match.scoreA ?? 0).toString());
    _scoreBController = TextEditingController(text: (widget.match.scoreB ?? 0).toString());
  }

  @override
  void dispose() {
    _scoreAController.dispose();
    _scoreBController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final sA = int.tryParse(_scoreAController.text);
    final sB = int.tryParse(_scoreBController.text);

    if (sA == null || sB == null) return;
    if (sA == sB) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Knockout matches cannot end in a draw!'))
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      await ref.read(tournamentMatchesProvider(widget.tournamentId).notifier)
          .updateMatchScore(widget.match.matchId, sA, sB);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enter Match Result',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: _ScoreInput(
                  teamName: widget.match.teamA?.name ?? 'TBD',
                  controller: _scoreAController,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight)),
              ),
              Expanded(
                child: _ScoreInput(
                  teamName: widget.match.teamB?.name ?? 'TBD',
                  controller: _scoreBController,
                ),
              ),
            ],
          ),
          const Gap(32),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSubmitting 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Confirm Result', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ScoreInput extends StatelessWidget {
  final String teamName;
  final TextEditingController controller;

  const _ScoreInput({required this.teamName, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(teamName, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        const Gap(12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
