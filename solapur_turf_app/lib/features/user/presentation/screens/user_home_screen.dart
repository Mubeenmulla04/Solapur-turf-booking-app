import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../turf/domain/entities/turf_listing.dart';
import '../../../turf/presentation/providers/turf_provider.dart';
import '../../../tournaments/domain/entities/tournament.dart';

// ── Location Provider ────────────────────────────────────────────────────────
final userLocationProvider = StateProvider<String>((ref) => 'Solapur, MH');

// ── Tournaments mini-provider ─────────────────────────────────────────────────
final _homeTournamentsProvider =
    FutureProvider.autoDispose<List<Tournament>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/tournaments');
    final list = (res.data is Map ? res.data['data'] : res.data) as List;
    return list
        .take(5)
        .map((j) => _mapTournament(j as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw AppException.fromDioException(e);
  }
});

Tournament _mapTournament(Map<String, dynamic> j) => Tournament(
      tournamentId:
          j['tournament_id'] as String? ?? j['tournamentId'] as String? ?? '',
      name: j['name'] as String? ?? '',
      sportType:
          j['sport_type'] as String? ?? j['sportType'] as String? ?? '',
      format: j['format'] as String? ?? '',
      entryFee:
          double.tryParse((j['entry_fee'] ?? j['entryFee'] ?? 0).toString()) ??
              0,
      prizePool: j['prize_pool'] != null
          ? double.tryParse(j['prize_pool'].toString())
          : null,
      maxTeams: (j['max_teams'] as int?) ?? (j['maxTeams'] as int?) ?? 0,
      registeredTeams:
          (j['registered_teams'] as int?) ?? (j['registeredTeams'] as int?) ?? 0,
      status: TournamentStatusX.fromString(j['status'] as String? ?? 'UPCOMING'),
      startDate:
          (j['start_date'] as String?) ?? (j['startDate'] as String?) ?? '',
      endDate: (j['end_date'] as String?) ?? (j['endDate'] as String?) ?? '',
      turfName: (j['turf'] as Map?)?['turf_name'] as String?,
      description: j['description'] as String?,
    );

// ─────────────────────────────────────────────────────────────────────────────
// User Home Screen
// ─────────────────────────────────────────────────────────────────────────────

final _hasPromptedLocationProvider = StateProvider<bool>((ref) => false);

