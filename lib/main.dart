import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_navigator.dart';
import 'screens/dashboard_screen.dart';
import 'screens/test_dashboard_screen.dart';
import 'state/app_state.dart';

const bool _kTestMode = false;

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.red,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            'BUILD ERROR:\n\n${details.exceptionAsString()}\n\n${details.stack}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  };
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  WidgetsFlutterBinding.ensureInitialized();
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT ASYNC ERROR: $error\n$stack');
    return true;
  };
  if (_kTestMode) {
    runApp(
      ChangeNotifierProvider(
        create: (_) => AppState()..load(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: TestDashboardScreen(),
        ),
      ),
    );
    return;
  }
  runApp(const LocateMeApp());
}

class LocateMeApp extends StatelessWidget {
  const LocateMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF2E7D6B);
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'LocateMe',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: seed),
          scaffoldBackgroundColor: const Color(0xFFF4F7F6),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
