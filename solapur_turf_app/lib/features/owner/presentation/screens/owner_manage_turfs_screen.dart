import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../turf/domain/entities/turf_listing.dart';
import '../../../turf/data/models/turf_model.dart';
import 'owner_create_turf_screen.dart';

final myTurfsProvider = FutureProvider.autoDispose<List<TurfListing>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get('/turfs/owner/my-turfs');
  final list = res.data['data'] as List;
  return list.map((e) => TurfListingModel.fromJson(e).toDomain()).toList();
});

class OwnerManageTurfsScreen extends ConsumerWidget {
  const OwnerManageTurfsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turfsAsync = ref.watch(myTurfsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text('Manage My Turfs', style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => context.go('/owner/turfs/create'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myTurfsProvider),
        color: AppColors.primary,
        child: turfsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed to load: $err')),
          data: (turfs) {
            if (turfs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.stadium_rounded,
                title: 'No Turfs Listed',
                subtitle: 'Register your first turf to start accepting bookings.',
                actionLabel: 'List New Turf',
                onAction: () => context.go('/owner/turfs/create'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: turfs.length,
              separatorBuilder: (_, __) => const Gap(16),
              itemBuilder: (context, i) {
                final turf = turfs[i];
                return _ManageTurfCard(turf: turf);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ManageTurfCard extends ConsumerWidget {
  final TurfListing turf;
  const _ManageTurfCard({required this.turf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  image: turf.imageUrls != null && turf.imageUrls!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(turf.imageUrls!.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: turf.imageUrls == null || turf.imageUrls!.isEmpty
                    ? const Icon(Icons.stadium_rounded, color: AppColors.primary)
                    : null,
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turf.turfName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Gap(4),
                    Text(
                      '${turf.city}, ${turf.state}',
                      style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                    ),
                    const Gap(4),
                    Text(
                      turf.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: turf.isActive ? AppColors.success : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          const Divider(height: 1),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OwnerCreateTurfScreen(editTurf: turf)));
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit'),
              ),
              Container(width: 1, height: 24, color: AppColors.dividerLight),
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delete Turf?'),
                      content: const Text('This action cannot be undone. Are you sure?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await ref.read(apiClientProvider).delete('/turfs/${turf.turfId}');
                      ref.invalidate(myTurfsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turf deleted successfully')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                label: const Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
