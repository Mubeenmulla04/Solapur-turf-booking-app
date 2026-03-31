import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminPlatformSettingsScreen extends ConsumerStatefulWidget {
  const AdminPlatformSettingsScreen({super.key});

  @override
  ConsumerState<AdminPlatformSettingsScreen> createState() =>
      _AdminPlatformSettingsScreenState();
}

class _AdminPlatformSettingsScreenState
    extends ConsumerState<AdminPlatformSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commissionCtrl = TextEditingController();
  final _maxBookingsCtrl = TextEditingController();
  final _platformNameCtrl = TextEditingController();
  final _supportEmailCtrl = TextEditingController();
  bool _maintenanceMode = false;
  bool _saving = false;
  bool _loaded = false;

  @override
  void dispose() {
    _commissionCtrl.dispose();
    _maxBookingsCtrl.dispose();
    _platformNameCtrl.dispose();
    _supportEmailCtrl.dispose();
    super.dispose();
  }

  void _populateFromData(Map<String, dynamic> data) {
    if (_loaded) return;
    _loaded = true;
    _commissionCtrl.text =
        (data['commissionPercent'] ?? 10).toString();
    _maxBookingsCtrl.text =
        (data['maxBookingsPerUser'] ?? 5).toString();
    _platformNameCtrl.text =
        (data['platformName'] ?? 'Solapur Turf').toString();
    _supportEmailCtrl.text =
        (data['supportEmail'] ?? '').toString();
    _maintenanceMode = data['maintenanceMode'] as bool? ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(adminSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Platform Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveSettings,
            child: const Text('SAVE',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1)),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.warning)),
        error: (_, __) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(adminSettingsProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (data) {
          _populateFromData(data);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Financial Settings ──
                _SectionHeader(
                    icon: Icons.currency_rupee_rounded,
                    label: 'FINANCIAL',
                    color: AppColors.success),
                const Gap(14),
                _SettingField(
                  controller: _commissionCtrl,
                  label: 'Platform Commission (%)',
                  hint: 'e.g. 10',
                  icon: Icons.percent_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0 || n > 100) {
                      return 'Enter 0–100';
                    }
                    return null;
                  },
                ),
                const Gap(14),

                // ── Booking Settings ──
                _SectionHeader(
                    icon: Icons.confirmation_num_rounded,
                    label: 'BOOKING LIMITS',
                    color: AppColors.primary),
                const Gap(14),
                _SettingField(
                  controller: _maxBookingsCtrl,
                  label: 'Max Bookings Per User',
                  hint: 'e.g. 5',
                  icon: Icons.bookmark_border_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1) return 'Enter a positive number';
                    return null;
                  },
                ),
                const Gap(24),

                // ── Platform Info ──
                _SectionHeader(
                    icon: Icons.info_outline_rounded,
                    label: 'PLATFORM INFO',
                    color: const Color(0xFF6366F1)),
                const Gap(14),
                _SettingField(
                  controller: _platformNameCtrl,
                  label: 'Platform Name',
                  hint: 'Solapur Turf',
                  icon: Icons.sports_soccer_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                const Gap(14),
                _SettingField(
                  controller: _supportEmailCtrl,
                  label: 'Support Email',
                  hint: 'support@solapurturf.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const Gap(24),

                // ── System Toggle ──
                _SectionHeader(
                    icon: Icons.build_outlined,
                    label: 'SYSTEM',
                    color: AppColors.error),
                const Gap(14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _maintenanceMode
                          ? AppColors.error.withOpacity(0.4)
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (_maintenanceMode
                                  ? AppColors.error
                                  : AppColors.textSecondaryLight)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.construction_rounded,
                          color: _maintenanceMode
                              ? AppColors.error
                              : AppColors.textSecondaryLight,
                          size: 20,
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Maintenance Mode',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.textPrimaryLight)),
                            const Gap(2),
                            Text(
                              _maintenanceMode
                                  ? '⚠️ Platform is in maintenance mode'
                                  : 'Platform is fully operational',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _maintenanceMode
                                      ? AppColors.error
                                      : AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _maintenanceMode,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          setState(() => _maintenanceMode = v);
                        },
                        activeColor: AppColors.error,
                      ),
                    ],
                  ),
                ),
                const Gap(32),

                // ── Save Button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _saveSettings,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      _saving ? 'Saving…' : 'Save Settings',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);

    try {
      final dio = ref.read(apiClientProvider);
      await dio.put('/admin/settings', data: {
        'commissionPercent': int.tryParse(_commissionCtrl.text) ?? 10,
        'maxBookingsPerUser': int.tryParse(_maxBookingsCtrl.text) ?? 5,
        'platformName': _platformNameCtrl.text.trim(),
        'supportEmail': _supportEmailCtrl.text.trim(),
        'maintenanceMode': _maintenanceMode,
      });

      ref.invalidate(adminSettingsProvider);
      setState(() {
        _saving = false;
        _loaded = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            Gap(10),
            Text('Settings saved successfully!'),
          ]),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to save settings'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const Gap(8),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 1.5)),
      ],
    );
  }
}

class _SettingField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _SettingField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(icon, color: AppColors.textSecondaryLight, size: 20),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.warning, width: 1.5),
        ),
      ),
    );
  }
}
