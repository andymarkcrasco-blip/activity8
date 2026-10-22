import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';

/// Navigation shell: consistent header + menu buttons on every page.
/// This satisfies the "Navigation Shell" requirement in Lesson 8.
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Activity 8\nIT 110 - Flutter Web',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                context.go(AppConstants.homeRoute);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                context.go(AppConstants.loginRoute);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                context.go(AppConstants.dashboardRoute);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top nav bar for web (visible route buttons)
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _NavButton(label: 'Home', route: AppConstants.homeRoute),
                  const SizedBox(width: 8),
                  _NavButton(label: 'Login', route: AppConstants.loginRoute),
                  const SizedBox(width: 8),
                  _NavButton(label: 'Dashboard', route: AppConstants.dashboardRoute),
                ],
              ),
            ),
          ),
          Expanded(child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ))),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final String route;
  const _NavButton({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.go(route),
      child: Text(label),
    );
  }
}
