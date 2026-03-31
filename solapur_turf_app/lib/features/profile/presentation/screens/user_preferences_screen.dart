import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

class UserPreferencesScreen extends ConsumerStatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  ConsumerState<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends ConsumerState<UserPreferencesScreen> {
  final List<String> _sportsOptions = [
    'Football', 'Box Cricket', 'Tennis', 'Basketball', 'Badminton', 'Volleyball',
  ];
  
  final List<String> _timeSlotOptions = [
    'Early Morning (5 AM - 8 AM)',
    'Morning (8 AM - 12 PM)',
    'Afternoon (12 PM - 4 PM)',
    'Evening (4 PM - 8 PM)',
    'Late Night (8 PM - 12 AM)',
  ];

  late Set<String> _selectedSports;
  late Set<String> _selectedTimeSlots;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedSports = {};
    _selectedTimeSlots = {};
    
    // Attempt to load existing data directly from the async provider state if loaded
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile?.favoriteSports != null && profile!.favoriteSports!.isNotEmpty) {
      _selectedSports.addAll(profile.favoriteSports!.split(', '));
    }
    if (profile?.preferredTimeSlots != null && profile!.preferredTimeSlots!.isNotEmpty) {
      _selectedTimeSlots.addAll(profile.preferredTimeSlots!.split(', '));
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    try {
      final updates = {
        'favoriteSports': _selectedSports.join(', '),
        'preferredTimeSlots': _selectedTimeSlots.join(', '),
      };
      // Calling the future provider directly updates and invalidates implicitly
      await ref.read(updateProfileProvider(updates).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved successfully!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Preferences', style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customize your experience',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: AppColors.textPrimaryLight),
            ),
            const Gap(8),
            const Text(
              'We use this to show you relevant turfs and notify you about related tournaments and deals.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight, height: 1.4),
            ),
            const Gap(32),

            // Favorite Sports
            const Text('Favorite Sports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
            const Gap(16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _sportsOptions.map((sport) {
                final isSelected = _selectedSports.contains(sport);
                return FilterChip(
                  label: Text(sport),
                  selected: isSelected,
                  onSelected: (selected) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      selected ? _selectedSports.add(sport) : _selectedSports.remove(sport);
                    });
                  },
                  backgroundColor: AppColors.surfaceLight,
                  selectedColor: AppColors.primaryContainer,
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryDark : AppColors.textSecondaryLight,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.dividerLight),
                  ),
                );
              }).toList(),
            ),
            const Gap(32),

            // Preferred Time Slots
            const Text('Preferred Time Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
            const Gap(16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _timeSlotOptions.map((slot) {
                final isSelected = _selectedTimeSlots.contains(slot);
                return FilterChip(
                  label: Text(slot.split(' (')[0]), // Show short name
                  tooltip: slot, // Show full time on long press if available
                  selected: isSelected,
                  onSelected: (selected) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      selected ? _selectedTimeSlots.add(slot) : _selectedTimeSlots.remove(slot);
                    });
                  },
                  backgroundColor: AppColors.surfaceLight,
                  selectedColor: AppColors.primaryContainer,
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryDark : AppColors.textSecondaryLight,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.dividerLight),
                  ),
                );
              }).toList(),
            ),
            
            const Gap(48),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePreferences,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const Gap(40),
          ],
        ),
      ),
    );
  }
}
