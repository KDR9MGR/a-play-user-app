import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../profile/providers/profile_provider.dart';

class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      context.go('/sign-in');
      return;
    }
    try {
      final profile = await ref.read(profileFutureProvider.future);
      if (!mounted) return;
      if (profile.isOnboardingComplete) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    } catch (_) {
      if (!mounted) return;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
