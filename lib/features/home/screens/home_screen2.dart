import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/config/feature_flags.dart';
import 'package:a_play/core/theme/app_theme.dart';
import 'package:a_play/features/home/widgets/searchbar_delegate.dart';
import 'package:a_play/features/widgets/section_title.dart';
import 'package:a_play/features/home/providers/home_event_provider.dart';
import 'package:a_play/features/home/providers/club_provider.dart';
import 'package:a_play/features/home/providers/event_category_provider.dart';
import 'package:a_play/features/home/widgets/home_app_bar.dart';
import 'package:a_play/features/home/widgets/event_carousel2.dart';
import 'package:a_play/features/home/widgets/clubs_horizontal_list.dart';
import 'package:a_play/features/home/widgets/featured_shimmer.dart';
import 'package:a_play/features/home/widgets/filtered_events_section.dart';
import 'package:a_play/features/home/widgets/filter_delegate.dart';
import 'package:a_play/features/restaurant/provider/restaurant_provider.dart';
import 'package:a_play/features/restaurant/widgets/restaurants_grid.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a_play/features/home/providers/welcome_provider.dart';
import 'package:a_play/features/home/providers/lounge_provider.dart';
import 'package:a_play/features/home/providers/pub_provider.dart';
import 'package:a_play/features/home/providers/arcade_center_provider.dart';
import 'package:a_play/features/home/providers/beach_provider.dart';
import 'package:a_play/features/home/providers/live_show_provider.dart';
import 'package:a_play/features/home/widgets/lounges_horizontal_list.dart';
import 'package:a_play/features/home/widgets/pubs_horizontal_list.dart';
import 'package:a_play/features/home/widgets/arcade_centers_horizontal_list.dart';
import 'package:a_play/features/home/widgets/beaches_horizontal_list.dart';
import 'package:a_play/features/home/widgets/live_shows_horizontal_list.dart';

class HomeScreen2 extends ConsumerStatefulWidget {
  const HomeScreen2({super.key});

