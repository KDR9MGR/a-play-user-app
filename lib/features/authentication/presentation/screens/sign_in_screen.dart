import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/auth_provider.dart';

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
      debugPrint(
          'Attempting to sign in with email: ${_emailController.text.trim()}');

      final authController = ref.read(authControllerProvider.notifier);
      await authController.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Check if sign in was successful by checking the state
      final authState = ref.read(authControllerProvider);
      authState.when(
        data: (user) {
          if (user == null) {
            throw 'Failed to sign in';
          }
        },
        error: (error, stackTrace) {
          throw error.toString();
        },
        loading: () {},
      );

      debugPrint('Sign in successful');
    } catch (e) {
      debugPrint('Sign in error: $e');
      if (mounted) {
        String errorMessage = 'An error occurred during sign in';
        if (e is AuthException) {
          errorMessage = e.message;
        } else if (e is String) {
          errorMessage = e;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
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
      debugPrint('Attempting to sign in with Google');

      final authController = ref.read(authControllerProvider.notifier);
      await authController.signInWithGoogle();

      // Check if sign in was successful
      final authState = ref.read(authControllerProvider);
      authState.when(
        data: (user) {
          if (user == null) {
            throw 'Failed to sign in with Google';
          }
        },
        error: (error, stackTrace) {
          throw error.toString();
        },
        loading: () {},
      );

      debugPrint('Google sign in successful');
    } catch (e) {
      debugPrint('Google sign in error: $e');
      if (mounted) {
        String errorMessage = 'An error occurred during Google sign in';
        if (e is AuthException) {
          errorMessage = e.message;
        } else if (e is String) {
          errorMessage = e;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
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
      debugPrint('Attempting to sign in with Apple');

      final authController = ref.read(authControllerProvider.notifier);
      await authController.signInWithApple();

      // Check if sign in was successful
      final authState = ref.read(authControllerProvider);
      authState.when(
        data: (user) {
          if (user == null) {
            throw 'Failed to sign in with Apple';
          }
        },
        error: (error, stackTrace) {
          throw error.toString();
        },
        loading: () {},
      );

      debugPrint('Apple sign in successful');
    } catch (e) {
      debugPrint('Apple sign in error: $e');
      if (mounted) {
        String errorMessage = 'An error occurred during Apple sign in';
        if (e is AuthException) {
          errorMessage = e.message;
        } else if (e is String) {
          errorMessage = e;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  bool get _isIOS => !kIsWeb && Platform.isIOS;

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
                        width: 100, height: 100),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

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
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 32),

                  // Sign In button with custom styling
                  _CustomButton(
                    text: 'Sign In',
                    onPressed: _signIn,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Divider
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

                  const SizedBox(height: 24),

                  // Apple Sign In button FIRST (iOS only) - Apple guideline 4.8 requires equal prominence
                  if (_isIOS) ...[
                    _CustomSocialButton(
                      text: 'Sign In with Apple',
                      onPressed: _signInWithApple,
                      isLoading: _isAppleLoading,
                      icon: FontAwesomeIcons.apple,
                      iconColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Google Sign In button
                  _CustomSocialButton(
                    text: 'Sign In with Google',
                    onPressed: _signInWithGoogle,
                    isLoading: _isGoogleLoading,
                    icon: FontAwesomeIcons.google,
                    iconColor: Colors.red,
                  ),

                  const SizedBox(height: 32),

                  // Sign Up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      TextButton(
                        onPressed: () => context.push('/sign-up'),
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

// Custom TextField Widget
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
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.grey[300],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.isPassword && _obscureText,
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
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
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

// Custom Social Button
class _CustomSocialButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData icon;
  final Color iconColor;

  const _CustomSocialButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Colors.grey[800]!),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      icon: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : FaIcon(
              icon,
              color: iconColor,
              size: 20,
            ),
      label: Text(text),
    );
  }
}