class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptLocation();
    });
  }

  void _checkAndPromptLocation() async {
    final hasPrompted = ref.read(_hasPromptedLocationProvider);
    if (!hasPrompted) {
      ref.read(_hasPromptedLocationProvider.notifier).state = true;

      // Check if location services and permissions are already enabled for auto-fetch
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (serviceEnabled &&
          (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse)) {
        await _fetchLocationSilently();
        return; // Skip prompt
      }

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _showSmartLocationPrompt(context, ref);
        }
      });
    }
  }

  Future<void> _fetchLocationSilently() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String area = place.subLocality ?? place.name ?? place.thoroughfare ?? '';
        String city = place.locality ?? place.subAdministrativeArea ?? 'Unknown City';

        String newLocation = city;
        if (area.isNotEmpty && area.toLowerCase() != city.toLowerCase()) {
          newLocation = '$area, $city';
        }

        if (mounted) {
          ref.read(userLocationProvider.notifier).state = newLocation;
        }
      }
    } catch (e) {
      // Silently fail and keep default location if something goes wrong
      debugPrint('Silent location fetch failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    final authState = ref.watch(authNotifierProvider);
    final user = authState.valueOrNull?.user;
    final firstName = user?.fullName.split(' ').first ?? 'Player';
    final location = ref.watch(userLocationProvider);
    final cityOnly = location.split(',').first.trim();

    final turfsAsync = ref.watch(turfsProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);
    final tournsAsync = ref.watch(_homeTournamentsProvider);

    // Find next upcoming confirmed booking that hasn't ended yet
    final activeBookings = bookingsAsync.valueOrNull?.where((b) {
      if (b.bookingStatus != BookingStatus.confirmed && b.bookingStatus != BookingStatus.pending) return false;
      try {
        final t = b.endTime.split(':').length == 2 ? '${b.endTime}:00' : b.endTime;
        return DateTime.parse('${b.bookingDate} $t').isAfter(DateTime.now());
      } catch (_) {
        return true; // Fallback if parse fails
      }
    }).toList();

    // Sort ascending by date & time to find the most immediate upcoming booking
    activeBookings?.sort((a, b) {
      try {
        final aT = a.startTime.split(':').length == 2 ? '${a.startTime}:00' : a.startTime;
        final bT = b.startTime.split(':').length == 2 ? '${b.startTime}:00' : b.startTime;
        return DateTime.parse('${a.bookingDate} $aT').compareTo(DateTime.parse('${b.bookingDate} $bT'));
      } catch (_) {
        return 0;
      }
    });
    
    final nextBooking = activeBookings?.firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(turfsProvider);
            ref.invalidate(myBookingsProvider);
            ref.invalidate(_homeTournamentsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showLocationPicker(context, ref, location);
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: AppColors.primary, size: 18),
                                  const Gap(4),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textHint, size: 18),
                                ],
                              ),
                            ),
                            const Gap(6),
                            Text(
                              '${_greeting()}, $firstName! ${_greetingEmoji()}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification Bell
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
                            HapticFeedback.lightImpact();
                            _showNotifications(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Search Bar Segment ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go('/user/browse');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.dividerLight),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: AppColors.primary, size: 22),
                          const Gap(12),
                          Text(
                            'Search for "Turfs in $cityOnly"',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textHint,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.tune_rounded,
                              color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── 3. Next Booking Banner (if any) ────────────────────────────────
              if (nextBooking != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _NextBookingBanner(booking: nextBooking),
                  ),
                ),

              // ── Quick Actions ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What are you up for?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const Gap(14),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Wallet',
                              color: const Color(0xFFE8F5E9),
                              iconColor: const Color(0xFF2E7D32),
                              onTap: () => context.go('/user/wallet'),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.receipt_long_rounded,
                              label: 'Bookings',
                              color: const Color(0xFFE3F2FD),
                              iconColor: const Color(0xFF1565C0),
                              onTap: () => context.go('/user/bookings'),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.groups_rounded,
                              label: 'Squads',
                              color: const Color(0xFFFFF3E0),
                              iconColor: const Color(0xFFE65100),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showSquadOptions(context);
                              },
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.emoji_events_rounded,
                              label: 'Tourneys',
                              color: const Color(0xFFF3E5F5),
                              iconColor: const Color(0xFF6A1B9A),
                              onTap: () => context.go('/user/tournaments'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Featured Turfs Carousel ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Featured Turfs',
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
                              child: const Text('See All',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      SizedBox(
                        height: 220,
                        child: turfsAsync.when(
                          loading: () => const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary)),
                          error: (e, _) => Center(
                            child: Text(
                              e is Failure ? e.userMessage : 'Failed to load',
                              style: const TextStyle(
                                  color: AppColors.textSecondaryLight),
                            ),
                          ),
                          data: (turfs) {
                            var localTurfs = turfs
                                .where((t) => t.city.toLowerCase().contains(cityOnly.toLowerCase()) || cityOnly.toLowerCase().contains(t.city.toLowerCase()))
                                .toList();
                            if (localTurfs.isEmpty) {
                              localTurfs = turfs.toList(); // Fallback to all turfs for empty dashboard
                            }
                            if (localTurfs.isEmpty) {
                              return Center(
                                child: EmptyStateWidget(
                                  icon: Icons.sports_soccer,
                                  title: 'No turfs found',
                                  subtitle: 'Not available yet',
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.only(right: 20),
                              scrollDirection: Axis.horizontal,
                              itemCount: localTurfs.take(6).length,
                              separatorBuilder: (_, __) => const Gap(16),
                              itemBuilder: (context, i) =>
                                  _FeaturedTurfCard(turf: localTurfs[i]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Upcoming Tournaments ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upcoming Tournaments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.go('/user/tournaments'),
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero),
                            child: const Text('View All',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const Gap(12),
                      tournsAsync.when(
                        loading: () => const Center(
                            child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        )),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (list) {
                          final upcoming = list
                              .where((t) =>
                                  t.status == TournamentStatus.upcoming)
                              .take(3)
                              .toList();
                          if (upcoming.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'No upcoming tournaments right now.',
                                style: TextStyle(
                                    color: AppColors.textSecondaryLight),
                              ),
                            );
                          }
                          return Column(
                            children: upcoming
                                .map((t) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _TournamentListTile(t: t),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(48)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context, WidgetRef ref, String currentLocation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select City',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'Showing turfs in your selected region',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
            ),
            const Gap(24),
            ...AppConstants.supportedCities.map((city) => ListTile(
              leading: const Icon(Icons.location_city_rounded, color: AppColors.primary),
              title: Text(city, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: city == currentLocation ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
              onTap: () {
                ref.read(userLocationProvider.notifier).state = city;
                Navigator.pop(bottomSheetContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Switched to $city'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primaryDark,
                    ),
                  );
                }
              },
            )),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  void _showSmartLocationPrompt(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (c, setState) {
          bool isScanning = false;
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Gap(8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: isScanning
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                        )
                      : const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 36),
                ),
                const Gap(20),
                const Text(
                  'Enable Location',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Gap(8),
                const Text(
                  'We use your location to find the best turfs and matches happening right around you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight, height: 1.4),
                ),
                const Gap(32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isScanning
                        ? null
                        : () async {
                            HapticFeedback.lightImpact();
                            setState(() => isScanning = true);
                            
                            try {
                              bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                              if (!serviceEnabled) {
                                if (ctx.mounted) {
                                  setState(() => isScanning = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Please turn on GPS/Location in device settings.'),
                                      action: SnackBarAction(
                                        label: 'SETTINGS',
                                        textColor: Colors.white,
                                        onPressed: () => Geolocator.openLocationSettings(),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppColors.error,
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                                return;
                              }

                              LocationPermission permission = await Geolocator.checkPermission();
                              if (permission == LocationPermission.denied) {
                                permission = await Geolocator.requestPermission();
                                if (permission == LocationPermission.denied) {
                                  if (ctx.mounted) {
                                    setState(() => isScanning = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Location permission denied.'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }
                              
                              if (permission == LocationPermission.deniedForever) {
                                if (ctx.mounted) {
                                  setState(() => isScanning = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Location permissions are permanently denied, we cannot request permissions.'),
                                      action: SnackBarAction(
                                        label: 'SETTINGS',
                                        textColor: Colors.white,
                                        onPressed: () => Geolocator.openAppSettings(),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppColors.error,
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                                return;
                              } 

                              Position position = await Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high);
                              
                              List<Placemark> placemarks = await placemarkFromCoordinates(
                                  position.latitude, position.longitude);

                              if (placemarks.isNotEmpty) {
                                Placemark place = placemarks[0];
                                String area = place.subLocality ?? place.name ?? place.thoroughfare ?? '';
                                String city = place.locality ?? place.subAdministrativeArea ?? 'Unknown City';
                                
                                String newLocation = city;
                                if (area.isNotEmpty && area.toLowerCase() != city.toLowerCase()) {
                                  newLocation = '$area, $city';
                                }

                                if (ctx.mounted) {
                                  HapticFeedback.heavyImpact();
                                  ref.read(userLocationProvider.notifier).state = newLocation;
                                  Navigator.pop(ctx);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Location intelligently set to $newLocation 📍'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.primaryDark,
                                      ),
                                    );
                                  }
                                }
                              } else {
                                throw Exception('Could not determine location from coordinates.');
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                setState(() => isScanning = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString().replaceAll('Exception: ', '')),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isScanning ? 'Detecting...' : 'Allow Smart Location',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const Gap(12),
                TextButton(
                  onPressed: isScanning
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(ctx);
                        },
                  child: const Text('Maybe Later', style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w600)),
                ),
                const Gap(8),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSquadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Squads',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'Manage your teams or join a new one with a code.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
            ),
            const Gap(24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.add_circle_outline, color: Color(0xFF2E7D32)),
              ),
              title: const Text('Create Squad', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Form a new team and invite your friends'),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/user/teams/create');
              },
            ),
            const Gap(8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.group_add_rounded, color: Color(0xFF1565C0)),
              ),
              title: const Text('Join Squad', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Use a team code to join an existing squad'),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/user/teams/join');
              },
            ),
            const Gap(8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.groups_rounded, color: Color(0xFFE65100)),
              ),
              title: const Text('My Squads', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('View and manage your current teams'),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/user/teams');
              },
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const Gap(12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.dividerLight, borderRadius: BorderRadius.circular(2))),
            const Gap(24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Gap(16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _notifTile('Booking Confirmed!', 'Your slot at Green Field Turf for tonight is ready.', '2h ago', true),
                  _notifTile('New Tournament!', 'Solapur Premier League is now open for registration.', '1d ago', false),
                  _notifTile('Squad Update', 'You have been added to the "Warriors SC" squad.', '3d ago', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notifTile(String title, String body, String time, bool isNew) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? AppColors.primaryContainer.withOpacity(0.3) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNew ? AppColors.primary.withOpacity(0.2) : AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
            ],
          ),
          const Gap(4),
          Text(body, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.4)),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _greetingEmoji() {
    final h = DateTime.now().hour;
    if (h < 12) return '🌤️';
    if (h < 17) return '⚽';
    return '🌙';
  }
}

// ── Next Booking Banner ──────────────────────────────────────────────────────

class _NextBookingBanner extends StatelessWidget {
  final Booking booking;
  const _NextBookingBanner({required this.booking});

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(booking.bookingDate);
    return GestureDetector(
      onTap: () => context.go('/user/bookings'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.sports_soccer_rounded,
                  color: Colors.white, size: 28),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR NEXT GAME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    booking.turfName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.white70, size: 12),
                      const Gap(4),
                      Text(
                        '$date  •  ${AppFormatters.formatTimeString(booking.startTime)} – ${AppFormatters.formatTimeString(booking.endTime)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('EEE, d MMM').format(d);
    } catch (_) {
      return date;
    }
  }
}

// ── Quick Action Card ─────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const Gap(8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured Turf Card (Horizontal Carousel) ──────────────────────────────────

class _FeaturedTurfCard extends StatelessWidget {
  final TurfListing turf;
  const _FeaturedTurfCard({required this.turf});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        turf.imageUrls?.isNotEmpty == true ? turf.imageUrls!.first : null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/user/turf/${turf.turfId}');
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: imageUrl != null
                    ? Image.network(imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholder(turf.sportType.label))
                    : _placeholder(turf.sportType.label),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    turf.turfName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    turf.city,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondaryLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.warning),
                          const Gap(3),
                          Text(
                            turf.ratingAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${AppFormatters.formatCurrency(turf.hourlyRate)}/hr',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String sport) => Container(
        color: AppColors.primaryContainer,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stadium_outlined,
                size: 36, color: AppColors.primary),
            const Gap(4),
            Text(sport,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

// ── Tournament Strip Tile ────────────────────────────────────────────────────

class _TournamentListTile extends StatelessWidget {
  final Tournament t;
  const _TournamentListTile({required this.t});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/user/tournaments/${t.tournamentId}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 12,
                offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: AppColors.warning, size: 22),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(3),
                  Text(
                    '${AppFormatters.toTitleCase(t.sportType)}  •  ${t.entryFee == 0 ? 'FREE' : AppFormatters.formatCurrency(t.entryFee)} Entry',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(t.startDate),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Gap(3),
                Text(
                  '${t.maxTeams - t.registeredTeams} spots left',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textHint),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String d) {
    try {
      return DateFormat('d MMM').format(DateTime.parse(d));
    } catch (_) {
      return d.isNotEmpty ? d : 'TBA';
    }
  }
}
