import 'dart:async';

import 'package:a_play/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'package:a_play/features/subscription/service/platform_subscription_service.dart';
import 'package:a_play/core/services/realtime_sync_service.dart';
import 'package:a_play/core/services/notification_service.dart';
import 'package:a_play/core/services/iap_service.dart';
import 'package:a_play/firebase_options.dart';

// Initialize app state provider
final appInitializationProvider = StateProvider<bool>((ref) => false);
 
Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Env.initialize();

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

    await _bootstrapApp(supabaseUrl: supabaseUrl, supabaseAnonKey: supabaseAnonKey);
  }, (error, stackTrace) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    }

    if (kDebugMode) {
      debugPrint('Error in main: $error');
      debugPrint('Stack trace: $stackTrace');
    }

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
    debugPrint('✅ OneSignal initialized with App ID: ${oneSignalAppId.substring(0, 8)}...');
  } else if (kIsWeb) {
    debugPrint('ℹ️ OneSignal disabled on Web for now');
  } else {
    debugPrint('⚠️ OneSignal App ID not found - push notifications disabled');
  }

  final platformService = PlatformSubscriptionService();
  await platformService.initialize();

  // Initialize new IAP service for subscription sync
  if (!kIsWeb) {
    debugPrint('Initializing IAP Service for subscription sync...');
    await IAPService.instance.initialize();
    debugPrint('✅ IAP Service initialized');
  } else {
    debugPrint('ℹ️ IAP Service skipped on Web');
  }

  final realtimeService = RealtimeSyncService();
  await realtimeService.initialize();

  runApp(
    ProviderScope(
      key: ValueKey('app_${DateTime.now().millisecondsSinceEpoch}'),
      child: const APlayApp(),
    ),
  );
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
