import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Free OpenStreetMap Nominatim service for location search
/// No API key required, completely free to use
class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'APlayApp/3.0.1 (Event booking app for Ghana)';

  // Major Ghana cities/locations for when user searches "ghana"
  static const List<Map<String, dynamic>> _popularGhanaLocations = [
    {'name': 'Accra', 'lat': 5.6037, 'lon': -0.1870, 'type': 'capital'},
    {'name': 'Kumasi', 'lat': 6.6885, 'lon': -1.6244, 'type': 'city'},
    {'name': 'Tamale', 'lat': 9.4008, 'lon': -0.8393, 'type': 'city'},
    {'name': 'Takoradi', 'lat': 4.8845, 'lon': -1.7554, 'type': 'city'},
    {'name': 'Cape Coast', 'lat': 5.1054, 'lon': -1.2466, 'type': 'city'},
    {'name': 'Tema', 'lat': 5.6698, 'lon': -0.0166, 'type': 'city'},
    {'name': 'Sunyani', 'lat': 7.3386, 'lon': -2.3266, 'type': 'city'},
    {'name': 'Koforidua', 'lat': 6.0940, 'lon': -0.2571, 'type': 'city'},
    {'name': 'Ho', 'lat': 6.6111, 'lon': 0.4711, 'type': 'city'},
    {'name': 'Wa', 'lat': 10.0603, 'lon': -2.5095, 'type': 'city'},
  ];

  /// Search for locations by query string
  /// Returns list of location results with coordinates and details
  Future<List<NominatimResult>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      debugPrint('🔍 Nominatim: Searching for "$query"');

      // Special handling for "ghana" searches - show popular cities
      if (query.trim().toLowerCase() == 'ghana') {
        debugPrint('✅ Nominatim: Showing popular Ghana cities');
        return _popularGhanaLocations.map((loc) {
          return NominatimResult(
            latitude: loc['lat'],
            longitude: loc['lon'],
            displayName: '${loc['name']}, Ghana',
            city: loc['name'],
            town: null,
            suburb: null,
            neighbourhood: null,
            region: null,
            country: 'Ghana',
            countryCode: 'gh',
            postcode: null,
            type: loc['type'],
            placeId: null,
          );
        }).toList();
      }

      // For other searches, use Nominatim API
      String searchQuery = query;
      
      // Don't append "Ghana" if query is very short or already contains Ghana/major city
      final lowerQuery = query.toLowerCase();
      final needsGhanaSuffix = query.length > 2 && 
          !lowerQuery.contains('ghana') &&
          !lowerQuery.contains('accra') &&
          !lowerQuery.contains('kumasi') &&
          !lowerQuery.contains('tema');
      
      if (needsGhanaSuffix) {
        searchQuery = '$query, Ghana';
      }

      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
        'q': searchQuery,
        'format': 'json',
        'limit': '20', // Increased to get more results
        'countrycodes': 'gh', // Restrict to Ghana
        'addressdetails': '1',
        'accept-language': 'en',
        'bounded': '1', // Restrict results to viewbox
        'viewbox': '-3.26,11.17,1.20,5.57', // Ghana bounding box
      });

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Search request timed out'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isEmpty) {
          debugPrint('⚠️  Nominatim: No results, trying without Ghana suffix');
          // If no results, try again without Ghana suffix
          final retryUri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
            'q': query,
            'format': 'json',
            'limit': '20',
            'countrycodes': 'gh',
            'addressdetails': '1',
            'accept-language': 'en',
          });
          
          final retryResponse = await http.get(retryUri, headers: {'User-Agent': _userAgent});
          if (retryResponse.statusCode == 200) {
            final retryData = json.decode(retryResponse.body) as List<dynamic>;
            if (retryData.isNotEmpty) {
              final results = retryData.map((item) => NominatimResult.fromJson(item)).toList();
              final filtered = _filterAndPrioritizeResults(results, query);
              debugPrint('✅ Nominatim: Found ${filtered.length} results on retry');
              return filtered;
            }
          }
          
          // Still no results? Return popular cities as fallback
          debugPrint('⚠️  Nominatim: No results found, showing popular cities');
          return _popularGhanaLocations.take(5).map((loc) {
            return NominatimResult(
              latitude: loc['lat'],
              longitude: loc['lon'],
              displayName: '${loc['name']}, Ghana',
              city: loc['name'],
              town: null,
              suburb: null,
              neighbourhood: null,
              region: null,
              country: 'Ghana',
              countryCode: 'gh',
              postcode: null,
              type: loc['type'],
              placeId: null,
            );
          }).toList();
        }

        final results = data.map((item) => NominatimResult.fromJson(item)).toList();
        final filtered = _filterAndPrioritizeResults(results, query);

        debugPrint('✅ Nominatim: Found ${filtered.length} filtered results');
        return filtered;
      } else {
        debugPrint('❌ Nominatim: Error ${response.statusCode}');
        throw Exception('Search failed with status ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Nominatim search error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // On error, return popular cities as fallback
      debugPrint('⚠️  Returning popular cities as fallback');
      return _popularGhanaLocations.take(5).map((loc) {
        return NominatimResult(
          latitude: loc['lat'],
          longitude: loc['lon'],
          displayName: '${loc['name']}, Ghana',
          city: loc['name'],
          town: null,
          suburb: null,
          neighbourhood: null,
          region: null,
          country: 'Ghana',
          countryCode: 'gh',
          postcode: null,
          type: loc['type'],
          placeId: null,
        );
      }).toList();
    }
  }

  /// Filter and prioritize search results
  List<NominatimResult> _filterAndPrioritizeResults(
    List<NominatimResult> results,
    String query,
  ) {
    if (results.isEmpty) return results;

    // Filter out results with "Unknown" as city name
    final validResults = results.where((r) => 
      r.cityName.toLowerCase() != 'unknown' && 
      r.cityName.isNotEmpty
    ).toList();

    if (validResults.isEmpty) return results.take(10).toList();

    // Prioritize: exact match > city > town > suburb > neighbourhood
    final prioritized = validResults.toList();
    prioritized.sort((a, b) {
      // Exact name match gets highest priority
      final aExact = a.cityName.toLowerCase() == query.toLowerCase();
      final bExact = b.cityName.toLowerCase() == query.toLowerCase();
      if (aExact && !bExact) return -1;
      if (bExact && !aExact) return 1;

      // Starts with query gets next priority
      final aStarts = a.cityName.toLowerCase().startsWith(query.toLowerCase());
      final bStarts = b.cityName.toLowerCase().startsWith(query.toLowerCase());
      if (aStarts && !bStarts) return -1;
      if (bStarts && !aStarts) return 1;

      // Then by type importance
      int aPriority = _getTypePriority(a.type);
      int bPriority = _getTypePriority(b.type);
      return aPriority.compareTo(bPriority);
    });

    return prioritized.take(15).toList(); // Return top 15
  }

  int _getTypePriority(String type) {
    switch (type.toLowerCase()) {
      case 'capital':
        return 0;
      case 'city':
        return 1;
      case 'town':
        return 2;
      case 'suburb':
        return 3;
      case 'neighbourhood':
        return 4;
      case 'village':
        return 5;
      default:
        return 10;
    }
  }

  /// Reverse geocode coordinates to get address
  Future<NominatimResult?> reverseGeocode(double lat, double lon) async {
    try {
      debugPrint('🔍 Nominatim: Reverse geocoding ($lat, $lon)');

      final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'format': 'json',
        'addressdetails': '1',
        'accept-language': 'en',
      });

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Reverse geocode request timed out'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = NominatimResult.fromJson(data);
        debugPrint('✅ Nominatim: Reverse geocode successful');
        return result;
      } else {
        debugPrint('❌ Nominatim: Error ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Nominatim reverse geocode error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}

/// Result from Nominatim search
class NominatimResult {
  final double latitude;
  final double longitude;
  final String displayName;
  final String? city;
  final String? town;
  final String? suburb;
  final String? neighbourhood;
  final String? region;
  final String? country;
  final String? countryCode;
  final String? postcode;
  final String type;
  final String? placeId;

  NominatimResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.city,
    this.town,
    this.suburb,
    this.neighbourhood,
    this.region,
    this.country,
    this.countryCode,
    this.postcode,
    required this.type,
    this.placeId,
  });

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;

    return NominatimResult(
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      displayName: json['display_name'] ?? '',
      city: address?['city'],
      town: address?['town'],
      suburb: address?['suburb'],
      neighbourhood: address?['neighbourhood'],
      region: address?['region'] ?? address?['state'],
      country: address?['country'],
      countryCode: address?['country_code'],
      postcode: address?['postcode'],
      type: json['type'] ?? 'unknown',
      placeId: json['place_id']?.toString(),
    );
  }

  /// Get the best available city/town name
  String get cityName {
    return city ?? town ?? suburb ?? neighbourhood ?? region ?? 'Unknown';
  }

  /// Get a short, user-friendly address
  String get shortAddress {
    final parts = <String>[];

    if (suburb != null && suburb!.isNotEmpty) parts.add(suburb!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (town != null && town!.isNotEmpty && city == null) parts.add(town!);
    if (region != null && region!.isNotEmpty) parts.add(region!);

    return parts.isEmpty ? displayName : parts.join(', ');
  }

  @override
  String toString() {
    return 'NominatimResult(city: $cityName, lat: $latitude, lon: $longitude)';
  }
}
