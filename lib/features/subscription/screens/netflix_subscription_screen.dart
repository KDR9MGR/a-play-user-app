import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../model/subscription_model.dart';
import '../provider/subscription_provider.dart';

class NetflixSubscriptionScreen extends ConsumerStatefulWidget {
  const NetflixSubscriptionScreen({super.key});

  @override
  ConsumerState<NetflixSubscriptionScreen> createState() => _NetflixSubscriptionScreenState();
}

class _NetflixSubscriptionScreenState extends ConsumerState<NetflixSubscriptionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  SubscriptionPlan? _selectedPlan;
  int _currentPlanIndex = 1; // Default to Monthly (most popular)

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Set default selected plan
    _selectedPlan = SubscriptionPlan.defaultPlans[_currentPlanIndex];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFE50914), Color(0xFFFF6B6B)],
        ).createShader(bounds),
        child: const Text(
          'Premium Plans',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        // Hero Section
        SliverToBoxAdapter(
          child: _buildHeroSection(),
        ),
        
        // Tier Status
        SliverToBoxAdapter(
          child: _buildTierStatus(),
        ),
        
        // Subscription Plans
        SliverToBoxAdapter(
          child: _buildSubscriptionPlans(),
        ),
        
        // Features Comparison
        SliverToBoxAdapter(
          child: _buildFeaturesSection(),
        ),
        
        // Subscribe Button
        SliverToBoxAdapter(
          child: _buildSubscribeButton(),
        ),
        
        // Bottom Padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 300,
      margin: const EdgeInsets.only(top: 100),
      child: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Color(0xFFE50914),
                  Color(0xFF0F0F0F),
                ],
                stops: [0.0, 0.8],
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1 + _glowController.value * 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE50914).withOpacity(_glowController.value * 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 48,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Unlock Premium Experience',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Join thousands of users enjoying premium content and exclusive features',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 800));
  }

  Widget _buildTierStatus() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Tier: Gold',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '850 / 1000 points to Platinum',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress Bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: -1, duration: const Duration(milliseconds: 600));
  }

  Widget _buildSubscriptionPlans() {
    final plans = SubscriptionPlan.defaultPlans;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Choose Your Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        SizedBox(
          height: 380,
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentPlanIndex = index;
                _selectedPlan = plans[index];
              });
            },
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final isSelected = index == _currentPlanIndex;
              
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 32,
                  vertical: isSelected ? 0 : 20,
                ),
                child: _buildPlanCard(plan, isSelected),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isSelected
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE50914),
                Color(0xFFFF6B6B),
              ],
            )
          : null,
        color: isSelected ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected 
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
          ? [
              BoxShadow(
                color: const Color(0xFFE50914).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ]
          : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (plan.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          plan.description!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (plan.isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.price.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    plan.currency,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            // Duration
            Text(
              _getPlanDuration(plan.planType),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            
            // Discount
            if (plan.discountPercentage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  'Save ${plan.discountPercentage!.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Features
            Text(
              'Features:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            ...plan.features?.entries.take(3).map((feature) {
              if (feature.value == true) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatFeatureName(feature.key),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList() ?? [],
            
            const SizedBox(height: 16),
            
            // Tier Points
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.stars,
                    color: Color(0xFFFFD700),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${plan.tierPointsBonus} Tier Points',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPlanDuration(SubscriptionPlanType planType) {
    switch (planType) {
      case SubscriptionPlanType.trial:
        return 'Free Trial';
      case SubscriptionPlanType.weekly:
        return 'Per Week';
      case SubscriptionPlanType.monthly:
        return 'Per Month';
      case SubscriptionPlanType.quarterly:
        return 'Per 3 Months';
      case SubscriptionPlanType.biannual:
        return 'Per 6 Months';
      case SubscriptionPlanType.annual:
        return 'Per Year';
    }
  }

  String _formatFeatureName(String key) {
    return key.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Widget _buildFeaturesSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Go Premium?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...[
            'Unlimited access to premium content',
            'HD and 4K streaming quality',
            'Download content for offline viewing',
            'Ad-free experience',
            'Early access to new releases',
            'Exclusive creator content',
            'Priority customer support',
            'Tier system rewards and benefits',
          ].map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 600));
  }

  Widget _buildSubscribeButton() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Main Subscribe Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE50914), Color(0xFFFF6B6B)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE50914).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleSubscribe,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    'Subscribe to ${_selectedPlan?.name} - ${_selectedPlan?.price.toStringAsFixed(2)} ${_selectedPlan?.currency}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Legal links
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                'By subscribing, you agree to:',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Apple EULA'),
              ),
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse('https://www.aplayworld.com/terms-and-conditions'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Terms & Conditions'),
              ),
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse('https://www.aplayworld.com/privacy-policy'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Privacy Policy'),
              ),
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse('https://www.aplayworld.com/refund-policy'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Refund Policy'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Auto-renewing subscription. Cancel at least 24 hours before renewal in Settings.',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleSubscribe() {
    if (_selectedPlan == null) return;
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Subscription',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan: ${_selectedPlan!.name}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ${_selectedPlan!.price.toStringAsFixed(2)} ${_selectedPlan!.currency}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${_getPlanDuration(_selectedPlan!.planType)}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Tier Points: +${_selectedPlan!.tierPointsBonus}',
              style: const TextStyle(color: Color(0xFFFFD700)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processSubscription();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _processSubscription() {
    // Implement subscription processing
    // For now, just show success message - you can integrate with actual subscription service later
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscribed to ${_selectedPlan!.name} successfully!'),
        backgroundColor: const Color(0xFFE50914),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Navigate back or to success screen
    Navigator.of(context).pop();
  }
}