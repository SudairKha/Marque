import '../../features/owner/presentation/screens/owner_booking_detail_screen.dart';
import '../../features/owner/presentation/screens/owner_proposal_detail_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/customer/presentation/screens/customer_shell.dart';
import '../../features/customer/presentation/screens/customer_home_screen.dart';
import '../../features/customer/presentation/screens/requirement_wizard.dart';
import '../../features/customer/presentation/screens/my_proposals_screen.dart';
import '../../features/customer/presentation/screens/proposal_detail_screen.dart';
import '../../features/customer/presentation/screens/customer_profile_screen.dart';

import '../../features/owner/presentation/screens/owner_shell.dart';
import '../../features/owner/presentation/screens/owner_dashboard_screen.dart';
import '../../features/owner/presentation/screens/owner_reqs_screen.dart';
import '../../features/owner/presentation/screens/owner_req_detail_screen.dart';
import '../../features/owner/presentation/screens/send_proposal_screen.dart';
import '../../features/owner/presentation/screens/owner_bookings_screen.dart';
import '../../features/owner/presentation/screens/owner_profile_screen.dart';
import '../../features/owner/presentation/screens/marquee_wizard.dart';

import '../../features/admin/presentation/screens/admin_shell.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_food_menu_screen.dart';
import '../../features/admin/presentation/screens/admin_event_types_screen.dart';
import '../../features/admin/presentation/screens/admin_services_screen.dart';
import '../../features/admin/presentation/screens/admin_marquees_screen.dart';
import '../../features/admin/presentation/screens/admin_customers_screen.dart';
import '../../features/admin/presentation/screens/admin_proposals_screen.dart';
import '../../features/admin/presentation/screens/admin_bookings_screen.dart';
import '../../features/admin/presentation/screens/admin_landing_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
    if (session == null && !isLoggingIn) return '/login';
    if (session != null && isLoggingIn) return '/customer/home';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),

    // CUSTOMER
    ShellRoute(
      builder: (_, __, child) => CustomerShell(child: child),
      routes: [
        GoRoute(path: '/customer/home', builder: (_, __) => const CustomerHomeScreen()),
        GoRoute(path: '/customer/req/1', builder: (_, __) => const ReqStep1Screen()),
        GoRoute(path: '/customer/req/2', builder: (_, __) => const ReqStep2Screen()),
        GoRoute(path: '/customer/req/3', builder: (_, __) => const ReqStep3Screen()),
        GoRoute(path: '/customer/req/4', builder: (_, __) => const ReqStep4Screen()),
        GoRoute(path: '/customer/proposals', builder: (_, __) => const MyProposalsScreen()),
        GoRoute(path: '/customer/proposal/:id', builder: (_, state) => ProposalDetailScreen(id: state.pathParameters['id']!)),
        GoRoute(path: '/customer/profile', builder: (_, __) => const CustomerProfileScreen()),
      ],
    ),

    // OWNER
        GoRoute(path: '/owner/proposal/:id', builder: (_, state) => OwnerProposalDetailScreen(proposalId: state.pathParameters['id']!)),
    GoRoute(path: '/owner/booking/:id', builder: (_, state) => OwnerBookingDetailScreen(id: state.pathParameters['id']!)),
    ShellRoute(builder: (_, __, child) => OwnerShell(child: child),
      routes: [
        GoRoute(path: '/owner/dashboard', builder: (_, __) => const OwnerDashboardScreen()),
        GoRoute(path: '/owner/reqs', builder: (_, __) => const OwnerReqsScreen()),
        GoRoute(path: '/owner/bookings', builder: (_, __) => const OwnerBookingsScreen()),
        GoRoute(path: '/owner/profile', builder: (_, __) => const OwnerProfileScreen()),
      ],
    ),
    GoRoute(path: '/owner/req/:id', builder: (_, state) => OwnerReqDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/owner/send-proposal/:id', builder: (_, state) => SendProposalScreen(reqId: state.pathParameters['id']!)),
    GoRoute(path: '/owner/marquee/:step', builder: (_, state) => MarqueeWizardScreen(step: int.tryParse(state.pathParameters['step']!) ?? 1)),

    // ADMIN
    ShellRoute(
      builder: (_, __, child) => AdminShell(child: child),
      routes: [
        GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardScreen()),
        GoRoute(path: '/admin/food', builder: (_, __) => const AdminFoodMenuScreen()),
        GoRoute(path: '/admin/event-types', builder: (_, __) => const AdminEventTypesScreen()),
        GoRoute(path: '/admin/services', builder: (_, __) => const AdminServicesScreen()),
        GoRoute(path: '/admin/marquees', builder: (_, __) => const AdminMarqueesScreen()),
        GoRoute(path: '/admin/customers', builder: (_, __) => const AdminCustomersScreen()),
        GoRoute(path: '/admin/proposals', builder: (_, __) => const AdminProposalsScreen()),
        GoRoute(path: '/admin/bookings', builder: (_, __) => const AdminBookingsScreen()),
        GoRoute(path: '/admin/landing', builder: (_, __) => const AdminLandingScreen()),
      ],
    ),
  ],
);
