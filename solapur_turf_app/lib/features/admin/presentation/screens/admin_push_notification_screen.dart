import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';

class AdminPushNotificationScreen extends ConsumerStatefulWidget {
  const AdminPushNotificationScreen({super.key});

  @override
  ConsumerState<AdminPushNotificationScreen> createState() =>
      _AdminPushNotificationScreenState();
}

class _AdminPushNotificationScreenState
    extends ConsumerState<AdminPushNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _audience = 'ALL';
  bool _sending = false;
  bool _sent = false;

  static const _audiences = ['ALL', 'USERS', 'OWNERS'];
  static const _audienceLabels = {
    'ALL': 'All Users',
    'USERS': 'Players Only',
    'OWNERS': 'Turf Owners Only',
  };
  static const _audienceIcons = {
    'ALL': Icons.public_rounded,
    'USERS': Icons.sports_soccer_rounded,
    'OWNERS': Icons.storefront_rounded,
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Push Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Broadcast Header ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Gap(16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Broadcast Message',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Gap(4),
                          Text(
                            'Send a push notification to your selected audience',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // ── Audience Selector ──
              const Text(
                'TARGET AUDIENCE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondaryLight,
                    letterSpacing: 1.5),
              ),
              const Gap(12),
              Row(
                children: _audiences.map((a) {
                  final selected = _audience == a;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: a != 'OWNERS' ? 10 : 0),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _audience = a);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF8B5CF6)
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF8B5CF6)
                                  : AppColors.dividerLight,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _audienceIcons[a]!,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondaryLight,
                                size: 22,
                              ),
                              const Gap(6),
                              Text(
                                _audienceLabels[a]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Gap(24),

              // ── Title Field ──
              const Text(
                'NOTIFICATION TITLE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondaryLight,
                    letterSpacing: 1.5),
              ),
              const Gap(10),
              TextFormField(
                controller: _titleCtrl,
                decoration: _inputDec(
                    hint: 'e.g. New Weekend Offer 🎉',
                    icon: Icons.title_rounded),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
                maxLength: 60,
              ),
              const Gap(20),

              // ── Message Body ──
              const Text(
                'MESSAGE BODY',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondaryLight,
                    letterSpacing: 1.5),
              ),
              const Gap(10),
              TextFormField(
                controller: _messageCtrl,
                decoration:
                    _inputDec(hint: 'Write your message here…', icon: Icons.message_rounded),
                maxLines: 4,
                maxLength: 200,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Message is required' : null,
              ),
              const Gap(28),

              // ── Preview ──
              if (_titleCtrl.text.isNotEmpty || _messageCtrl.text.isNotEmpty) ...[
                const Text(
                  'PREVIEW',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondaryLight,
                      letterSpacing: 1.5),
                ),
                const Gap(10),
                _NotificationPreview(
                  title: _titleCtrl.text,
                  message: _messageCtrl.text,
                ),
                const Gap(20),
              ],

              // ── Send Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sending ? null : _sendBroadcast,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    _sending ? 'Sending…' : 'Send Broadcast',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    disabledBackgroundColor:
                        const Color(0xFF8B5CF6).withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondaryLight, size: 20),
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
      ),
    );
  }

  Future<void> _sendBroadcast() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.heavyImpact();
    setState(() => _sending = true);

    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/admin/notifications/broadcast', data: {
        'title': _titleCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
        'audience': _audience,
      });

      if (mounted) {
        setState(() {
          _sending = false;
          _sent = true;
        });
        _titleCtrl.clear();
        _messageCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                Gap(10),
                Text('Broadcast sent successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF8B5CF6),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      setState(() => _sending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to send broadcast'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }
}

class _NotificationPreview extends StatelessWidget {
  final String title;
  final String message;
  const _NotificationPreview({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_rounded,
                color: Color(0xFF8B5CF6), size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Notification Title' : title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimaryLight),
                ),
                const Gap(4),
                Text(
                  message.isEmpty ? 'Your message will appear here…' : message,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondaryLight),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
