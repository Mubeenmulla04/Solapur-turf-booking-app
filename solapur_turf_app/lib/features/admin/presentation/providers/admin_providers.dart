import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

// ── Platform Stats ─────────────────────────────────────────────────────────

final adminPlatformStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/admin/stats');
    if (res.data is Map && res.data['data'] is Map) {
      return Map<String, dynamic>.from(res.data['data'] as Map);
    }
    return {};
  } on DioException {
    return {'totalUsers': 0, 'totalTurfs': 0, 'totalBookings': 0, 'totalRevenue': 0};
  }
});

// ── Revenue Analytics ──────────────────────────────────────────────────────

final adminRevenueProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/admin/revenue');
    if (res.data is Map && res.data['data'] is Map) {
      return Map<String, dynamic>.from(res.data['data'] as Map);
    }
    return {};
  } on DioException {
    return {};
  }
});

// ── User Management ────────────────────────────────────────────────────────

final adminAllUsersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/users', queryParameters: {'page': 0, 'size': 50});
    final data = res.data is Map ? res.data['data'] : null;
    if (data is Map && data['content'] is List) {
      return List<Map<String, dynamic>>.from(data['content'] as List);
    }
    return [];
  } on DioException {
    return [];
  }
});

// ── Platform Settings ──────────────────────────────────────────────────────

final adminSettingsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/admin/settings');
    if (res.data is Map && res.data['data'] is Map) {
      return Map<String, dynamic>.from(res.data['data'] as Map);
    }
    return {};
  } on DioException {
    return {
      'commissionPercent': 10,
      'maxBookingsPerUser': 5,
      'maintenanceMode': false,
      'platformName': 'Solapur Turf',
      'supportEmail': 'support@solapurturf.com',
    };
  }
});

// ── Audit Log ──────────────────────────────────────────────────────────────

final adminAuditLogProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/admin/audit-log');
    final data = res.data is Map ? res.data['data'] : null;
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  } on DioException {
    return [];
  }
});
