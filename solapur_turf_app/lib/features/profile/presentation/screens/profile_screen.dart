import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final authUser = authState.valueOrNull?.user;
    final profileAsync = ref.watch(userProfileProvider);
    final user = profileAsync.valueOrNull ?? authUser;
    final appTheme = ref.watch(themeProvider);

    // Fallback info if user is somehow null
    final fullName = user?.fullName ?? 'Guest User';
    final email = user?.email ?? 'Not provided';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium App Bar ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.backgroundLight,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(20),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundLight.withOpacity(0.2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.backgroundLight,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.backgroundLight,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.backgroundLight.withOpacity(0.8),
                        ),
                      ),
                      if (user?.phone != null && user!.phone!.isNotEmpty) ...[  
                        const Gap(2),
                        Text(
                          user.phone!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.backgroundLight.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Scrollable Body ──
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                child: Column(
                  children: [
                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStatCard(
                            title: 'Wallet',
                            value: '₹${user?.walletBalance.toStringAsFixed(0) ?? "0"}',
                            icon: Icons.account_balance_wallet_rounded,
                            iconColor: AppColors.primary,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push('/user/wallet');
                            },
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _buildQuickStatCard(
                            title: 'Loyalty Points',
                            value: '${user?.loyaltyPoints ?? 0}',
                            icon: Icons.stars_rounded,
                            iconColor: AppColors.warning,
                            onTap: () {
                            onTap: () => _showLoyaltyInfo(context, user?.loyaltyPoints ?? 0),
                          ),
                        ),
                      ],
                    ),
                    const Gap(32),

                    // Preferences
                    _buildSectionHeader('Preferences'),
                    _buildSettingsCard(
                      children: [
                        _buildListTile(
                          title: 'Favorite Sports',
                          subtitle: user?.favoriteSports?.isNotEmpty == true
                              ? user!.favoriteSports!
                              : 'Not set yet',
                          icon: Icons.sports_soccer_rounded,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/user/preferences');
                          },
                        ),
                        _buildDivider(),
                        _buildListTile(
                          title: 'Preferred Time Slots',
                          subtitle: user?.preferredTimeSlots?.isNotEmpty == true
                              ? user!.preferredTimeSlots!
                              : 'Not set yet',
                          icon: Icons.access_time_rounded,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/user/preferences');
                          },
                        ),
                      ],
                    ),
                    const Gap(24),


                    // Account Settings
                    _buildSectionHeader('Account Settings'),
                    _buildSettingsCard(
                      children: [
                        _buildListTile(
                          title: 'Edit Profile',
                          subtitle: 'Update name, phone & change password',
                          icon: Icons.manage_accounts_rounded,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/user/edit-profile');
                          },
                        ),
                        _buildDivider(),
                        _buildListTile(
                          title: 'Active Sessions',
                          subtitle: '2 Devices Logged In',
                          icon: Icons.devices_rounded,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/user/sessions');
                          },
                        ),
                        _buildDivider(),
                        _buildListTile(
                          title: 'Theme & Display',
                          subtitle: appTheme == ThemeMode.system
                              ? 'System Default'
                              : appTheme == ThemeMode.dark
                                  ? 'Dark Mode'
                                  : 'Light Mode',
                          icon: Icons.dark_mode_rounded,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/user/theme');
                          },
                        ),
                      ],
                    ),
                    const Gap(32),

                    // Log Out Action
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        // Removed context.go() to avoid conflicting with GoRouter's built-in redirect listener mapping unauthenticated state
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          ref.read(authNotifierProvider.notifier).logout();
                        },
                        icon: const Icon(Icons.power_settings_new_rounded, color: AppColors.backgroundLight),
                        label: const Text('Log Out', style: TextStyle(color: AppColors.backgroundLight, fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
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

  Widget _buildQuickStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const Gap(8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const Gap(4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _showLoyaltyInfo(BuildContext context, int points) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Loyalty Rewards',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1)),
                IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textHint)),
              ],
            ),
            const Gap(24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.stars_rounded,
                      color: AppColors.warning, size: 36),
                ),
                const Gap(20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$points',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight)),
                    const Text('Total Points Earned',
                        style: TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            const Gap(32),
            const Text('HOW IT WORKS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.textHint)),
            const Gap(16),
            _buildLoyaltyRule(Icons.sports_soccer_rounded, 'Play & Earn',
                'Get 1 point for every ₹10 spent on confirmed bookings.'),
            const Gap(16),
            _buildLoyaltyRule(Icons.confirmation_number_rounded,
                'Unlock Coupons', 'Redeem points for flat discounts on your next games.'),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Back to Profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyRule(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Gap(2),
              Text(desc,
                  style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12,
                      height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 60),
      child: Divider(height: 1),
    );
  }
}
