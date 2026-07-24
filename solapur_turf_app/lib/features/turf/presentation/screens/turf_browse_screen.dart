import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/turf_listing.dart';
import '../providers/turf_provider.dart';
import '../../../user/presentation/screens/user_home_screen.dart';
import 'package:geolocator/geolocator.dart';

class TurfBrowseScreen extends ConsumerStatefulWidget {
  const TurfBrowseScreen({super.key});

  @override
  ConsumerState<TurfBrowseScreen> createState() => _TurfBrowseScreenState();
}

class _TurfBrowseScreenState extends ConsumerState<TurfBrowseScreen> {
  final _searchCtrl = TextEditingController();

  final List<String> _sportsCategories = [
    'FOOTBALL',
    'BOX_CRICKET',
    'BASKETBALL',
    'TENNIS',
    'BADMINTON'
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(turfFilterProvider);
    final turfsAsync = ref.watch(turfsProvider);

    final authState = ref.watch(authNotifierProvider);
    final firstName = authState.valueOrNull?.user?.fullName.split(' ').first ?? 'Player';
    final location = ref.watch(userLocationProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(turfsProvider),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // ── 1. App Bar & Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppColors.primary, size: 20),
                              const Gap(4),
                              Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: AppColors.textSecondaryLight,
                                  size: 18),
                            ],
                          ),
                          const Gap(6),
                          Text(
                            'Ready for a game, $firstName? ⚽',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.dividerLight),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none_outlined,
                              color: AppColors.textPrimaryLight),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(children: [
                                  Icon(Icons.notifications_none,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 10),
                                  Text('No new notifications'),
                                ]),
                                backgroundColor: AppColors.primaryDark,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // ── 2. Search Bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 15,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => ref
                          .read(turfFilterProvider.notifier)
                          .update(filter.copyWith(
                              search: v.isEmpty ? null : v,
                              clearSearch: v.isEmpty)),
                      decoration: InputDecoration(
                        hintText: 'Search for turfs, sports...',
                        hintStyle:
                            const TextStyle(color: AppColors.textSecondaryLight),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondaryLight),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune,
                              color: AppColors.primary),
                          onPressed: () => _showFilterSheet(context, filter),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(24)),

              // ── 3. Categories (Pill Chips) ──
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _sportsCategories.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) {
                      final sport = _sportsCategories[index];
                      final isSelected = filter.sportType == sport;
                      return GestureDetector(
                        onTap: () {
                          ref.read(turfFilterProvider.notifier).update(
                              filter.copyWith(
                                  sportType: isSelected ? null : sport,
                                  clearSportType: isSelected));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.dividerLight),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppFormatters.toTitleCase(sport),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(24)),

              // ── 4. Popular Near You Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Popular Near You',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/user/browse'),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(12)),

              // ── 5. Turfs List ──
              turfsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: AppLoadingIndicator(message: 'Finding best turfs...'),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: AppErrorWidget(
                    message: e is Failure ? e.userMessage : e.toString(),
                    onRetry: () => ref.invalidate(turfsProvider),
                  ),
                ),
                data: (turfs) => turfs.isEmpty
                    ? const SliverFillRemaining(
                        child: EmptyStateWidget(
                          icon: Icons.sports_soccer,
                          title: 'No turfs found',
                          subtitle: 'Try adjusting your filters',
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _TurfCard(turf: turfs[index]),
                              );
                            },
                            childCount: turfs.length,
                          ),
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: Gap(40)),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext ctx, TurfFilterState filter) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Allow totally custom shapes
      builder: (_) => _FilterSheet(current: filter),
    );
  }
}

// ── Turf Card (Redesigned matching AppTheme) ──
class _TurfCard extends StatelessWidget {
  final TurfListing turf;
  const _TurfCard({required this.turf});

