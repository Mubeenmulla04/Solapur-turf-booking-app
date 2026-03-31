import 'package:flutter/material.dart';

/// Premium SaaS Brand colors — Turf Booking App
/// Colors mapped to convey trust, nature (sports), and minimalistic cleanliness.
class AppColors {
  AppColors._();

  // Primary: Deep Saturated Green (Provides trust & energy)
  static const Color primary = Color(0xFF0E7C61);
  static const Color primaryDark = Color(0xFF064E3B); // Dark theme primary container
  static const Color primaryLight = Color(0xFF34D399); // Active elements, borders
  static const Color primaryContainer = Color(0xFFE6F5F2); // Pale green (Light theme chips)

  // Secondary/Accent: Soft Coral/Orange (Used strictly for warnings, "Few slots left")
  static const Color secondary = Color(0xFFF97316);
  static const Color secondaryContainer = Color(0xFFFFEDD5);

  // Background Systems (Anti-harsh-white for better eye comfort)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);

  // Surface Systems (Cards, Dialogs)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9); // Light grey inputs
  static const Color surfaceVariantDark = Color(0xFF334155); // Dark inputs

  // Semantic Colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981); // Bright neon lime-ish green

  // Text & Typography
  static const Color textPrimaryLight = Color(0xFF0F172A); // Deep slate (not black)
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Off-white
  static const Color textSecondaryLight = Color(0xFF64748B); // Cool grey
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Colors.white;

  // Dividers & Borders
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);
  static const Color disabled = Color(0xFFCBD5E1);

  // Unified Soft Shadow (Glassmorphic)
  static const Color shadowLight = Color(0x0C0F172A); // 5% Slate
  static const Color shadowDark = Color(0x33000000); // 20% Black

  // ── Specific Domain Colors (Bookings) ──
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF10B981);
  static const Color statusCompleted = Color(0xFF3B82F6);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusInProgress = Color(0xFF8B5CF6);

  // Payment Status
  static const Color paymentPaid = Color(0xFF10B981);
  static const Color paymentPending = Color(0xFFF59E0B);
  static const Color paymentFailed = Color(0xFFEF4444);
  static const Color paymentRefunded = Color(0xFF3B82F6);

  // ── Legacy Aliases (Backwards Compatibility) ──
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color surfaceVariant = surfaceVariantLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color divider = dividerLight;
}
