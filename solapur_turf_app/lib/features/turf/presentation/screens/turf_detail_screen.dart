import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/turf_listing.dart';
import '../providers/turf_provider.dart';

class TurfDetailScreen extends ConsumerStatefulWidget {
  final String turfId;
  const TurfDetailScreen({super.key, required this.turfId});
  
  @override
  ConsumerState<TurfDetailScreen> createState() => _TurfDetailScreenState();
}

class _TurfDetailScreenState extends ConsumerState<TurfDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    // Force light status bar icons for parallax hero image
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    
    final turfAsync = ref.watch(turfDetailProvider(widget.turfId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: turfAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
          ),
          body: AppErrorWidget(
            message: e is Failure ? e.userMessage : e.toString(),
            onRetry: () => ref.invalidate(turfDetailProvider(widget.turfId)),
          ),
        ),
        data: (turf) => Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── Parallax Hero Image App Bar ──
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  backgroundColor: AppColors.surfaceLight,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        turf.imageUrls?.isNotEmpty == true
                            ? Image.network(
                                turf.imageUrls!.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                        // Bottom Gradient for seamless transition
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 120,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.backgroundLight,
                                  AppColors.backgroundLight.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? AppColors.error : Colors.white,
                            size: 22),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _isFavorite = !_isFavorite);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isFavorite ? 'Removed from favorites' : 'Added to favorites'),
                              backgroundColor: AppColors.primaryDark,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: Colors.white, size: 22),
                        onPressed: () {
                          Share.share(
                              'Check out ${turf.turfName} on Solapur Turf!\n\nBook now: https://solapurturf.app/turf/${turf.turfId}');
                        },
                      ),
                    ),
                  ],
                ),

                // ── Sticky Floating Title Block ──
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  turf.turfName,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: AppColors.warning, size: 20),
                                    const Gap(4),
                                    Text(
                                      turf.ratingAverage.toStringAsFixed(1),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.textPrimaryLight),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  color: AppColors.primary, size: 18),
                              const Gap(6),
                              Expanded(
                                child: Text(
                                  '${turf.address}, ${turf.city}, ${turf.state} - ${turf.pincode}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(16),

                        // Sport Badges
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                turf.sportType.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Gap(12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariantLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.grass,
                                      size: 14, color: AppColors.textSecondaryLight),
                                  const Gap(6),
                                  Text(
                                    AppFormatters.toTitleCase(
                                        turf.surfaceType.name),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondaryLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Gap(32),

                        // Section: Amenities
                        if (turf.amenities?.isNotEmpty == true) ...[
                          const Text(
                            'Amenities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const Gap(16),
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: turf.amenities!.length,
                              separatorBuilder: (_, __) => const Gap(24),
                              itemBuilder: (context, index) {
                                return _buildAmenityIcon(
                                    turf.amenities![index]);
                              },
                            ),
                          ),
                          const Gap(32),
                        ],

                        // Section: About
                        if (turf.description?.isNotEmpty == true) ...[
                          const Text(
                            'About This Turf',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const Gap(12),
                          _ExpandableDescription(text: turf.description!),
                          const Gap(32),
                        ],

                        // Additional Pricing Detail block (Optional to fill space before Booking CTA)
                        const Text(
                          'Pricing Matrix',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.dividerLight),
                          ),
                          child: Column(
                            children: [
                              _PriceRow(
                                title: 'Standard Hourly Rate',
                                amount: turf.hourlyRate,
                              ),
                              if (turf.peakHourRate != null) ...[
                                const Gap(12),
                                const Divider(color: AppColors.dividerLight),
                                const Gap(12),
                                _PriceRow(
                                  title: 'Peak Hourly Rate',
                                  amount: turf.peakHourRate!,
                                  isPeak: true,
                                ),
                              ]
                            ],
                          ),
                        ),

                        // Massive padding to ensure users can scroll past the sticky button
                        const Gap(140),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Sticky Glassmorphic Bottom Bar ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withOpacity(0.85),
                      border: const Border(
                        top: BorderSide(
                            color: AppColors.dividerLight, width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Starting at',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  AppFormatters.formatCurrency(turf.hourlyRate),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 4, left: 4),
                                  child: Text(
                                    '/ hour',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => context.go('/user/book/${widget.turfId}'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(180, 56),
                            elevation: 8,
                            shadowColor:
                                AppColors.primary.withOpacity(0.5),
                          ),
                          child: const Text('Book Now',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryDark,
      child: const Center(
        child: Icon(Icons.sports_soccer, size: 80, color: Colors.white24),
      ),
    );
  }

  Widget _buildAmenityIcon(String amenity) {
    IconData icon;
    String label = amenity.toLowerCase();

    // Naive string matching for massive SaaS feel
    if (label.contains('park')) {
      icon = Icons.local_parking;
    } else if (label.contains('wash') || label.contains('rest')) {
      icon = Icons.wc;
    } else if (label.contains('water')) {
      icon = Icons.water_drop_outlined;
    } else if (label.contains('light') || label.contains('flood')) {
      icon = Icons.lightbulb_outline;
    } else if (label.contains('change') || label.contains('room')) {
      icon = Icons.checkroom_outlined;
    } else if (label.contains('bib')) {
      icon = Icons.dry_cleaning_outlined;
    } else {
      icon = Icons.check_circle_outline;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.dividerLight),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const Gap(8),
        Text(
          AppFormatters.toTitleCase(amenity),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final double amount;
  final bool isPeak;

  const _PriceRow(
      {required this.title, required this.amount, this.isPeak = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isPeak ? Icons.bolt_rounded : Icons.access_time_rounded,
              size: 20,
              color: isPeak ? AppColors.warning : AppColors.textSecondaryLight,
            ),
            const Gap(8),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight),
            ),
          ],
        ),
        Text(
          '${AppFormatters.formatCurrency(amount)} / hr',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String text;
  const _ExpandableDescription({required this.text});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _isExpanded ? null : 3,
          overflow: _isExpanded ? null : TextOverflow.fade,
          style: const TextStyle(
            color: AppColors.textSecondaryLight,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const Gap(8),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(
            _isExpanded ? 'Show less' : 'Read more',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
