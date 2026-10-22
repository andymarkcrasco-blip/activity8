import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:activity8/app.dart';
import 'package:activity8/screens/report_form_screen.dart';
import 'package:activity8/services/api_client.dart';
import 'package:activity8/services/report_service.dart';

/// Gives the test a tall surface so every widget is on-screen.
void useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Opens the DropdownButton at [index] and picks [item] from the menu.
Future<void> pickDropdown(
    WidgetTester tester, int index, String item) async {
  await tester.tap(find.byType(DropdownButton<String>).at(index));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item).last);
  await tester.pumpAndSettle();
}

/// A fake REST API so the tests never need a running server.
MockClient fakeApi({
  List<Map<String, dynamic>> reports = const [],
  int createStatus = 200,
  bool online = true,
}) {
  // The fake keeps the reports it creates so the list behaves like the real API.
  final stored = <Map<String, dynamic>>[...reports];

  return MockClient((request) async {
    if (request.url.path == '/api/health') {
      return http.Response(
        jsonEncode({
          'ok': online,
          'service': 'eventvenue-api',
          'database': online ? 'connected' : 'offline',
        }),
        200,
      );
    }
    if (request.url.path == '/api/reports' && request.method == 'GET') {
      return http.Response(
        jsonEncode({'ok': true, 'count': stored.length, 'reports': stored}),
        200,
      );
    }
    if (request.url.path == '/api/reports' && request.method == 'POST') {
      // A real request takes time, so the LOADING state is observable.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (createStatus != 200) {
        return http.Response(
          jsonEncode({'detail': 'Simulated server error'}),
          createStatus,
        );
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final record = {
        'report_id': stored.length + 1,
        'reference': 'EV-000001',
        'title': body['title'],
        'category': body['category'],
        'location': body['location'],
        'description': body['description'],
        'contact': body['contact'],
        'status': 'open',
        'created_at': '2026-10-22T10:00:00',
      };
      stored.add(record);
      return http.Response(
        jsonEncode({
          'ok': true,
          'message': 'Report EV-000001 saved to PostgreSQL.',
          'report': record,
        }),
        200,
      );
    }
    return http.Response(jsonEncode({'detail': 'Not found'}), 404);
  });
}

ReportService serviceWith(MockClient client) =>
    ReportService(api: ApiClient(baseUrl: 'http://test.local', client: client));

Future<void> openReportForm(WidgetTester tester, ReportService service) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: ReportFormScreen(service: service)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Activity8 app boots with Home navigation shell', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const Activity8App());
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Activity 8!'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Login'), findsWidgets);
  });

  testWidgets('Home screen links to the Activity 9 report form', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const Activity8App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go to Report Form'));
    await tester.pumpAndSettle();
    expect(find.byType(ReportFormScreen), findsOneWidget);
    expect(find.text('Report an Issue'), findsOneWidget);
  });

  testWidgets('EMPTY state is shown when the API returns no reports',
      (tester) async {
    useTallSurface(tester);
    await openReportForm(tester, serviceWith(fakeApi()));
    expect(find.textContaining('EMPTY'), findsOneWidget);
    expect(find.textContaining('no reports in the database'), findsOneWidget);
  });

  testWidgets('Saved reports from the API are listed', (tester) async {
    useTallSurface(tester);
    final saved = [
      {
        'report_id': 1,
        'reference': 'EV-696748',
        'title': 'Beach resort closed early',
        'category': 'Venue Listing Issue',
        'location': 'Butuan City',
        'description': 'The beach resort venue closed early.',
        'contact': '09171234567',
        'status': 'open',
        'created_at': '2026-10-22T10:00:00',
      }
    ];
    await openReportForm(tester, serviceWith(fakeApi(reports: saved)));
    expect(find.textContaining('EV-696748'), findsOneWidget);
    expect(find.text('Submitted Reports (1)'), findsOneWidget);
  });

  testWidgets('Invalid input triggers field-level validation', (tester) async {
    useTallSurface(tester);
    await openReportForm(tester, serviceWith(fakeApi()));
    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();
    expect(find.text('Report title is required'), findsOneWidget);
    expect(find.text('Please choose a category'), findsOneWidget);
    expect(find.text('Please choose a location'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
  });

  testWidgets('Valid submit goes LOADING then SUCCESS', (tester) async {
    useTallSurface(tester);
    await openReportForm(tester, serviceWith(fakeApi()));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Report Title'), 'Beach venue closed');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'The beach venue in Butuan City closed early on the event date.');
    await pickDropdown(tester, 0, 'Venue Listing Issue');
    await pickDropdown(tester, 1, 'Butuan City');

    await tester.tap(find.text('Submit Report'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // LOADING state
    expect(find.textContaining('LOADING'), findsOneWidget);
    expect(find.text('Submit Report...'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // SUCCESS state
    expect(find.textContaining('SUCCESS'), findsOneWidget);
    expect(find.textContaining('EV-000001'), findsWidgets);
  });

  testWidgets('A server failure shows ERROR with a Retry action', (tester) async {
    useTallSurface(tester);
    await openReportForm(tester, serviceWith(fakeApi(createStatus: 500)));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Report Title'), 'Duplicate listing');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'The same venue appears twice in the Caraga search results list.');
    await pickDropdown(tester, 0, 'Booking / Reservation Problem');
    await pickDropdown(tester, 1, 'Butuan City');

    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ERROR state + Retry
    expect(find.text('ERROR - Report was not submitted'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Simulated failure switch shows the ERROR state', (tester) async {
    useTallSurface(tester);
    await openReportForm(tester, serviceWith(fakeApi()));

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Report Title'), 'Duplicate listing');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'The same venue appears twice in the Caraga search results list.');
    await pickDropdown(tester, 0, 'Other');
    await pickDropdown(tester, 1, 'Butuan City');

    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('ERROR - Report was not submitted'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
