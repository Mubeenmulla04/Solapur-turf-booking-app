import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';

final _adminTurfsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/admin/turfs');
    final list = res.data is Map ? res.data['data'] as List : [];
    return list.cast<Map<String, dynamic>>();
  } on DioException catch (e) {
    throw Exception(e.message);
  }
});

class AdminTurfManagementScreen extends ConsumerWidget {
  const AdminTurfManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turfsAsync = ref.watch(_adminTurfsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Turf Management', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: turfsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (turfs) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: turfs.length,
          itemBuilder: (context, i) {
            final t = turfs[i];
            final isActive = t['active'] ?? t['isActive'] ?? false;
            final isVerified = t['verified'] ?? t['isVerified'] ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                title: Text(t['name'] ?? 'Turf', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${t['city']}, ${t['sportType']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isVerified)
                      const Tooltip(
                        message: 'Pending Verification',
                        child: Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                      ),
                    const Gap(8),
                    Switch(
                      value: isActive,
                      activeColor: AppColors.primary,
                      onChanged: (val) async {
                        try {
                          final dio = ref.read(apiClientProvider);
                          await dio.put('/admin/turfs/${t['id']}/status', queryParameters: {'isActive': val});
                          ref.invalidate(_adminTurfsProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Turf ${val ? 'enabled' : 'disabled'}!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update status: $e'), backgroundColor: AppColors.error),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
