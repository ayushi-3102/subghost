import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/paywall_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Lock to Portrait orientation (Standard for mobile utilities)
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (_) {}

  // 2. Set Status bar style to match OLED dark theme
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  } catch (_) {}

  // 3. Initialize 100% Offline Local Storage (Hive)
  try {
    await StorageService.initialize();
  } catch (e) {
    debugPrint("StorageService init error: $e");
  }

  // 4. Initialize Paywall (RevenueCat)
  try {
    await PaywallService.initialize();
  } catch (e) {
    debugPrint("PaywallService init error: $e");
  }

  // 5. Determine starting route (First launch vs Returning user)
  bool hasSeenOnboarding = false;
  try {
    hasSeenOnboarding = StorageService.hasSeenOnboarding();
  } catch (_) {}

  runApp(
    ProviderScope(
      child: SubZeroApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class SubZeroApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const SubZeroApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubGhost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0910),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFFA78BFA),
          surface: Color(0xFF141220),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: hasSeenOnboarding ? const DashboardScreen() : const OnboardingScreen(),
    );
  }
}
