import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import 'auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  // Step 1 — Account
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole  = 'USER';

  // Step 2 — Owner Business
  final _bizNameCtrl  = TextEditingController();
  final _bizPhoneCtrl = TextEditingController();
  final _addr1Ctrl    = TextEditingController();
  final _addr2Ctrl    = TextEditingController();
  final _cityCtrl     = TextEditingController();
  final _stateCtrl    = TextEditingController();
  final _pinCtrl      = TextEditingController();
  final _upiCtrl      = TextEditingController();
  final _bankAccCtrl  = TextEditingController();
  final _ifscCtrl     = TextEditingController();
  final _gstCtrl      = TextEditingController();
  final _panCtrl      = TextEditingController();

  int _step = 1;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passwordCtrl.dispose(); _bizNameCtrl.dispose(); _bizPhoneCtrl.dispose();
    _addr1Ctrl.dispose(); _addr2Ctrl.dispose(); _cityCtrl.dispose();
    _stateCtrl.dispose(); _pinCtrl.dispose(); _upiCtrl.dispose();
    _bankAccCtrl.dispose(); _ifscCtrl.dispose(); _gstCtrl.dispose();
    _panCtrl.dispose(); _animCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_step1Key.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    if (_selectedRole == 'OWNER') {
      _animCtrl.reset();
      setState(() => _step = 2);
      _animCtrl.forward();
    } else {
      _submitForm();
    }
  }

  void _goBack() {
    _animCtrl.reset();
    setState(() => _step = 1);
    _animCtrl.forward();
  }

  Future<void> _submitForm() async {
    if (_selectedRole == 'OWNER' && !_step2Key.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    await ref.read(authNotifierProvider.notifier).register(
      email:             _emailCtrl.text.trim(),
      phone:             _phoneCtrl.text.trim(),
      password:          _passwordCtrl.text,
      fullName:          _nameCtrl.text.trim(),
      role:              _selectedRole,
      businessName:      _v(_bizNameCtrl),
      contactNumber:     _v(_bizPhoneCtrl),
      addressLine1:      _v(_addr1Ctrl),
      addressLine2:      _v(_addr2Ctrl),
      city:              _v(_cityCtrl),
      stateProvince:     _v(_stateCtrl),
      pinCode:           _v(_pinCtrl),
      upiId:             _v(_upiCtrl),
      bankAccountNumber: _v(_bankAccCtrl),
      ifscCode:          _v(_ifscCtrl),
      gstNumber:         _v(_gstCtrl),
      panNumber:         _v(_panCtrl),
    );
  }

  String? _v(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    ref.listen(authNotifierProvider, (_, next) {
      next.whenData((state) {
        state.mapOrNull(
          error: (e) {
            HapticFeedback.vibrate();
            _showErrorSnack(e.message);
          },
          authenticated: (s) {
            HapticFeedback.heavyImpact();
            if (s.user.role.name.toUpperCase() == 'OWNER') {
              _showPendingDialog();
            } else {
              context.go('/user/dashboard');
            }
          },
        );
      });
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          AuthBackground(size: size),
          SafeArea(
            child: Column(children: [
              // ── Top bar ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 24),
                    onPressed: () => _step == 2 ? _goBack() : context.go('/auth/login'),
                  ),
                  const Spacer(),
                  if (_selectedRole == 'OWNER') _StepIndicator(step: _step),
                ]),
              ),

              // ── Animated Page Content ──────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _step == 1
                      ? _buildStep1(isLoading, key: const ValueKey('s1'))
                      : _buildStep2(isLoading, key: const ValueKey('s2')),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Account Info ────────────────────────────────────────────────────

  Widget _buildStep1(bool isLoading, {required Key key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(8),
              // Badge
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 14),
                    Gap(4),
                    Text('New Account', style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ]),
              const Gap(16),
              const Text('Join the League. 🏆', // TEXT BREAK FIXED
                style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.w900,
                  height: 1.2, letterSpacing: -1, color: Color(0xFF0F172A),
                ),
              ),
              const Gap(8),
              const Text('Set up your profile and start booking in seconds.',
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5, fontWeight: FontWeight.w500)),
              const Gap(28),

              // Form Card
              AuthGlassCard(
                child: Form(
                  key: _step1Key,
                  child: Column(children: [
                    AuthTextField(
                      label: 'FULL NAME', hint: 'John Doe', controller: _nameCtrl,
                      validator: (v) => AppValidators.required(v, fieldName: 'Full name'),
                      prefixIcon: Icons.person_outline_rounded, enabled: !isLoading,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const Gap(16),
                    AuthTextField(
                      label: 'EMAIL ADDRESS', hint: 'player@team.com', controller: _emailCtrl,
                      validator: AppValidators.email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.alternate_email_rounded, enabled: !isLoading,
                    ),
                    const Gap(16),
                    AuthTextField(
                      label: 'MOBILE NUMBER', hint: '98765 43210', controller: _phoneCtrl,
                      validator: AppValidators.phone,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined, enabled: !isLoading,
                    ),
                    const Gap(16),
                    AuthTextField(
                      label: 'PASSWORD', hint: 'Minimum 8 characters', controller: _passwordCtrl,
                      validator: AppValidators.password, obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline_rounded, enabled: !isLoading,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF94A3B8), size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ]),
                ),
              ),
              const Gap(24),

              // Role Selector
              const _SectionLabel('JOIN AS'),
              const Gap(12),
              _RoleSelector(
                selected: _selectedRole,
                onChanged: isLoading ? null : (r) => setState(() => _selectedRole = r),
              ),
              const Gap(28),

              AuthGreenButton(
                label: _selectedRole == 'OWNER' ? 'Continue to Business Info' : 'Create Account',
                isLoading: isLoading,
                onPressed: isLoading ? null : _nextStep,
              ),
              const Gap(24),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Already registered? ', style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: isLoading ? null : () {
                    HapticFeedback.selectionClick();
                    context.go('/auth/login');
                  },
                  child: const Text('Sign In',
                    style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ]),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 2: Owner Business Info ─────────────────────────────────────────────

  Widget _buildStep2(bool isLoading, {required Key key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Form(
            key: _step2Key,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Gap(8),
              const Text('Business Details. 🏟️', // TEXT BREAK FIXED
                style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.w900,
                  height: 1.2, letterSpacing: -1, color: Color(0xFF0F172A),
                ),
              ),
              const Gap(8),
              const Text('Provide your turf business info for admin verification and payments.',
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5, fontWeight: FontWeight.w500)),
              const Gap(24),

              // ── Business Info Card ──────────────────────────────────
              _SectionChip(label: 'Business Info', icon: Icons.business_rounded),
              const Gap(12),
              AuthGlassCard(
                child: Column(children: [
                  AuthTextField(
                    label: 'TURF / BUSINESS NAME *', hint: 'Raj Sports Arena',
                    controller: _bizNameCtrl,
                    validator: (v) => AppValidators.required(v, fieldName: 'Business name'),
                    prefixIcon: Icons.stadium_rounded, enabled: !isLoading,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const Gap(16),
                  AuthTextField(
                    label: 'BUSINESS CONTACT *', hint: '98765 43210',
                    controller: _bizPhoneCtrl, validator: AppValidators.phone,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_in_talk_outlined, enabled: !isLoading,
                  ),
                ]),
              ),
              const Gap(20),

              // ── Address Card ────────────────────────────────────────
              _SectionChip(label: 'Turf Address', icon: Icons.location_on_outlined),
              const Gap(12),
              AuthGlassCard(
                child: Column(children: [
                  AuthTextField(
                    label: 'ADDRESS LINE 1 *', hint: '123 Sports Street',
                    controller: _addr1Ctrl,
                    validator: (v) => AppValidators.required(v, fieldName: 'Address'),
                    prefixIcon: Icons.location_on_outlined, enabled: !isLoading,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const Gap(16),
                  AuthTextField(
                    label: 'ADDRESS LINE 2', hint: 'Near Main Market (Optional)',
                    controller: _addr2Ctrl,
                    prefixIcon: Icons.add_location_alt_outlined, enabled: !isLoading,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const Gap(16),
                  Row(children: [
                    Expanded(child: AuthTextField(
                      label: 'CITY *', hint: 'Solapur', controller: _cityCtrl,
                      validator: (v) => AppValidators.required(v, fieldName: 'City'),
                      prefixIcon: Icons.location_city_outlined, enabled: !isLoading,
                      textCapitalization: TextCapitalization.words,
                    )),
                    const Gap(12),
                    Expanded(child: AuthTextField(
                      label: 'STATE *', hint: 'Maharashtra', controller: _stateCtrl,
                      validator: (v) => AppValidators.required(v, fieldName: 'State'),
                      prefixIcon: Icons.map_outlined, enabled: !isLoading,
                      textCapitalization: TextCapitalization.words,
                    )),
                  ]),
                  const Gap(16),
                  AuthTextField(
                    label: 'PIN CODE *', hint: '413001', controller: _pinCtrl,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'PIN code required';
                      if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'Enter valid 6-digit PIN';
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.pin_drop_outlined, enabled: !isLoading,
                  ),
                ]),
              ),
              const Gap(20),

              // ── Payment Card ────────────────────────────────────────
              _SectionChip(label: 'Payment & Settlement', icon: Icons.account_balance_wallet_outlined),
              const Gap(8),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF059669), size: 16),
                  Gap(8),
                  Expanded(child: Text(
                    'Booking earnings will be settled to your UPI or bank account.',
                    style: TextStyle(color: Color(0xFF059669), fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
                  )),
                ]),
              ),
              AuthGlassCard(
                child: Column(children: [
                  AuthTextField(
                    label: 'UPI ID *', hint: 'yourname@upi', controller: _upiCtrl,
                    validator: (v) => AppValidators.required(v, fieldName: 'UPI ID'),
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.account_balance_wallet_outlined, enabled: !isLoading,
                  ),
                  const Gap(16),
                  AuthTextField(
                    label: 'BANK ACCOUNT NUMBER', hint: '1234567890 (Optional)',
                    controller: _bankAccCtrl, keyboardType: TextInputType.number,
                    prefixIcon: Icons.account_balance_outlined, enabled: !isLoading,
                  ),
                  const Gap(16),
                  AuthTextField(
                    label: 'IFSC CODE', hint: 'SBIN0001234 (Optional)',
                    controller: _ifscCtrl,
                    prefixIcon: Icons.code_rounded, enabled: !isLoading,
                  ),
                ]),
              ),
              const Gap(20),

              // ── Tax Card ────────────────────────────────────────────
              _SectionChip(label: 'Tax Info (Optional)', icon: Icons.receipt_long_outlined),
              const Gap(12),
              AuthGlassCard(
                child: Column(children: [
                  AuthTextField(
                    label: 'GST NUMBER', hint: '29ABCDE1234F1Z5',
                    controller: _gstCtrl,
                    prefixIcon: Icons.receipt_long_rounded, enabled: !isLoading,
                  ),
                  const Gap(16),
                  AuthTextField(
                    label: 'PAN NUMBER', hint: 'ABCDE1234F',
                    controller: _panCtrl,
                    prefixIcon: Icons.credit_card_outlined, enabled: !isLoading,
                  ),
                ]),
              ),
              const Gap(28),

              AuthGreenButton(
                label: 'Submit for Admin Approval',
                isLoading: isLoading,
                onPressed: isLoading ? null : _submitForm,
              ),
              const Gap(40),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Dialogs & Snacks ────────────────────────────────────────────────────────

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5), // Softer background
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 10))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.1),
              ),
              child: const Icon(Icons.pending_actions_rounded, color: Colors.orange, size: 48),
            ),
            const Gap(24),
            const Text('Application Submitted!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            const Text(
              "Your turf admin account is under review.\n\nOur admin team will verify your details and approve your account within 24-48 hours.\n\nYou'll be able to login and add your turf details once approved.",
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.6, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const Gap(28),
            AuthGreenButton(
              label: 'Back to Login',
              isLoading: false,
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/auth/login');
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        const Gap(8),
        Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
      ]),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}

