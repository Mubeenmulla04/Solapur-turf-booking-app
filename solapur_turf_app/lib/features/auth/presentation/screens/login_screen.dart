import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import 'auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    await ref.read(authNotifierProvider.notifier).login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

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
            final route = switch (s.user.role.name.toUpperCase()) {
              'OWNER' => '/owner/dashboard',
              'ADMIN' => '/admin/dashboard',
              _ => '/user/dashboard',
            };
            context.go(route);
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
          // ── Background ──────────────────────────────────────────────
          AuthBackground(size: size),

          // ── Content ─────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Gap(16),

                        // ── Branding Logo ────────────────────────────
                        Center(
                          child: Column(children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/images/splash-logo1.jpeg',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.sports_soccer_rounded,
                                  size: 48,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                            const Gap(16),
                            const Text(
                              'SOLAPUR TURF', 
                              style: TextStyle(
                                fontSize: 18,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              )
                            ),
                            const Gap(4),
                            const Text(
                              'PREMIUM BOOKING', 
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              )
                            ),
                          ]),
                        ),

                        const Gap(24),

                        // ── Headline ─────────────────────────────────
                        const Text(
                          'Welcome Back! 👋',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -1,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(8),
                        const Text(
                          'Sign in to book pitches & manage your squad.',
                          style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(24),

                        // ── Glass Form ────────────────────────────────
                        AuthGlassCard(
                          child: Form(
                            key: _formKey,
                            child: Column(children: [
                              AuthTextField(
                                label: 'EMAIL / PHONE',
                                hint: 'player@team.com',
                                controller: _emailCtrl,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Email or phone is required' : null,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.alternate_email_rounded,
                                enabled: !isLoading,
                              ),
                              const Gap(16),
                              AuthTextField(
                                label: 'PASSWORD',
                                hint: '••••••••',
                                controller: _passwordCtrl,
                                validator: AppValidators.password,
                                obscureText: _obscurePassword,
                                prefixIcon: Icons.lock_outline_rounded,
                                enabled: !isLoading,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color(0xFF94A3B8), size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF10B981),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('Forgot Password?',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                ),
                              ),
                            ]),
                          ),
                        ),

                        const Gap(16),

                        // ── CTA ───────────────────────────────────────
                        AuthGreenButton(
                          label: 'Sign In',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _submit,
                        ),

                        const Gap(20),

                        // ── Divider ───────────────────────────────────
                        const Row(children: [
                          Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                          Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                        ]),
                        const Gap(16),

                        // ── Register Link ─────────────────────────────
                        GestureDetector(
                          onTap: isLoading ? null : () {
                            HapticFeedback.selectionClick();
                            context.go('/auth/register');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? ",
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500)),
                                Text('Create one',
                                    style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 15)),
                                Gap(4),
                                Icon(Icons.arrow_forward_rounded, color: Color(0xFF10B981), size: 16),
                              ],
                            ),
                          ),
                        ),
                        const Gap(16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        const Gap(8),
        Expanded(child: Text(message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}
