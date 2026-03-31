import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_widgets.dart';

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() =>
      _CreateTournamentScreenState();
}

class _CreateTournamentScreenState
    extends ConsumerState<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _entryFeeCtrl = TextEditingController();
  final _prizePoolCtrl = TextEditingController();
  final _maxTeamsCtrl = TextEditingController(text: '8');
  final _descCtrl = TextEditingController();

  String _sport = 'FOOTBALL';
  String _format = 'KNOCKOUT';
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _entryFeeCtrl.dispose();
    _prizePoolCtrl.dispose();
    _maxTeamsCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(apiClientProvider).post('tournaments', data: {
        'name': _nameCtrl.text.trim(),
        'sportType': _sport,
        'format': _format,
        'entryFee': double.parse(_entryFeeCtrl.text.trim()),
        if (_prizePoolCtrl.text.trim().isNotEmpty)
          'prizePool': double.parse(_prizePoolCtrl.text.trim()),
        'maxTeams': int.parse(_maxTeamsCtrl.text.trim()),
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        if (_descCtrl.text.trim().isNotEmpty)
          'description': _descCtrl.text.trim(),
      });
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournament active and launched! 🏆'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/owner/dashboard');
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
    SystemChrome.setSystemUIOverlayStyle(Theme.of(context).brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    const sports = ['FOOTBALL', 'BOX_CRICKET', 'BASKETBALL', 'VOLLEYBALL', 'TENNIS', 'BADMINTON', 'MULTI_SPORT'];
    const formats = ['KNOCKOUT', 'LEAGUE', 'ROUND_ROBIN'];
    final dateFmt = DateFormat('dd MMM yyyy');

    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: t.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: t.colorScheme.onSurface),
        centerTitle: true,
        title: Text(
          'Create Event',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.colorScheme.onSurface),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Sleek Hero Section ──
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Icon(Icons.emoji_events_rounded, size: 140, color: Colors.white.withOpacity(0.05)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: const Text('TOURNAMENT CONFIG', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                          const Gap(16),
                          const Text(
                            'Host & Manage',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1, color: Colors.white),
                          ),
                          const Gap(8),
                          Text(
                            'Setup the framework, define prize pools, and open up registrations.',
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), height: 1.4, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(32),

                // ── Event Identity Group ──
                _buildSectionHeader('Event Identity', Icons.style_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  AppTextField(
                    label: 'Tournament Name',
                    hint: 'e.g. Solapur Super League',
                    controller: _nameCtrl,
                    validator: (v) => AppValidators.required(v, fieldName: 'Name'),
                    prefixIcon: const Icon(Icons.stadium_rounded, color: AppColors.primary),
                    enabled: !_isLoading,
                    textCapitalization: TextCapitalization.words,
                  ),
                ]),
                const Gap(32),

                // ── Event Structure Group ──
                _buildSectionHeader('Game Structure', Icons.account_tree_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            initialValue: _sport,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
                            decoration: const InputDecoration(
                              labelText: 'Sport Type',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            items: sports.map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.replaceAll('_', ' '), style: TextStyle(fontWeight: FontWeight.w600, color: t.colorScheme.onSurface, fontSize: 13)),
                                )).toList(),
                            onChanged: _isLoading ? null : (v) => setState(() => _sport = v!),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 40, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      const Gap(16),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            initialValue: _format,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
                            decoration: const InputDecoration(
                              labelText: 'Format',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            items: formats.map((f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(f.replaceAll('_', ' '), style: TextStyle(fontWeight: FontWeight.w600, color: t.colorScheme.onSurface, fontSize: 13)),
                                )).toList(),
                            onChanged: _isLoading ? null : (v) => setState(() => _format = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
                const Gap(32),

                // ── Capacity & Timeline Group ──
                _buildSectionHeader('Capacity & Timeline', Icons.date_range_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  AppTextField(
                    label: 'Maximum Teams',
                    hint: 'e.g. 16',
                    controller: _maxTeamsCtrl,
                    validator: AppValidators.positiveNumber,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.groups_rounded, color: AppColors.primary),
                    enabled: !_isLoading,
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _DateTile(
                          label: 'Start Date',
                          date: dateFmt.format(_startDate),
                          onTap: () => _pickDate(true),
                          isDark: isDark,
                          t: t,
                        ),
                      ),
                      const Gap(12),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.textHint, size: 16),
                      const Gap(12),
                      Expanded(
                        child: _DateTile(
                          label: 'End Date',
                          date: dateFmt.format(_endDate),
                          onTap: () => _pickDate(false),
                          isDark: isDark,
                          t: t,
                        ),
                      ),
                    ],
                  ),
                ]),
                const Gap(32),

                // ── Economics Group ──
                _buildSectionHeader('Economics', Icons.account_balance_wallet_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Entry Fee (₹)',
                          hint: '0 for free',
                          controller: _entryFeeCtrl,
                          validator: AppValidators.positiveNumber,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.payments_rounded, color: AppColors.primary),
                          enabled: !_isLoading,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: AppTextField(
                          label: 'Prize Pool (₹)',
                          hint: 'e.g. 5000',
                          controller: _prizePoolCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.savings_rounded, color: AppColors.warning),
                          enabled: !_isLoading,
                        ),
                      ),
                    ],
                  ),
                ]),
                const Gap(32),

                // ── Additional Info ──
                _buildSectionHeader('Additional Information', Icons.info_outline_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  AppTextField(
                    label: 'Tournament Description / Rules',
                    hint: 'Optional detailing of event rules or sponsors...',
                    controller: _descCtrl,
                    maxLines: 4,
                    enabled: !_isLoading,
                  ),
                ]),
                const Gap(48),

                // ── Submission ──
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    shadowColor: const Color(0xFF10B981).withOpacity(0.5),
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
                              'Launch Tournament',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                            ),
                            Gap(8),
                            Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                ),
                const Gap(40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        const Gap(8),
        Text(
          title.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildCardGroup(ThemeData t, List<Widget> children) {
    final isDark = t.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;
  final bool isDark;
  final ThemeData t;

  const _DateTile({required this.label, required this.date, required this.onTap, required this.isDark, required this.t});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: t.inputDecorationTheme.fillColor,
          border: Border.all(color: isDark ? const Color(0xFF475569) : AppColors.dividerLight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.edit_calendar_rounded, size: 14, color: AppColors.primary),
              ],
            ),
            const Gap(8),
            Text(
              date,
              style: TextStyle(fontWeight: FontWeight.bold, color: t.colorScheme.onSurface, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
