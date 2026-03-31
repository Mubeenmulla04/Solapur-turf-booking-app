import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';

class UserSessionsScreen extends ConsumerWidget {
  const UserSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Active Sessions', style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const Text(
            'Devices currently logged in',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: AppColors.textPrimaryLight),
          ),
          const Gap(8),
          const Text(
            'If you see a device you do not recognize, sign out immediately.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight, height: 1.4),
          ),
          const Gap(32),

          // Current Device
          _buildSessionCard(
            deviceName: 'iPhone 14 Pro',
            location: 'Solapur, Maharashtra',
            time: 'Active now',
            icon: Icons.phone_iphone_rounded,
            isCurrentDevice: true,
          ),
          const Gap(16),

          // Other Device
          _buildSessionCard(
            deviceName: 'MacBook Pro 14"',
            location: 'Pune, Maharashtra',
            time: 'Last active 2 days ago',
            icon: Icons.laptop_mac_rounded,
            isCurrentDevice: false,
          ),

          const Gap(40),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All other sessions signed out.')));
              },
              icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.error),
              label: const Text('Sign Out of All Other Devices', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required String deviceName,
    required String location,
    required String time,
    required IconData icon,
    required bool isCurrentDevice,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariantLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(deviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimaryLight)),
                    if (isCurrentDevice)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Text('THIS DEVICE', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      )
                    else
                      InkWell(
                        onTap: () {},
                         child: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const Gap(8),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondaryLight),
                    const Gap(4),
                    Text(location, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                  ],
                ),
                const Gap(4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondaryLight),
                    const Gap(4),
                    Text(time, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
