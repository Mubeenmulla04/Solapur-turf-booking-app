import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/review_provider.dart';

class ReviewListWidget extends ConsumerWidget {
  final String turfId;
  const ReviewListWidget({super.key, required this.turfId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(turfReviewsProvider(turfId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ratings & Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            TextButton(
              onPressed: () => _showReviewSheet(context),
              child: const Text('Write Review'),
            ),
          ],
        ),
        const Gap(16),
        reviewsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (reviews) {
            if (reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerLight),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.rate_review_outlined, size: 48, color: AppColors.textHint),
                    Gap(12),
                    Text('No reviews yet', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Be the first to share your experience!', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13)),
                  ],
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const Gap(16),
              itemBuilder: (context, i) {
                final r = reviews[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.dividerLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < r.rating ? Icons.star_rounded : Icons.star_border_rounded,
                                color: index < r.rating ? AppColors.warning : AppColors.textHint,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      if (r.isVerifiedReview) ...[
                        const Gap(4),
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: AppColors.primary, size: 12),
                            const Gap(4),
                            Text(
                              'Verified Booking',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Gap(12),
                      Text(
                        r.comment,
                        style: const TextStyle(color: AppColors.textSecondaryLight, height: 1.4, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubmitReviewSheet(turfId: turfId),
    );
  }
}

class SubmitReviewSheet extends ConsumerStatefulWidget {
  final String turfId;
  const SubmitReviewSheet({super.key, required this.turfId});

  @override
  ConsumerState<SubmitReviewSheet> createState() => _SubmitReviewSheetState();
}

class _SubmitReviewSheetState extends ConsumerState<SubmitReviewSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewNotifierProvider);
    final isLoading = state.isLoading;

    ref.listen(reviewNotifierProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted!'), backgroundColor: AppColors.success),
          );
        },
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        ),
      );
    });

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.dividerLight, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Gap(24),
            const Text('Share Your Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Gap(8),
            const Text('How was your game at this turf?', style: TextStyle(color: AppColors.textSecondaryLight)),
            const Gap(32),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final starVal = i + 1;
                  return IconButton(
                    iconSize: 40,
                    onPressed: () => setState(() => _rating = starVal),
                    icon: Icon(
                      starVal <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: starVal <= _rating ? AppColors.warning : AppColors.textHint,
                    ),
                  );
                }),
              ),
            ),
            const Gap(32),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe your experience...',
                filled: true,
                fillColor: AppColors.surfaceVariantLight.withOpacity(0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const Gap(32),
            ElevatedButton(
              onPressed: isLoading ? null : () {
                ref.read(reviewNotifierProvider.notifier).submitReview(
                  turfId: widget.turfId,
                  rating: _rating,
                  comment: _commentController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Post Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
