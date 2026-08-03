import 'dart:async';

import 'package:a_play/core/theme/app_theme.dart';
// Firebase temporarily disabled for testing - uncomment when GoogleService-Info.plist is configured
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/config/router.dart';
import 'package:a_play/core/config/supabase_config.dart';
import 'package:a_play/core/config/env.dart';
import 'package:a_play/core/widgets/connectivity_overlay.dart';
import 'package:a_play/core/widgets/auth_error_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:a_play/core/services/realtime_sync_service.dart';
import 'package:a_play/core/services/notification_service.dart';
import 'package:a_play/core/services/iap_service.dart';
// import 'package:a_play/firebase_options.dart';

// Initialize app state provider
final appInitializationProvider = StateProvider<bool>((ref) => false);

// Tracks whether the app has already successfully reached its first runApp()
// call. Only errors that happen *before* that point are genuine bootstrap
// failures worth replacing the whole UI for - once the app is running
// normally, an uncaught async error elsewhere (a disposed provider, a
// flaky network call, ...) should be logged, not treated as if the entire
// app failed to start.
bool _appStarted = false;

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Env.initialize();

    // Firebase temporarily disabled for testing
    // TODO: Re-enable when GoogleService-Info.plist is properly configured
    /*
    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (!kIsWeb) {
        FlutterError.onError = (details) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }
    } catch (e) {
      // Firebase initialization failed - continue without Firebase
      // This allows app to run without proper Firebase configuration during testing
      if (kDebugMode) {
        debugPrint('⚠️ Firebase initialization failed: $e');
        debugPrint('⚠️ App will run without Firebase/Crashlytics');
      }
      // Don't throw - allow app to continue
    }
    */

    if (kDebugMode) {
      debugPrint('ℹ️ Firebase/Crashlytics disabled for testing');
    }

    await Connectivity().checkConnectivity();

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

    final supabaseUrl = SupabaseConfig.projectUrl;
    final supabaseAnonKey = SupabaseConfig.anonKey;

    final missing = <String>[];
    if (supabaseUrl.isEmpty) missing.add('SUPABASE_URL');
    if (supabaseAnonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');
    if (missing.isNotEmpty) {
      throw Exception(
        'Missing Supabase configuration (${missing.join(' / ')}). '
        'Pass values at build/run time using --dart-define or --dart-define-from-file. '
        'For local dev, create a .env file and run: tool/flutter_run.sh',
      );
    }

    // Force evaluation now so a misconfigured/missing Paystack key (or a test key
    // in a release build) fails app startup instead of failing silently later,
    // mid-checkout, in production.
    Env.paystackPublicKey;

    await _bootstrapApp(supabaseUrl: supabaseUrl, supabaseAnonKey: supabaseAnonKey);
  }, (error, stackTrace) {
    // Firebase/Crashlytics temporarily disabled for testing
    /*
    // Try to record error in Crashlytics if available
    if (!kIsWeb) {
      try {
        FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      } catch (e) {
        // Firebase/Crashlytics not available - log to console only
        if (kDebugMode) {
          debugPrint('Could not record error to Crashlytics: $e');
        }
      }
    }
    */

    // Log error to console
    if (kDebugMode) {
      debugPrint('${_appStarted ? "Uncaught app error" : "App initialization failed"}: $error');
      debugPrint('Stack trace: $stackTrace');
    }

    // The app already started successfully - this is a runtime error
    // somewhere else, not a bootstrap failure. Don't tear down the whole
    // running UI over it.
    if (_appStarted) return;

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
                  'Failed to initialize app: $error',
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
  });
}

Future<void> _bootstrapApp({
  required String supabaseUrl,
  required String supabaseAnonKey,
}) async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: kDebugMode,
  );

  // Initialize OneSignal for push notifications
  final oneSignalAppId = Env.oneSignalAppId;
  if (oneSignalAppId.isNotEmpty && !kIsWeb) {
    await NotificationService().initialize(appId: oneSignalAppId);
  }

  // Initialize IAP service for subscription sync (the only IAP stack in the app)
  if (!kIsWeb) {
    await IAPService.instance.initialize();
  }

  final realtimeService = RealtimeSyncService();
  await realtimeService.initialize();

  runApp(
    const ProviderScope(
      child: APlayApp(),
    ),
  );
  _appStarted = true;
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
