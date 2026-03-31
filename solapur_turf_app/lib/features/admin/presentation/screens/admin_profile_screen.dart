import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/admin_providers.dart';
import 'admin_user_management_screen.dart';
import 'admin_revenue_analytics_screen.dart';
import 'admin_push_notification_screen.dart';
import 'admin_platform_settings_screen.dart';
import 'admin_audit_log_screen.dart';
import 'admin_help_support_screen.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final authState = ref.watch(authNotifierProvider);
    final statsAsync = ref.watch(adminPlatformStatsProvider);
    final user = authState.valueOrNull?.user;
    final fullName = user?.fullName ?? 'System Admin';
    final email = user?.email ?? 'admin@solapur.com';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient Header ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF0E7C61)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(24),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primaryLight, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor:
                                  Colors.white.withOpacity(0.15),
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      const Gap(12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                color: AppColors.primaryLight, size: 14),
                            Gap(6),
                            Text(
                              'Super Administrator · Full Access',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Live Platform Stats ──
                    const Text(
                      'PLATFORM ACCESS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondaryLight,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Gap(16),
                    statsAsync.when(
                      loading: () => const SizedBox(
                        height: 80,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2)),
                      ),
                      error: (_, __) => Row(
                        children: [
                          Expanded(
                              child: _StatChip(
                                  icon: Icons.group_rounded,
                                  label: 'Total Users',
                                  value: '—',
                                  color: AppColors.primary)),
                          const Gap(12),
                          Expanded(
                              child: _StatChip(
                                  icon: Icons.storefront_rounded,
                                  label: 'Turf Listings',
                                  value: '—',
                                  color: AppColors.warning)),
                          const Gap(12),
                          Expanded(
                              child: _StatChip(
                                  icon: Icons.confirmation_num_rounded,
                                  label: 'Bookings',
                                  value: '—',
                                  color: AppColors.success)),
                        ],
                      ),
                      data: (stats) => Row(
                        children: [
                          Expanded(
                              child: _StatChip(
                                  icon: Icons.group_rounded,
                                  label: 'Total Users',
                                  value:
                                      '${stats['totalUsers'] ?? 0}',
                                  color: AppColors.primary)),
                          const Gap(12),
                          Expanded(
                              child: _StatChip(
                                  icon: Icons.storefront_rounded,
                                  label: 'Turf Listings',
                                  value:
                                      '${stats['totalTurfs'] ?? 0}',
                                  color: AppColors.warning)),
                          const Gap(12),
                          Expanded(
                              child: _StatChip(
                                  icon: Icons.confirmation_num_rounded,
                                  label: 'Bookings',
                                  value:
                                      '${stats['totalBookings'] ?? 0}',
                                  color: AppColors.success)),
                        ],
                      ),
                    ),
                    const Gap(32),

                    // ── Admin Actions ──
                    const Text(
                      'ADMIN CONTROLS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondaryLight,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Gap(16),
                    _buildActionCard(
                      icon: Icons.manage_accounts_rounded,
                      title: 'User Management',
                      subtitle: 'View, suspend & manage all users',
                      color: AppColors.primary,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AdminUserManagementScreen())),
                    ),
                    const Gap(12),
                    _buildActionCard(
                      icon: Icons.tune_rounded,
                      title: 'Platform Settings',
                      subtitle: 'Commission rates, limits & configurations',
                      color: AppColors.warning,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AdminPlatformSettingsScreen())),
                    ),
                    const Gap(12),
                    _buildActionCard(
                      icon: Icons.analytics_rounded,
                      title: 'Revenue Analytics',
                      subtitle: 'Monthly charts and financial KPIs',
                      color: AppColors.success,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AdminRevenueAnalyticsScreen())),
                    ),
                    const Gap(12),
                    _buildActionCard(
                      icon: Icons.notifications_active_rounded,
                      title: 'Push Notifications',
                      subtitle: 'Broadcast messages to all users',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AdminPushNotificationScreen())),
                    ),
                    const Gap(32),

                    // ── Account Settings ──
                    const Text(
                      'ACCOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondaryLight,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Gap(16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.dividerLight),
                      ),
                      child: Column(
                        children: [
                          _buildMenuTile(
                            icon: Icons.lock_reset_rounded,
                            title: 'Change Password',
                            onTap: () =>
                                _showChangePasswordDialog(context, ref),
                          ),
                          const Divider(
                              height: 1, color: AppColors.dividerLight),
                          _buildMenuTile(
                            icon: Icons.history_rounded,
                            title: 'Audit Log',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminAuditLogScreen())),
                          ),
                          const Divider(
                              height: 1, color: AppColors.dividerLight),
                          _buildMenuTile(
                            icon: Icons.support_agent_rounded,
                            title: 'Help & Support',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminHelpSupportScreen())),
                          ),
                        ],
                      ),
                    ),
                    const Gap(32),

                    // ── Danger Zone ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            AppColors.errorContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Session Control',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                              fontSize: 15,
                            ),
                          ),
                          const Gap(4),
                          const Text(
                            'Logging out will clear your admin session immediately.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight),
                          ),
                          const Gap(16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                HapticFeedback.heavyImpact();
                                await ref
                                    .read(
                                        authNotifierProvider.notifier)
                                    .logout();
                              },
                              icon: const Icon(
                                  Icons.power_settings_new_rounded,
                                  size: 20),
                              label: const Text(
                                'End Admin Session',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    Center(
                      child: Text(
                        'Solapur Turf Admin Panel v1.0.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight
                              .withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Change Password Dialog ──────────────────────────────────────────────────

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool showCurrent = false;
    bool showNew = false;
    bool showConfirm = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            title: const Text('Change Password',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentCtrl,
                    obscureText: !showCurrent,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(showCurrent
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded),
                        onPressed: () =>
                            setDialogState(() => showCurrent = !showCurrent),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const Gap(14),
                  TextFormField(
                    controller: newCtrl,
                    obscureText: !showNew,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon:
                          const Icon(Icons.lock_reset_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(showNew
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded),
                        onPressed: () =>
                            setDialogState(() => showNew = !showNew),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'At least 6 characters'
                        : null,
                  ),
                  const Gap(14),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: !showConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon:
                          const Icon(Icons.check_circle_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(showConfirm
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded),
                        onPressed: () => setDialogState(
                            () => showConfirm = !showConfirm),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v != newCtrl.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(ctx);
                  try {
                    final dio = ref.read(apiClientProvider);
                    await dio.post('/users/me/change-password', data: {
                      'currentPassword': currentCtrl.text,
                      'newPassword': newCtrl.text,
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Row(children: [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.white),
                          Gap(10),
                          Text('Password changed successfully!'),
                        ]),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                            'Failed to change password. Check current password.'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ));
                    }
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight)),
                  const Gap(2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.textSecondaryLight, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
              fontSize: 14)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textHint, size: 20),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const Gap(8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const Gap(2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
