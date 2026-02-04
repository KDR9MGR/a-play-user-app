import 'dart:async';

import 'package:a_play/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a_play/config/router.dart';
import 'package:a_play/core/config/supabase_config.dart';
import 'package:a_play/core/config/env.dart';
import 'package:a_play/core/widgets/connectivity_overlay.dart';
import 'package:a_play/core/widgets/auth_error_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:a_play/features/subscription/service/platform_subscription_service.dart';
import 'package:a_play/core/services/realtime_sync_service.dart';
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

    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

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

    final prefs = await SharedPreferences.getInstance();

    final envSupabaseUrl = SupabaseConfig.projectUrl;
    final envSupabaseAnonKey = SupabaseConfig.anonKey;

    final supabaseUrl = envSupabaseUrl.isNotEmpty
        ? envSupabaseUrl
        : (prefs.getString('SUPABASE_URL') ??
            'https://yvnfhsipyfxdmulajbgl.supabase.co');

    final supabaseAnonKey = envSupabaseAnonKey.isNotEmpty
        ? envSupabaseAnonKey
        : (prefs.getString('SUPABASE_ANON_KEY') ?? '');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      runApp(
        _SupabaseSetupApp(
          initialUrl: supabaseUrl,
          initialAnonKey: supabaseAnonKey,
          onSave: (url, anonKey) async {
            await prefs.setString('SUPABASE_URL', url);
            await prefs.setString('SUPABASE_ANON_KEY', anonKey);
            await _bootstrapApp(supabaseUrl: url, supabaseAnonKey: anonKey);
          },
        ),
      );
      return;
    }

    await _bootstrapApp(supabaseUrl: supabaseUrl, supabaseAnonKey: supabaseAnonKey);
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);

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

  final platformService = PlatformSubscriptionService();
  await platformService.initialize();

  final realtimeService = RealtimeSyncService();
  await realtimeService.initialize();

  runApp(
    ProviderScope(
      key: ValueKey('app_${DateTime.now().millisecondsSinceEpoch}'),
      child: const APlayApp(),
    ),
  );
}

class _SupabaseSetupApp extends StatefulWidget {
  final String initialUrl;
  final String initialAnonKey;
  final Future<void> Function(String url, String anonKey) onSave;

  const _SupabaseSetupApp({
    required this.initialUrl,
    required this.initialAnonKey,
    required this.onSave,
  });

  @override
  State<_SupabaseSetupApp> createState() => _SupabaseSetupAppState();
}

class _SupabaseSetupAppState extends State<_SupabaseSetupApp> {
  late final TextEditingController _urlController;
  late final TextEditingController _anonKeyController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl);
    _anonKeyController = TextEditingController(text: widget.initialAnonKey);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _anonKeyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;

    final url = _urlController.text.trim();
    final anonKey = _anonKeyController.text.trim();

    if (url.isEmpty || anonKey.isEmpty) {
      setState(() => _error = 'Please enter SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSave(url, anonKey);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Failed to save Supabase credentials: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Supabase Setup',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter your Supabase Project URL and anon key to start the app.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _urlController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'SUPABASE_URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _anonKeyController,
                      decoration: const InputDecoration(
                        labelText: 'SUPABASE_ANON_KEY',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        child: Text(_saving ? 'Saving...' : 'Save & Continue'),
                      ),
                    ),
                  ],
                ),
              ),
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
