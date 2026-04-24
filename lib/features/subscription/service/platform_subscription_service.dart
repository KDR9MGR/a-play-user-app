import 'dart:io';
import 'package:flutter/foundation.dart';
import '../model/subscription_model.dart';
import 'apple_iap_service.dart';
import 'subscription_service.dart';
import '../../../core/services/purchase_manager.dart';

class PlatformSubscriptionService {
  static final PlatformSubscriptionService _instance = PlatformSubscriptionService._internal();
  factory PlatformSubscriptionService() => _instance;
  PlatformSubscriptionService._internal();

  AppleIAPService? _appleIAPService;
  SubscriptionService? _subscriptionService;

  // Initialize the appropriate service based on platform
  Future<void> initialize() async {
    debugPrint('=== PLATFORM SUBSCRIPTION SERVICE INIT ===');
    if (kIsWeb) {
      debugPrint('Initializing service for Web platform');
      _subscriptionService = SubscriptionService();
    } else {
      debugPrint('Platform.isIOS: ${Platform.isIOS}');
      
      if (Platform.isIOS) {
        debugPrint('Initializing Apple IAP Service...');
        _appleIAPService = AppleIAPService();
        debugPrint('Apple IAP Service initialized successfully');
      } else {
        debugPrint('Initializing Paystack service for non-iOS platform');
        _subscriptionService = SubscriptionService();
      }
    }
    debugPrint('=== PLATFORM SUBSCRIPTION SERVICE INIT COMPLETE ===');
  }

  // Check if the platform supports in-app purchases
  Future<bool> isInAppPurchaseAvailable() async {
    if (!kIsWeb && Platform.isIOS && _appleIAPService != null) {
      return await _appleIAPService!.isAvailable();
    }
    return false;
  }

