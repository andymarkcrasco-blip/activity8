import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'routes/app_routes.dart';

/// Root widget for Activity 8.
/// Uses go_router (MaterialApp.router) to prove client-side navigation works.
class Activity8App extends StatelessWidget {
  const Activity8App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      routerConfig: AppRoutes.router,
    );
  }
}
