import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:activity8/app.dart';
import 'package:activity8/screens/report_form_screen.dart';

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

Future<void> openReportForm(WidgetTester tester) async {
  await tester.pumpWidget(const Activity8App());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Report').first);
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

  testWidgets('EMPTY state is visible before any report exists', (tester) async {
    useTallSurface(tester);
    await openReportForm(tester);
    expect(find.textContaining('EMPTY'), findsOneWidget);
    expect(find.textContaining('no reports to display yet'), findsOneWidget);
  });

  testWidgets('Invalid input triggers field-level validation', (tester) async {
    useTallSurface(tester);
    await openReportForm(tester);
    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();
    expect(find.text('Report title is required'), findsOneWidget);
    expect(find.text('Please choose a category'), findsOneWidget);
    expect(find.text('Please choose a location'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
  });

  testWidgets('Valid submit goes LOADING then SUCCESS', (tester) async {
    useTallSurface(tester);
    await openReportForm(tester);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Report Title'), 'Beach venue closed');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'The beach venue in Butuan closed early on the event date.');
    await pickDropdown(tester, 0, 'Venue Listing Issue');
    await pickDropdown(tester, 1, 'Butuan City');

    await tester.tap(find.text('Submit Report'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // LOADING state
    expect(find.textContaining('LOADING'), findsOneWidget);
    expect(find.text('Submit Report...'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 4));

    // SUCCESS state
    expect(find.textContaining('SUCCESS'), findsOneWidget);
    expect(find.textContaining('saved successfully'), findsOneWidget);
  });

  testWidgets('Simulated failure shows ERROR with a Retry action', (tester) async {
    useTallSurface(tester);
    await openReportForm(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Report Title'), 'Duplicate listing');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'The same venue appears twice in the search results list.');
    await pickDropdown(tester, 0, 'Booking / Reservation Problem');
    await pickDropdown(tester, 1, 'Butuan City');

    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // ERROR state + Retry
    expect(find.text('ERROR - Report was not submitted'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
