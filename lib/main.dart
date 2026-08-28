import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'screens/landing_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? startupError;
  try {
    await Supabase.initialize(
      url: 'https://ewlcshkyrqkdfwoaqkil.supabase.co',
      publishableKey: 'sb_publishable_X_7iPQun5AHFvPEuSbwNVg_lm_dp72_',
    );
    await StorageService.init();
    await appThemeController.load();
  } catch (error) {
    startupError = error.toString();
  }
  runApp(MireaSanctumApp(startupError: startupError));
}

class MireaSanctumApp extends StatelessWidget {
  const MireaSanctumApp({super.key, this.startupError});

  final String? startupError;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appThemeController,
      builder: (context, _) => MaterialApp(
        title: 'Mirea Sanctum',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeFor(appThemeController.variant),
        home: startupError != null
            ? StartupErrorScreen(message: startupError!)
            : Supabase.instance.client.auth.currentSession != null
                ? const MainScreen()
                : const LandingScreen(),
      ),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 16),
              const Text('Mirea Sanctum could not start'),
              const SizedBox(height: 8),
              SelectableText(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