  @override
  ConsumerState<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends ConsumerState<HomeScreen2> {
  String selectedTimeFilter = 'today';
  
  // Tour keys for tutorial
  final GlobalKey searchBarKey = GlobalKey();
  final GlobalKey featuredEventsKey = GlobalKey();
  final GlobalKey popularClubsKey = GlobalKey();
  final GlobalKey restaurantsKey = GlobalKey();
  
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    // Don't show tutorial immediately - wait for welcome overlay to be dismissed
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('has_seen_home_tutorial') ?? false;
    
    if (!hasSeenTutorial) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showTutorial();
        }
      });
    }
  }

  void _initTargets() {
    // MVP: Only show tutorial for enabled features
    targets = [
      TargetFocus(
        identify: "searchBar",
        keyTarget: searchBarKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                title: "Search Events & Places",
                description: "Find events and entertainment quickly using our smart search feature.",
                step: "1 of 2",
                controller: controller,
              );
            },
          )
        ],
      ),
      TargetFocus(
        identify: "featuredEvents",
        keyTarget: featuredEventsKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                title: "Featured Events",
                description: "Discover trending events happening in Ghana. Swipe through to explore more.",
                step: "2 of 2",
                controller: controller,
                isLastStep: true,
              );
            },
          )
        ],
      ),
      // MVP: Club and Restaurant tutorials hidden
      if (FeatureFlags.enableClubs)
        TargetFocus(
          identify: "popularClubs",
          keyTarget: popularClubsKey,
          alignSkip: Alignment.topRight,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return _buildTutorialContent(
                  title: "Popular Clubs",
                  description: "Explore the hottest clubs and nightlife venues. Book VIP tables and experiences.",
                  step: "3 of 4",
                  controller: controller,
                );
              },
            )
          ],
        ),
      if (FeatureFlags.enableRestaurants)
        TargetFocus(
          identify: "restaurants",
          keyTarget: restaurantsKey,
          alignSkip: Alignment.topRight,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return _buildTutorialContent(
                  title: "Popular Restaurants",
                  description: "Discover amazing restaurants and book tables for your next dining experience.",
                  step: "4 of 4",
                  controller: controller,
                  isLastStep: true,
                );
              },
            )
          ],
        ),
    ];
  }

  Widget _buildTutorialContent({
    required String title,
    required String description,
    required String step,
    required TutorialCoachMarkController controller,
    bool isLastStep = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    step,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => controller.skip(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isLastStep)
                  TextButton(
                    onPressed: () => controller.skip(),
                    child: const Text(
                      'Skip Tour',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                if (isLastStep) const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (isLastStep) {
                      controller.skip();
                    } else {
                      controller.next();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(isLastStep ? 'Get Started' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
  void _showTutorial() {
    _initTargets();
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_home_tutorial', true);
      },
      onSkip: () {
        // onSkip expects a synchronous bool Function(), not async
        // So we persist the value asynchronously, but return true immediately
        SharedPreferences.getInstance().then(
          (prefs) => prefs.setBool('has_seen_home_tutorial', true),
        );
        return true;
      },
    );
    tutorialCoachMark?.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final featuredEvents = ref.watch(featuredEventsProvider);
    // MVP: These providers are loaded but UI sections are conditionally hidden
    final popularClubs = ref.watch(popularClubsProvider);
    final featuredRestaurants = ref.watch(featuredRestaurantsProvider);
    final featuredLounges = ref.watch(featuredLoungesProvider);
    final featuredPubs = ref.watch(featuredPubsProvider);
    final featuredArcadeCenters = ref.watch(featuredArcadeCentersProvider);
    final featuredBeaches = ref.watch(featuredBeachesProvider);
    final featuredLiveShows = ref.watch(featuredLiveShowsProvider);
    
    
    // Listen for welcome overlay dismissal to trigger tutorial
    ref.listen<bool>(welcomeOverlayDismissedProvider, (previous, current) {
      if (current == true && previous == false) {
        // Welcome overlay was just dismissed, check and show tutorial
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndShowTutorial();
        });
      }
    });
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundEnd,
      body: RefreshIndicator(
            onRefresh: () async {
              // Invalidate providers to trigger loading states and shimmer effects
              // MVP: Only invalidate providers for enabled features
              ref.invalidate(homeEventProvider);
              ref.invalidate(featuredEventsProvider);
              ref.invalidate(upcomingEventsProvider);
              ref.invalidate(featuredLiveShowsProvider);
              ref.invalidate(eventCategoriesProvider);
              ref.invalidate(eventsByCategoryProvider);

              // MVP: Only invalidate club/restaurant providers if features are enabled
              if (FeatureFlags.enableClubs) {
                ref.invalidate(popularClubsProvider);
                ref.invalidate(featuredClubsProvider);
                ref.invalidate(featuredLoungesProvider);
                ref.invalidate(featuredPubsProvider);
                ref.invalidate(featuredArcadeCentersProvider);
                ref.invalidate(featuredBeachesProvider);
              }

              if (FeatureFlags.enableRestaurants) {
                ref.invalidate(featuredRestaurantsProvider);
              }

              // Add a small delay to ensure loading states are triggered
              await Future.delayed(const Duration(milliseconds: 100));

              // Wait for key providers to load but don't block UI updates
              try {
                final futures = <Future>[
                  ref.read(featuredEventsProvider.future),
                  ref.read(upcomingEventsProvider.future),
                  ref.read(featuredLiveShowsProvider.future),
                ];

                // MVP: Only wait for club/restaurant providers if enabled
                if (FeatureFlags.enableClubs) {
                  futures.addAll([
                    ref.read(popularClubsProvider.future),
                    ref.read(featuredClubsProvider.future),
                    ref.read(featuredLoungesProvider.future),
                    ref.read(featuredPubsProvider.future),
                    ref.read(featuredArcadeCentersProvider.future),
                    ref.read(featuredBeachesProvider.future),
                  ]);
                }

                if (FeatureFlags.enableRestaurants) {
                  futures.add(ref.read(featuredRestaurantsProvider.future));
                }

                await Future.wait(futures, eagerError: false);
              } catch (e) {
                // Continue even if some providers fail
                debugPrint('Refresh error: $e');
              }
            },
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  const HomeAppBar(),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SearchBarDelegate(ref: ref, key: searchBarKey),
                  ),
                  //Carousel for featured events
                  SliverToBoxAdapter(
                    child: Container(
                      key: featuredEventsKey,
                      child: featuredEvents.when(
                        data: (events) {
                          if (events.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  'No featured events available',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            );
                          }
                          return EventCarousel2(
                            events: events,
                            key: ValueKey(events.length),
                          );
                        },
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading featured events',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                        loading: () => const Center(child: FeaturedShimmer()),
                      ),
                    ),
                  ),
                  // Filter delegate for time filters
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: FilterDelegate(
                      ref: ref,
                      selectedFilter: selectedTimeFilter,
                      onFilterChanged: (filter) {
                        setState(() {
                          selectedTimeFilter = filter;
                        });
                      },
                    ),
                  ),
                  // Filtered Events Section  
                  SliverToBoxAdapter(
                    child: FilteredEventsSection(
                      selectedTimeFilter: selectedTimeFilter,
                    ),
                  ),
                  // MVP: Clubs, Lounges, Pubs, Arcade Centers, and Beaches hidden - Coming in v2.1
                  // These sections are part of the club bookings feature
                  if (FeatureFlags.enableClubs) ...[
                    // 1. Clubs Section
                    SliverToBoxAdapter(
                      child: Container(
                        key: popularClubsKey,
                        child: popularClubs.when(
                          data: (clubsList) => ClubsHorizontalList(
                            clubs: clubsList,
                            title: 'Clubs',
                          ),
                          error: (error, stack) => const ClubsHorizontalList(
                            clubs: [],
                            title: 'Clubs',
                            isLoading: false,
                          ),
                          loading: () => const ClubsHorizontalList(
                            clubs: [],
                            title: 'Clubs',
                            isLoading: true,
                          ),
                        ),
                      ),
                    ),

                    // 2. Lounges Section
                    SliverToBoxAdapter(
                      child: featuredLounges.when(
                        data: (loungesList) => LoungesHorizontalList(
                          lounges: loungesList,
                          title: 'Lounges',
                        ),
                        error: (error, stack) => const LoungesHorizontalList(
                          lounges: [],
                          title: 'Lounges',
                          isLoading: false,
                        ),
                        loading: () => const LoungesHorizontalList(
                          lounges: [],
                          title: 'Lounges',
                          isLoading: true,
                        ),
                      ),
                    ),

                    // 3. Pubs Section
                    SliverToBoxAdapter(
                      child: featuredPubs.when(
                        data: (pubsList) => PubsHorizontalList(
                          pubs: pubsList,
                          title: 'Pubs',
                        ),
                        error: (error, stack) => const PubsHorizontalList(
                          pubs: [],
                          title: 'Pubs',
                          isLoading: false,
                        ),
                        loading: () => const PubsHorizontalList(
                          pubs: [],
                          title: 'Pubs',
                          isLoading: true,
                        ),
                      ),
                    ),

                    // 4. Arcade Centers Section
                    SliverToBoxAdapter(
                      child: featuredArcadeCenters.when(
                        data: (arcadeCentersList) => ArcadeCentersHorizontalList(
                          arcadeCenters: arcadeCentersList,
                          title: 'Arcade Centers',
                        ),
                        error: (error, stack) => const ArcadeCentersHorizontalList(
                          arcadeCenters: [],
                          title: 'Arcade Centers',
                          isLoading: false,
                        ),
                        loading: () => const ArcadeCentersHorizontalList(
                          arcadeCenters: [],
                          title: 'Arcade Centers',
                          isLoading: true,
                        ),
                      ),
                    ),

                    // 5. Beaches Section
                    SliverToBoxAdapter(
                      child: featuredBeaches.when(
                        data: (beachesList) => BeachesHorizontalList(
                          beaches: beachesList,
                          title: 'Beaches',
                        ),
                        error: (error, stack) => const BeachesHorizontalList(
                          beaches: [],
                          title: 'Beaches',
                          isLoading: false,
                        ),
                        loading: () => const BeachesHorizontalList(
                          beaches: [],
                          title: 'Beaches',
                          isLoading: true,
                        ),
                      ),
                    ),
                  ],

                  // 6. Live Shows Section
                  SliverToBoxAdapter(
                    child: featuredLiveShows.when(
                      data: (liveShowsList) => LiveShowsHorizontalList(
                        liveShows: liveShowsList,
                        title: 'Live Shows',
                      ),
                      error: (error, stack) => const LiveShowsHorizontalList(
                        liveShows: [],
                        title: 'Live Shows',
                        isLoading: false,
                      ),
                      loading: () => const LiveShowsHorizontalList(
                        liveShows: [],
                        title: 'Live Shows',
                        isLoading: true,
                      ),
                    ),
                  ),

                  // MVP: Restaurants section hidden - Coming in v2.1
                  if (FeatureFlags.enableRestaurants) ...[
                    // 7. Restaurants Section Title
                    SliverToBoxAdapter(
                      child: Container(
                        key: restaurantsKey,
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: SectionTitle(title: 'Restaurants'),
                        ),
                      ),
                    ),
                    // 8. Restaurants Grid
                    SliverToBoxAdapter(
                      child: featuredRestaurants.when(
                        data: (restaurantsList) => RestaurantsGrid(restaurants: restaurantsList),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading restaurants: $error',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                        loading: () => const RestaurantsGrid(restaurants: [], isLoading: true),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
    );
  }
}
