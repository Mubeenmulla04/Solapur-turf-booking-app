import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/team_provider.dart';

class JoinTeamScreen extends ConsumerStatefulWidget {
  const JoinTeamScreen({super.key});

  @override
  ConsumerState<JoinTeamScreen> createState() => _JoinTeamScreenState();
}

class _JoinTeamScreenState extends ConsumerState<JoinTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      final team = await ref.read(teamMutationProvider.notifier)
          .joinTeam(_codeCtrl.text.trim().toUpperCase());
      if (team != null && mounted) {
        HapticFeedback.heavyImpact();
        ref.invalidate(myTeamsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Joined squad successfully! 🎉'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/user/teams');
      } else if (mounted) {
        final errMsg = ref.read(teamMutationProvider).error?.toString() ?? 'Invalid team code';
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header Graphic ──
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariantLight.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hub_outlined, size: 64, color: AppColors.textPrimaryLight),
                  ),
                ),
                const Gap(32),

                // ── Titles ──
                const Center(
                  child: Text(
                    'Link Up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const Gap(8),
                const Center(
                  child: Text(
                    'Enter the 8-character squad code\nshared by your captain.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                ),
                const Gap(48),

                // ── Input ──
                AppTextField(
                  label: 'Squad Code',
                  hint: 'e.g. ABCD1234',
                  controller: _codeCtrl,
                  validator: AppValidators.teamCode,
                  prefixIcon: const Icon(Icons.key_rounded, color: AppColors.primary),
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.characters,
                ),
                const Gap(32),

                // ── Action CTA ──
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimaryLight,
                    disabledBackgroundColor: AppColors.textPrimaryLight.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: AppColors.backgroundLight, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Join Squad',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.backgroundLight),
                            ),
                            Gap(8),
                            Icon(Icons.login_rounded, color: AppColors.backgroundLight, size: 20),
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