  @override
  Widget build(BuildContext context) {
    final imageUrl = turf.imageUrls?.isNotEmpty == true
        ? turf.imageUrls!.first
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: turf.isFeatured ? const Color(0xFFFFB300) : AppColors.dividerLight,
          width: turf.isFeatured ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: turf.isFeatured
                ? const Color(0xFFFFB300).withValues(alpha: 0.15)
                : AppColors.shadowLight,
            blurRadius: turf.isFeatured ? 24 : 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go('/user/turf/${turf.turfId}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beautiful Hero Image with optional Featured badge
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    imageUrl != null
                        ? Image.network(
                            imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _TurfImagePlaceholder(sport: turf.sportType.label),
                          )
                        : _TurfImagePlaceholder(sport: turf.sportType.label),

                    // ⭐ Featured Badge — only paid ACTIVE owners
                    if (turf.isFeatured)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium_rounded,
                                  size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'FEATURED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Card Meta Info
              Padding(
                padding: const EdgeInsets.all(16),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            turf.sportType.label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: AppColors.textSecondaryLight),
                        const Gap(4),
                        Expanded(
                          child: Text(
                            '${turf.city}, ${turf.state}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 20, color: AppColors.warning),
                        const Gap(4),
                        Text(
                          turf.ratingAverage.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight),
                        ),
                        Text(
                          ' (${turf.totalReviews} reviews)',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textHint),
                        ),
                        const Spacer(),
                        Text(
                          '${AppFormatters.formatCurrency(turf.hourlyRate)} ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text(
                          '/ hr',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TurfImagePlaceholder extends StatelessWidget {
  final String sport;
  const _TurfImagePlaceholder({required this.sport});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      color: AppColors.primaryContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stadium_outlined, size: 48, color: AppColors.primary),
          const Gap(8),
          Text(sport,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Updated Filter Bottom Sheet ──
class _FilterSheet extends ConsumerStatefulWidget {
  final TurfFilterState current;
  const _FilterSheet({required this.current});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late String? _sport;
  late String? _city;
  late String _sort;

  @override
  void initState() {
    super.initState();
    _sport = widget.current.sportType;
    _city = widget.current.city;
    _sort = widget.current.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    const sorts = ['NEWEST', 'PRICE_ASC', 'PRICE_DESC', 'RATING_DESC', 'NEAREST'];
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 24;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Sort & Filter',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _sport = null;
                    _city = null;
                    _sort = 'NEWEST';
                  });
                },
                child: const Text('Reset',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const Gap(24),
          const Text('Sort By',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight)),
          const Gap(12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: sorts
                .map((s) => ChoiceChip(
                      label: Text(AppFormatters.toTitleCase(s)),
                      selected: _sort == s,
                      onSelected: (_) => setState(() => _sort = s),
                      backgroundColor: AppColors.surfaceVariantLight,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: _sort == s
                            ? AppColors.primary
                            : AppColors.textPrimaryLight,
                        fontWeight: _sort == s ? FontWeight.bold : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: _sort == s
                                  ? AppColors.primary
                                  : Colors.transparent)),
                      elevation: 0,
                    ))
                .toList(),
          ),
          const Gap(32),
          ElevatedButton(
            onPressed: () async {
              double? lat;
              double? lng;
              if (_sort == 'NEAREST') {
                try {
                  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                  if (!serviceEnabled) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enable location services to find nearest turfs.'), backgroundColor: AppColors.error),
                      );
                    }
                    return;
                  }
                  LocationPermission permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location permission is denied.'), backgroundColor: AppColors.error),
                        );
                      }
                      return;
                    }
                  }
                  if (permission == LocationPermission.deniedForever) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location permissions are permanently denied. Please enable them in settings.'), backgroundColor: AppColors.error),
                      );
                    }
                    return;
                  }

                  Position position = await Geolocator.getCurrentPosition();
                  lat = position.latitude;
                  lng = position.longitude;
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to get location: $e'), backgroundColor: AppColors.error),
                    );
                  }
                  return;
                }
              }

              ref.read(turfFilterProvider.notifier).update(TurfFilterState(
                    search: ref.read(turfFilterProvider).search,
                    sportType: _sport,
                    city: _city,
                    sortBy: _sort,
                    latitude: lat,
                    longitude: lng,
                  ));
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Apply Changes'),
          ),
          const Gap(16),
        ],
      ),
    );
  }
}
