import 'package:a_play/core/theme/app_theme.dart';
import 'package:a_play/features/concierge/screens/service_detail_page.dart';
import 'package:a_play/features/widgets/squircle_container.dart';
import 'package:a_play/features/subscription/utils/subscription_utils.dart';
import 'package:a_play/features/subscription/provider/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class ConciergePage extends ConsumerStatefulWidget {
  const ConciergePage({super.key});

  @override
  ConsumerState<ConciergePage> createState() => _ConciergePageState();
}

class _ConciergePageState extends ConsumerState<ConciergePage> {
  
  @override
  void initState() {
    super.initState();
    // Refresh premium status when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SubscriptionUtils.refreshPremiumStatus(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMiddle,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Premium Design
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.backgroundMiddle,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary, // AppTheme.backgroundStart
                      AppTheme.primary, // AppTheme.backgroundMiddle
                      AppTheme.primary, // AppTheme.backgroundStart
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 1.0,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 40,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Lottie.asset(
                                'assets/lotties/diamond.json',
                                width: 100,
                                height: 100,
                                repeat: true,
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'Premium\nConcierge',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your personal lifestyle assistant',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              title: null,
            ),
          ),

          // Stats & Welcome Message
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '24/7',
                          'Available',
                          'assets/lotties/support.json',
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '500+',
                          'Services',
                          'assets/lotties/hotel.json',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '98%',
                          'Satisfaction',
                          'assets/lotties/disc.json',
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Welcome Text
                  const Text(
                    'How can we assist you today?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose from our premium services below',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Service Categories Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.98,
              ),
              delegate: SliverChildListDelegate([
                _buildServiceCard(
                  context,
                  title: 'Travel',
                  lottieAsset: 'assets/lotties/travel.json',
                  description: 'Flights, transfers, and transport services',
                  color: Colors.blue,
                  services: [
                    const ServiceItem(
                      name: 'Flight Bookings',
                      icon: Iconsax.airplane,
                      description: 'Book and manage your flights',
                      features: [
                        'International & domestic flights',
                        'Flight changes & cancellations',
                        'Special assistance requests',
                        'Seat selection & upgrades',
                      ],
                    ),
                    const ServiceItem(
                      name: 'Airport Transfers',
                      icon: Iconsax.car,
                      description: 'Reliable airport pickup and drop-off',
                      features: [
                        'Professional chauffeurs',
                        'Flight tracking',
                        'Meet & greet service',
                        'Luxury vehicle options',
                      ],
                    ),
                    const ServiceItem(
                      name: 'Car Rentals',
                      icon: Iconsax.car,
                      description: 'Rent vehicles for your journey',
                      features: [
                        'Wide range of vehicles',
                        'Flexible rental periods',
                        'Insurance coverage',
                        'GPS navigation',
                      ],
                    ),
                    const ServiceItem(
                      name: 'Visa Assistance',
                      icon: Iconsax.document,
                      description: 'Help with visa applications',
                      features: [
                        'Document preparation',
                        'Application assistance',
                        'Status tracking',
                        'Express processing',
                      ],
                    ),
                  ],
                ),
                _buildServiceCard(
                  context,
                  title: 'Events',
                  lottieAsset: 'assets/lotties/disc.json',
                  description: 'Bookings, tickets, and reservations',
                  color: Colors.purple,
                  services: [
                    const ServiceItem(
                      name: 'EventModel Tickets',
                      icon: Iconsax.ticket,
                      description: 'Access to exclusive events',
                      features: [
                        'Concert tickets',
                        'Sports events',
                        'Theater shows',
                        'VIP packages',
                      ],
                    ),
                    const ServiceItem(
                      name: 'Restaurant Reservations',
                      icon: Iconsax.coffee,
                      description: 'Book tables at top restaurants',
                      features: [
                        'Fine dining establishments',
                        'Special occasion planning',
                        'Dietary accommodations',
                        'Private dining rooms',
                      ],
                    ),
                  ],
                ),
                _buildServiceCard(
                  context,
                  title: 'Personal',
                  lottieAsset: 'assets/lotties/shopping-bag.json',
                  description: 'Shopping, errands, and lifestyle',
                  color: Colors.orange,
                  services: [
                    const ServiceItem(
                      name: 'Personal Shopping',
                      icon: Iconsax.shopping_cart,
                      description: 'Customized shopping assistance',
                      features: [
                        'Gift shopping',
                        'Wardrobe consultation',
                        'Personal styling',
                        'Product sourcing',
                      ],
                    ),
                    const ServiceItem(
                      name: 'Home Services',
                      icon: Iconsax.home,
                      description: 'Maintenance and cleaning',
                      features: [
                        'House cleaning',
                        'Repairs & maintenance',
                        'Pest control',
                        'Garden maintenance',
                      ],
                    ),
                  ],
                ),
                _buildServiceCard(
                  context,
                  title: 'Entertainment',
                  lottieAsset: 'assets/lotties/snack.json',
                  description: 'VIP access and exclusive experiences',
                  color: Colors.green,
                  services: [
                    const ServiceItem(
                      name: 'VIP Experiences',
                      icon: Iconsax.crown,
                      description: 'Exclusive access and experiences',
                      features: [
                        'Private events',
                        'Celebrity meet & greets',
                        'Backstage access',
                        'VIP club entry',
                      ],
                    ),
                  ],
                ),
                _buildServiceCard(
                  context,
                  title: 'Business',
                  lottieAsset: 'assets/lotties/hotel.json',
                  description: 'Professional and office support',
                  color: Colors.red,
                  services: [
                    const ServiceItem(
                      name: 'Meeting Arrangements',
                      icon: Iconsax.people,
                      description: 'Professional meeting support',
                      features: [
                        'Venue booking',
                        'Catering services',
                        'Equipment setup',
                        'Virtual meeting support',
                      ],
                    ),
                  ],
                ),
                _buildServiceCard(
                  context,
                  title: 'Special',
                  lottieAsset: 'assets/lotties/vip.json',
                  description: 'Custom requests and emergencies',
                  color: Colors.teal,
                  services: [
                    const ServiceItem(
                      name: 'Emergency Support',
                      icon: Iconsax.shield_tick,
                      description: '24/7 emergency assistance',
                      features: [
                        'Medical assistance',
                        'Lost item recovery',
                        'Emergency transport',
                        'Crisis management',
                      ],
                    ),
                  ],
                ),
              ]),
            ),
          ),

          // Quick Actions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need immediate help?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildQuickActionButton(
                    context,
                    lottieAsset: 'assets/lotties/disc.json',
                    title: 'Live Chat Support',
                    subtitle: 'Get instant help from our team',
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionButton(
                    context,
                    lottieAsset: 'assets/lotties/hotel.json',
                    title: 'Request Callback',
                    subtitle: 'Schedule a personalized consultation',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String lottieAsset,
    required String description,
    required Color color,
    required List<ServiceItem> services,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final hasPremiumAccess = SubscriptionUtils.hasPremiumAccess(ref);
        
        final cardContent = SquircleContainer(
          radius: 50,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 19, 19, 19),
              
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      
                      if (!hasPremiumAccess) {
                        await SubscriptionUtils.requirePremiumAccess(
                          context,
                          ref,
                          featureName: 'Concierge Services',
                        );
                        return;
                      }
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceDetailPage(
                            title: title,
                            icon: Iconsax
                                .star, // Keep icon for ServiceDetailPage compatibility
                            color: color,
                            services: services,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ColorFiltered(
                            colorFilter: hasPremiumAccess 
                                ? const ColorFilter.mode(
                                    Colors.transparent, 
                                    BlendMode.multiply,
                                  )
                                : ColorFilter.mode(
                                    Colors.grey.withOpacity(0.6), 
                                    BlendMode.saturation,
                                  ),
                            child: Lottie.asset(
                              lottieAsset,
                              width: 65,
                              height: 65,
                              repeat: hasPremiumAccess,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: hasPremiumAccess 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Lock overlay for non-premium users
                if (!hasPremiumAccess)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Feature',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );

        return cardContent;
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String number,
    String label,
    String lottieAsset,
    Color color,
  ) {
    final statCard = SquircleContainer(
      radius: 45,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Lottie.asset(
              lottieAsset,
              width: 45,
              height: 45,
              repeat: true,
            ),
            const SizedBox(height: 8),
            Text(
              number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    return statCard;
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String lottieAsset,
    required String title,
    required String subtitle,
  }) {
    final actionButton = SquircleContainer(
      radius: 45,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withOpacity(0.1),
              AppTheme.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              // TODO: Implement quick action
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Lottie.asset(
                    lottieAsset,
                    width: 24,
                    height: 24,
                    repeat: true,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Iconsax.arrow_right_3,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return actionButton;
  }
}
