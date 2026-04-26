import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/iap_service.dart';
import '../service/iap_verification_service.dart';
import '../service/subscription_sync_service.dart';

/// Brand new, clean subscription screen
class SubscriptionScreenNew extends ConsumerStatefulWidget {
  const SubscriptionScreenNew({super.key});

  @override
  ConsumerState<SubscriptionScreenNew> createState() => _SubscriptionScreenNewState();
}

class _SubscriptionScreenNewState extends ConsumerState<SubscriptionScreenNew> {
  final _iapService = IAPService.instance;
  final _verificationService = IAPVerificationService();
  final _syncService = SubscriptionSyncService();

  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _hasActiveSubscription = false;
  Map<String, dynamic>? _activeSubscription;
  List<ProductDetails> _products = [];
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    debugPrint('SubscriptionScreen: Initializing...');

    // DEBUG: Check current user
    final currentUser = Supabase.instance.client.auth.currentUser;
    debugPrint('SubscriptionScreen: Current User ID = ${currentUser?.id}');
    debugPrint('SubscriptionScreen: Current User Email = ${currentUser?.email}');

    // CRITICAL: Sync database with StoreKit state FIRST
    // This detects cancellations and restores
    debugPrint('SubscriptionScreen: Syncing with StoreKit...');
    await _iapService.syncDatabaseWithStoreKit();

    // STEP 1: Check for existing subscription AFTER sync
    debugPrint('SubscriptionScreen: Checking for existing subscriptions...');
    final hasActive = await _syncService.hasActiveSubscription();
    final activeSub = await _syncService.getActiveSubscription();

    debugPrint('SubscriptionScreen: hasActive = $hasActive');
    debugPrint('SubscriptionScreen: activeSub = $activeSub');

    if (hasActive) {
      debugPrint('SubscriptionScreen: ✓ User already has active subscription - SHOWING MANAGEMENT VIEW');
      setState(() {
        _hasActiveSubscription = true;
        _activeSubscription = activeSub;
        _isLoading = false;
      });
      return; // Don't load products if already subscribed
    }

    debugPrint('SubscriptionScreen: No active subscription found, loading products...');

    // STEP 2: Set up IAP callbacks
    _iapService.onPurchaseSuccess = _handlePurchaseSuccess;
    _iapService.onPurchaseError = _handlePurchaseError;
    _iapService.onPurchaseCancelled = _handlePurchaseCancelled;

    // STEP 3: Initialize IAP
    await _iapService.initialize();

    setState(() {
      _products = _iapService.products;
      _isLoading = false;
    });

