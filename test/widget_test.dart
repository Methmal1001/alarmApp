import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:locate_me/screens/dashboard_screen.dart';
import 'package:locate_me/state/app_state.dart';

void main() {
  testWidgets('Dashboard shows LocateMe title and action cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    expect(find.text('LocateMe'), findsOneWidget);
    expect(find.text('Set Alarm'), findsOneWidget);
    expect(find.text('Set Location'), findsOneWidget);
  });
}
