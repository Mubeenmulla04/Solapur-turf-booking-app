import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState
    extends ConsumerState<AdminUserManagementScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminAllUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminAllUsersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Container(
            color: AppColors.primaryDark,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name or email…',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon:
                    Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),

          // ── User List ──
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, __) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.error),
                    const Gap(12),
                    Text('Failed to load users',
                        style: TextStyle(color: AppColors.textSecondaryLight)),
                    const Gap(8),
                    TextButton(
                      onPressed: () => ref.invalidate(adminAllUsersProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (users) {
                final filtered = _search.isEmpty
                    ? users
                    : users.where((u) {
                        final name =
                            (u['fullName'] ?? '').toString().toLowerCase();
                        final email =
                            (u['email'] ?? '').toString().toLowerCase();
                        return name.contains(_search) || email.contains(_search);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 64,
                            color: AppColors.textSecondaryLight.withOpacity(0.4)),
                        const Gap(12),
                        const Text('No users found',
                            style:
                                TextStyle(color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Gap(10),
                  itemBuilder: (_, i) => _UserCard(
                    user: filtered[i],
                    onStatusChanged: (userId, isActive) =>
                        _toggleStatus(userId, isActive),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleStatus(String userId, bool isActive) async {
    final dio = ref.read(apiClientProvider);
    try {
      await dio.patch('/users/$userId/status', data: {'isActive': isActive});
      ref.invalidate(adminAllUsersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isActive ? '✅ User activated' : '🚫 User suspended'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isActive ? AppColors.success : AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to update status'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final Future<void> Function(String userId, bool isActive) onStatusChanged;

  const _UserCard({required this.user, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final name = user['fullName'] as String? ?? 'Unknown';
    final email = user['email'] as String? ?? '';
    final role = user['role'] as String? ?? 'USER';
    final isActive = user['isActive'] as bool? ?? true;
    final userId = user['userId'] as String? ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final Color roleColor = switch (role) {
      'ADMIN' => const Color(0xFF8B5CF6),
      'OWNER' => AppColors.warning,
      _ => AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColors.dividerLight
              : AppColors.error.withOpacity(0.3),
        ),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowLight, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: roleColor.withOpacity(0.12),
            child: Text(initial,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                    fontSize: 18)),
          ),
          const Gap(14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimaryLight),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(role,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: roleColor)),
                    ),
                  ],
                ),
                const Gap(2),
                Text(email,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight),
                    overflow: TextOverflow.ellipsis),
                const Gap(4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const Gap(5),
                    Text(isActive ? 'Active' : 'Suspended',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color:
                                isActive ? AppColors.success : AppColors.error)),
                  ],
                ),
              ],
            ),
          ),
          const Gap(8),
          // Toggle button
          if (role != 'ADMIN')
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _confirmToggle(context, userId, isActive, name);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.error.withOpacity(0.08)
                      : AppColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? AppColors.error.withOpacity(0.3)
                        : AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  isActive ? 'Suspend' : 'Activate',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.error : AppColors.success),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmToggle(
      BuildContext context, String userId, bool isActive, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isActive ? 'Suspend User?' : 'Activate User?',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          isActive
              ? 'Are you sure you want to suspend "$name"? They will not be able to log in.'
              : 'Re-activate "$name"? They will regain full access.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.error : AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onStatusChanged(userId, !isActive);
            },
            child: Text(isActive ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );
  }
}
