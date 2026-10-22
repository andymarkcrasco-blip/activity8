import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';

/// Dashboard / module placeholder.
/// In the semester project this becomes the real system modules.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text(
            'Module placeholder - future features (API, database) will be added here.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const AppCard(title: 'Module 1', body: 'Placeholder card for future feature.', icon: Icons.widgets),
          const AppCard(title: 'Module 2', body: 'Placeholder card for future feature.', icon: Icons.widgets),
          const AppCard(title: 'Version Control', body: 'This working baseline is committed to Git/GitHub.', icon: Icons.cloud_upload),
          const SizedBox(height: 16),
          AppButton(
            label: 'Logout (back to Home)',
            icon: Icons.logout,
            onPressed: () => context.go(AppConstants.homeRoute),
          ),
        ],
      ),
    );
  }
}
