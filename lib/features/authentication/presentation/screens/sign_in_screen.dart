import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/feature_flags.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    ref.listenManual(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          context.go('/home');
        }
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('📱 [SIGN-IN] Starting sign-in process');
      debugPrint('📱 [SIGN-IN] Email: ${_emailController.text.trim()}');

      final authController = ref.read(authControllerProvider.notifier);
      await authController.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      debugPrint('📱 [SIGN-IN] signInWithEmail completed');

      // Check if sign in was successful by checking the state
      final authState = ref.read(authControllerProvider);
      debugPrint('📱 [SIGN-IN] Checking auth state...');

      authState.when(
        data: (user) {
          debugPrint('📱 [SIGN-IN] State: data - User: ${user?.email ?? "null"}');
          if (user == null) {
            throw 'Failed to sign in';
          }
          // Show success message
          if (mounted) {
            debugPrint('📱 [SIGN-IN] ✓ Sign-in successful!');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sign in successful! Welcome back.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        error: (error, stackTrace) {
          debugPrint('📱 [SIGN-IN] State: error - $error');
          throw error.toString();
        },
        loading: () {
          debugPrint('📱 [SIGN-IN] State: loading');
        },
      );
    } catch (e) {
      debugPrint('📱 [SIGN-IN] ✗ Caught exception: $e');
      debugPrint('📱 [SIGN-IN] Exception type: ${e.runtimeType}');
      if (mounted) {
        String errorMessage = 'An error occurred during sign in';

        // Extract the actual error message
        String rawError = e.toString();

        // Parse Supabase AuthException for user-friendly messages
        if (e is AuthException) {
          rawError = e.message;
          debugPrint('📱 [SIGN-IN] AuthException message: $rawError');
        }

        // Check for common error patterns
        if (rawError.toLowerCase().contains('invalid login credentials') ||
            rawError.toLowerCase().contains('invalid email or password') ||
            rawError.toLowerCase().contains('invalid credentials')) {
          errorMessage = 'Invalid email or password. Please try again.';
        } else if (rawError.toLowerCase().contains('email not confirmed')) {
          errorMessage = 'Please verify your email address before signing in.';
        } else if (rawError.toLowerCase().contains('user not found')) {
          errorMessage = 'No account found with this email.';
        } else if (rawError.toLowerCase().contains('network') ||
                   rawError.toLowerCase().contains('connection')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else {
          // Clean up the error message - remove "AuthException:" or "Exception:" prefix
          errorMessage = rawError
              .replaceAll('AuthException:', '')
              .replaceAll('Exception:', '')
              .replaceAll('AuthException', '')
              .trim();

          // If still too technical, use generic message
          if (errorMessage.length > 100 || errorMessage.contains('(') || errorMessage.contains('{')) {
            errorMessage = 'Unable to sign in. Please check your credentials and try again.';
          }
        }

        debugPrint('📱 [SIGN-IN] Showing error to user: $errorMessage');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      debugPrint('🔵 [GOOGLE] Starting Google sign-in');
      // isSignUp: false - throws "No account found... please sign up first"
      // if this Google account has no existing A-Play account.
      await ref
          .read(authControllerProvider.notifier)
          .signInWithGoogle(isSignUp: false);

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      debugPrint('🔵 [GOOGLE] ✗ Error: $e');
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

  Future<void> _signInWithApple() async {
    setState(() => _isAppleLoading = true);

    try {
      debugPrint('🍎 [APPLE] Starting Apple sign-in');
      // isSignUp: false - throws "No account found... please sign up first"
      // if this Apple ID has no existing A-Play account.
      await ref
          .read(authControllerProvider.notifier)
          .signInWithApple(isSignUp: false);

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      debugPrint('🍎 [APPLE] ✗ Error: $e');
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
      backgroundColor: Colors.black,
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
                  // App Logo
                  Center(
                    child: Image.asset('assets/images/logo.png',
                        width: 80, height: 80),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Email field with custom styling
                  _CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field with custom styling
                  _CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outline,
                    onSubmitted: (_) => _signIn(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  // Forgot Password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go('/reset-password'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sign In button with custom styling
                  _CustomButton(
                    text: 'Sign In',
                    onPressed: _signIn,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Social login hidden again at user's request. The
                  // underlying sign-in/sign-up intent enforcement and email
                  // fallback fixes remain in place - only the entry points
                  // are hidden - so re-enabling later is just deleting this
                  // `if (FeatureFlags.enableSocialLogin)` guard.
                  if (FeatureFlags.enableSocialLogin) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey[800],
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey[800],
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    AuthButton(
                      text: 'Sign In with Google',
                      onPressed: _signInWithGoogle,
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
                        text: 'Sign In with Apple',
                        onPressed: _signInWithApple,
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

                    const SizedBox(height: 16),
                  ],

                  // Guest Access Option
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/home'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign Up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      TextButton(
                        onPressed: () => context.go('/sign-up'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

// Custom TextField Widget - Optimized with proper state management
class _CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isPassword;
  final IconData prefixIcon;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    required this.textInputAction,
    this.isPassword = false,
    required this.prefixIcon,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<_CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<_CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(text: widget.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(
              widget.prefixIcon,
              color: Colors.grey[400],
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[400],
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}

// Extracted label widget for performance
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[300],
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }
}

// Custom Button
class _CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }
}
