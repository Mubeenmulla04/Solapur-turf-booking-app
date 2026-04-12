import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/review_provider.dart';

class SubmitReviewScreen extends ConsumerStatefulWidget {
  final String turfId;
  final String turfName;

  const SubmitReviewScreen({
    super.key,
    required this.turfId,
    required this.turfName,
  });

  @override
  ConsumerState<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends ConsumerState<SubmitReviewScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _commentCtrl = TextEditingController();
  int _rating = 0;
  int _hoveredRating = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    await ref.read(reviewNotifierProvider.notifier).submitReview(
          turfId: widget.turfId,
          rating: _rating,
          comment: _commentCtrl.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(reviewNotifierProvider);
    state.when(
      data: (_) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted! Thank you 🙌'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      },
      error: (e, _) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      loading: () {},
    );
  }

  String _getRatingLabel(int rating) => switch (rating) {
        1 => 'Poor 😞',
        2 => 'Below Average 😕',
        3 => 'Average 😐',
        4 => 'Good 😊',
        5 => 'Excellent 🔥',
        _ => 'Tap to rate',
      };

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewNotifierProvider);
    final isLoading = reviewState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        centerTitle: true,
        title: const Text(
          'Write a Review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Turf Info Header ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryContainer.withOpacity(0.5),
                          AppColors.primaryContainer.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.sports_soccer_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'You played at',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                widget.turfName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryLight,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(40),

                  // ── Star Rating Section ───────────────────────────────────
                  const Text(
                    'Your Rating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const Gap(16),

                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starIndex = index + 1;
                            final filled = starIndex <= (_hoveredRating > 0 ? _hoveredRating : _rating);
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _rating = starIndex);
                              },
                              onTapDown: (_) => setState(() => _hoveredRating = starIndex),
                              onTapUp: (_) => setState(() => _hoveredRating = 0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 150),
                                  child: Icon(
                                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                                    key: ValueKey(filled),
                                    size: 48,
                                    color: filled ? AppColors.warning : AppColors.textHint,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const Gap(12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _getRatingLabel(_hoveredRating > 0 ? _hoveredRating : _rating),
                            key: ValueKey(_hoveredRating > 0 ? _hoveredRating : _rating),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _rating > 0
                                  ? (_rating >= 4 ? AppColors.success : AppColors.warning)
                                  : AppColors.textHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(40),

                  // ── Comment Section ───────────────────────────────────────
                  const Text(
                    'Your Experience',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const Gap(12),

                  AppTextField(
                    label: 'Write your review',
                    hint: 'Describe the pitch quality, facilities, and overall experience...',
                    controller: _commentCtrl,
                    maxLines: 5,
                    enabled: !isLoading,
                    validator: (v) => AppValidators.required(v, fieldName: 'Review'),
                  ),

                  const Gap(12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_commentCtrl.text.length} characters',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),

                  const Gap(40),

                  // ── Submit CTA ─────────────────────────────────────────────
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star_rounded, color: Colors.white, size: 20),
                              Gap(10),
                              Text(
                                'Submit Review',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),

                  const Gap(24),

                  // ── Disclaimer ─────────────────────────────────────────────
                  const Text(
                    'Your review helps other players find great turfs. We verify reviews based on completed bookings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                      height: 1.5,
                    ),
                  ),

                  const Gap(20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
