import 'package:a_play/core/constants/app_constants.dart';
import 'package:a_play/core/constants/colors.dart';
import 'package:a_play/data/models/event_model.dart';
import 'package:a_play/features/booking/providers/ticket_price_provider.dart';
import 'package:a_play/features/booking/screens/zone_selection_screen.dart';
import 'package:a_play/features/subscription/utils/subscription_utils.dart';
import 'package:a_play/features/widgets/squircle_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  late ScrollController _scrollController;
  bool _showAppBarBg = false;
  double _opacity = 0.0;
  LatLng? _eventLocation;
  GoogleMapController? _mapController;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        final shouldShowAppBarBg = _scrollController.offset > 20;
        if (shouldShowAppBarBg != _showAppBarBg) {
          setState(() {
            _showAppBarBg = shouldShowAppBarBg;
            _opacity = (_scrollController.offset - 20).clamp(0, 60) / 60;
          });
        }
      });
    _getLocationFromAddress();
  }

  Future<void> _getLocationFromAddress() async {
    try {
      final locations = await locationFromAddress(widget.event.location);
      if (locations.isNotEmpty) {
        setState(() {
          _eventLocation =
              LatLng(locations.first.latitude, locations.first.longitude);
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      // Fallback to a default location (Ghana coordinates)
      setState(() {
        _eventLocation = const LatLng(5.6037, -0.1870); // Accra, Ghana
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _openMap() async {
    // Safe null check for location (iPad crash fix)
    final eventLocation = _eventLocation;
    if (eventLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location not available. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final latitude = eventLocation.latitude;
    final longitude = eventLocation.longitude;
    final location = Uri.encodeComponent(widget.event.location);

    // Try multiple URL schemes for better compatibility
    final List<String> mapUrls = [
      // Google Maps app (most common on Android)
      'geo:$latitude,$longitude?q=$latitude,$longitude($location)',
      // Google Maps web fallback
      'https://maps.google.com/?q=$latitude,$longitude',
      // Apple Maps (iOS)
      'maps://maps.apple.com/?q=$location&ll=$latitude,$longitude',
      // Generic map intent
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    ];

    bool launched = false;

    for (String url in mapUrls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Could not open maps. Please install Google Maps or another map app.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //    backgroundColor: AppColors.darkGrey,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(_opacity),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.event.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.ios_share,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.2,
            ),
          ),
        ),
        child: Row(
          children: [
            // Price section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Starts from',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer(
                  builder: (context, ref, child) {
                    final ticketPrice =
                        ref.watch(ticketPriceProvider(widget.event.id));
                    return ticketPrice.when(
                      data: (data) => Text(
                        '${AppConstants.currency} ${data.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      error: (error, stack) => const Text(
                        'Price unavailable',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      loading: () => Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[600]!,
                        child: Container(
                          width: 80,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const Spacer(),

            // Book tickets button
            Consumer(
              builder: (context, ref, child) {
                final hasPremiumAccess =
                    SubscriptionUtils.hasPremiumAccess(ref);
                final isFeaturedEvent =
                    widget.event.title.toLowerCase().contains('featured');
                final canBook = hasPremiumAccess || isFeaturedEvent;

                return ElevatedButton(
                  onPressed: canBook
                      ? () => _onBookTicketsPressed(context)
                      : () async {
                          await SubscriptionUtils.requirePremiumAccess(
                            context,
                            ref,
                            featureName: 'Event Booking',
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canBook ? Colors.white : Colors.grey.withOpacity(0.3),
                    foregroundColor:
                        canBook ? Colors.black : Colors.white.withOpacity(0.5),
                    fixedSize: const Size(180, 56),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!canBook) ...[
                        const Icon(Icons.lock, size: 16),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        canBook ? 'Book tickets' : 'Premium Required',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // Event Image - simple rectangular image
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: SquircleContainer(
              radius: 45,
              // Safe image loading with error handling (iPad crash fix)
              child: widget.event.coverImage.isNotEmpty
                  ? Image.network(
                      widget.event.coverImage,
                      height: MediaQuery.of(context).size.height * 0.5,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          color: const Color(0xFF1E1E1E),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          color: const Color(0xFF1E1E1E),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      color: const Color(0xFF1E1E1E),
                      child: const Center(
                        child: Icon(
                          Icons.event,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // Event Title
          Text(
            widget.event.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 24),

          // Date and time section
          _buildInfoCard(
            icon: Icons.calendar_today_outlined,
            title:
                '${DateFormat('d MMM').format(widget.event.startDate)} - ${DateFormat('d MMM').format(widget.event.endDate)}',
            subtitle1:
                '${DateFormat('h:mm a').format(widget.event.startDate)} onwards',
          ),

          const SizedBox(height: 16),

          // Location section
          _buildInfoCard(
            icon: Icons.location_on_outlined,
            title: widget.event.location,
            subtitle1: widget.event.location,
            rightIcon: Icons.directions_outlined,
            onTap: _openMap,
          ),

          const SizedBox(height: 16),

          // Mini Map
          _buildMiniMap(),

          const SizedBox(height: 24),

          // About section
          const Text(
            'About',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.event.description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Capacity section

          const SizedBox(height: 24),

          const SizedBox(height: 12),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    String? subtitle1,
    IconData? rightIcon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900]?.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle1 != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle1,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (rightIcon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  rightIcon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.3),
      ),
      child: SquircleContainer(
        radius: 16,
        child: _isLoadingLocation
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : _eventLocation == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          color: Colors.grey,
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Unable to load map',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      // Google Maps widget
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _eventLocation!,
                          zoom: 15.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                          // Set dark theme
                          controller.setMapStyle('''
                            [
                              {
                                "elementType": "geometry",
                                "stylers": [
                                  {
                                    "color": "#242f3e"
                                  }
                                ]
                              },
                              {
                                "elementType": "labels.text.fill",
                                "stylers": [
                                  {
                                    "color": "#746855"
                                  }
                                ]
                              },
                              {
                                "elementType": "labels.text.stroke",
                                "stylers": [
                                  {
                                    "color": "#242f3e"
                                  }
                                ]
                              },
                              {
                                "featureType": "administrative.locality",
                                "elementType": "labels.text.fill",
                                "stylers": [
                                  {
                                    "color": "#d59563"
                                  }
                                ]
                              },
                              {
                                "featureType": "poi",
                                "elementType": "labels.text.fill",
                                "stylers": [
                                  {
                                    "color": "#d59563"
                                  }
                                ]
                              },
                              {
                                "featureType": "poi.park",
                                "elementType": "geometry",
                                "stylers": [
                                  {
                                    "color": "#263c3f"
                                  }
                                ]
                              },
                              {
                                "featureType": "poi.park",
                                "elementType": "labels.text.fill",
                                "stylers": [
                                  {
                                    "color": "#6b9a76"
                                  }
                                ]
                              },
                              {
                                "featureType": "road",
                                "elementType": "geometry",
                                "stylers": [
                                  {
                                    "color": "#38414e"
                                  }
                                ]
                              },
                              {
                                "featureType": "road",
                                "elementType": "geometry.stroke",
                                "stylers": [
                                  {
                                    "color": "#212a37"
                                  }
                                ]
                              },
                              {
                                "featureType": "road",
                                "elementType": "labels.text.fill",
                                "stylers": [
                                  {
                                    "color": "#9ca5b3"
                                  }
                                ]
                              },
                              {
                                "featureType": "road.highway",
                                "elementType": "geometry",
                                "stylers": [
                                  {
                                    "color": "#746855"
                                  }
                                ]
                              },
                              {
                                "featureType": "road.highway",
                                "elementType": "geometry.stroke",
                                "stylers": [
                                  {
                                    "color": "#1f2835"
                                  }
                                ]
                              },
                              {
                                "featureType": "road.highway",
                                "elementType": "labels.text.fill",
                                "stylers": [
                                  {
                                    "color": "#f3d19c"
                                  }
                                ]
                              },
                              {
                                "featureType": "transit",
                                "elementType": "geometry",
                                "stylers": [
                                  {
                                    "color": "#2f3948"
                                  }
                                ]
                              },
                              {
                                "featureType": "transit.station",
                                "elementType": "labels.text.fill",
                                "stylers": [
                                  {
                                    "color": "#d59563"
                                  }
                                ]
                              },
                              {
                                "featureType": "water",
                                "elementType": "geometry",
                                "stylers": [
                                  {
                                    "color": "#17263c"
                                  }
                                ]
                              },
                              {
                                "featureType": "water",
                                "elementType": "labels.text.fill",
                                "stylers": [
                                  {
                                    "color": "#515c6d"
                                  }
                                ]
                              },
                              {
                                "featureType": "water",
                                "elementType": "labels.text.stroke",
                                "stylers": [
                                  {
                                    "color": "#17263c"
                                  }
                                ]
                              }
                            ]
                          ''');
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('event_location'),
                            position: _eventLocation!,
                            infoWindow: InfoWindow(
                              title: 'Event Location',
                              snippet: widget.event.location,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                          ),
                        },
                        mapType: MapType.normal,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        rotateGesturesEnabled: false,
                        scrollGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                      ),
                      // Tap overlay to handle navigation
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _openMap,
                          child: SquircleContainer(
                            radius: 12,
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      // Tap to navigate indicator
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_outlined,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tap to navigate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  void _onBookTicketsPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoneSelectionScreen(event: widget.event),
      ),
    );
  }
}
