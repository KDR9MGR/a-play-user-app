import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:geocoding/geocoding.dart';
import 'package:a_play/core/services/location_service.dart';
import 'package:a_play/core/theme/app_theme.dart';

class SelectLocationScreen extends ConsumerStatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  ConsumerState<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<LocationData> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final locations = await locationFromAddress(query);
      final locationService = ref.read(locationServiceProvider);
      
      _searchResults = await Future.wait(
        locations.map((location) async {
          return locationService.getAddressFromCoordinates(
            location.latitude,
            location.longitude,
          );
        }),
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error searching location')),
        );
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final hasPermission = await locationService.handleLocationPermission();
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final locationData = await locationService.getCurrentLocation();
      if (mounted) {
        ref.read(currentLocationProvider.notifier).setManualLocation(locationData);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  void _selectLocation(LocationData location) {
    ref.read(currentLocationProvider.notifier).setManualLocation(location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundStart,
      appBar: AppBar(
        title: const Text('Select Location'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocation,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Use Current Location Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              onTap: _useCurrentLocation,
              leading: const Icon(Iconsax.location, color: AppTheme.primary),
              title: const Text(
                'Use current location',
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade800),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Search Results',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Search for a location'
                              : 'No results found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final location = _searchResults[index];
                          return ListTile(
                            onTap: () => _selectLocation(location),
                            leading: const Icon(Iconsax.location,
                                color: AppTheme.primary),
                            title: Text(
                              location.city,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              location.fullAddress,
                              style: TextStyle(color: Colors.grey.shade400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade800),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 