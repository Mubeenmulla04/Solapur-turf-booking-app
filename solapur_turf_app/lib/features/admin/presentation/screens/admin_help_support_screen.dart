import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';

class AdminHelpSupportScreen extends StatelessWidget {
  const AdminHelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Help & Support',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Banner ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF0E7C61)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.support_agent_rounded,
                      color: Colors.white, size: 36),
                  Gap(12),
                  Text('Admin Support Center',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  Gap(6),
                  Text(
                    'Architecture documentation and vendor contacts for the Solapur Turf platform.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const Gap(28),

            // ── Architecture Overview ──
            const _SectionHeader(
                label: 'SYSTEM ARCHITECTURE', icon: Icons.account_tree_rounded),
            const Gap(14),
            _InfoCard(
              icon: Icons.phone_android_rounded,
              title: 'Flutter Frontend',
              subtitle: 'Cross-platform mobile app (Android & iOS)',
              detail: 'Flutter 3.x · Riverpod · GoRouter · Dio',
              color: const Color(0xFF0EA5E9),
            ),
            const Gap(10),
            _InfoCard(
              icon: Icons.storage_rounded,
              title: 'Spring Boot Backend',
              subtitle: 'REST API server with JWT authentication',
              detail: 'Java 17 · Spring Boot 3 · Spring Security · JPA',
              color: const Color(0xFF6366F1),
            ),
            const Gap(10),
            _InfoCard(
              icon: Icons.data_usage_rounded,
              title: 'PostgreSQL Database',
              subtitle: 'Relational data storage',
              detail: 'PostgreSQL 15 · Flyway migrations · UUID primary keys',
              color: AppColors.success,
            ),
            const Gap(10),
            _InfoCard(
              icon: Icons.cloud_rounded,
              title: 'Razorpay Gateway',
              subtitle: 'Payment processing',
              detail: 'Test mode · Webhook integration ready',
              color: AppColors.warning,
            ),
            const Gap(28),

            // ── Quick Help ──
            const _SectionHeader(
                label: 'QUICK HELP', icon: Icons.help_outline_rounded),
            const Gap(14),
            ..._faqs.map((faq) => _FaqTile(
                  question: faq['q']!,
                  answer: faq['a']!,
                )),
            const Gap(28),

            // ── Contact ──
            const _SectionHeader(
                label: 'VENDOR CONTACTS', icon: Icons.contact_phone_rounded),
            const Gap(14),
            _ContactTile(
              name: 'Platform Support',
              email: 'support@solapurturf.com',
              role: 'General enquiries & technical issues',
              icon: Icons.email_outlined,
            ),
            const Gap(10),
            _ContactTile(
              name: 'Razorpay Support',
              email: 'support.razorpay.com',
              role: 'Payment gateway issues',
              icon: Icons.payment_rounded,
            ),
            const Gap(10),
            _ContactTile(
              name: 'Infrastructure / DevOps',
              email: 'devops@solapurturf.com',
              role: 'Server uptime & deployment issues',
              icon: Icons.dns_rounded,
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How do I reset a user\'s password?',
      'a':
          'Go to User Management, tap on the user, and use the "Reset Password" option. An OTP will be sent to their registered email.',
    },
    {
      'q': 'How does the commission system work?',
      'a':
          'Set the commission percentage in Platform Settings. That % is deducted from each booking amount before the turf owner receives their settlement.',
    },
    {
      'q': 'What does Maintenance Mode do?',
      'a':
          'When Maintenance Mode is ON, new user registrations and bookings are paused. Existing sessions remain active.',
    },
    {
      'q': 'How to approve a new turf listing?',
      'a':
          'The turf approval workflow is handled via the Owner portal. Owners submit listings and the admin receives a notification for review via the Bookings module.',
    },
  ];
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondaryLight, size: 15),
        const Gap(8),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondaryLight,
                letterSpacing: 1.5)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowLight, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimaryLight)),
                const Gap(2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight)),
                const Gap(4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(detail,
                      style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _open
                  ? AppColors.primary.withOpacity(0.4)
                  : AppColors.dividerLight),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.question_mark_rounded,
                      color: AppColors.primary, size: 16),
                  const Gap(10),
                  Expanded(
                    child: Text(widget.question,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textPrimaryLight)),
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ),
            if (_open)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Text(widget.answer,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                        height: 1.5)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final IconData icon;

  const _ContactTile({
    required this.name,
    required this.email,
    required this.role,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimaryLight)),
                const Gap(2),
                Text(role,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondaryLight)),
                const Gap(4),
                Text(email,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
