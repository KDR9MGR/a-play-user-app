import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resend Email Service
/// Handles transactional emails:
/// - Welcome emails for new users
/// - Email verification
/// - Password reset emails
/// - Booking confirmations (fallback)
class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // Get Resend API key from environment
  final String _apiKey = const String.fromEnvironment('RESEND_API_KEY');
  final String _baseUrl = 'https://api.resend.com';

  // Your verified domain/email in Resend
  final String _fromEmail = const String.fromEnvironment(
    'RESEND_FROM_EMAIL',
    defaultValue: 'A-Play <noreply@yourdomain.com>',
  );

  /// Send welcome email to new user
  Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String userName,
  }) async {
    try {
      final response = await _sendEmail(
        to: toEmail,
        subject: 'Welcome to A-Play! 🎉',
        html: _buildWelcomeEmailHtml(userName),
      );

      return response;
    } catch (e) {
      debugPrint('Error sending welcome email: $e');
      return false;
    }
  }

  /// Send email verification
  Future<bool> sendVerificationEmail({
    required String toEmail,
    required String verificationLink,
    required String userName,
  }) async {
    try {
      final response = await _sendEmail(
        to: toEmail,
        subject: 'Verify Your A-Play Email',
        html: _buildVerificationEmailHtml(userName, verificationLink),
      );

      return response;
    } catch (e) {
      debugPrint('Error sending verification email: $e');
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({
    required String toEmail,
    required String resetLink,
    required String userName,
  }) async {
    try {
      final response = await _sendEmail(
        to: toEmail,
        subject: 'Reset Your A-Play Password',
        html: _buildPasswordResetEmailHtml(userName, resetLink),
      );

      return response;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return false;
    }
  }

  /// Send booking confirmation email
  Future<bool> sendBookingConfirmationEmail({
    required String toEmail,
    required String userName,
    required String eventName,
    required String bookingId,
    required DateTime eventDate,
    required String venue,
    required int ticketCount,
  }) async {
    try {
      final response = await _sendEmail(
        to: toEmail,
        subject: 'Booking Confirmed - $eventName',
        html: _buildBookingConfirmationHtml(
          userName: userName,
          eventName: eventName,
          bookingId: bookingId,
          eventDate: eventDate,
          venue: venue,
          ticketCount: ticketCount,
        ),
      );

      return response;
    } catch (e) {
      debugPrint('Error sending booking confirmation: $e');
      return false;
    }
  }

  /// Core method to send email via Resend API
  Future<bool> _sendEmail({
    required String to,
    required String subject,
    required String html,
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint('Resend API key not configured');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/emails'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': _fromEmail,
          'to': [to],
          'subject': subject,
          'html': html,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Email sent successfully to $to');
        return true;
      } else {
        debugPrint('Failed to send email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error calling Resend API: $e');
      return false;
    }
  }

  // Email HTML Templates

  String _buildWelcomeEmailHtml(String userName) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to A-Play</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Poppins', Arial, sans-serif; background-color: #121212;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #121212;">
        <tr>
            <td align="center" style="padding: 40px 20px;">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #1E1E1E; border-radius: 16px; overflow: hidden;">
                    <!-- Header with gradient -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="color: #FFFFFF; margin: 0; font-size: 32px; font-weight: 700;">Welcome to A-Play! 🎉</h1>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <p style="color: #FFFFFF; font-size: 18px; line-height: 1.6; margin: 0 0 20px 0;">
                                Hi <strong>$userName</strong>,
                            </p>
                            <p style="color: #B0B0B0; font-size: 16px; line-height: 1.6; margin: 0 0 20px 0;">
                                Thank you for joining A-Play - Ghana's premier event booking platform!
                            </p>
                            <p style="color: #B0B0B0; font-size: 16px; line-height: 1.6; margin: 0 0 30px 0;">
                                You're now part of a vibrant community that connects you to the best events, entertainment, and experiences across Ghana.
                            </p>

                            <!-- What's Next Section -->
                            <div style="background-color: #2A2A2A; border-radius: 12px; padding: 25px; margin: 0 0 30px 0;">
                                <h2 style="color: #FF6B35; font-size: 20px; margin: 0 0 15px 0;">What's Next?</h2>
                                <ul style="color: #B0B0B0; font-size: 15px; line-height: 1.8; margin: 0; padding-left: 20px;">
                                    <li>Explore trending events happening in Ghana</li>
                                    <li>Book tickets with zone-based seating</li>
                                    <li>Connect with friends through chat</li>
                                    <li>Share your experiences on the social feed</li>
                                    <li>Upgrade to premium for exclusive benefits</li>
                                </ul>
                            </div>

                            <!-- CTA Button -->
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="padding: 20px 0;">
                                        <a href="https://yourapp.com/events" style="background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); color: #FFFFFF; padding: 16px 40px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 16px; display: inline-block;">
                                            Explore Events
                                        </a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #151515; padding: 30px; text-align: center; border-top: 1px solid #2A2A2A;">
                            <p style="color: #707070; font-size: 14px; margin: 0 0 10px 0;">
                                Need help? Contact us at <a href="mailto:support@yourapp.com" style="color: #FF6B35; text-decoration: none;">support@yourapp.com</a>
                            </p>
                            <p style="color: #505050; font-size: 12px; margin: 0;">
                                © 2026 A-Play. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
    ''';
  }

  String _buildVerificationEmailHtml(String userName, String verificationLink) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Your Email</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Poppins', Arial, sans-serif; background-color: #121212;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #121212;">
        <tr>
            <td align="center" style="padding: 40px 20px;">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #1E1E1E; border-radius: 16px; overflow: hidden;">
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="color: #FFFFFF; margin: 0; font-size: 32px; font-weight: 700;">Verify Your Email 📧</h1>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <p style="color: #FFFFFF; font-size: 18px; line-height: 1.6; margin: 0 0 20px 0;">
                                Hi <strong>$userName</strong>,
                            </p>
                            <p style="color: #B0B0B0; font-size: 16px; line-height: 1.6; margin: 0 0 30px 0;">
                                Thanks for signing up! Please verify your email address to activate your A-Play account and start booking amazing events.
                            </p>

                            <!-- CTA Button -->
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="padding: 20px 0;">
                                        <a href="$verificationLink" style="background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); color: #FFFFFF; padding: 16px 40px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 16px; display: inline-block;">
                                            Verify Email Address
                                        </a>
                                    </td>
                                </tr>
                            </table>

                            <p style="color: #808080; font-size: 14px; line-height: 1.6; margin: 30px 0 0 0; text-align: center;">
                                Or copy and paste this link in your browser:<br>
                                <a href="$verificationLink" style="color: #FF6B35; word-break: break-all;">$verificationLink</a>
                            </p>

                            <p style="color: #606060; font-size: 13px; line-height: 1.6; margin: 30px 0 0 0; text-align: center;">
                                This link will expire in 24 hours for security reasons.
                            </p>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #151515; padding: 30px; text-align: center; border-top: 1px solid #2A2A2A;">
                            <p style="color: #707070; font-size: 14px; margin: 0 0 10px 0;">
                                If you didn't create this account, you can safely ignore this email.
                            </p>
                            <p style="color: #505050; font-size: 12px; margin: 0;">
                                © 2026 A-Play. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
    ''';
  }

  String _buildPasswordResetEmailHtml(String userName, String resetLink) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Your Password</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Poppins', Arial, sans-serif; background-color: #121212;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #121212;">
        <tr>
            <td align="center" style="padding: 40px 20px;">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #1E1E1E; border-radius: 16px; overflow: hidden;">
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="color: #FFFFFF; margin: 0; font-size: 32px; font-weight: 700;">Reset Your Password 🔐</h1>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <p style="color: #FFFFFF; font-size: 18px; line-height: 1.6; margin: 0 0 20px 0;">
                                Hi <strong>$userName</strong>,
                            </p>
                            <p style="color: #B0B0B0; font-size: 16px; line-height: 1.6; margin: 0 0 30px 0;">
                                We received a request to reset your A-Play password. Click the button below to create a new password.
                            </p>

                            <!-- CTA Button -->
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="padding: 20px 0;">
                                        <a href="$resetLink" style="background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); color: #FFFFFF; padding: 16px 40px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 16px; display: inline-block;">
                                            Reset Password
                                        </a>
                                    </td>
                                </tr>
                            </table>

                            <p style="color: #808080; font-size: 14px; line-height: 1.6; margin: 30px 0 0 0; text-align: center;">
                                Or copy and paste this link in your browser:<br>
                                <a href="$resetLink" style="color: #FF6B35; word-break: break-all;">$resetLink</a>
                            </p>

                            <div style="background-color: #2A2A2A; border-left: 4px solid #FF6B35; padding: 20px; margin: 30px 0 0 0; border-radius: 8px;">
                                <p style="color: #FFA500; font-size: 14px; line-height: 1.6; margin: 0;">
                                    <strong>Security Note:</strong><br>
                                    This link will expire in 1 hour. If you didn't request this password reset, please ignore this email or contact support if you have concerns.
                                </p>
                            </div>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #151515; padding: 30px; text-align: center; border-top: 1px solid #2A2A2A;">
                            <p style="color: #707070; font-size: 14px; margin: 0 0 10px 0;">
                                Need help? Contact us at <a href="mailto:support@yourapp.com" style="color: #FF6B35; text-decoration: none;">support@yourapp.com</a>
                            </p>
                            <p style="color: #505050; font-size: 12px; margin: 0;">
                                © 2026 A-Play. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
    ''';
  }

  String _buildBookingConfirmationHtml({
    required String userName,
    required String eventName,
    required String bookingId,
    required DateTime eventDate,
    required String venue,
    required int ticketCount,
  }) {
    final formattedDate = '${eventDate.day}/${eventDate.month}/${eventDate.year}';
    final formattedTime = '${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}';

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Confirmed</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Poppins', Arial, sans-serif; background-color: #121212;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #121212;">
        <tr>
            <td align="center" style="padding: 40px 20px;">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #1E1E1E; border-radius: 16px; overflow: hidden;">
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #4CAF50 0%, #45A049 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="color: #FFFFFF; margin: 0; font-size: 32px; font-weight: 700;">Booking Confirmed! ✅</h1>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <p style="color: #FFFFFF; font-size: 18px; line-height: 1.6; margin: 0 0 20px 0;">
                                Hi <strong>$userName</strong>,
                            </p>
                            <p style="color: #B0B0B0; font-size: 16px; line-height: 1.6; margin: 0 0 30px 0;">
                                Your booking for <strong style="color: #FFFFFF;">$eventName</strong> has been confirmed!
                            </p>

                            <!-- Booking Details -->
                            <div style="background-color: #2A2A2A; border-radius: 12px; padding: 25px; margin: 0 0 30px 0;">
                                <h2 style="color: #FF6B35; font-size: 20px; margin: 0 0 20px 0;">Booking Details</h2>

                                <table width="100%" cellpadding="8" cellspacing="0">
                                    <tr>
                                        <td style="color: #808080; font-size: 14px; padding-bottom: 12px;">Booking ID:</td>
                                        <td style="color: #FFFFFF; font-size: 14px; text-align: right; font-family: monospace;">$bookingId</td>
                                    </tr>
                                    <tr>
                                        <td style="color: #808080; font-size: 14px; padding-bottom: 12px;">Event:</td>
                                        <td style="color: #FFFFFF; font-size: 14px; text-align: right; font-weight: 600;">$eventName</td>
                                    </tr>
                                    <tr>
                                        <td style="color: #808080; font-size: 14px; padding-bottom: 12px;">Date:</td>
                                        <td style="color: #FFFFFF; font-size: 14px; text-align: right;">$formattedDate at $formattedTime</td>
                                    </tr>
                                    <tr>
                                        <td style="color: #808080; font-size: 14px; padding-bottom: 12px;">Venue:</td>
                                        <td style="color: #FFFFFF; font-size: 14px; text-align: right;">$venue</td>
                                    </tr>
                                    <tr>
                                        <td style="color: #808080; font-size: 14px;">Tickets:</td>
                                        <td style="color: #FFFFFF; font-size: 14px; text-align: right;">$ticketCount ${ticketCount == 1 ? 'ticket' : 'tickets'}</td>
                                    </tr>
                                </table>
                            </div>

                            <!-- CTA Button -->
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="padding: 20px 0;">
                                        <a href="https://yourapp.com/my-tickets" style="background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); color: #FFFFFF; padding: 16px 40px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 16px; display: inline-block;">
                                            View My Tickets
                                        </a>
                                    </td>
                                </tr>
                            </table>

                            <p style="color: #808080; font-size: 14px; line-height: 1.6; margin: 30px 0 0 0; text-align: center;">
                                Your QR code tickets are available in the app. Present them at the venue for entry.
                            </p>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #151515; padding: 30px; text-align: center; border-top: 1px solid #2A2A2A;">
                            <p style="color: #707070; font-size: 14px; margin: 0 0 10px 0;">
                                Questions? Contact us at <a href="mailto:support@yourapp.com" style="color: #FF6B35; text-decoration: none;">support@yourapp.com</a>
                            </p>
                            <p style="color: #505050; font-size: 12px; margin: 0;">
                                © 2026 A-Play. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
    ''';
  }

  /// Send booking cancellation confirmation email
  Future<bool> sendCancellationEmail({
    required String toEmail,
    required String userName,
    required String eventName,
    required String bookingId,
    required double refundAmount,
    required String refundStatus,
  }) async {
    try {
      final html = _buildCancellationHtml(
        userName: userName,
        eventName: eventName,
        bookingId: bookingId,
        refundAmount: refundAmount,
        refundStatus: refundStatus,
      );

      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'from': _fromEmail,
          'to': [toEmail],
          'subject': 'Booking Cancelled - $eventName',
          'html': html,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Cancellation email sent to $toEmail');
        return true;
      } else {
        debugPrint('❌ Failed to send cancellation email: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending cancellation email: $e');
      return false;
    }
  }

  String _buildCancellationHtml({
    required String userName,
    required String eventName,
    required String bookingId,
    required double refundAmount,
    required String refundStatus,
  }) {
    String refundMessage;
    String refundColor;
    String refundTitle;

    if (refundStatus == 'full_refund') {
      refundTitle = 'Full Refund Approved';
      refundColor = '#4CAF50';
      refundMessage = 'You will receive a full refund of <strong>GHS ${refundAmount.toStringAsFixed(2)}</strong> within 5-7 business days to your original payment method.';
    } else if (refundStatus == 'partial_refund') {
      refundTitle = 'Partial Refund (50%)';
      refundColor = '#FF9800';
      refundMessage = 'You will receive a partial refund of <strong>GHS ${refundAmount.toStringAsFixed(2)}</strong> (50% of booking amount) within 5-7 business days to your original payment method.';
    } else {
      refundTitle = 'No Refund Available';
      refundColor = '#F44336';
      refundMessage = 'Unfortunately, this booking is not eligible for a refund as it was cancelled less than 24 hours before the event, per our <a href="https://www.aplayworld.com/refund-policy" style="color: #FF6B35;">cancellation policy</a>.';
    }

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Cancelled</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Poppins', Arial, sans-serif; background-color: #121212;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #121212;">
        <tr>
            <td align="center" style="padding: 40px 20px;">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #1E1E1E; border-radius: 16px; overflow: hidden;">
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #F44336 0%, #D32F2F 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="color: #FFFFFF; margin: 0; font-size: 32px; font-weight: 700;">Booking Cancelled</h1>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <p style="color: #FFFFFF; font-size: 18px; line-height: 1.6; margin: 0 0 20px 0;">
                                Hi <strong>$userName</strong>,
                            </p>
                            <p style="color: #B0B0B0; font-size: 16px; line-height: 1.6; margin: 0 0 30px 0;">
                                Your booking for <strong style="color: #FFFFFF;">$eventName</strong> has been cancelled as requested.
                            </p>

                            <!-- Cancellation Details -->
                            <div style="background-color: #2A2A2A; border-radius: 12px; padding: 25px; margin: 0 0 30px 0;">
                                <h2 style="color: #FF6B35; font-size: 20px; margin: 0 0 20px 0;">Cancellation Details</h2>

                                <table width="100%" cellpadding="8" cellspacing="0">
                                    <tr>
                                        <td style="color: #808080; font-size: 14px; padding-bottom: 12px;">Booking ID:</td>
                                        <td style="color: #FFFFFF; font-size: 14px; text-align: right; font-family: monospace;">$bookingId</td>
                                    </tr>
                                    <tr>
                                        <td style="color: #808080; font-size: 14px; padding-bottom: 12px;">Event:</td>
                                        <td style="color: #FFFFFF; font-size: 14px; text-align: right; font-weight: 600;">$eventName</td>
                                    </tr>
                                    <tr>
                                        <td style="color: #808080; font-size: 14px; padding-bottom: 12px;">Cancelled On:</td>
                                        <td style="color: #FFFFFF; font-size: 14px; text-align: right;">${DateTime.now().toString().split(' ')[0]}</td>
                                    </tr>
                                    <tr>
                                        <td style="color: #808080; font-size: 14px;">Status:</td>
                                        <td style="color: #F44336; font-size: 14px; text-align: right; font-weight: 600;">CANCELLED</td>
                                    </tr>
                                </table>
                            </div>

                            <!-- Refund Information -->
                            <div style="background-color: #2A2A2A; border-left: 4px solid $refundColor; padding: 25px; margin: 0 0 30px 0; border-radius: 8px;">
                                <h3 style="color: $refundColor; font-size: 18px; margin: 0 0 15px 0;">💰 $refundTitle</h3>
                                <p style="color: #B0B0B0; font-size: 14px; line-height: 1.6; margin: 0;">
                                    $refundMessage
                                </p>
                            </div>

                            <!-- Refund Timeline (if applicable) -->
                            ${refundAmount > 0 ? '''
                            <div style="background-color: #252525; border-radius: 8px; padding: 20px; margin: 0 0 30px 0;">
                                <h4 style="color: #FFFFFF; font-size: 16px; margin: 0 0 15px 0;">📅 Refund Timeline</h4>
                                <table width="100%" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td style="padding: 8px 0;">
                                            <span style="display: inline-block; width: 24px; height: 24px; background-color: #4CAF50; border-radius: 50%; text-align: center; line-height: 24px; color: white; font-size: 12px; margin-right: 10px;">✓</span>
                                            <span style="color: #B0B0B0; font-size: 14px;">Cancellation processed</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 8px 0;">
                                            <span style="display: inline-block; width: 24px; height: 24px; background-color: #FF9800; border-radius: 50%; text-align: center; line-height: 24px; color: white; font-size: 12px; margin-right: 10px;">⏳</span>
                                            <span style="color: #B0B0B0; font-size: 14px;">Refund processing (3-5 business days)</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 8px 0;">
                                            <span style="display: inline-block; width: 24px; height: 24px; background-color: #757575; border-radius: 50%; text-align: center; line-height: 24px; color: white; font-size: 12px; margin-right: 10px;">○</span>
                                            <span style="color: #B0B0B0; font-size: 14px;">Refund appears in your account (5-7 business days)</span>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            ''' : ''}

                            <!-- Important Notes -->
                            <div style="background-color: #2A2A2A; border-left: 4px solid #FF6B35; padding: 20px; margin: 30px 0 0 0; border-radius: 8px;">
                                <p style="color: #FFA500; font-size: 14px; line-height: 1.6; margin: 0;">
                                    <strong>📌 Important Notes:</strong><br>
                                    ${refundAmount > 0 ? '• Refunds are processed to your original payment method<br>• Service fees (2.9% + GHS 1) are non-refundable<br>' : ''}• Your tickets are now invalid and cannot be used for entry<br>
                                    • If you have any questions, please contact our support team
                                </p>
                            </div>

                            <!-- CTA Button -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0 0 0;">
                                <tr>
                                    <td align="center">
                                        <a href="https://www.aplayworld.com/events" style="display: inline-block; background: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%); color: #FFFFFF; text-decoration: none; padding: 16px 32px; border-radius: 8px; font-weight: 600; font-size: 16px;">Browse Other Events</a>
                                    </td>
                                </tr>
                            </table>

                            <p style="color: #808080; font-size: 14px; line-height: 1.6; margin: 30px 0 0 0; text-align: center;">
                                We're sorry to see you go! We hope to see you at another event soon.
                            </p>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #151515; padding: 30px; text-align: center; border-top: 1px solid #2A2A2A;">
                            <p style="color: #707070; font-size: 14px; margin: 0 0 10px 0;">
                                Questions? Contact us at <a href="mailto:support@aplayapp.com" style="color: #FF6B35; text-decoration: none;">support@aplayapp.com</a>
                            </p>
                            <p style="color: #707070; font-size: 12px; margin: 10px 0;">
                                <a href="https://www.aplayworld.com/refund-policy" style="color: #808080; text-decoration: none;">Refund Policy</a> •
                                <a href="https://www.aplayworld.com/faq" style="color: #808080; text-decoration: none;">FAQ</a>
                            </p>
                            <p style="color: #505050; font-size: 12px; margin: 10px 0 0 0;">
                                © 2026 A-Play. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
    ''';
  }
}

/// Riverpod provider for EmailService
final emailServiceProvider = Provider<EmailService>((ref) {
  return EmailService();
});
