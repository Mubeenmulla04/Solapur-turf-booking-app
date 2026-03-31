import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/utils/validators.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Shared Auth UI components — Clean Modern Light Theme
// ═══════════════════════════════════════════════════════════════════════════════

class AuthBackground extends StatelessWidget {
  final Size size;
  const AuthBackground({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC), // Very clean light grey/white background
      child: CustomPaint(
        size: size,
        painter: TurfGridPainter(),
      ),
    );
  }
}

class TurfGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.04)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    final circlePaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.12), 100, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 60, circlePaint);
  }

  @override
  bool shouldRepaint(TurfGridPainter old) => false;
}

class AuthGlassCard extends StatelessWidget {
  final Widget child;
  const AuthGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    required this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const Gap(8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.normal),
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF10B981), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ],
    );
  }
}

class AuthGreenButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool showArrow;

  const AuthGreenButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onPressed,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: onPressed == null ? const Color(0xFF10B981).withOpacity(0.5) : const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(16),
          boxShadow: onPressed != null
              ? [BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )]
              : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 22, width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (showArrow) ...[
                      const Gap(8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
