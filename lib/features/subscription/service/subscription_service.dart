import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../model/subscription_model.dart';
import '../../../core/config/paystack_config.dart';

class SubscriptionService {
  late final SupabaseClient _client;
  final String _paystackPublicKey = PaystackConfig.publicKey;

  SubscriptionService() {
    try {
      _client = Supabase.instance.client;
    } catch (e) {
      throw Exception('Supabase client not initialized. Please ensure Supabase.initialize() is called before accessing the client.');
    }
  }

  // Get the current user ID
  String? get _userId => _client.auth.currentUser?.id;
  
  // Get the current user's email
  String? getUserEmail() {
    return _client.auth.currentUser?.email;
  }

  // Get all available subscription plans
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final response = await _client
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .order('tier_level', ascending: true);

      return (response as List)
          .map((json) => SubscriptionPlan.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch subscription plans: $e');
    }
  }

  // Get user's active subscription if any
  Future<UserSubscription?> getActiveSubscription() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('user_subscriptions')
          .select('''
            *,
            subscription_plans (*)
          ''')
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserSubscription.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch active subscription: $e');
    }
  }

  // Check if user has an active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final subscription = await getActiveSubscription();
      return subscription != null;
    } catch (e) {
      return false;
    }
  }

  // Check if user has used their free trial
  Future<bool> hasUsedTrial() async {
    try {
      final userId = _userId;
      if (userId == null) {
        return false;
      }

      // Check if user has ever had a trial subscription
      final response = await _client
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('subscription_type', '3-Day Free Trial')
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Check if user is eligible for free trial
  Future<bool> isEligibleForTrial() async {
    try {
      final hasUsed = await hasUsedTrial();
      final hasActive = await hasActiveSubscription();
      return !hasUsed && !hasActive;
    } catch (e) {
      return false;
    }
  }

  // Get user's subscription history
  Future<List<UserSubscription>> getSubscriptionHistory() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserSubscription.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch subscription history: $e');
    }
  }

  // Get payment history for a subscription
  Future<List<SubscriptionPayment>> getPaymentHistory() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('subscription_payments')
          .select()
          .eq('user_id', userId)
          .order('payment_date', ascending: false);

      return (response as List)
          .map((json) => SubscriptionPayment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch payment history: $e');
    }
  }

  // Initialize PayStack payment
  Future<Map<String, dynamic>> initializePaystackPayment(
      String email, double amount, String planId) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Convert amount to kobo (Paystack requires amount in the smallest currency unit)
      final amountInKobo = (amount * 100).toInt();

      // Generate a reference
      final reference = 'SUB_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}';

      final response = await _client.functions.invoke(
        'paystack',
        body: {
          'action': 'initialize',
          'email': email,
          'amount': amountInKobo,
          'reference': reference,
          'callback_url': 'https://aplay.com/subscription/callback',
          'metadata': {
            'user_id': userId,
            'plan_id': planId,
            'custom_fields': [
              {
                'display_name': 'Subscription Plan',
                'variable_name': 'plan_id',
                'value': planId,
              }
            ]
          }
        },
      );

      if (response.status == 200) {
        final responseData = (response.data as Map).cast<String, dynamic>();
        final data = (responseData['data'] as Map?)?.cast<String, dynamic>();

        return {
          'status': true,
          'reference': reference,
          'authorization_url': data?['authorization_url'],
          'access_code': data?['access_code'],
        };
      } else {
        throw Exception(
            'Failed to initialize payment: ${response.status}');
      }
    } catch (e) {
      throw Exception('Failed to initialize payment: $e');
    }
  }

  // Verify PayStack payment
  Future<PaystackVerification> verifyPaystackPayment(String reference) async {
    try {
      final response = await _client.functions.invoke(
        'paystack',
        body: {
          'action': 'verify',
          'reference': reference,
        },
      );

      if (response.status != 200) {
        throw Exception('Paystack verify returned status ${response.status}');
      }

      final responseData = (response.data as Map).cast<String, dynamic>();
      return PaystackVerification.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  // Start free trial subscription
  /// S2: eligibility and the actual insert are both re-checked/performed
  /// server-side by the start-free-trial edge function (service role only -
  /// the client can no longer insert a trial row directly).
  Future<UserSubscription> startFreeTrial() async {
    final response = await _client.functions.invoke('start-free-trial');
    final data = response.data;
    if (data is! Map || data['success'] != true) {
      throw Exception(data is Map ? (data['error'] ?? 'Failed to start free trial') : 'Failed to start free trial');
    }
    return UserSubscription.fromJson(Map<String, dynamic>.from(data['subscription']));
  }

  /// S2: after Paystack confirms the reference, fulfillment (creating the
  /// user_subscriptions/subscription_payments rows) is done server-side by
  /// confirm-purchase, which re-verifies with Paystack itself and builds the
  /// subscription strictly from what paystack/initialize computed and
  /// recorded for this reference - never from planId/amount supplied here.
  Future<UserSubscription> createSubscription(
      String planId, String paymentReference) async {
    final response = await _client.functions.invoke(
      'confirm-purchase',
      body: {'reference': paymentReference},
    );
    final data = response.data;
    if (data is! Map || data['success'] != true) {
      throw Exception(data is Map ? (data['error'] ?? 'Failed to confirm subscription') : 'Failed to confirm subscription');
    }

    // Best-effort side effects; failures here must not undo a real payment.
    try {
      await _client.functions.invoke(
        'trigger-referral-award',
        body: {'userId': _userId, 'subscriptionId': data['id']},
      );
    } catch (_) {}
    try {
      final user = _client.auth.currentUser;
      if (user != null && user.email != null) {
        await _client.functions.invoke('send-email', body: {
          'to': user.email,
          'subject': 'Your A-Play Subscription Confirmation',
          'html': '<h1>Subscription Confirmed!</h1><p>Your subscription is confirmed.</p>',
        });
      }
    } catch (e) {
      debugPrint('Failed to send subscription confirmation email: $e');
    }

    return UserSubscription.fromJson(Map<String, dynamic>.from(data['subscription']));
  }

  // Sync Apple subscription status with local database
  Future<UserSubscription?> syncAppleSubscriptionStatus(
      String originalTransactionId) async {
    try {
      debugPrint('=== SYNCING APPLE SUBSCRIPTION STATUS ===');
      debugPrint('Original Transaction ID: $originalTransactionId');
      
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Find existing subscription by original transaction ID
      final existingSubscriptions = await _client
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('payment_method', 'apple_iap')
          .eq('payment_reference', originalTransactionId);

      if (existingSubscriptions.isEmpty) {
        debugPrint('No existing subscription found for transaction: $originalTransactionId');
        return null;
      }

      final subscription = UserSubscription.fromJson(existingSubscriptions.first);
      debugPrint('Found existing subscription: ${subscription.id}');

      // Get the latest receipt data from Apple (this would typically come from the app)
      // For now, we'll update based on the current subscription status
      final now = DateTime.now().toUtc();
      final endDate = subscription.endDate;
      
      String newStatus = subscription.status;
      if (now.isAfter(endDate)) {
        newStatus = 'expired';
        debugPrint('Subscription has expired, updating status');
      } else {
        newStatus = 'active';
        debugPrint('Subscription is still active');
      }

      // Update subscription status if changed
      if (newStatus != subscription.status) {
        await _client
            .from('user_subscriptions')
            .update({
              'status': newStatus,
              'updated_at': now.toIso8601String(),
            })
            .eq('id', subscription.id);

        debugPrint('Subscription status updated to: $newStatus');
        
        // Return updated subscription
        final updatedResponse = await _client
            .from('user_subscriptions')
            .select()
            .eq('id', subscription.id)
            .single();
            
        return UserSubscription.fromJson(updatedResponse);
      }

      debugPrint('=== APPLE SUBSCRIPTION SYNC COMPLETE ===');
      return subscription;
    } catch (e) {
      debugPrint('=== APPLE SUBSCRIPTION SYNC FAILED ===');
      debugPrint('Error: $e');
      throw Exception('Failed to sync Apple subscription status: $e');
    }
  }

  // Update subscription with Apple receipt validation data
  Future<UserSubscription> updateSubscriptionWithReceiptData(
      String subscriptionId, Map<String, dynamic> receiptData) async {
    try {
      debugPrint('=== UPDATING SUBSCRIPTION WITH RECEIPT DATA ===');
      debugPrint('Subscription ID: $subscriptionId');
      
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final expiresDateMs = receiptData['expiresDateMs'] as String?;

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Update end date if provided
      if (expiresDateMs != null) {
        final expiresDate = DateTime.fromMillisecondsSinceEpoch(
          int.parse(expiresDateMs),
          isUtc: true,
        );
        updateData['end_date'] = expiresDate.toIso8601String();
        updateData['status'] = expiresDate.isAfter(DateTime.now().toUtc()) ? 'active' : 'expired';
      }

      // Update the subscription
      await _client
          .from('user_subscriptions')
          .update(updateData)
          .eq('id', subscriptionId)
          .eq('user_id', userId);

      debugPrint('Subscription updated with receipt data');

      // Return updated subscription
      final updatedResponse = await _client
          .from('user_subscriptions')
          .select()
          .eq('id', subscriptionId)
          .single();

      debugPrint('=== SUBSCRIPTION UPDATE COMPLETE ===');
      return UserSubscription.fromJson(updatedResponse);
    } catch (e) {
      debugPrint('=== SUBSCRIPTION UPDATE FAILED ===');
      debugPrint('Error: $e');
      throw Exception('Failed to update subscription with receipt data: $e');
    }
  }

  // Check and sync all Apple subscriptions for current user
  Future<List<UserSubscription>> syncAllAppleSubscriptions() async {
    try {
      debugPrint('=== SYNCING ALL APPLE SUBSCRIPTIONS ===');
      
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get all Apple IAP subscriptions for user
      final subscriptions = await _client
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('payment_method', 'apple_iap')
          .order('created_at', ascending: false);

      final syncedSubscriptions = <UserSubscription>[];
      
      for (final subscriptionData in subscriptions) {
        try {
          final subscription = UserSubscription.fromJson(subscriptionData);
          final now = DateTime.now().toUtc();
          final endDate = subscription.endDate;
          
          // Check if subscription needs status update
          String expectedStatus = subscription.status;
          if (now.isAfter(endDate) && subscription.status == 'active') {
            expectedStatus = 'expired';
          } else if (now.isBefore(endDate) && subscription.status == 'expired') {
            expectedStatus = 'active';
          }

          if (expectedStatus != subscription.status) {
            await _client
                .from('user_subscriptions')
                .update({
                  'status': expectedStatus,
                  'updated_at': now.toIso8601String(),
                })
                .eq('id', subscription.id);

            // Get updated subscription
            final updatedResponse = await _client
                .from('user_subscriptions')
                .select()
                .eq('id', subscription.id)
                .single();
                
            syncedSubscriptions.add(UserSubscription.fromJson(updatedResponse));
            debugPrint('Updated subscription ${subscription.id} status to: $expectedStatus');
          } else {
            syncedSubscriptions.add(subscription);
          }
        } catch (e) {
          debugPrint('Failed to sync subscription: $e');
          // Continue with other subscriptions
        }
      }

      debugPrint('=== ALL APPLE SUBSCRIPTIONS SYNCED ===');
      return syncedSubscriptions;
    } catch (e) {
      debugPrint('=== APPLE SUBSCRIPTIONS SYNC FAILED ===');
      debugPrint('Error: $e');
      throw Exception('Failed to sync Apple subscriptions: $e');
    }
  }

  // Cancel a subscription
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from('user_subscriptions')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toUtc().toIso8601String()
          })
          .eq('id', subscriptionId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // Get Paystack public key
  String getPaystackPublicKey() {
    return _paystackPublicKey;
  }

  // Check if user has already applied a referral code
  Future<bool> hasAppliedReferralCode() async {
    try {
      final userId = _userId;
      if (userId == null) {
        return false;
      }
      
      final response = await _client
          .from('referral_history')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Apply referral code (delegate to referral service)
  Future<void> applyReferralCode(String code) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if user has already applied a referral code
      final hasApplied = await hasAppliedReferralCode();
      if (hasApplied) {
        throw Exception('You have already used a referral code');
      }

      // Find the referral code
      final referral = await _client
          .from('referrals')
          .select()
          .eq('referral_code', code)
          .maybeSingle();

      if (referral == null) {
        throw Exception('Invalid referral code');
      }

      final referrerId = referral['user_id'];

      // Check if user is trying to use their own code
      if (referrerId == userId) {
        throw Exception('You cannot use your own referral code');
      }

      // Record the referral - Note: Points will be awarded when user subscribes
      await _client.from('referral_history').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'referrer_id': referrerId,
        'points_earned': 0, // Points will be awarded when user subscribes
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      // Increment referral count for the referrer
      await _client
          .from('referrals')
          .update({
            'referral_count': referral['referral_count'] + 1,
            'updated_at': DateTime.now().toUtc().toIso8601String()
          })
          .eq('user_id', referrerId);
    } catch (e) {
      throw Exception('Failed to apply referral code: $e');
    }
  }

  // Apple product ID -> internal plan ID mapping (must match App Store Connect config)
  static const Map<String, String> _appleProductToPlanId = {
    '3SUB': 'quarterly_plan',
    '1month': 'monthly_plan',
    '7day': 'weekly_plan',
    '365day': 'annual_plan',
  };


  /// S2: verify-apple-receipt now performs the DB write itself (service
  /// role), deriving plan/tier from the product_id Apple's own receipt
  /// confirms - not from anything supplied here. This method just calls it
  /// and returns the row it wrote; the client can no longer insert a
  /// subscription of its own choosing after a merely-valid receipt. Throws
  /// on any failure - callers must not complete the StoreKit transaction
  /// until this succeeds, so StoreKit redelivers the transaction on next
  /// launch instead of losing it.
  Future<UserSubscription> verifyAndActivateAppleSubscription({
    required String productId,
    String? transactionId,
    required String receiptData,
    DateTime? transactionDate,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final planId = _appleProductToPlanId[productId];

    debugPrint('SubscriptionService: Verifying Apple receipt (transaction: ${transactionId ?? "latest"})...');
    final response = await _client.functions.invoke(
      'verify-apple-receipt',
      body: {
        'userId': userId,
        'planId': planId,
        if (transactionId != null) 'transactionId': transactionId,
        'receiptData': receiptData,
      },
    );

    final data = response.data;
    if (data is! Map || data['valid'] != true || data['subscription'] == null) {
      throw Exception('Apple receipt verification failed: ${data is Map ? data['error'] : response.data}');
    }

    debugPrint('SubscriptionService: Verified and activated subscription for product: $productId');
    return UserSubscription.fromJson(Map<String, dynamic>.from(data['subscription']));
  }
}
