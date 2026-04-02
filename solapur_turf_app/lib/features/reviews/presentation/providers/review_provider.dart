import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/review.dart';

final turfReviewsProvider = FutureProvider.family<List<Review>, String>((ref, turfId) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get('/reviews/turf/$turfId');
  final list = res.data['data'] as List;
  return list.map((e) => Review.fromJson(e)).toList();
});

class ReviewNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ReviewNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> submitReview({
    required String turfId,
    required int rating,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/reviews/turf/$turfId', data: {
        'rating': rating,
        'comment': comment,
      });
      state = const AsyncValue.data(null);
      ref.invalidate(turfReviewsProvider(turfId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final reviewNotifierProvider = StateNotifierProvider<ReviewNotifier, AsyncValue<void>>((ref) {
  return ReviewNotifier(ref);
});
