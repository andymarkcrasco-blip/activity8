import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';

/// Visible home page - first checkpoint requirement (Activity 8).
/// Activity 9 adds the link to the Report Form screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Welcome to Activity 8!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            '${AppConstants.schoolSubject}\n${AppConstants.lesson}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.activity,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          const AppCard(
            title: 'Clear Setup',
            body: 'Flutter SDK + Chrome/Edge + VS Code ready. Run: flutter run -d chrome',
            icon: Icons.computer,
          ),
          const AppCard(
            title: 'Clean Structure',
            body: 'lib/screens, widgets, routes, services, models, constants are organized.',
            icon: Icons.folder,
          ),
          const AppCard(
            title: 'Working Shell',
            body: 'Home, Login, and Dashboard pages connected via go_router navigation.',
            icon: Icons.navigation,
          ),
          const AppCard(
            title: 'Reusable Widgets',
            body:
                'AppButton and AppTextField are shared by the login screen and the report form.',
            icon: Icons.widgets,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Go to Login',
            icon: Icons.login,
            onPressed: () => context.go(AppConstants.loginRoute),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Go to Dashboard',
            icon: Icons.dashboard,
            onPressed: () => context.go(AppConstants.dashboardRoute),
          ),
          const SizedBox(height: 8),
          // Activity 9: entry point to the new Report Form screen.
          AppButton(
            label: 'Go to Report Form',
            icon: Icons.report_problem,
            onPressed: () => context.go(AppConstants.reportRoute),
          ),
        ],
      ),
    );
  }
}
