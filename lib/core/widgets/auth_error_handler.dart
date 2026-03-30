import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';

class AuthErrorHandler extends ConsumerStatefulWidget {
  final Widget child;
  
  const AuthErrorHandler({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AuthErrorHandler> createState() => _AuthErrorHandlerState();
}

class _AuthErrorHandlerState extends ConsumerState<AuthErrorHandler> {
  bool _isShowingDialog = false;
  
  @override
  void initState() {
    super.initState();
    _setupAuthErrorListener();
  }
  
  void _setupAuthErrorListener() {
    // Listen to auth state changes
    ref.listenManual(authStateProvider, (previous, next) {
      next.when(
        data: (user) {
          // User is authenticated or signed out normally
        },
        error: (error, stackTrace) {
          _handleAuthError(error);
        },
        loading: () {
          // Loading state
        },
      );
    });
  }
  
  void _handleAuthError(Object error) {
    if (!mounted || _isShowingDialog) return;
    
    final errorString = error.toString();
    
    // Check if it's a JWT expiration error
    if (errorString.contains('JWT expired') || 
        errorString.contains('PGRST301') ||
        errorString.contains('Unauthorized')) {
      _showSessionExpiredDialog();
    }
  }
  
  void _showSessionExpiredDialog() {
    if (_isShowingDialog) return;
    
    setState(() {
      _isShowingDialog = true;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              
              navigator.pop();
              setState(() {
                _isShowingDialog = false;
              });
              
              // Sign out and redirect to login
              await AuthService.signOut();
              if (mounted) {
                router.go('/sign-in');
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 