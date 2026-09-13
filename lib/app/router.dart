import 'package:go_router/go_router.dart';

import '../features/admin/presentation/screens/admin_dashboard.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/consumer/presentation/screens/consumer_dashboard.dart';
import '../features/farmer/presentation/screens/farmer_dashboard.dart';
import '../features/international_buyer/presentation/screens/international_dashboard.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/farmer', builder: (_, __) => const FarmerDashboard()),
    GoRoute(path: '/consumer', builder: (_, __) => const ConsumerDashboard()),
    GoRoute(path: '/international', builder: (_, __) => const InternationalDashboard()),
    GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
  ],
);
