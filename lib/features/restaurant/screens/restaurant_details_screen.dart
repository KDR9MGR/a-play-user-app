import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../provider/restaurant_provider.dart';
import '../provider/cart_provider.dart';
import 'table_booking_screen.dart';

class RestaurantDetailsScreen extends ConsumerStatefulWidget {
  final String restaurantId;

  const RestaurantDetailsScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  ConsumerState<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends ConsumerState<RestaurantDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = ref.watch(restaurantByIdProvider(widget.restaurantId));
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: restaurant.when(
        data: (restaurantData) {
          if (restaurantData == null) {
            return const Center(
              child: Text(
                'Restaurant not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: const Color(0xFF121212),
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: restaurantData.coverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: restaurantData.coverImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[800],
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.restaurant,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.restaurant,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                ),
                actions: [
                  if (cartItemCount > 0)
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            _showCartBottomSheet(context);
                          },
                          icon: const Icon(Icons.shopping_cart),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$cartItemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              restaurantData.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (restaurantData.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Featured',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (restaurantData.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          restaurantData.description!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 20,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurantData.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${restaurantData.totalReviews} reviews)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurantData.estimatedDeliveryTime} min',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              restaurantData.address,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Delivery: GH₵ ${restaurantData.deliveryFee.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Min: GH₵ ${restaurantData.minimumOrder.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      ),
      bottomNavigationBar: restaurant.when(
        data: (restaurantData) {
          if (restaurantData == null) return null;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TableBookingScreen(
                        restaurant: restaurantData,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.table_restaurant,
                  color: Colors.white,
                ),
                label: const Text(
                  'Book a Table',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
        },
        error: (error, stack) => null,
        loading: () => null,
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _CartBottomSheet(),
    );
  }
}


class _CartBottomSheet extends ConsumerWidget {
  const _CartBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Your Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  color: const Color(0xFF2A2A2A),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.menuItem.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'GH₵ ${item.menuItem.price.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                ref.read(cartProvider.notifier).updateQuantity(
                                  item.id,
                                  item.quantity - 1,
                                );
                              },
                              icon: const Icon(Icons.remove, color: Colors.white),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () {
                                ref.read(cartProvider.notifier).updateQuantity(
                                  item.id,
                                  item.quantity + 1,
                                );
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.grey),
          Row(
            children: [
              const Text(
                'Total: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'GH₵ ${cartTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cartItems.isEmpty ? null : () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Checkout functionality coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}