  // Get available subscription plans for the current platform
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    if (!kIsWeb && Platform.isIOS && _appleIAPService != null) {
      try {
        final products = await _appleIAPService!.getProducts();
        
        // Convert Apple products to SubscriptionPlan objects
        return products.map((product) {
          final planId = AppleIAPService.getPlanIdFromProductId(product.id);
          final defaultPlan = SubscriptionPlan.defaultPlans
              .firstWhere((plan) => plan.id == planId, 
                         orElse: () => SubscriptionPlan.defaultPlans.first);
          
          return SubscriptionPlan(
            id: planId ?? product.id,
            name: product.title,
            description: product.description,
            durationDays: defaultPlan.durationDays,
            price: double.tryParse(product.price) ?? defaultPlan.price,
            currency: product.currencyCode,
            planType: defaultPlan.planType,
            features: defaultPlan.features,
            isActive: true,
            isPopular: defaultPlan.isPopular,
            discountPercentage: defaultPlan.discountPercentage,
            createdAt: DateTime.now(),
          );
        }).toList();
      } catch (e) {
        debugPrint('Error loading Apple IAP products: $e');
        return SubscriptionPlan.defaultPlans
            .where((plan) => AppleIAPService.getProductIdFromPlanId(plan.id) != null)
            .toList();
      }
    } else {
      // Return default plans for other platforms
      return SubscriptionPlan.defaultPlans;
    }
  }

  // Purchase a subscription
  Future<bool> purchaseSubscription(SubscriptionPlan plan) async {
    if (Platform.isIOS && _appleIAPService != null) {
      try {
        await _appleIAPService!.purchaseSubscription(plan.id);
        return true; // Success will be handled by the callback
      } catch (e) {
        debugPrint('Apple IAP Purchase Error: $e');
        return false;
      }
    } else {
      // For other platforms, return false to indicate Paystack should be used
      return false;
    }
  }

  // Restore purchases (iOS only) - Enhanced version
  Future<List<UserSubscription>> restorePurchases() async {
    debugPrint('=== RESTORE PURCHASES ===');
    
    if (!Platform.isIOS || _appleIAPService == null) {
      debugPrint('Restore purchases not supported on this platform');
      throw Exception('Restore purchases not supported on this platform');
    }

    try {
      _subscriptionService ??= SubscriptionService();

      debugPrint('Starting Apple IAP restore purchases...');
      
      // Set up callbacks to collect restored purchases
      final List<RestoredPurchase> restoredPurchases = [];
      bool restoreCompleted = false;
      String? restoreError;

      _appleIAPService!.onRestoreStarted = () {
        debugPrint('Restore purchases started');
      };

      _appleIAPService!.onPurchasesRestored = (purchases) {
        debugPrint('Received ${purchases.length} restored purchases');
        restoredPurchases.addAll(purchases);
      };

      _appleIAPService!.onRestoreCompleted = (String? error) {
          debugPrint('Restore purchases completed with error: $error');
          restoreCompleted = true;
          restoreError = error;
        } as dynamic Function()?;

      // Initiate restore
      await _appleIAPService!.restorePurchases();

      // Wait for restore to complete (with timeout)
      int attempts = 0;
      const maxAttempts = 30; // 15 seconds timeout
      while (!restoreCompleted && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }

      if (!restoreCompleted) {
        throw Exception('Restore purchases timed out');
      }

      if (restoreError != null) {
        throw Exception('Restore purchases failed: $restoreError');
      }

      debugPrint('Processing ${restoredPurchases.length} restored purchases...');
      
      // Process restored purchases through subscription service
      final processedSubscriptions = await _subscriptionService!.handleRestoredPurchases(restoredPurchases);
      
      debugPrint('Successfully restored ${processedSubscriptions.length} subscriptions');
      return processedSubscriptions;

    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      rethrow;
    } finally {
      // Clean up callbacks
      if (_appleIAPService != null) {
        _appleIAPService!.onRestoreStarted = null;
        _appleIAPService!.onPurchasesRestored = null;
        _appleIAPService!.onRestoreCompleted = null;
      }
    }
  }

  // Handle successful purchase and create subscription record
  Future<void> handleSuccessfulPurchase(String planId, String transactionId, String paymentMethod, [String? receiptData]) async {
    try {
      debugPrint('Handling successful purchase: $planId, $transactionId, $paymentMethod');
      
      // Use existing subscription service to create the subscription
      _subscriptionService ??= SubscriptionService();
      
      // Create subscription for Apple IAP with backend verification when available
      if (paymentMethod == 'apple_iap' && receiptData != null && receiptData.isNotEmpty) {
        debugPrint('Creating Apple IAP subscription with receipt verification...');
        await _subscriptionService!.createSubscriptionForApple(planId, transactionId, receiptData);
        debugPrint('Subscription created successfully via Apple IAP for plan: $planId');
        
        // Sync subscription status after creation
        try {
          await _subscriptionService!.syncAppleSubscriptionStatus(transactionId);
          debugPrint('Apple subscription status synchronized for transaction: $transactionId');
        } catch (e) {
          debugPrint('Warning: Failed to sync Apple subscription status: $e');
          // Don't throw here as the subscription was created successfully
        }
      } else {
        debugPrint('Subscription purchase handled without Apple receipt data.');
        throw Exception('Missing receipt data for Apple IAP purchase');
      }
    } catch (e) {
      debugPrint('Error creating subscription record: $e');
      rethrow; // Propagate error to UI
    }
  }

  // Handle successful purchase and create subscription record
  Future<void> _handleSuccessfulPurchase(String planId, String transactionId, String paymentMethod, [String? receiptData]) async {
    try {
      // Create subscription payment record
      final payment = SubscriptionPayment(
        id: transactionId,
        userId: 'current_user_id', // This should be passed from the calling context
        subscriptionId: 'subscription_$transactionId',
        amount: 0.0, // Will be filled from plan details
        currency: 'USD', // Default, will be updated
        paymentReference: transactionId,
        paymentMethod: paymentMethod,
        paymentStatus: 'completed',
        paymentDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Use existing subscription service to create the subscription
      _subscriptionService ??= SubscriptionService();
      
      // Create subscription for Apple IAP with backend verification when available
      if (paymentMethod == 'apple_iap' && receiptData != null && receiptData.isNotEmpty) {
        _subscriptionService ??= SubscriptionService();
        await _subscriptionService!.createSubscriptionForApple(planId, transactionId, receiptData);
        debugPrint('Subscription created via Apple IAP for plan: $planId');
      } else {
        debugPrint('Subscription purchase handled without Apple receipt data.');
      }
    } catch (e) {
      debugPrint('Error creating subscription record: $e');
    }
  }

  // Check if current platform should use native IAP
  bool shouldUseNativeIAP() {
    return Platform.isIOS;
  }

  // Sync all Apple subscriptions for the current user
  Future<void> syncAllAppleSubscriptions() async {
    if (!Platform.isIOS) {
      debugPrint('Skipping Apple subscription sync - not on iOS platform');
      return;
    }

    try {
      _subscriptionService ??= SubscriptionService();
      
      debugPrint('Starting sync of all Apple subscriptions...');
      await _subscriptionService!.syncAllAppleSubscriptions();
      debugPrint('Successfully synced all Apple subscriptions');
    } catch (e) {
      debugPrint('Error syncing Apple subscriptions: $e');
      rethrow;
    }
  }

  // Sync specific Apple subscription by transaction ID
  Future<void> syncAppleSubscription(String transactionId) async {
    if (!Platform.isIOS) {
      debugPrint('Skipping Apple subscription sync - not on iOS platform');
      return;
    }

    try {
      _subscriptionService ??= SubscriptionService();
      
      debugPrint('Syncing Apple subscription for transaction: $transactionId');
      await _subscriptionService!.syncAppleSubscriptionStatus(transactionId);
      debugPrint('Successfully synced Apple subscription: $transactionId');
    } catch (e) {
      debugPrint('Error syncing Apple subscription $transactionId: $e');
      rethrow;
    }
  }

  // Get Apple IAP service (for setting callbacks)
  AppleIAPService? get appleIAPService => _appleIAPService;

  // Dispose resources
  void dispose() {
    _appleIAPService?.dispose();
  }
}