// ── Private layout helpers (Updated to Light Theme) ──────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(
      color: Color(0xFF64748B), fontSize: 11,
      fontWeight: FontWeight.w800, letterSpacing: 1.2,
    ));
}

class _SectionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: const Color(0xFF059669), size: 16),
          const Gap(6),
          Text(label, style: const TextStyle(
            color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.w700,
          )),
        ]),
      ),
    ]);
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        _dot(1, step >= 1),
        Container(width: 24, height: 2,
          color: step >= 2 ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
        _dot(2, step >= 2),
      ]),
    );
  }

  Widget _dot(int n, bool active) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFF10B981) : Colors.white,
        border: Border.all(
          color: active ? const Color(0xFF10B981) : const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: active ? [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 6)] : [],
      ),
      child: Center(child: Text('$n',
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF94A3B8),
          fontSize: 12, fontWeight: FontWeight.w800,
        ))),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String selected;
  final void Function(String)? onChanged;
  const _RoleSelector({required this.selected, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final roles = [
      ('USER', 'Player', Icons.sports_kabaddi_rounded, 'Book turfs & join tournaments'),
      ('OWNER', 'Turf Admin', Icons.stadium_rounded, 'List & manage your turf'),
    ];

    return Row(children: roles.map((r) {
      final isSelected = selected == r.$1;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: r.$1 == 'USER' ? 8 : 0,
            left: r.$1 == 'OWNER' ? 8 : 0,
          ),
          child: GestureDetector(
            onTap: onChanged != null ? () {
              HapticFeedback.lightImpact();
              onChanged!(r.$1);
            } : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        blurRadius: 20, offset: const Offset(0, 8),
                      )]
                    : [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF10B981).withOpacity(0.15)
                        : const Color(0xFFF1F5F9),
                  ),
                  child: Icon(r.$3, size: 28,
                    color: isSelected ? const Color(0xFF059669) : const Color(0xFF64748B)),
                ),
                const Gap(12),
                Text(r.$2, style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                )),
                const Gap(6),
                Text(r.$4, textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 12, color: const Color(0xFF64748B), height: 1.4, fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                )),
                if (isSelected) ...[
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                  ),
                ],
              ]),
            ),
          ),
        ),
      );
    }).toList());
  }
}