    debugPrint('SubscriptionScreen: Found ${_products.length} products');
  }

  void _handlePurchaseSuccess(ProductDetails product) async {
    debugPrint('SubscriptionScreen: Purchase successful: ${product.id}');

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
      _successMessage = 'Verifying purchase...';
    });

    try {
      // Verify with backend - pass amount from StoreKit
      await _verificationService.verifyAndActivateSubscription(
        productId: product.id,
        amount: product.rawPrice, // Pass actual price from StoreKit
      );

      if (mounted) {
        setState(() {
          _isPurchasing = false;
          _successMessage = 'Subscription activated successfully!';
        });

        // Show success dialog
        _showSuccessDialog();
      }
    } catch (e) {
      debugPrint('SubscriptionScreen: Verification failed: $e');

      if (mounted) {
        setState(() {
          _isPurchasing = false;
          _errorMessage = 'Purchase successful but verification failed. Please contact support.';
          _successMessage = null;
        });
      }
    }
  }

  void _handlePurchaseError(String error) {
    debugPrint('SubscriptionScreen: Purchase error: $error');

    if (mounted) {
      setState(() {
        _isPurchasing = false;
        _errorMessage = error;
        _successMessage = null;
      });
    }
  }

  void _handlePurchaseCancelled() {
    debugPrint('SubscriptionScreen: Purchase cancelled');

    if (mounted) {
      setState(() {
        _isPurchasing = false;
        _errorMessage = null;
        _successMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase cancelled')),
      );
    }
  }

  Future<void> _purchaseProduct(ProductDetails product) async {
    debugPrint('SubscriptionScreen: Purchasing ${product.id}');

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await _iapService.purchaseSubscription(product.id);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: const Text('Your subscription has been activated successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close subscription screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSubscriptionManagement() async {
    // iOS Settings URL for managing subscriptions
    final uri = Uri.parse('https://apps.apple.com/account/subscriptions');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open subscription management. Please go to iOS Settings > Your Name > Subscriptions.'),
          ),
        );
      }
    }
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You\'ll still have access to premium features until the end of your current billing period.\n\n'
          'To cancel, you need to manage your subscription in iOS Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openSubscriptionManagement();
            },
            child: const Text('Manage in Settings'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeOptions() {
    final currentTier = _activeSubscription?['subscription_tier'] ?? 'Gold';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade/Change Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Plan: $currentTier Tier'),
            const SizedBox(height: 16),
            const Text(
              'To change or upgrade your subscription, you need to manage it through iOS Settings.\n\n'
              'Steps:\n'
              '1. Go to iOS Settings\n'
              '2. Tap your name at the top\n'
              '3. Tap Subscriptions\n'
              '4. Select this app\n'
              '5. Choose a different plan',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openSubscriptionManagement();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadySubscribedView() {
    final tier = _activeSubscription?['subscription_tier'] ?? 'Premium';
    final planId = _activeSubscription?['plan_id'] ?? '';
    final expiresAtStr = _activeSubscription?['subscription_expires_at'] as String?;

    DateTime? expiresAt;
    int? daysRemaining;

    if (expiresAtStr != null) {
      expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt != null) {
        daysRemaining = expiresAt.difference(DateTime.now()).inDays;
      }
    }

    Color tierColor;
    IconData tierIcon;

    switch (tier) {
      case 'Black':
        tierColor = Colors.black;
        tierIcon = Icons.workspace_premium;
        break;
      case 'Platinum':
        tierColor = const Color(0xFFE5E4E2);
        tierIcon = Icons.diamond;
        break;
      case 'Gold':
        tierColor = const Color(0xFFFFD700);
        tierIcon = Icons.star;
        break;
      default:
        tierColor = Colors.blue;
        tierIcon = Icons.check_circle;
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Tier Icon
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tierIcon,
              size: 60,
              color: tierColor,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Title
        const Text(
          'Active Subscription',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Tier Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: tierColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '$tier Tier',
              style: TextStyle(
                color: tier == 'Platinum' ? Colors.black : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Subscription Details Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscription Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Plan Type
                _buildDetailRow(
                  Icons.card_membership,
                  'Plan',
                  _getPlanName(planId),
                ),
                const Divider(height: 24),

                // Days Remaining
                if (daysRemaining != null) ...[
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Time Remaining',
                    daysRemaining > 0
                        ? '$daysRemaining days'
                        : 'Expires today',
                  ),
                  const Divider(height: 24),
                ],

                // Renewal Date
                if (expiresAt != null) ...[
                  _buildDetailRow(
                    Icons.event_repeat,
                    'Renews On',
                    '${expiresAt.day}/${expiresAt.month}/${expiresAt.year}',
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Management Actions
        const Text(
          'Manage Subscription',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Upgrade/Change Plan Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showUpgradeOptions,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.blue),
            ),
            icon: const Icon(Icons.upgrade),
            label: const Text(
              'Change Plan',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Manage in Settings Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openSubscriptionManagement,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.settings),
            label: const Text(
              'Manage in iOS Settings',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Cancel Subscription Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showCancelConfirmation,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
            ),
            icon: const Icon(Icons.cancel),
            label: const Text(
              'Cancel Subscription',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Info Message
        Card(
          color: Colors.blue.withValues(alpha: 0.1),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your subscription is managed through the App Store. Changes made in iOS Settings will be reflected here.',
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Back Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Go Back',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _getPlanName(String planId) {
    switch (planId) {
      case '7day':
        return 'Weekly Plan';
      case '1month':
        return 'Monthly Plan';
      case '3SUB':
        return 'Quarterly Plan';
      case '365day':
        return 'Annual Plan';
      default:
        return 'Premium Plan';
    }
  }

  Future<void> _refreshSubscriptionStatus() async {
    setState(() => _isLoading = true);

    debugPrint('SubscriptionScreen: Manual refresh triggered');
    await _iapService.syncDatabaseWithStoreKit();

    final hasActive = await _syncService.hasActiveSubscription();
    final activeSub = await _syncService.getActiveSubscription();

    setState(() {
      _hasActiveSubscription = hasActive;
      _activeSubscription = activeSub;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hasActive
            ? 'Subscription status refreshed'
            : 'No active subscription found'),
          backgroundColor: hasActive ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe to Premium'),
        centerTitle: true,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshSubscriptionStatus,
            tooltip: 'Refresh subscription status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    // PRIORITY 1: If user already has active subscription, show that
    debugPrint('SubscriptionScreen: _buildBody() - _hasActiveSubscription = $_hasActiveSubscription');
    if (_hasActiveSubscription) {
      debugPrint('SubscriptionScreen: Rendering ALREADY SUBSCRIBED view with management buttons');
      return _buildAlreadySubscribedView();
    }

    // PRIORITY 2: If no products available
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No subscription plans available',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'This is normal in simulator.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Get access to premium features',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Success message
            if (_successMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Product list
            ..._products.map((product) => _buildProductCard(product)),

            const SizedBox(height: 24),

            // Terms
            const Text(
              'Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        // Loading overlay
        if (_isPurchasing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Processing purchase...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(ProductDetails product) {
    final isPopular = product.id == '1month';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Card(
            elevation: isPopular ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isPopular
                  ? const BorderSide(color: Colors.blue, width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: _isPurchasing ? null : () => _purchaseProduct(product),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.title.split('(').first.trim(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 16),

                    // Price
                    Row(
                      children: [
                        Text(
                          product.price,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPeriodText(product.id),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subscribe button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPurchasing ? null : () => _purchaseProduct(product),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: isPopular ? Colors.blue : null,
                        ),
                        child: const Text(
                          'Subscribe Now',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Popular badge
          if (isPopular)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getPeriodText(String productId) {
    switch (productId) {
      case '7day':
        return '/ week';
      case '1month':
        return '/ month';
      case '3SUB':
        return '/ 3 months';
      case '365day':
        return '/ year';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    // Clear callbacks
    _iapService.onPurchaseSuccess = null;
    _iapService.onPurchaseError = null;
    _iapService.onPurchaseCancelled = null;
    super.dispose();
  }
}
