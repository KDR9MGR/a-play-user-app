import 'package:a_play/core/constants/colors.dart';
import 'package:a_play/data/models/event_model.dart';
import 'package:a_play/features/booking/screens/event_details_screen.dart';
import 'package:a_play/features/explore/model/service_event_model.dart';
import 'package:a_play/features/explore/provider/explore_event_provider.dart';
import 'package:a_play/features/explore/provider/category_provider.dart';
import 'package:a_play/features/subscription/utils/subscription_utils.dart';
import 'package:a_play/features/subscription/provider/subscription_provider.dart';
import 'package:a_play/features/subscription/screens/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        DateTime tempSelectedDate = _selectedDate ?? DateTime.now();
        
        return Container(
          height: 350,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: AppColors.orange),
                    ),
                  ),
                  const Text(
                    'Select Date',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = tempSelectedDate;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(color: AppColors.orange),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempSelectedDate,
                  minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                  maximumDate: DateTime.now().add(const Duration(days: 365)),
                  onDateTimeChanged: (DateTime date) {
                    tempSelectedDate = date;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventListAsync = ref.watch(eventListProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Explore',
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        IconButton(
                          onPressed: _showDatePicker,
                          icon: Icon(
                            _selectedDate != null 
                                ? Iconsax.calendar_1 
                                : Iconsax.calendar,
                            color: _selectedDate != null 
                                ? AppColors.orange 
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.calendar_1,
                                size: 16,
                                color: AppColors.orange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('MMM dd, yyyy').format(_selectedDate!),
                                style: const TextStyle(
                                  color: AppColors.orange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search events...',
                          hintStyle: TextStyle(color: AppColors.textTertiary),
                          prefixIcon: Icon(Iconsax.search_normal,
                              color: AppColors.textTertiary),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category chips
                    categories.when(
                      data: (categoryList) => SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryList.length,
                          itemBuilder: (context, index) {
                            final category = categoryList[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(category.name),
                                selected: selectedCategory == category.name,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state = category.name;
                                    // Refresh events when category changes
                                    ref
                                        .read(eventListProvider.notifier)
                                        .refreshEvents();
                                  }
                                },
                                backgroundColor: AppColors.surface,
                                selectedColor: AppColors.orange,
                                labelStyle: TextStyle(
                                  color: selectedCategory == category.name
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      loading: () => const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.orange),
                      ),
                      error: (error, stack) => const Center(
                        child: Text(
                          'Error loading categories',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Event List
            eventListAsync.when(
              data: (data) {
                // Filter events based on search query and selected date
                final filteredData = data.where((event) {
                  // Search filter
                  bool matchesSearch = _searchQuery.isEmpty ||
                      event.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      event.description
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                  
                  // Date filter
                  bool matchesDate = true;
                  if (_selectedDate != null) {
                    try {
                      final eventDate = DateTime.parse(event.startDate);
                      final selectedDateOnly = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                      );
                      final eventDateOnly = DateTime(
                        eventDate.year,
                        eventDate.month,
                        eventDate.day,
                      );
                      matchesDate = eventDateOnly.isAtSameMomentAs(selectedDateOnly);
                    } catch (e) {
                      matchesDate = false;
                    }
                  }
                  
                  return matchesSearch && matchesDate;
                }).toList();

                if (filteredData.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedDate != null ? Iconsax.calendar_remove : Iconsax.search_status,
                            color: AppColors.textTertiary,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedDate != null 
                                ? 'No events found for ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'
                                : _searchQuery.isNotEmpty 
                                    ? 'No events found for "$_searchQuery"'
                                    : 'No events found',
                            style: const TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          if (_selectedDate != null || _searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDate = null;
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                              child: const Text(
                                'Clear filters',
                                style: TextStyle(color: AppColors.orange),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                // Responsive grid - 2 columns on phone, 3-4 on tablet (iPad Air fix)
                final screenWidth = MediaQuery.of(context).size.width;
                final crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildEventCard(context, filteredData[index]);
                      },
                      childCount: filteredData.length,
                    ),
                  ),
                );
              },
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.warning_2,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => ref
                            .read(eventListProvider.notifier)
                            .refreshEvents(),
                        icon: const Icon(Iconsax.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.orange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, ServiceEventModel event) {
    return Consumer(
      builder: (context, ref, child) {
        final hasPremiumAccess = SubscriptionUtils.hasPremiumAccess(ref);
        final isFeaturedEvent = event.title.toLowerCase().contains('featured') || 
                              event.description.toLowerCase().contains('featured');
        final canAccess = hasPremiumAccess || isFeaturedEvent;
        
        return GestureDetector(
          onTap: () async {
            if (!canAccess) {
              // Show paywall for non-premium content
              await SubscriptionUtils.requirePremiumAccess(
                context,
                ref,
                featureName: 'Explore Events',
              );
              return;
            }
            
            final eventToPass = EventModel(
              id: event.id,
              title: event.title,
              description: event.description,
              coverImage: event.coverImage,
              startDate: DateTime.parse(event.startDate),
              endDate: DateTime.parse(event.endDate),
              location: event.location,
              capacity: 0, // Default value, as it's not in ServiceEventModel
              status: 'active', // Default value
              clubId: event.clubId ?? '', // Handle nullable clubId
              price: 0.0, // Default value
              createdAt: DateTime.now(), // Default value
              updatedAt: DateTime.now(), // Default value
            );

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventDetailsScreen(event: eventToPass),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Image
                    Expanded(
                      flex: 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColorFiltered(
                            colorFilter: canAccess 
                                ? const ColorFilter.mode(
                                    Colors.transparent, 
                                    BlendMode.multiply,
                                  )
                                : ColorFilter.mode(
                                    Colors.grey.withOpacity(0.6), 
                                    BlendMode.saturation,
                                  ),
                            child: Image.network(
                              event.coverImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.surface,
                                  child: const Center(
                                    child: Icon(
                                      Iconsax.gallery,
                                      color: AppColors.textTertiary,
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Date badge
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: canAccess ? AppColors.orange : Colors.grey,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _formatDate(event.startDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          
                          // Premium badge for featured events
                          if (isFeaturedEvent)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'FEATURED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Event Details
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                color: canAccess 
                                    ? AppColors.textPrimary 
                                    : AppColors.textPrimary.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.description,
                              style: TextStyle(
                                color: canAccess 
                                    ? AppColors.textSecondary 
                                    : AppColors.textSecondary.withOpacity(0.5),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.location,
                                  color: canAccess 
                                      ? AppColors.textTertiary 
                                      : AppColors.textTertiary.withOpacity(0.5),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style: TextStyle(
                                      color: canAccess 
                                          ? AppColors.textTertiary 
                                          : AppColors.textTertiary.withOpacity(0.5),
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Lock overlay for non-premium events
                if (!canAccess)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
      },
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMM dd').format(date);
  }
}
