import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_navigator.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
