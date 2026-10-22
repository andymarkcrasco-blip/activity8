/// Centralized constants so repeated values stay in one place.
class AppConstants {
  static const String appTitle = 'Activity 8 - Flutter Web Init';
  static const String homeTitle = 'Home Page';
  static const String loginTitle = 'Login Page';
  static const String dashboardTitle = 'Dashboard / Module Placeholder';

  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String reportRoute = '/report';

  static const String schoolSubject = 'IT 110 - Web Systems and Technologies';
  static const String lesson = 'Lesson 8: Flutter Web Project Initialization';
  static const String activity = 'Activity 9: Reusable Screens, Widgets and Async UI States';

  // EventVenue Caraga domain values used by the report form.
  static const List<String> reportCategories = <String>[
    'Venue Listing Issue',
    'Booking / Reservation Problem',
    'Payment or Refund Issue',
    'Content or Safety Concern',
    'Suggestion / Feature Request',
    'Other',
  ];

  static const List<String> reportLocations = <String>[
    'Butuan City',
    'Surigao del Norte',
    'Surigao del Sur',
    'Agusan del Norte',
    'Agusan del Sur',
    'Dinagat Islands',
    'Other (Caraga Region)',
  ];
}
