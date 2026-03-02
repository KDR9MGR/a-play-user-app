import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized error handling utility
/// Converts technical errors into user-friendly messages
class ErrorHandler {
  /// Parse Supabase auth errors into user-friendly messages
  static String handleAuthError(Object error) {
    if (error is AuthException) {
      switch (error.statusCode) {
        case '400':
          if (error.message.toLowerCase().contains('invalid login credentials')) {
            return 'Incorrect email or password. Please try again.';
          }
          if (error.message.toLowerCase().contains('email not confirmed')) {
            return 'Please verify your email address before signing in.';
          }
          if (error.message.toLowerCase().contains('user already registered')) {
            return 'This email is already registered. Try signing in instead.';
          }
          if (error.message.toLowerCase().contains('password')) {
            return 'Password must be at least 6 characters long.';
          }
          return 'Invalid request. Please check your input and try again.';

        case '401':
          return 'Your session has expired. Please sign in again.';

        case '403':
          return 'Access denied. You don\'t have permission to perform this action.';

        case '404':
          return 'Account not found. Please sign up first.';

        case '422':
          if (error.message.toLowerCase().contains('email')) {
            return 'Please enter a valid email address.';
          }
          return 'Invalid data provided. Please check your input.';

        case '429':
          return 'Too many attempts. Please wait a few minutes and try again.';

        case '500':
        case '502':
        case '503':
        case '504':
          return 'Server error. Please try again later.';

        default:
          // Try to extract meaningful message from error
          if (error.message.toLowerCase().contains('network')) {
            return 'Network error. Please check your internet connection.';
          }
          if (error.message.toLowerCase().contains('timeout')) {
            return 'Request timed out. Please try again.';
          }
          if (error.message.isNotEmpty && !error.message.contains('Exception')) {
            return error.message;
          }
          return 'Authentication failed. Please try again.';
      }
    }

    // Handle other auth-related errors
    if (error.toString().contains('Invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (error.toString().contains('Email not confirmed')) {
      return 'Please verify your email address before signing in.';
    }
    if (error.toString().contains('User not found')) {
      return 'Account not found. Please sign up first.';
    }

    return 'Authentication error. Please try again.';
  }

  /// Parse Supabase database errors into user-friendly messages
  static String handleDatabaseError(Object error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    // Timeout errors
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    // Constraint violations
    if (errorString.contains('unique constraint') || errorString.contains('duplicate')) {
      return 'This record already exists.';
    }

    if (errorString.contains('foreign key constraint')) {
      return 'Cannot complete action. Related data not found.';
    }

    if (errorString.contains('not null constraint')) {
      return 'Required information is missing.';
    }

    // Permission errors
    if (errorString.contains('permission') || errorString.contains('rls')) {
      return 'You don\'t have permission to perform this action.';
    }

    // Server errors (5xx)
    if (errorString.contains('500') || errorString.contains('internal server')) {
      return 'Server error. Please try again later.';
    }

    if (errorString.contains('502') || errorString.contains('bad gateway')) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    if (errorString.contains('503') || errorString.contains('service unavailable')) {
      return 'Service is currently down for maintenance. Please try again later.';
    }

    if (errorString.contains('504') || errorString.contains('gateway timeout')) {
      return 'Request timed out. Please try again.';
    }

    // Client errors (4xx)
    if (errorString.contains('400') || errorString.contains('bad request')) {
      return 'Invalid request. Please check your input.';
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Please sign in to continue.';
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Access denied. You don\'t have permission for this action.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Resource not found.';
    }

    if (errorString.contains('409') || errorString.contains('conflict')) {
      return 'This action conflicts with existing data.';
    }

    if (errorString.contains('422') || errorString.contains('unprocessable')) {
      return 'Invalid data provided. Please check your input.';
    }

    if (errorString.contains('429') || errorString.contains('too many')) {
      return 'Too many requests. Please wait a moment and try again.';
    }

    // Generic database error
    return 'Database error. Please try again.';
  }

  /// Parse payment/subscription errors
  static String handlePaymentError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('insufficient') || errorString.contains('not enough')) {
      return 'Insufficient balance. Please add funds to continue.';
    }

    if (errorString.contains('card declined') || errorString.contains('payment declined')) {
      return 'Payment declined. Please check your payment method.';
    }

    if (errorString.contains('expired card')) {
      return 'Your card has expired. Please update your payment method.';
    }

    if (errorString.contains('invalid card')) {
      return 'Invalid card details. Please check your card information.';
    }

    if (errorString.contains('subscription') && errorString.contains('active')) {
      return 'You already have an active subscription.';
    }

    if (errorString.contains('subscription') && errorString.contains('expired')) {
      return 'Your subscription has expired. Please renew to continue.';
    }

