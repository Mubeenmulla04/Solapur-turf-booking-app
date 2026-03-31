import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ── Owner Profile Data Provider ───────────────────────────────────────────────

final _ownerProfileProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/owners/me');
    if (res.data != null && res.data['data'] is Map) {
      return res.data['data'] as Map<String, dynamic>;
    }
    return {};
  } catch (e) {
    return {};
  }
});

// ── Screen ────────────────────────────────────────────────────────────────────

class OwnerProfileScreen extends ConsumerWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.valueOrNull?.user;
    final ownerProfile = ref.watch(_ownerProfileProvider);

    final fullName = user?.fullName ?? 'Owner';
    final email = user?.email ?? '';
    final initials = fullName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient AppBar ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.backgroundLight,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Gap(16),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.white,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ),
                        const Gap(12),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                                  Gap(4),
                                  Text(
                                    'Turf Partner',
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
                      ],
                    ),
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business Info Card
                    ownerProfile.when(
                      loading: () => const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      ),
                      error: (_, __) => const _BusinessInfoCard(profile: {}), // Show placeholder on error
                      data: (profile) => InkWell(
                        onTap: () => _showEditDialog(
                          context,
                          ref,
                          'businessName',
                          'Business Name',
                          profile['businessName']?.toString() ?? '',
                          TextInputType.text,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: _BusinessInfoCard(profile: profile),
                      ),
                    ),

                    const Gap(24),

                    // Location & Address (Moved Up)
                    _SectionLabel('Location & Address'),
                    _SettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Office Address',
                      subtitle: ownerProfile.valueOrNull?['addressLine1']?.toString() ?? 'Not set',
                      onTap: () => _showEditDialog(
                        context,
                        ref,
                        'addressLine1',
                        'Address Line 1',
                        ownerProfile.valueOrNull?['addressLine1']?.toString() ?? '',
                        TextInputType.streetAddress,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.add_location_outlined,
                      title: 'Secondary Address',
                      subtitle: ownerProfile.valueOrNull?['addressLine2']?.toString() ?? 'Optional',
                      onTap: () => _showEditDialog(
                        context,
                        ref,
                        'addressLine2',
                        'Address Line 2 (Optional)',
                        ownerProfile.valueOrNull?['addressLine2']?.toString() ?? '',
                        TextInputType.streetAddress,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.location_city_outlined,
                      title: 'City',
                      subtitle: ownerProfile.valueOrNull?['city']?.toString() ?? 'Not set',
                      onTap: () => _showEditDialog(
                        context,
                        ref,
                        'city',
                        'City',
                        ownerProfile.valueOrNull?['city']?.toString() ?? '',
                        TextInputType.text,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.map_outlined,
                      title: 'State',
                      subtitle: ownerProfile.valueOrNull?['state']?.toString() ?? 'Not set',
                      onTap: () => _showEditDialog(
                        context,
                        ref,
                        'state',
                        'State',
                        ownerProfile.valueOrNull?['state']?.toString() ?? '',
                        TextInputType.text,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.pin_drop_outlined,
                      title: 'Pin Code',
                      subtitle: ownerProfile.valueOrNull?['pinCode']?.toString() ?? 'Not set',
                      onTap: () => _showEditDialog(
                        context,
                        ref,
                        'pinCode',
                        'Pin Code',
                        ownerProfile.valueOrNull?['pinCode']?.toString() ?? '',
                        TextInputType.number,
                      ),
                    ),

                    const Gap(24),
                    
                    // Contact & Account
                    _SectionLabel('Account Settings'),
                    _SettingsTile(
                      icon: Icons.email_outlined,
                      title: 'Email Address',
                      subtitle: email,
                      onTap: null, // Readonly
                      trailing: const SizedBox.shrink(),
                    ),
                    _SettingsTile(
                      icon: Icons.phone_outlined,
                      title: 'Contact Number',
                      subtitle: ownerProfile.valueOrNull?['contactNumber']?.toString() ?? 'Not set',
                      onTap: () => _showEditDialog(
                        context,
                        ref,
                        'contactNumber',
                        'Contact Number',
                        ownerProfile.valueOrNull?['contactNumber']?.toString() ?? '',
                        TextInputType.phone,
                      ),
                    ),

                    const Gap(24),

                    // Banking & Settlements
                    _SectionLabel('Banking & Settlements'),
                    _SettingsTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'UPI ID',
                      subtitle: _mask(ownerProfile.valueOrNull?['upiId']?.toString()),
                      onTap: () => _showEditDialog(
                        context,
                        ref,
                        'upiId',
                        'UPI ID',
                        ownerProfile.valueOrNull?['upiId']?.toString() ?? '',
                        TextInputType.emailAddress,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.account_balance_outlined,
                      title: 'Bank Account',
                      subtitle: _maskAccount(ownerProfile.valueOrNull?['bankAccountNumber']?.toString()),
                      onTap: () => _showEditDialog(
                        context,
                        ref,
                        'bankAccountNumber',
                        'Bank Account Number',
                        ownerProfile.valueOrNull?['bankAccountNumber']?.toString() ?? '',
                        TextInputType.number,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.vpn_key_outlined,
                      title: 'IFSC Code',
                      subtitle: ownerProfile.valueOrNull?['ifscCode']?.toString() ?? 'Not set',
                      onTap: () => _showEditDialog(
                        context,
                        ref,
                        'ifscCode',
                        'IFSC Code',
                        ownerProfile.valueOrNull?['ifscCode']?.toString() ?? '',
                        TextInputType.text,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.currency_rupee_rounded,
                      title: 'Total Earnings',
                      subtitle: '₹${ownerProfile.valueOrNull?['totalEarnings'] ?? '0'}',
                      onTap: null,
                      trailing: const SizedBox.shrink(),
                    ),
                    _SettingsTile(
                      icon: Icons.pending_outlined,
                      title: 'Pending Settlement',
                      subtitle: '₹${ownerProfile.valueOrNull?['pendingSettlement'] ?? '0'}',
                      onTap: null,
                      trailing: const SizedBox.shrink(),
                    ),

                    const Gap(24),

                    // Verification Status
                    _SectionLabel('Verification Status'),
                    _VerificationBanner(
                      status: ownerProfile.valueOrNull?['verificationStatus']?.toString() ?? 'PENDING',
                    ),

                    const Gap(24),

                    // Support & More
                    _SectionLabel('Support & More'),
                    _SettingsTile(
                      icon: Icons.contact_support_outlined,
                      title: 'Platform Support',
                      subtitle: 'Connect via WhatsApp for instant help',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.camera_alt_outlined,
                      title: 'Instagram',
                      subtitle: '@solapurturf_official',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Service Agreement',
                      subtitle: 'View your contract and terms',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we protect your data',
                      onTap: () {},
                    ),

                    const Gap(24),

                    // Danger Zone
                    _SectionLabel('Account Actions'),
                    _SettingsTile(
                      icon: Icons.no_accounts_outlined,
                      title: 'Deactivate Account',
                      subtitle: 'Temporarily stop receiving bookings',
                      iconBg: AppColors.error.withOpacity(0.1),
                      iconColor: AppColors.error,
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.delete_forever_outlined,
                      title: 'Delete Data',
                      subtitle: 'Permanently remove account history',
                      iconBg: AppColors.error.withOpacity(0.1),
                      iconColor: AppColors.error,
                      onTap: () {},
                    ),

                    const Gap(32),

                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          HapticFeedback.heavyImpact();
                          await ref.read(authNotifierProvider.notifier).logout();
                          if (context.mounted) context.go('/auth/login');
                        },
                        icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
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

  String _mask(String? value) {
    if (value == null || value.isEmpty) return 'Not set';
    if (value.length <= 4) return value;
    return '${value.substring(0, 3)}${'*' * (value.length - 4)}${value.substring(value.length - 2)}';
  }

  String _maskAccount(String? value) {
    if (value == null || value.isEmpty) return 'Not set';
    if (value.length <= 4) return value;
    return '****${value.substring(value.length - 4)}';
  }

  void _showEditDialog(
      BuildContext context,
      WidgetRef ref,
      String fieldKey,
      String label,
      String initialValue,
      TextInputType keyboardType) {
    final ctrl = TextEditingController(text: initialValue);
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (c, setState) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit $label',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight)),
              const Gap(20),
              TextField(
                controller: ctrl,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                autofocus: true,
                onSubmitted: (_) {},
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (ctrl.text.isEmpty) return;
                          setState(() => isLoading = true);
                          try {
                            HapticFeedback.lightImpact();
                            final dio = ref.read(apiClientProvider);
                            await dio.put('/owners/me', data: {fieldKey: ctrl.text.trim()});
                            ref.invalidate(_ownerProfileProvider);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$label updated successfully'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update. Try again.'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            if (ctx.mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? iconBg;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing = const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
    this.iconColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: AppColors.surfaceLight,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg ?? AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
        ),
        trailing: onTap != null ? trailing : null,
      ),
    );
  }
}

class _BusinessInfoCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _BusinessInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.primaryContainer.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business_rounded, color: AppColors.primary, size: 20),
              const Gap(8),
              Expanded(
                child: Text(
                  profile['businessName']?.toString() ?? 'Your Business',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const Icon(Icons.edit_outlined, color: AppColors.primary, size: 16),
            ],
          ),
          const Gap(8),
          Text(
            '${profile['addressLine1'] ?? 'Set Address'}, ${profile['city'] ?? 'Set City'}, ${profile['state'] ?? 'Set State'} - ${profile['pinCode'] ?? 'Set Pin'}',
            style: const TextStyle(fontSize: 13, color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  final String status;
  const _VerificationBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final statusStr = status.toUpperCase();
    final isVerified = statusStr == 'VERIFIED' || statusStr == 'APPROVED';
    final isPending = statusStr == 'PENDING';
    
    final color = isVerified
        ? AppColors.success
        : isPending
            ? AppColors.warning
            : AppColors.error;
    final icon = isVerified
        ? Icons.verified_rounded
        : isPending
            ? Icons.hourglass_empty_rounded
            : Icons.cancel_rounded;
    final message = isVerified
        ? 'Your account is fully verified and approved'
        : isPending
            ? 'Verification under review. Usually takes 48 hours.'
            : 'Verification rejected. Please contact support.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
                const Gap(2),
                Text(
                  message,
                  style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
