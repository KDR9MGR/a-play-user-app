
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).resetPassword(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email. Please check your inbox.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        // Navigate back to sign in after short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go('/sign-in');
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to send reset email. Please try again.';
        if (e.toString().toLowerCase().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (e.toString().toLowerCase().contains('user not found')) {
          errorMessage = 'No account found with this email address.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/sign-in'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[400],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _resetPassword(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    labelStyle: TextStyle(color: Colors.grey[300]),
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
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
                const SizedBox(height: 32),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Back to sign in
                TextButton(
                  onPressed: () => context.go('/sign-in'),
                  child: Text(
                    'Back to Sign In',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
