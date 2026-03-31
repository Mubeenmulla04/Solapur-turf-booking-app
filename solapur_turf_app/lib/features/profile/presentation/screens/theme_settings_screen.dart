import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    // Automatically match system overlay style
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    SystemChrome.setSystemUIOverlayStyle(isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Display & Theme', style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Text(
            'Choose your style',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
          const Gap(8),
          Text(
            'Customize how Solapur Turf looks on your device.',
            style: TextStyle(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, height: 1.4),
          ),
          const Gap(32),

          _buildThemeCard(
            title: 'Light Mode',
            description: 'Clean and bright, easy on the eyes during daytime.',
            icon: Icons.light_mode_rounded,
            isSelected: themeMode == ThemeMode.light,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              themeNotifier.setTheme(ThemeMode.light);
            },
          ),
          const Gap(16),
          
          _buildThemeCard(
            title: 'Dark Mode',
            description: 'Reduces battery usage, perfect for low-light environments.',
            icon: Icons.dark_mode_rounded,
            isSelected: themeMode == ThemeMode.dark,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              themeNotifier.setTheme(ThemeMode.dark);
            },
          ),
          const Gap(16),

          _buildThemeCard(
            title: 'System Default',
            description: 'Automatically switches based on your device settings.',
            icon: Icons.brightness_auto_rounded,
            isSelected: themeMode == ThemeMode.system,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              themeNotifier.setTheme(ThemeMode.system);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isDark ? (isSelected ? AppColors.surfaceVariantDark : AppColors.surfaceDark) : (isSelected ? AppColors.surfaceVariantLight : AppColors.surfaceLight);
    final borderColor = isSelected ? (isDark ? AppColors.primaryLight : AppColors.primary) : (isDark ? AppColors.dividerDark : AppColors.dividerLight);
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor.withOpacity(0.1) : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? primaryColor : hintColor, size: 28),
            ),
            const Gap(20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                  const Gap(4),
                  Text(description, style: TextStyle(fontSize: 13, height: 1.3, color: hintColor)),
                ],
              ),
            ),
            if (isSelected)
               Icon(Icons.check_circle_rounded, color: primaryColor, size: 28)
            else
               const SizedBox(width: 28, height: 28),
          ],
        ),
      ),
    );
  }
}
