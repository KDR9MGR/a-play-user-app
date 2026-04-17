import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/services/iap_service.dart';
import '../service/iap_verification_service.dart';

/// Brand new, clean subscription screen
class SubscriptionScreenNew extends ConsumerStatefulWidget {
  const SubscriptionScreenNew({super.key});

  @override
  ConsumerState<SubscriptionScreenNew> createState() => _SubscriptionScreenNewState();
}

class _SubscriptionScreenNewState extends ConsumerState<SubscriptionScreenNew> {
  final _iapService = IAPService.instance;
  final _verificationService = IAPVerificationService();

  bool _isLoading = true;
  bool _isPurchasing = false;
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

    // Set up IAP callbacks
    _iapService.onPurchaseSuccess = _handlePurchaseSuccess;
    _iapService.onPurchaseError = _handlePurchaseError;
    _iapService.onPurchaseCancelled = _handlePurchaseCancelled;

    // Initialize IAP
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
      // Verify with backend
      await _verificationService.verifyAndActivateSubscription(
        productId: product.id,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe to Premium'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
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
                  color: Colors.red.withOpacity(0.1),
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
                  color: Colors.green.withOpacity(0.1),
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
