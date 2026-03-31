import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_widgets.dart';

class OwnerCreateTurfScreen extends ConsumerStatefulWidget {
  const OwnerCreateTurfScreen({super.key});

  @override
  ConsumerState<OwnerCreateTurfScreen> createState() => _OwnerCreateTurfScreenState();
}

class _OwnerCreateTurfScreenState extends ConsumerState<OwnerCreateTurfScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pinCodeCtrl = TextEditingController();
  final _pitchSizeCtrl = TextEditingController(text: '5v5');
  final _hourlyRateCtrl = TextEditingController();
  final _peakHourlyRateCtrl = TextEditingController();

  String _sport = 'FOOTBALL';
  String _surface = 'ARTIFICIAL_GRASS';
  bool _isIndoor = false;
  bool _isLoading = false;
  List<File> _uploadedImages = [];
  TimeOfDay _openTime = const TimeOfDay(hour: 6, minute: 0); // 6 AM
  TimeOfDay _closeTime = const TimeOfDay(hour: 23, minute: 0); // 11 PM

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pinCodeCtrl.dispose();
    _pitchSizeCtrl.dispose();
    _hourlyRateCtrl.dispose();
    _peakHourlyRateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    HapticFeedback.lightImpact();
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _openTime : _closeTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          if (isStart) {
            _openTime = picked;
          } else {
            _closeTime = picked;
          }
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final dio = ref.read(apiClientProvider);

      String formatTime(TimeOfDay td) => 
         '${td.hour.toString().padLeft(2, '0')}:${td.minute.toString().padLeft(2, '0')}:00';

      // 1. Create the Turf Listing
      final createRes = await dio.post('/turfs', data: {
        'turfName': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'pinCode': _pinCodeCtrl.text.trim(),
        'sportType': _sport,
        'surfaceType': _surface,
        'pitchSize': _pitchSizeCtrl.text.trim(),
        'isIndoor': _isIndoor,
        'hourlyRate': double.parse(_hourlyRateCtrl.text.trim()),
        'peakHourRate': _peakHourlyRateCtrl.text.trim().isNotEmpty ? double.parse(_peakHourlyRateCtrl.text.trim()) : null,
        // Added for partial Medium fix
        'openingTime': formatTime(_openTime),
        'closingTime': formatTime(_closeTime),
      });

      final turfId = createRes.data['data']['turfId'];

      // 2. Upload Images if any
      if (_uploadedImages.isNotEmpty && turfId != null) {
        var formData = FormData();
        for (var file in _uploadedImages) {
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
          ));
        }

        await dio.post(
          '/turfs/$turfId/images',
          data: formData,
        );
      }

      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Turf registered successfully! 🏗️'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/owner/dashboard');
      }
    } catch (e, st) {
      if (mounted) {
        HapticFeedback.vibrate();
        print('Error creating turf: $e\n$st');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString().replaceAll("Exception:", "")}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    
    SystemChrome.setSystemUIOverlayStyle(isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    
    const sports = ['FOOTBALL', 'BOX_CRICKET', 'BASKETBALL', 'VOLLEYBALL', 'TENNIS', 'BADMINTON', 'MULTI_SPORT'];
    const surfaces = ['ARTIFICIAL_GRASS', 'NATURAL_GRASS', 'CONCRETE', 'WOODEN', 'SYNTHETIC_HARD_COURT', 'CLAY'];

    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: t.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: t.colorScheme.onSurface),
        centerTitle: true,
        title: Text(
          'Register New Turf',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.colorScheme.onSurface),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Hero ──
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? [const Color(0xFF0F172A), const Color(0xFF1E293B)] : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(right: -30, top: -30, child: Icon(Icons.stadium_rounded, size: 140, color: Colors.white.withOpacity(0.05))),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: const Text('NEW PROPERTY', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                          const Gap(16),
                          const Text('Register Turf', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1, color: Colors.white)),
                          const Gap(8),
                          Text('Expand your business by listing a new playground and accepting bookings instantly.', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), height: 1.4, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(32),

                // ── Property Identity ──
                _buildSectionHeader('Property Identity', Icons.title_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  AppTextField(
                    label: 'Turf Name',
                    hint: 'e.g. Apex Sports Arena',
                    controller: _nameCtrl,
                    validator: (v) => AppValidators.required(v, fieldName: 'Name'),
                    prefixIcon: const Icon(Icons.stadium_rounded, color: AppColors.primary),
                    enabled: !_isLoading,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const Gap(16),
                  AppTextField(
                    label: 'Description / Amenities',
                    hint: 'Details about the turf, facilities available...',
                    controller: _descCtrl,
                    maxLines: 3,
                    enabled: !_isLoading,
                  ),
                ]),
                const Gap(32),

                // ── Location Details ──
                _buildSectionHeader('Location Details', Icons.location_on_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  AppTextField(
                    label: 'Complete Address',
                    hint: 'Street, Landmark...',
                    controller: _addressCtrl,
                    validator: (v) => AppValidators.required(v, fieldName: 'Address'),
                    prefixIcon: const Icon(Icons.map_rounded, color: AppColors.primary),
                    enabled: !_isLoading,
                  ),
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(label: 'City', controller: _cityCtrl, validator: (v) => AppValidators.required(v, fieldName: 'City'), enabled: !_isLoading),
                      ),
                      const Gap(16),
                      Expanded(
                        child: AppTextField(label: 'State', controller: _stateCtrl, validator: (v) => AppValidators.required(v, fieldName: 'State'), enabled: !_isLoading),
                      ),
                    ],
                  ),
                  const Gap(16),
                  AppTextField(label: 'Pincode', controller: _pinCodeCtrl, keyboardType: TextInputType.number, validator: (v) => AppValidators.required(v, fieldName: 'Pincode'), enabled: !_isLoading),
                ]),
                const Gap(32),

                // ── Facility Specifications ──
                _buildSectionHeader('Facility Specifications', Icons.tune_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            initialValue: _sport,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
                            decoration: const InputDecoration(labelText: 'Primary Sport', border: InputBorder.none, isDense: true),
                            items: sports.map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' '), overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, color: t.colorScheme.onSurface, fontSize: 13)))).toList(),
                            onChanged: _isLoading ? null : (v) => setState(() => _sport = v!),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 40, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      const Gap(16),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            initialValue: _surface,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
                            decoration: const InputDecoration(labelText: 'Surface Type', border: InputBorder.none, isDense: true),
                            items: surfaces.map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' '), overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontWeight: FontWeight.w600, color: t.colorScheme.onSurface, fontSize: 12)))).toList(),
                            onChanged: _isLoading ? null : (v) => setState(() => _surface = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Pitch Size',
                          hint: 'e.g. 5v5',
                          controller: _pitchSizeCtrl,
                          validator: (v) => AppValidators.required(v, fieldName: 'Size'),
                          enabled: !_isLoading,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Indoor Turf?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.colorScheme.onSurface)),
                          trailing: Switch(
                            value: _isIndoor,
                            activeColor: const Color(0xFF10B981),
                            onChanged: _isLoading ? null : (v) => setState(() => _isIndoor = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
                const Gap(32),

                // ── Operating Hours ──
                _buildSectionHeader('Operating Hours', Icons.schedule_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  Row(
                    children: [
                      Expanded(
                        child: _TimeTile(
                          label: 'Opening Time',
                          time: _openTime.format(context),
                          onTap: () => _pickTime(true),
                          isDark: isDark,
                          t: t,
                        ),
                      ),
                      const Gap(12),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.textHint, size: 16),
                      const Gap(12),
                      Expanded(
                        child: _TimeTile(
                          label: 'Closing Time',
                          time: _closeTime.format(context),
                          onTap: () => _pickTime(false),
                          isDark: isDark,
                          t: t,
                        ),
                      ),
                    ],
                  ),
                ]),
                const Gap(32),
                
                // ── Images & Media ──
                _buildSectionHeader('Media & Photos', Icons.collections_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: t.inputDecorationTheme.fillColor,
                      border: Border.all(color: isDark ? const Color(0xFF475569) : AppColors.dividerLight),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          if (_uploadedImages.length >= 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Maximum 5 images allowed.')),
                            );
                            return;
                          }
                          final picker = ImagePicker();
                          final xfiles = await picker.pickMultiImage(limit: 5 - _uploadedImages.length);
                          if (xfiles.isNotEmpty) {
                            setState(() {
                              _uploadedImages.addAll(xfiles.map((e) => File(e.path)));
                            });
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 28),
                              ),
                              const Gap(12),
                              Text(
                                'Tap to upload turf photos',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.colorScheme.onSurface),
                              ),
                              const Gap(4),
                              Text(
                                'JPG, PNG format (Max 5MB each)',
                                style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_uploadedImages.isNotEmpty) ...[
                    const Gap(16),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _uploadedImages.length,
                        separatorBuilder: (_, __) => const Gap(12),
                        itemBuilder: (context, index) {
                          return Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryLight),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_uploadedImages[index], fit: BoxFit.cover),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _uploadedImages.removeAt(index));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ]),
                const Gap(32),

                // ── Economics ──
                _buildSectionHeader('Economics (Pricing)', Icons.currency_rupee_rounded, isDark),
                const Gap(16),
                _buildCardGroup(t, [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Hourly Rate (₹)',
                          hint: 'e.g. 1000',
                          controller: _hourlyRateCtrl,
                          validator: AppValidators.positiveNumber,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.payments_rounded, color: AppColors.primary),
                          enabled: !_isLoading,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: AppTextField(
                          label: 'Peak Rate (₹)',
                          hint: 'Optional',
                          controller: _peakHourlyRateCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.trending_up_rounded, color: AppColors.warning),
                          enabled: !_isLoading,
                        ),
                      ),
                    ],
                  ),
                ]),
                const Gap(48),

                // ── Submit ──
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    shadowColor: const Color(0xFF10B981).withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Publish Turf to Network', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Gap(8),
                            Icon(Icons.publish_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                ),
                const Gap(40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        const Gap(8),
        Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 1)),
      ],
    );
  }

  Widget _buildCardGroup(ThemeData t, List<Widget> children) {
    final isDark = t.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [if (!isDark) BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;
  final bool isDark;
  final ThemeData t;

  const _TimeTile({required this.label, required this.time, required this.onTap, required this.isDark, required this.t});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: t.inputDecorationTheme.fillColor,
          border: Border.all(color: isDark ? const Color(0xFF475569) : AppColors.dividerLight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
              ],
            ),
            const Gap(8),
            Text(
              time,
              style: TextStyle(fontWeight: FontWeight.bold, color: t.colorScheme.onSurface, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
