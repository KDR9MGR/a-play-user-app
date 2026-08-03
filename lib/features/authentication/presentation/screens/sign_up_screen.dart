import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/feature_flags.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! Welcome, ${_nameController.text.trim()}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to onboarding
        context.go('/onboarding');
      }
    } catch (e) {
      if (mounted) {
        // Parse error for user-friendly messages
        String errorMessage = 'An error occurred during sign up';
        bool isEmailConfirmation = false;

        // Extract the actual error message
        String rawError = e.toString();
        if (e is AuthException) {
          rawError = e.message;
        }

        if (rawError.toLowerCase().contains('check your email') ||
            rawError.toLowerCase().contains('confirm your account')) {
          // Email confirmation required — not really an error
          isEmailConfirmation = true;
          errorMessage = 'Account created! Please check your email to verify your account.';
        } else if (rawError.toLowerCase().contains('already registered') ||
            rawError.toLowerCase().contains('user already exists') ||
            rawError.toLowerCase().contains('already been registered')) {
          errorMessage = 'This email is already registered. Please sign in instead.';
        } else if (rawError.toLowerCase().contains('invalid email')) {
          errorMessage = 'Please enter a valid email address.';
        } else if (rawError.toLowerCase().contains('weak password') ||
                   rawError.toLowerCase().contains('password')) {
          errorMessage = rawError.replaceAll('AuthException:', '').replaceAll('Exception:', '').trim();
        } else {
          // Clean up technical error messages
          errorMessage = rawError
              .replaceAll('AuthException:', '')
              .replaceAll('Exception:', '')
              .replaceAll('AuthException', '')
              .trim();
          if (errorMessage.length > 100 || errorMessage.contains('{')) {
            errorMessage = 'Unable to create account. Please try again.';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: isEmailConfirmation ? Colors.green : Colors.red[700],
            duration: Duration(seconds: isEmailConfirmation ? 6 : 4),
            action: SnackBarAction(
              label: isEmailConfirmation ? 'Sign In' : 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (isEmailConfirmation) {
                  context.go('/sign-in');
                }
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      debugPrint('🔵 [GOOGLE-SIGNUP] Starting Google sign-up');
      // isSignUp: true - throws "already exists... please sign in" if this
      // Google account already has an A-Play account.
      await ref
          .read(authControllerProvider.notifier)
          .signInWithGoogle(isSignUp: true);

      if (!mounted) return;
      context.go('/onboarding');
    } catch (e) {
      debugPrint('🔵 [GOOGLE-SIGNUP] ✗ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('AuthException: ', '')),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _signUpWithApple() async {
    setState(() => _isAppleLoading = true);

    try {
      debugPrint('🍎 [APPLE-SIGNUP] Starting Apple sign-up');
      // isSignUp: true - throws "already exists... please sign in" if this
      // Apple ID already has an A-Play account.
      await ref
          .read(authControllerProvider.notifier)
          .signInWithApple(isSignUp: true);

      if (!mounted) return;
      context.go('/onboarding');
    } catch (e) {
      debugPrint('🍎 [APPLE-SIGNUP] ✗ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('AuthException: ', '')),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                      final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
                      if (!hasNumber || !hasSpecial) {
                        return 'Password must include a number and a special character';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _signUp(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    text: 'Sign Up',
                    onPressed: _signUp,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  // Social login hidden again at user's request. The
                  // underlying sign-up/sign-in intent enforcement and email
                  // fallback fixes remain in place - only the entry points
                  // are hidden - so re-enabling later is just deleting this
                  // `if (FeatureFlags.enableSocialLogin)` guard.
                  if (FeatureFlags.enableSocialLogin) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AuthButton(
                    text: 'Sign Up with Google',
                    onPressed: _signUpWithGoogle,
                    isLoading: _isGoogleLoading,
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                      color: Colors.red,
                    ),
                  ),
                  // Apple guideline: Sign in with Apple must be offered on
                  // Apple platforms whenever other third-party logins are.
                  if (!kIsWeb && Platform.isIOS) ...[
                    const SizedBox(height: 12),
                    AuthButton(
                      text: 'Sign Up with Apple',
                      onPressed: _signUpWithApple,
                      isLoading: _isAppleLoading,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      icon: const Icon(
                        Icons.apple,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () => context.go('/sign-in'),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
