import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// User Edit Profile + Change Password Screen
//
// Two tabs in one screen:
//   Tab 1: Edit Profile  — name + phone, calls PUT /api/users/me
//   Tab 2: Change Password — current / new / confirm, calls POST /api/users/me/change-password
// ─────────────────────────────────────────────────────────────────────────────

class UserEditProfileScreen extends ConsumerStatefulWidget {
  const UserEditProfileScreen({super.key});

  @override
  ConsumerState<UserEditProfileScreen> createState() =>
      _UserEditProfileScreenState();
}

class _UserEditProfileScreenState
    extends ConsumerState<UserEditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  // ── Edit profile controllers ──
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _profileSaving = false;
  bool _profileLoaded = false;

  // ── Change password controllers ──
  final _curPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _curPwVisible = false;
  bool _newPwVisible = false;
  bool _confirmPwVisible = false;
  bool _pwSaving = false;
  final _pwFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _curPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  void _prefillProfile(user) {
    if (!_profileLoaded && user != null) {
      _nameCtrl.text = user.fullName;
      _phoneCtrl.text = user.phone ?? '';
      _profileLoaded = true;
    }
  }

  // ── Save profile ──────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _showSnack('Full name cannot be empty', isError: true);
      return;
    }
    setState(() => _profileSaving = true);
    try {
      await ref.read(updateProfileProvider({
        'fullName': name,
        'phone': _phoneCtrl.text.trim(),
      }).future);
      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSnack('Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to update profile', isError: true);
    } finally {
      if (mounted) setState(() => _profileSaving = false);
    }
  }

  // ── Change password ───────────────────────────────────────────────────────
  Future<void> _changePassword() async {
    if (!_pwFormKey.currentState!.validate()) return;
    setState(() => _pwSaving = true);
    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/users/me/change-password', data: {
        'currentPassword': _curPwCtrl.text,
        'newPassword': _newPwCtrl.text,
      });
      if (mounted) {
        HapticFeedback.heavyImpact();
        _curPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
        _showSnack('Password changed successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Incorrect current password or server error', isError: true);
      }
    } finally {
      if (mounted) setState(() => _pwSaving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
          color: Colors.white,
          size: 18,
        ),
        const Gap(10),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    profileAsync.whenData(_prefillProfile);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: AppColors.textPrimaryLight),
        title: const Text(
          'Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimaryLight,
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Edit Profile'),
            Tab(text: 'Change Password'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _EditProfileTab(
            nameCtrl: _nameCtrl,
            phoneCtrl: _phoneCtrl,
            isSaving: _profileSaving,
            onSave: _saveProfile,
          ),
          _ChangePasswordTab(
            formKey: _pwFormKey,
            curPwCtrl: _curPwCtrl,
            newPwCtrl: _newPwCtrl,
            confirmPwCtrl: _confirmPwCtrl,
            curVisible: _curPwVisible,
            newVisible: _newPwVisible,
            confirmVisible: _confirmPwVisible,
            onToggleCur: () =>
                setState(() => _curPwVisible = !_curPwVisible),
            onToggleNew: () =>
                setState(() => _newPwVisible = !_newPwVisible),
            onToggleConfirm: () =>
                setState(() => _confirmPwVisible = !_confirmPwVisible),
            isSaving: _pwSaving,
            onSave: _changePassword,
          ),
        ],
      ),
    );
  }
}

// ── Tab 1: Edit Profile ───────────────────────────────────────────────────────

class _EditProfileTab extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final bool isSaving;
  final VoidCallback onSave;

  const _EditProfileTab({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar Hero ──
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    nameCtrl.text.isNotEmpty
                        ? nameCtrl.text[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.backgroundLight, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Gap(36),

          // ── Full Name ──
          const _FieldLabel('Full Name'),
          const Gap(8),
          TextField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: _fieldDeco(
              hint: 'Your full name',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const Gap(20),

          // ── Phone ──
          const _FieldLabel('Phone Number'),
          const Gap(8),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: _fieldDeco(
              hint: '+91 9876543210',
              icon: Icons.phone_outlined,
            ),
          ),
          const Gap(40),

          // ── Save Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDeco(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon,
          color: AppColors.textSecondaryLight, size: 20),
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ── Tab 2: Change Password ────────────────────────────────────────────────────

class _ChangePasswordTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController curPwCtrl;
  final TextEditingController newPwCtrl;
  final TextEditingController confirmPwCtrl;
  final bool curVisible;
  final bool newVisible;
  final bool confirmVisible;
  final VoidCallback onToggleCur;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final bool isSaving;
  final VoidCallback onSave;

  const _ChangePasswordTab({
    required this.formKey,
    required this.curPwCtrl,
    required this.newPwCtrl,
    required this.confirmPwCtrl,
    required this.curVisible,
    required this.newVisible,
    required this.confirmVisible,
    required this.onToggleCur,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Security Icon ──
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.primary, size: 40),
              ),
            ),
            const Gap(16),
            const Center(
              child: Text(
                'Keep your account secure',
                style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Gap(36),

            // ── Current Password ──
            const _FieldLabel('Current Password'),
            const Gap(8),
            TextFormField(
              controller: curPwCtrl,
              obscureText: !curVisible,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
              decoration: _pwDeco(
                hint: 'Your current password',
                visible: curVisible,
                onToggle: onToggleCur,
              ),
            ),
            const Gap(20),

            // ── New Password ──
            const _FieldLabel('New Password'),
            const Gap(8),
            TextFormField(
              controller: newPwCtrl,
              obscureText: !newVisible,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              },
              decoration: _pwDeco(
                hint: 'At least 8 characters',
                visible: newVisible,
                onToggle: onToggleNew,
              ),
            ),
            const Gap(20),

            // ── Confirm Password ──
            const _FieldLabel('Confirm New Password'),
            const Gap(8),
            TextFormField(
              controller: confirmPwCtrl,
              obscureText: !confirmVisible,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v != newPwCtrl.text) return 'Passwords do not match';
                return null;
              },
              decoration: _pwDeco(
                hint: 'Repeat new password',
                visible: confirmVisible,
                onToggle: onToggleConfirm,
              ),
            ),
            const Gap(12),

            // ── Strength tip ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates_outlined,
                      color: AppColors.primary, size: 16),
                  Gap(10),
                  Expanded(
                    child: Text(
                      'Use a mix of letters, numbers and symbols. '
                      'Avoid using your name or email.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryDark,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(40),

            // ── Submit Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withOpacity(0.5),
                  padding:
                      const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Update Password',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _pwDeco({
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.lock_outline_rounded,
          color: AppColors.textSecondaryLight, size: 20),
      suffixIcon: IconButton(
        icon: Icon(
          visible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textSecondaryLight,
          size: 20,
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ── Shared Helper ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondaryLight,
        letterSpacing: 0.3,
      ),
    );
  }
}
