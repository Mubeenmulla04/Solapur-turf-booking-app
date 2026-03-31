import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminAuditLogScreen extends ConsumerWidget {
  const AdminAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(adminAuditLogProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Audit Log',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminAuditLogProvider),
          ),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const Gap(12),
              const Text('Failed to load audit log'),
              const Gap(8),
              TextButton(
                  onPressed: () => ref.invalidate(adminAuditLogProvider),
                  child: const Text('Retry')),
            ],
          ),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.history_rounded,
                    size: 64,
                    color: AppColors.textSecondaryLight.withOpacity(0.3)),
                const Gap(12),
                const Text('No audit logs yet',
                    style: TextStyle(color: AppColors.textSecondaryLight)),
              ]),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(adminAuditLogProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: logs.length,
              itemBuilder: (_, i) {
                final log = logs[i];
                final actor = log['actor']?.toString() ?? 'SYSTEM';
                final action = log['action']?.toString() ?? '';
                final timestamp = log['timestamp']?.toString() ?? '';

                final isAdmin = actor == 'ADMIN';
                final color = isAdmin ? AppColors.primary : const Color(0xFF6366F1);
                final icon =
                    isAdmin ? Icons.admin_panel_settings_rounded : Icons.computer_rounded;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline line
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        if (i < logs.length - 1)
                          Container(
                            width: 2,
                            height: 52,
                            color: AppColors.dividerLight,
                          ),
                      ],
                    ),
                    const Gap(14),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(actor,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: color)),
                                ),
                                const Spacer(),
                                Text(
                                  _formatTimestamp(timestamp),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                            const Gap(6),
                            Text(action,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(String ts) {
    if (ts.isEmpty) return '';
    try {
      final dt = DateTime.parse(ts);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return ts.length > 16 ? ts.substring(0, 16) : ts;
    }
  }
}