    return 'Payment failed. Please try again or contact support.';
  }

  /// Parse points/gifting errors
  static String handlePointsError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('insufficient points')) {
      return 'You don\'t have enough points for this action.';
    }

    if (errorString.contains('already gifted')) {
      return 'You\'ve already gifted this post.';
    }

    if (errorString.contains('no active subscription')) {
      return 'Please subscribe to gift points.';
    }

    if (errorString.contains('invalid amount') || errorString.contains('points_amount')) {
      return 'Invalid points amount. Please enter a valid number.';
    }

    return 'Unable to process points transaction. Please try again.';
  }

  /// Parse booking/reservation errors
  static String handleBookingError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('fully booked') || errorString.contains('no capacity')) {
      return 'Sorry, this event is fully booked.';
    }

    if (errorString.contains('booking expired')) {
      return 'This booking has expired. Please create a new booking.';
    }

    if (errorString.contains('already booked')) {
      return 'You already have a booking for this event.';
    }

    if (errorString.contains('past event')) {
      return 'Cannot book past events.';
    }

    if (errorString.contains('cancelled')) {
      return 'This event has been cancelled.';
    }

    return 'Booking failed. Please try again.';
  }

  /// Parse file upload errors
  static String handleUploadError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('file too large') || errorString.contains('size')) {
      return 'File is too large. Maximum size is 10MB.';
    }

    if (errorString.contains('invalid format') || errorString.contains('file type')) {
      return 'Invalid file format. Please upload an image (JPG, PNG, GIF).';
    }

    if (errorString.contains('permission')) {
      return 'No permission to upload files. Please check app permissions.';
    }

    return 'Upload failed. Please try again.';
  }

  /// Generic error handler - determines error type and returns appropriate message
  static String handle(Object error, {String? context}) {
    debugPrint('❌ Error in $context: $error');

    // Authentication errors
    if (error is AuthException ||
        error.toString().contains('Auth') ||
        error.toString().contains('login') ||
        error.toString().contains('password')) {
      return handleAuthError(error);
    }

    // Payment/subscription errors
    if (context?.contains('payment') == true ||
        context?.contains('subscription') == true ||
        error.toString().contains('payment') ||
        error.toString().contains('subscription')) {
      return handlePaymentError(error);
    }

    // Points/gifting errors
    if (context?.contains('points') == true ||
        context?.contains('gift') == true ||
        error.toString().contains('points') ||
        error.toString().contains('gift')) {
      return handlePointsError(error);
    }

    // Booking errors
    if (context?.contains('booking') == true ||
        context?.contains('reservation') == true ||
        error.toString().contains('booking')) {
      return handleBookingError(error);
    }

    // Upload errors
    if (context?.contains('upload') == true ||
        error.toString().contains('upload')) {
      return handleUploadError(error);
    }

    // Network/connection errors
    if (error.toString().toLowerCase().contains('socket') ||
        error.toString().toLowerCase().contains('connection') ||
        error.toString().toLowerCase().contains('network')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    // Default to database error handler
    return handleDatabaseError(error);
  }

  /// Get HTTP status code from error
  static int? getStatusCode(Object error) {
    if (error is AuthException) {
      return int.tryParse(error.statusCode ?? '');
    }

    final errorString = error.toString();
    final statusCodeMatch = RegExp(r'\b([45]\d{2})\b').firstMatch(errorString);
    if (statusCodeMatch != null) {
      return int.tryParse(statusCodeMatch.group(1) ?? '');
    }

    return null;
  }

  /// Check if error is a client error (4xx)
  static bool isClientError(Object error) {
    final statusCode = getStatusCode(error);
    return statusCode != null && statusCode >= 400 && statusCode < 500;
  }

  /// Check if error is a server error (5xx)
  static bool isServerError(Object error) {
    final statusCode = getStatusCode(error);
    return statusCode != null && statusCode >= 500 && statusCode < 600;
  }

  /// Check if error is a network error
  static bool isNetworkError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket') ||
        errorString.contains('timeout');
  }

  /// Check if error requires authentication
  static bool requiresAuth(Object error) {
    final statusCode = getStatusCode(error);
    return statusCode == 401 ||
        error.toString().toLowerCase().contains('unauthorized') ||
        error.toString().toLowerCase().contains('session expired');
  }

  /// Format error for logging (includes technical details)
  static String formatForLogging(Object error, StackTrace? stackTrace, {String? context}) {
    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('❌ ERROR REPORT');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    if (context != null) {
      buffer.writeln('Context: $context');
    }
    buffer.writeln('Error Type: ${error.runtimeType}');
    buffer.writeln('Error Message: $error');

    final statusCode = getStatusCode(error);
    if (statusCode != null) {
      buffer.writeln('HTTP Status Code: $statusCode');
      buffer.writeln('Error Category: ${_getErrorCategory(statusCode)}');
    }

    if (stackTrace != null) {
      buffer.writeln('\nStack Trace:');
      buffer.writeln(stackTrace.toString().split('\n').take(10).join('\n'));
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return buffer.toString();
  }

  static String _getErrorCategory(int statusCode) {
    if (statusCode >= 400 && statusCode < 500) {
      return 'Client Error (Invalid Request)';
    } else if (statusCode >= 500 && statusCode < 600) {
      return 'Server Error';
    }
    return 'Unknown';
  }
}
