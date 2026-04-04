import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/forgot_password_email_screen.dart';
import '../features/auth/presentation/screens/forgot_password_otp_screen.dart';
import '../features/turf/presentation/screens/turf_browse_screen.dart';
import '../features/turf/presentation/screens/turf_detail_screen.dart';
import '../features/booking/presentation/screens/booking_screen.dart';
import '../features/booking/presentation/screens/booking_history_screen.dart';
import '../features/booking/presentation/screens/booking_confirmation_screen.dart';
import '../features/booking/domain/entities/booking.dart';
import '../features/teams/presentation/screens/my_teams_screen.dart';
import '../features/teams/presentation/screens/create_team_screen.dart';
import '../features/teams/presentation/screens/join_team_screen.dart';
import '../features/teams/presentation/screens/team_detail_screen.dart';
import '../features/tournaments/presentation/screens/tournament_list_screen.dart';
import '../features/tournaments/presentation/screens/tournament_detail_screen.dart';
import '../features/owner/presentation/screens/owner_dashboard_screen.dart';
import '../features/owner/presentation/screens/owner_bookings_screen.dart';
import '../features/owner/presentation/screens/owner_profile_screen.dart';
import '../features/owner/presentation/screens/owner_create_turf_screen.dart';
import '../features/owner/presentation/screens/owner_manage_turfs_screen.dart';
import '../features/tournaments/presentation/screens/create_tournament_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/admin_bookings_screen.dart';
import '../features/admin/presentation/screens/admin_tournaments_screen.dart';
import '../features/admin/presentation/screens/admin_owner_approvals_screen.dart';
import '../features/admin/presentation/screens/admin_turf_management_screen.dart';
import '../features/admin/presentation/screens/settlement_report_screen.dart';
import '../features/admin/presentation/screens/admin_profile_screen.dart';
import '../features/admin/presentation/screens/admin_user_management_screen.dart';
import '../features/admin/presentation/screens/admin_revenue_analytics_screen.dart';
import '../features/admin/presentation/screens/admin_push_notification_screen.dart';
import '../features/admin/presentation/screens/admin_platform_settings_screen.dart';
import '../features/admin/presentation/screens/admin_audit_log_screen.dart';
import '../features/admin/presentation/screens/admin_help_support_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/user_wallet_screen.dart';
import '../features/profile/presentation/screens/user_preferences_screen.dart';
import '../features/profile/presentation/screens/user_sessions_screen.dart';
import '../features/profile/presentation/screens/theme_settings_screen.dart';
import '../features/profile/presentation/screens/user_edit_profile_screen.dart';
import '../features/user/presentation/screens/user_home_screen.dart';
import 'shell_screens.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {

  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
      final role = authState.valueOrNull?.role;
      final onAuthPage = state.uri.path.startsWith('/auth');

      if (!isAuthenticated && !onAuthPage) return '/auth/login';
      if (isAuthenticated && onAuthPage) {
        return switch (role) {
          'USER' => '/user/dashboard',
          'OWNER' => '/owner/dashboard',
          'ADMIN' => '/admin/dashboard',
          _ => '/auth/login',
        };
      }
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordEmailScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password/otp',
        name: 'forgotPasswordOtp',
        builder: (_, state) {
          final email = state.extra as String;
          return ForgotPasswordOtpScreen(email: email);
        },
      ),

      // ── User Shell ────────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            UserShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/user/dashboard',
            name: 'userDashboard',
            builder: (_, __) => const UserHomeScreen(),
          ),
          GoRoute(
            path: '/user/browse',
            name: 'turfBrowse',
            builder: (_, __) => const TurfBrowseScreen(),
          ),
          GoRoute(
            path: '/user/turf/:id',
            name: 'turfDetail',
            builder: (_, state) =>
                TurfDetailScreen(turfId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/user/book/:turfId',
            name: 'booking',
            builder: (_, state) =>
                BookingScreen(turfId: state.pathParameters['turfId']!),
          ),
          GoRoute(
            path: '/user/bookings',
            name: 'bookingHistory',
            builder: (_, __) => const BookingHistoryScreen(),
          ),
          GoRoute(
            path: '/user/booking-confirmation',
            name: 'bookingConfirmation',
            builder: (_, state) =>
                BookingConfirmationScreen(booking: state.extra as Booking),
          ),
          GoRoute(
            path: '/user/teams',
            name: 'myTeams',
            builder: (_, __) => const MyTeamsScreen(),
          ),
          GoRoute(
            path: '/user/teams/create',
            name: 'createTeam',
            builder: (_, __) => const CreateTeamScreen(),
          ),
          GoRoute(
            path: '/user/teams/join',
            name: 'joinTeam',
            builder: (_, __) => const JoinTeamScreen(),
          ),
          GoRoute(
            path: '/user/teams/:id',
            name: 'teamDetail',
            builder: (_, state) =>
                TeamDetailScreen(teamId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/user/tournaments',
            name: 'tournamentList',
            builder: (_, __) => const TournamentListScreen(),
          ),
          GoRoute(
            path: '/user/tournaments/:id',
            name: 'tournamentDetail',
            builder: (_, state) =>
                TournamentDetailScreen(tournamentId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/user/profile',
            name: 'userProfile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/user/wallet',
            name: 'userWallet',
            builder: (_, __) => const UserWalletScreen(),
          ),
          GoRoute(
            path: '/user/preferences',
            name: 'userPreferences',
            builder: (_, __) => const UserPreferencesScreen(),
          ),
          GoRoute(
            path: '/user/sessions',
            name: 'userSessions',
            builder: (_, __) => const UserSessionsScreen(),
          ),
          GoRoute(
            path: '/user/theme',
            name: 'userTheme',
            builder: (_, __) => const ThemeSettingsScreen(),
          ),
          GoRoute(
            path: '/user/edit-profile',
            name: 'userEditProfile',
            builder: (_, __) => const UserEditProfileScreen(),
          ),
        ],
      ),

      // ── Owner Shell ───────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            OwnerShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/owner/dashboard',
            name: 'ownerDashboard',
            builder: (_, __) => const OwnerDashboardScreen(),
          ),
          GoRoute(
            path: '/owner/bookings',
            name: 'ownerBookings',
            builder: (_, __) => const OwnerBookingsScreen(),
          ),
          GoRoute(
            path: '/owner/turfs/create',
            name: 'createTurf',
            builder: (_, __) => const OwnerCreateTurfScreen(),
          ),
          GoRoute(
            path: '/owner/turfs',
            name: 'manageTurfs',
            builder: (_, __) => const OwnerManageTurfsScreen(),
          ),
          GoRoute(
            path: '/owner/tournaments/create',
            name: 'createTournament',
            builder: (_, __) => const CreateTournamentScreen(),
          ),
          GoRoute(
            path: '/owner/profile',
            name: 'ownerProfile',
            builder: (_, __) => const OwnerProfileScreen(),
          ),
        ],
      ),

      // ── Admin Shell ───────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            AdminShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            name: 'adminDashboard',
            builder: (_, __) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/bookings',
            name: 'adminBookings',
            builder: (_, __) => const AdminBookingsScreen(),
          ),
          GoRoute(
            path: '/admin/tournaments',
            name: 'adminTournaments',
            builder: (_, __) => const AdminTournamentsScreen(),
          ),
          GoRoute(
            path: '/admin/approvals',
            name: 'adminApprovals',
            builder: (_, __) => const AdminOwnerApprovalsScreen(),
          ),
          GoRoute(
            path: '/admin/turfs',
            name: 'adminTurfs',
            builder: (_, __) => const AdminTurfManagementScreen(),
          ),
          GoRoute(
            path: '/admin/settlements',
            name: 'settlements',
            builder: (_, __) => const SettlementReportScreen(),
          ),
          GoRoute(
            path: '/admin/profile',
            name: 'adminProfile',
            builder: (_, __) => const AdminProfileScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            name: 'adminUsers',
            builder: (_, __) => const AdminUserManagementScreen(),
          ),
          GoRoute(
            path: '/admin/revenue',
            name: 'adminRevenue',
            builder: (_, __) => const AdminRevenueAnalyticsScreen(),
          ),
          GoRoute(
            path: '/admin/notifications',
            name: 'adminNotifications',
            builder: (_, __) => const AdminPushNotificationScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            name: 'adminSettings',
            builder: (_, __) => const AdminPlatformSettingsScreen(),
          ),
          GoRoute(
            path: '/admin/audit-log',
            name: 'adminAuditLog',
            builder: (_, __) => const AdminAuditLogScreen(),
          ),
          GoRoute(
            path: '/admin/help',
            name: 'adminHelp',
            builder: (_, __) => const AdminHelpSupportScreen(),
          ),
        ],
      ),
    ],
  );
}
