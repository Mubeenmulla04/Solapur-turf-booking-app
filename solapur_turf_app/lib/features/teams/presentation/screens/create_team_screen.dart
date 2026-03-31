import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_widgets.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String _sport = 'FOOTBALL';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    
    try {
      await ref.read(apiClientProvider).post('/teams', data: {
        'teamName': _nameCtrl.text.trim(),
        'sportType': _sport,
        'description': _descCtrl.text.trim(),
        'homeCity': _cityCtrl.text.trim(),
      });
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Squad forged successfully! 🛡️'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/user/teams');
      }
    } on AppException catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message), 
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
    const sports = ['FOOTBALL', 'CRICKET', 'BASKETBALL', 'VOLLEYBALL', 'TENNIS', 'BADMINTON', 'MULTI_SPORT'];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        centerTitle: true,
        title: const Text(
          'Create Squad',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                      color: AppColors.primaryContainer.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, size: 64, color: AppColors.primary),
                  ),
                ),
                const Gap(24),
                const Center(
                  child: Text(
                    'Forge your Identity',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                const Gap(8),
                const Center(
                  child: Text(
                    'Setup your team profile to compete in tournaments.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondaryLight),
                  ),
                ),
                const Gap(40),

                // ── Form Core ──
                AppTextField(
                  label: 'Squad Name',
                  hint: 'e.g. Manchester United',
                  controller: _nameCtrl,
                  validator: (v) => AppValidators.required(v, fieldName: 'Squad name'),
                  prefixIcon: const Icon(Icons.group_outlined),
                  enabled: !_isLoading,
                ),
                const Gap(20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.dividerLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      initialValue: _sport,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
                      decoration: const InputDecoration(
                        labelText: 'Primary Sport',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      items: sports
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s.replaceAll('_', ' '),
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
                                ),
                              ))
                          .toList(),
                      onChanged: _isLoading ? null : (v) => setState(() => _sport = v!),
                    ),
                  ),
                ),
                const Gap(20),

                AppTextField(
                  label: 'Home City / Base',
                  hint: 'e.g. Solapur',
                  controller: _cityCtrl,
                  prefixIcon: const Icon(Icons.map_outlined),
                  enabled: !_isLoading,
                ),
                const Gap(20),

                AppTextField(
                  label: 'Club Description',
                  hint: 'What makes your squad special? (Optional)',
                  controller: _descCtrl,
                  maxLines: 4,
                  enabled: !_isLoading,
                ),
                const Gap(40),

                // ── Submit CTA ──
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Establish Squad',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Gap(8),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
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
