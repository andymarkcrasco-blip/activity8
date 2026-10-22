import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../screens/dashboard_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../widgets/app_shell.dart';

/// Centralized navigation for the initialization shell.
/// Proves: Home <-> Login <-> Dashboard page transitions work.
class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.homeRoute,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppConstants.homeRoute,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppConstants.loginRoute,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: AppConstants.dashboardRoute,
            builder: (context, state) => const DashboardScreen(),
          ),
        ],
      ),
    ],
  );
}
