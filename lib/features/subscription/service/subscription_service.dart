import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../model/subscription_model.dart';
import '../../../core/config/paystack_config.dart';
import '../../../core/services/purchase_manager.dart';
import 'apple_iap_service.dart';

class SubscriptionService {
  late final SupabaseClient _client;
  final String _paystackSecretKey = PaystackConfig.secretKey;
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

      // Initialize payment with Paystack
      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $_paystackSecretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
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
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'status': true,
          'reference': reference,
          'authorization_url': responseData['data']['authorization_url'],
          'access_code': responseData['data']['access_code'],
        };
      } else {
        throw Exception(
            'Failed to initialize payment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to initialize payment: $e');
    }
  }

  // Verify PayStack payment
  Future<PaystackVerification> verifyPaystackPayment(String reference) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {
          'Authorization': 'Bearer $_paystackSecretKey',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      
      return PaystackVerification.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  // Start free trial subscription
  Future<UserSubscription> startFreeTrial() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user is eligible for trial
      final isEligible = await isEligibleForTrial();
      if (!isEligible) {
        throw Exception('User is not eligible for free trial');
      }

      // Calculate trial dates
      final startDate = DateTime.now().toUtc();
      final endDate = startDate.add(const Duration(days: 3));

      // Create trial subscription
      final subscriptionId = const Uuid().v4();
      
      // First, expire any active subscriptions
      await _client
          .from('user_subscriptions')
          .update({'status': 'expired', 'updated_at': DateTime.now().toUtc().toIso8601String()})
          .eq('user_id', userId)
          .eq('status', 'active');

      // Create the trial subscription
      final response = await _client.from('user_subscriptions').insert({
        'id': subscriptionId,
        'user_id': userId,
        'subscription_type': '3-Day Free Trial',
        'plan_type': 'trial',
        'amount': 0.0,
        'currency': 'GHS',
        'status': 'active',
        'payment_reference': 'TRIAL_${DateTime.now().millisecondsSinceEpoch}',
        'payment_method': 'trial',
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_auto_renew': false,
        'tier_points_earned': 25,
        'features_unlocked': ['premium_content', 'hd_streaming', 'offline_download', 'ad_free'],
      }).select().single();

      return UserSubscription.fromJson(response);
    } catch (e) {
      throw Exception('Failed to start free trial: $e');
    }
  }

  // Create a new subscription after successful payment
  Future<UserSubscription> createSubscription(
      String planId, String paymentReference) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get the plan details
      final planResponse = await _client
          .from('subscription_plans')
          .select()
          .eq('id', planId)
          .single();

      final plan = SubscriptionPlan.fromJson(planResponse);
      final price =
          plan.price ?? plan.priceMonthly ?? plan.priceYearly ?? 0.0;
      final durationDays = plan.durationDays ?? 30;
      final startDate = DateTime.now().toUtc();
      final endDate = startDate.add(Duration(days: durationDays));
      final billingCycle =
          plan.priceMonthly != null || plan.priceYearly == null ? 'monthly' : 'annual';
      final tier =
          (plan.features != null ? plan.features!['tier'] as String? : null) ??
              plan.name;

      // Create a new subscription
      final subscriptionId = const Uuid().v4();
      
      // First, expire any active subscriptions
      await _client
          .from('user_subscriptions')
          .update({'status': 'expired', 'updated_at': DateTime.now().toUtc().toIso8601String()})
          .eq('user_id', userId)
          .eq('status', 'active');

      // Create the new subscription
      final response = await _client.from('user_subscriptions').insert({
        'id': subscriptionId,
        'user_id': userId,
        'plan_id': plan.id,
        'tier': tier,
        'billing_cycle': billingCycle,
        'subscription_type': plan.name,
        'amount': price,
        'currency': plan.currency,
        'status': 'active',
        'payment_reference': paymentReference,
        'payment_method': 'paystack',
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_auto_renew': false,
      }).select().single();

      // Record the payment
      await _client.from('subscription_payments').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'subscription_id': subscriptionId,
        'amount': price,
        'currency': plan.currency,
        'payment_reference': paymentReference,
        'payment_method': 'paystack',
        'payment_status': 'success',
        'payment_date': DateTime.now().toUtc().toIso8601String(),
        'metadata': {
          'plan_id': planId,
          'plan_name': plan.name,
          'duration_days': durationDays,
        },
      });

      // Notify referral system if available
      try {
        final referralService = await _client.functions.invoke(
          'trigger-referral-award',
          body: {'userId': userId, 'subscriptionId': subscriptionId},
        );
      } catch (_) {
        // Ignore if referral service is not available
      }

      return UserSubscription.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  // Create subscription for Apple IAP after server-side receipt verification
  Future<UserSubscription> createSubscriptionForApple(
      String planId, String transactionId, String receiptData) async {
    try {
      debugPrint('=== APPLE IAP SUBSCRIPTION CREATION ===');
      debugPrint('Plan ID: $planId');
      debugPrint('Transaction ID: $transactionId');
      debugPrint('Receipt Data Length: ${receiptData.length}');
      
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      debugPrint('User ID: $userId');

      // Verify receipt via Supabase Edge Function (backend should validate with Apple)
      bool verified = false;
      Map<String, dynamic>? receiptInfo;
      
      try {
        debugPrint('Calling verify-apple-receipt function...');
        final response = await _client.functions.invoke(
          'verify-apple-receipt',
          body: {
            'userId': userId,
            'planId': planId,
            'transactionId': transactionId,
            'receiptData': receiptData,
          },
        );
        
        debugPrint('Receipt verification response: ${response.data}');
        final data = response.data;
        
        if (data is Map && data['valid'] == true) {
          verified = true;
          receiptInfo = Map<String, dynamic>.from(data);
          debugPrint('Receipt verification successful');
        } else {
          debugPrint('Receipt verification failed - invalid response: $data');
          throw Exception('Invalid receipt response: $data');
        }
      } catch (e) {
        debugPrint('Receipt verification error: $e');
        throw Exception('Receipt verification failed: $e');
      }

      if (!verified) {
        throw Exception('Apple receipt is not valid');
      }

      debugPrint('Getting plan details for: $planId');
      // Get plan details
      final planResponse = await _client
          .from('subscription_plans')
          .select()
          .eq('id', planId)
          .single();

      final plan = SubscriptionPlan.fromJson(planResponse);
      final price =
          plan.price ?? plan.priceMonthly ?? plan.priceYearly ?? 0.0;
      final durationDays = plan.durationDays ?? 30;
      debugPrint('Plan found: ${plan.name}, Duration: $durationDays days');

      final startDate = DateTime.now().toUtc();
      final endDate = startDate.add(Duration(days: durationDays));
      debugPrint('Subscription period: $startDate to $endDate');

      debugPrint('Expiring existing active subscriptions...');
      // Expire any active subscriptions
      await _client
          .from('user_subscriptions')
          .update({
            'status': 'expired',
            'updated_at': DateTime.now().toUtc().toIso8601String()
          })
          .eq('user_id', userId)
          .eq('status', 'active');

      // Create the subscription
      final subscriptionId = const Uuid().v4();
      debugPrint('Creating new subscription with ID: $subscriptionId');
      
      final response = await _client.from('user_subscriptions').insert({
        'id': subscriptionId,
        'user_id': userId,
        'plan_id': plan.id,
        'subscription_type': plan.name,
        'amount': price,
        'currency': plan.currency,
        'status': 'active',
        'payment_reference': transactionId,
        'payment_method': 'apple_iap',
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_auto_renew': true,
      }).select().single();

      debugPrint('Subscription created successfully');

      // Record the payment with enhanced metadata
      debugPrint('Recording payment...');
      await _client.from('subscription_payments').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'subscription_id': subscriptionId,
        'amount': price,
        'currency': plan.currency,
        'payment_reference': transactionId,
        'payment_method': 'apple_iap',
        'payment_status': 'success',
        'payment_date': DateTime.now().toUtc().toIso8601String(),
        'metadata': {
          'plan_id': planId,
          'plan_name': plan.name,
          'duration_days': durationDays,
          'verified': true,
          'source': 'app_store',
          'receipt_info': receiptInfo,
          'original_transaction_id': receiptInfo?['originalTransactionId'],
          'product_id': receiptInfo?['productId'],
          'subscription_status': receiptInfo?['subscriptionStatus'],
          'auto_renew_status': receiptInfo?['autoRenewStatus'],
          'environment': receiptInfo?['environment'],
        },
      });

      debugPrint('Payment recorded successfully');

      // Update subscription with receipt data if available
      if (receiptInfo != null) {
        try {
          await updateSubscriptionWithReceiptData(subscriptionId, receiptInfo);
          debugPrint('Subscription updated with receipt validation data');
        } catch (e) {
          debugPrint('Failed to update subscription with receipt data (non-critical): $e');
        }
      }

      // Optional: notify referral system
      try {
        debugPrint('Triggering referral award...');
        await _client.functions.invoke(
          'trigger-referral-award',
          body: {'userId': userId, 'subscriptionId': subscriptionId},
        );
        debugPrint('Referral award triggered');
      } catch (e) {
        debugPrint('Referral award failed (non-critical): $e');
      }

      debugPrint('=== APPLE IAP SUBSCRIPTION CREATION COMPLETE ===');
      return UserSubscription.fromJson(response);
    } catch (e) {
      debugPrint('=== APPLE IAP SUBSCRIPTION CREATION FAILED ===');
      debugPrint('Error: $e');
      throw Exception('Failed to create Apple IAP subscription: $e');
    }
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
          .or('payment_reference.eq.$originalTransactionId,metadata->>original_transaction_id.eq.$originalTransactionId');

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

      // Extract relevant data from receipt
      final isExpired = receiptData['isExpired'] as bool? ?? false;
      final subscriptionStatus = receiptData['subscriptionStatus'] as String? ?? 'active';
      final autoRenewStatus = receiptData['autoRenewStatus'] as bool? ?? false;
      final expiresDateMs = receiptData['expiresDateMs'] as String?;
      
      String dbStatus = 'active';
      if (isExpired) {
        dbStatus = subscriptionStatus == 'cancelled' ? 'cancelled' : 'expired';
      }

      final updateData = <String, dynamic>{
        'status': dbStatus,
        'is_auto_renew': autoRenewStatus,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Update end date if provided
      if (expiresDateMs != null) {
        final expiresDate = DateTime.fromMillisecondsSinceEpoch(
          int.parse(expiresDateMs),
          isUtc: true,
        );
        updateData['end_date'] = expiresDate.toIso8601String();
      }

      // Update metadata with receipt information
      final currentSubscription = await _client
          .from('user_subscriptions')
          .select('metadata')
          .eq('id', subscriptionId)
          .single();

      final currentMetadata = currentSubscription['metadata'] as Map<String, dynamic>? ?? {};
      currentMetadata['last_receipt_validation'] = receiptData;
      currentMetadata['last_sync'] = DateTime.now().toUtc().toIso8601String();
      updateData['metadata'] = currentMetadata;

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

  // Get Paystack secret key
  String getPaystackSecretKey() {
    return _paystackSecretKey;
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

  /// Handle restored Apple IAP purchases
  Future<List<UserSubscription>> handleRestoredPurchases(List<RestoredPurchase> restoredPurchases) async {
    debugPrint('SubscriptionService: Processing ${restoredPurchases.length} restored purchases');
    
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final processedSubscriptions = <UserSubscription>[];
    
    for (final restoredPurchase in restoredPurchases) {
      try {
        debugPrint('Processing restored purchase: ${restoredPurchase.productId}');
        
        // Convert Apple product ID to plan ID
        final planId = AppleIAPService.getPlanIdFromProductId(restoredPurchase.productId);
        if (planId == null) {
          debugPrint('Unknown product ID: ${restoredPurchase.productId}');
          continue;
        }

        // Check if this subscription already exists
        final existingSubscription = await _client
            .from('user_subscriptions')
            .select()
            .eq('user_id', userId)
            .eq('payment_reference', restoredPurchase.transactionId)
            .maybeSingle();

        if (existingSubscription != null) {
          debugPrint('Subscription already exists for transaction: ${restoredPurchase.transactionId}');
          
          // Update the existing subscription status if needed
          final subscription = UserSubscription.fromJson(existingSubscription);
          final now = DateTime.now().toUtc();
          
          if (subscription.endDate.isAfter(now) && subscription.status != 'active') {
            await _client
                .from('user_subscriptions')
                .update({
                  'status': 'active',
                  'updated_at': now.toIso8601String(),
                })
                .eq('id', subscription.id);
            
            processedSubscriptions.add(subscription.copyWith(status: 'active'));
          } else {
            processedSubscriptions.add(subscription);
          }
          continue;
        }

        // Validate the receipt with backend
        debugPrint('Validating restored purchase receipt...');
        bool verified = false;
        Map<String, dynamic>? receiptInfo;
        
        try {
          debugPrint('Calling verify-apple-receipt function...');
          final response = await _client.functions.invoke(
            'verify-apple-receipt',
            body: {
              'userId': userId,
              'planId': planId,
              'transactionId': restoredPurchase.transactionId,
              'receiptData': restoredPurchase.receiptData,
            },
          );
          
          debugPrint('Receipt verification response: ${response.data}');
          final data = response.data;
          
          if (data is Map && data['valid'] == true) {
            verified = true;
            receiptInfo = Map<String, dynamic>.from(data);
            debugPrint('Receipt verification successful');
          } else {
            debugPrint('Receipt verification failed - invalid response: $data');
            continue;
          }
        } catch (e) {
          debugPrint('Receipt verification error: $e');
          continue;
        }

        if (!verified || receiptInfo == null) {
          debugPrint('Invalid receipt for restored purchase: ${restoredPurchase.transactionId}');
          continue;
        }

        // Get plan details
        final plan = SubscriptionPlan.defaultPlans.firstWhere(
          (p) => p.id == planId,
          orElse: () => SubscriptionPlan.defaultPlans.first,
        );

        // Calculate subscription end date from receipt
        final subscriptionEndDate = receiptInfo['expires_date'] != null
            ? DateTime.parse(receiptInfo['expires_date'])
            : DateTime.now()
                .toUtc()
                .add(Duration(days: plan.durationDays ?? 30));

        final now = DateTime.now().toUtc();
        final status = subscriptionEndDate.isAfter(now) ? 'active' : 'expired';

        // Expire existing active subscriptions
        debugPrint('Expiring existing active subscriptions...');
        await _client
            .from('user_subscriptions')
            .update({
              'status': 'expired',
              'updated_at': now.toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('status', 'active');

        // Create new subscription entry
        final subscriptionData = {
          'user_id': userId,
          'plan_name': plan.name,
          'plan_price': plan.price ?? 0.0,
          'plan_duration_days': plan.durationDays ?? 30,
          'start_date': restoredPurchase.transactionDate?.toUtc().toIso8601String() ?? now.toIso8601String(),
          'end_date': subscriptionEndDate.toIso8601String(),
          'status': status,
          'payment_method': 'apple_iap',
          'payment_reference': restoredPurchase.transactionId,
          'is_auto_renew': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final subscriptionResponse = await _client
            .from('user_subscriptions')
            .insert(subscriptionData)
            .select()
            .single();

        final newSubscription = UserSubscription.fromJson(subscriptionResponse);
        processedSubscriptions.add(newSubscription);

        // Record the payment
        debugPrint('Recording payment...');
        await _client.from('subscription_payments').insert({
          'id': const Uuid().v4(),
          'user_id': userId,
          'subscription_id': newSubscription.id,
          'amount': plan.price,
          'currency': 'USD',
          'payment_reference': restoredPurchase.transactionId,
          'payment_method': 'apple_iap',
          'payment_status': 'success',
          'payment_date': DateTime.now().toUtc().toIso8601String(),
          'metadata': {
            'restored_purchase': true,
            'original_transaction_id': restoredPurchase.transactionId,
            'product_id': restoredPurchase.productId,
            'transaction_date': restoredPurchase.transactionDate?.toIso8601String(),
            'plan_id': planId,
            'plan_name': plan.name,
            'duration_days': plan.durationDays,
            'verified': true,
            'source': 'app_store',
            'receipt_info': receiptInfo,
          },
        });

        debugPrint('Successfully processed restored purchase: ${restoredPurchase.transactionId}');
        
      } catch (e) {
        debugPrint('Error processing restored purchase ${restoredPurchase.transactionId}: $e');
        // Continue with other purchases even if one fails
      }
    }

    debugPrint('Successfully processed ${processedSubscriptions.length} restored purchases');
    return processedSubscriptions;
  }
}
