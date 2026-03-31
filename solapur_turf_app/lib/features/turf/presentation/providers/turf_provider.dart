import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/turf_remote_datasource.dart';
import '../../data/repositories/turf_repository_impl.dart';
import '../../domain/entities/turf_listing.dart';
import '../../domain/repositories/turf_repository.dart';

part 'turf_provider.g.dart';

// ── Repository ───────────────────────────────────────────────────────────────

@riverpod
TurfRepository turfRepository(Ref ref) => TurfRepositoryImpl(
      TurfRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );

// ── Filter State ──────────────────────────────────────────────────────────────

@riverpod
class TurfFilter extends _$TurfFilter {
  @override
  TurfFilterState build() => const TurfFilterState();

  void update(TurfFilterState filter) => state = filter;
  void reset() => state = const TurfFilterState();
}

class TurfFilterState {
  final String? search;
  final String? sportType;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;

  const TurfFilterState({
    this.search,
    this.sportType,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'NEWEST',
  });

  TurfFilterState copyWith({
    String? search,
    bool clearSearch = false,
    String? sportType,
    bool clearSportType = false,
    String? city,
    bool clearCity = false,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) =>
      TurfFilterState(
        search: clearSearch ? null : (search ?? this.search),
        sportType: clearSportType ? null : (sportType ?? this.sportType),
        city: clearCity ? null : (city ?? this.city),
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        sortBy: sortBy ?? this.sortBy,
      );
}

// ── Turfs List ────────────────────────────────────────────────────────────────

@riverpod
Future<List<TurfListing>> turfs(Ref ref) async {
  final filter = ref.watch(turfFilterProvider);
  final repo = ref.watch(turfRepositoryProvider);
  final result = await repo.getTurfs(
    search: filter.search,
    sportType: filter.sportType,
    city: filter.city,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    sortBy: filter.sortBy == 'NEWEST' ? null : filter.sortBy,
  );
  return result.fold((f) => throw f, (data) => data);
}

// ── Single Turf ───────────────────────────────────────────────────────────────

@riverpod
Future<TurfListing> turfDetail(Ref ref, String turfId) async {
  final result = await ref.watch(turfRepositoryProvider).getTurfById(turfId);
  return result.fold((f) => throw f, (data) => data);
}

// ── Available Slots ───────────────────────────────────────────────────────────

@riverpod
Future<List<AvailabilitySlot>> availableSlots(
  Ref ref, {
  required String turfId,
  required String date,
}) async {
  final result = await ref
      .watch(turfRepositoryProvider)
      .getAvailableSlots(turfId: turfId, date: date);
  return result.fold((f) => throw f, (data) => data);
}
