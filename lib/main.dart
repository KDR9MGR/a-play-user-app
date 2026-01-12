import 'package:a_play/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/config/router.dart';
import 'package:a_play/core/config/supabase_config.dart';
import 'package:a_play/core/widgets/connectivity_overlay.dart';
import 'package:a_play/core/widgets/auth_error_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:a_play/features/subscription/service/platform_subscription_service.dart';
import 'package:a_play/core/services/realtime_sync_service.dart';

// Initialize app state provider
final appInitializationProvider = StateProvider<bool>((ref) => false);
 
Future<void> main() async {
  try {
    // Ensure Flutter bindings are initialized first
    WidgetsFlutterBinding.ensureInitialized();

    // Clear any cached state in debug mode
    assert(() {
      debugPrint('Debug mode: Clearing cached state for fresh restart');
      return true;
    }());

    // Initialize Connectivity Plugin
    await Connectivity().checkConnectivity();

    // Set system preferences
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color.fromARGB(255, 234, 156, 156),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    debugPrint('Initializing Supabase with URL: ${SupabaseConfig.projectUrl}');
    
    // Initialize Supabase first
    try {
      await Supabase.initialize(
        url: SupabaseConfig.projectUrl,
        anonKey: SupabaseConfig.anonKey,
        debug: true,
      );
    } catch (e) {
      // If already initialized, that's fine in debug mode
      debugPrint('Supabase initialization: $e');
    }

    debugPrint('Supabase initialized successfully');

    // Initialize Platform Subscription Service early for debugging
    debugPrint('=== EARLY PLATFORM SUBSCRIPTION SERVICE INIT ===');
    final platformService = PlatformSubscriptionService();
    await platformService.initialize();
    debugPrint('=== EARLY PLATFORM SUBSCRIPTION SERVICE INIT COMPLETE ===');

    // Initialize Real-time Sync Service for live data updates
    debugPrint('=== INITIALIZING REAL-TIME SYNC SERVICE ===');
    final realtimeService = RealtimeSyncService();
    await realtimeService.initialize();
    debugPrint('✅ Real-time sync initialized - User app will receive live updates from admin/org apps');

    // Run the app only after Supabase is initialized
    runApp(
      // Use a new ProviderScope for fresh state in debug mode
      ProviderScope(
        key: ValueKey('app_${DateTime.now().millisecondsSinceEpoch}'),
        child: const APlayApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Error in main: $e');
    debugPrint('Stack trace: $stackTrace');
    // Show error UI
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize app: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class APlayApp extends ConsumerWidget {
  const APlayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      title: 'A Play',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: AuthErrorHandler(
            child: ConnectivityOverlay(
              child: child ?? const SizedBox(),
            ),
          ),
        );
      },
    );
  }
}
