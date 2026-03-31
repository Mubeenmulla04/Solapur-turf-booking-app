import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';

// â”€â”€ Provider for fetching pending owners â”€â”€
final pendingOwnersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  // Use extra: {'refresh': true} to force CacheInterceptor to bypass cache and hit network
  final res = await dio.get('/admin/owners/pending', options: Options(extra: {'refresh': true}));
  if (res.data is Map && res.data['data'] is List) {
    return List<Map<String, dynamic>>.from(res.data['data']);
  }
  return [];
});

class AdminOwnerApprovalsScreen extends ConsumerWidget {
  const AdminOwnerApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final ownersAsync = ref.watch(pendingOwnersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // â”€â”€ Header â”€â”€
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimaryLight, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const Gap(8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pending Approvals', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: AppColors.textPrimaryLight)),
                        Text('Review new turf owner registrations', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                    onPressed: () => ref.invalidate(pendingOwnersProvider),
                  ),
                ],
              ),
            ),

            // â”€â”€ List â”€â”€
            Expanded(
              child: ownersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(child: Text('Error loading requests:\n$e', textAlign: TextAlign.center)),
                data: (owners) {
                  if (owners.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 60, color: AppColors.success),
                          Gap(16),
                          Text('All caught up!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                          Gap(8),
                          Text('No pending owner registrations.', style: TextStyle(color: AppColors.textSecondaryLight)),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(pendingOwnersProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: owners.length,
                      separatorBuilder: (_, __) => const Gap(16),
                      itemBuilder: (context, index) {
                        final owner = owners[index];
                        return _OwnerRequestCard(owner: owner);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerRequestCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> owner;
  const _OwnerRequestCard({required this.owner});

  @override
  ConsumerState<_OwnerRequestCard> createState() => _OwnerRequestCardState();
}

class _OwnerRequestCardState extends ConsumerState<_OwnerRequestCard> {
  bool _isLoading = false;

  Future<void> _processRequest(bool approve) async {
    setState(() => _isLoading = true);
    final dio = ref.read(apiClientProvider);
    final ownerId = widget.owner['ownerId'];
    
    try {
      if (approve) {
        await dio.put('/admin/owners/$ownerId/approve');
        _showSnack('Owner approved successfully.', isError: false);
      } else {
        await dio.put('/admin/owners/$ownerId/reject', data: {'reason': 'Rejected by admin on review'});
        _showSnack('Owner request rejected.', isError: false);
      }
      ref.invalidate(pendingOwnersProvider);
    } on DioException catch (e) {
      _showSnack(e.response?.data?['message'] ?? 'Failed to process request', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final businessName = widget.owner['businessName'] ?? 'No Business Name';
    final name = widget.owner['userName'] ?? 'Unknown User';
    final email = widget.owner['userEmail'] ?? 'No Email';
    final phone = widget.owner['contactNumber'] ?? widget.owner['userPhone'] ?? '';
    final city = widget.owner['city'] ?? 'No City';
    final state = widget.owner['state'] ?? 'No State';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header Segment ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
                ),
                child: const Icon(Icons.stadium_rounded, color: Color(0xFFD97706), size: 28),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            businessName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('PENDING', style: TextStyle(color: Color(0xFFD97706), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Gap(24),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1.5),
          const Gap(24),
          
          // ── Info Grid ──
          _InfoNode(icon: Icons.alternate_email_rounded, label: 'Email Address', value: email),
          _InfoNode(icon: Icons.phone_outlined, label: 'Contact Number', value: phone),
          _InfoNode(icon: Icons.location_on_outlined, label: 'Location', value: '$city, $state'),

          const Gap(32),

          // ── Actions ──
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF10B981))))
          else
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _processRequest(false),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFEF4444))),
                    ),
                    child: const Text('Reject Request', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _processRequest(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: const Color(0xFF10B981).withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Approve Owner', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoNode extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoNode({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const Gap(2),
                Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
