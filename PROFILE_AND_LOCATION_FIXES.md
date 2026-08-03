# Profile Edit & Location Search Fixes

**Date:** June 3, 2026
**Issues:** Profile edit white screen error + Location search not working properly

---

## Issue 1: Profile Edit White Screen Error ❌

### Error Message:
```
PostgrestException(message: relation "post_gifts" does not exist, code: 42P01)
Context: Get Gift Summary
```

### Root Cause:
The `post_gifts` table doesn't exist in the database, but the app tries to query it when loading profile-related data (likely in a feed/gifts widget).

### Fix Applied: ✅
**File Created:** [`supabase/migrations/20260603_create_post_gifts_table.sql`](supabase/migrations/20260603_create_post_gifts_table.sql)

Created the missing `post_gifts` table with:
- Basic gift tracking structure
- Indexes for performance
- `get_post_gift_summary()` function
- `process_post_gift()` placeholder function
- Proper permissions

**What This Fixes:**
- ✅ No more PostgrestException errors
- ✅ Profile edit screen works properly
- ✅ Can navigate back from profile edit without white screen
- ✅ Feed/gift features won't crash the app

### Deployment Steps:
```bash
# Execute the migration in Supabase
cd supabase
supabase db push

# OR manually in Supabase Dashboard SQL Editor
# Copy and execute: supabase/migrations/20260603_create_post_gifts_table.sql
```

---

## Issue 2: Location Search Not Working Properly ❌

### Current Implementation:
**File:** [`lib/features/location/screens/select_location_screen.dart`](lib/features/location/screens/select_location_screen.dart)

```dart
// Current code uses basic geocoding
final locations = await locationFromAddress(query);
```

**Problems:**
1. ❌ Only returns a few results
2. ❌ No autocomplete/suggestions
3. ❌ Poor search accuracy
4. ❌ No detailed place information
5. ❌ Doesn't work like Google Maps/industry standard

### Solution: Google Places API Integration

To make location search work like "industry standards" (Google Maps, Uber, etc.), you need to integrate **Google Places API**.

#### Option 1: Google Places API (Recommended) 🌟

**Pros:**
- ✅ Industry-standard autocomplete
- ✅ Detailed place information
- ✅ Works globally
- ✅ Rich search results
- ✅ Same as Google Maps

**Cons:**
- 💰 Requires Google Cloud billing (has free tier)
- 🔑 Requires API key

**Cost:** FREE for first $200/month (covers ~40,000 searches)

#### Option 2: Mapbox Search API

**Pros:**
- ✅ Good autocomplete
- ✅ Global coverage
- ✅ Generous free tier

**Cons:**
- 🔑 Requires API key
- 💰 Paid after free tier

**Cost:** FREE for first 100,000 requests/month

#### Option 3: OpenStreetMap Nominatim (Free)

**Pros:**
- ✅ Completely free
- ✅ No API key needed
- ✅ Global coverage

**Cons:**
- ❌ Rate limited (1 request/second)
- ❌ Less accurate than Google
- ❌ Slower response

---

## Recommended Fix: Google Places API

### Step 1: Get Google Places API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Places API**
4. Create credentials → API Key
5. Restrict the API key:
   - **Application restrictions:** Android apps / iOS apps
   - **API restrictions:** Places API only

### Step 2: Add Package

Add to `pubspec.yaml`:
```yaml
dependencies:
  google_places_flutter: ^3.0.0
  # OR
  flutter_google_places_hoc081098: ^2.0.0
```

### Step 3: Update Location Search Screen

**File to modify:** `lib/features/location/screens/select_location_screen.dart`

Replace the `_searchLocation` method:

```dart
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  // Your existing code...

  // Add Google Places API key
  static const String _googleApiKey = 'YOUR_API_KEY_HERE'; // TODO: Move to .env file

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use Google Places Autocomplete
      final predictions = await PlacesAutocomplete.show(
        context: context,
        apiKey: _googleApiKey,
        mode: Mode.overlay,
        language: 'en',
        components: [Component(Component.country, 'gh')], // Restrict to Ghana
        types: [], // All types
        strictbounds: false,
      );

      if (predictions != null) {
        // Get place details
        final placeDetails = await GoogleMapsPlaces(apiKey: _googleApiKey)
            .getDetailsByPlaceId(predictions.placeId!);

        if (placeDetails.status == 'OK') {
          final result = placeDetails.result;
          final location = LocationData(
            latitude: result.geometry!.location.lat,
            longitude: result.geometry!.location.lng,
            address: result.formattedAddress ?? '',
            city: _extractCity(result.addressComponents),
            country: 'Ghana',
          );

          _selectLocation(location);
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching location: $e')),
        );
      }
    }
  }

  String _extractCity(List<AddressComponent>? components) {
    if (components == null) return '';

    for (var component in components) {
      if (component.types.contains('locality')) {
        return component.longName;
      }
    }
    return '';
  }
}
```

### Step 4: Alternative - Simple Autocomplete Widget

For a simpler implementation, use the widget directly:

```dart
TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: 'Search location',
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (value) {
    GooglePlaceAutoCompleteTextField(
      textEditingController: _searchController,
      googleAPIKey: _googleApiKey,
      inputDecoration: InputDecoration(
        hintText: 'Search location',
        prefixIcon: Icon(Icons.search),
      ),
      debounceTime: 400,
      countries: ['gh'], // Restrict to Ghana
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (Prediction prediction) {
        // Handle place selection
        final location = LocationData(
          latitude: double.parse(prediction.lat!),
          longitude: double.parse(prediction.lng!),
          address: prediction.description ?? '',
          city: '', // Extract from place details
          country: 'Ghana',
        );
        _selectLocation(location);
      },
      itemClick: (Prediction prediction) {
        _searchController.text = prediction.description ?? '';
      },
    );
  },
)
```

---

## Alternative: Free OpenStreetMap Solution

If you don't want to use Google Places API, here's a free alternative:

### Add Package:
```yaml
dependencies:
  dio: ^5.0.0  # For HTTP requests
```

### Create Nominatim Service:

**File:** `lib/core/services/nominatim_service.dart`

```dart
import 'package:dio/dio.dart';

class NominatimService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://nominatim.openstreetmap.org',
    headers: {
      'User-Agent': 'APlayApp/1.0', // Required by Nominatim
    },
  ));

  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    try {
      final response = await _dio.get('/search', queryParameters: {
        'q': query,
        'format': 'json',
        'limit': 10,
        'countrycodes': 'gh', // Restrict to Ghana
        'addressdetails': 1,
      });

      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to search location: $e');
    }
  }

  Future<Map<String, dynamic>> reverseGeocode(double lat, double lon) async {
    try {
      final response = await _dio.get('/reverse', queryParameters: {
        'lat': lat,
        'lon': lon,
        'format': 'json',
        'addressdetails': 1,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to reverse geocode: $e');
    }
  }
}
```

### Update Search Screen:

```dart
Future<void> _searchLocation(String query) async {
  if (query.isEmpty) {
    setState(() => _searchResults = []);
    return;
  }

  setState(() => _isLoading = true);

  try {
    final nominatim = NominatimService();
    final results = await nominatim.searchLocation(query);

    _searchResults = results.map((result) {
      return LocationData(
        latitude: double.parse(result['lat']),
        longitude: double.parse(result['lon']),
        address: result['display_name'] ?? '',
        city: result['address']?['city'] ?? result['address']?['town'] ?? '',
        country: result['address']?['country'] ?? 'Ghana',
      );
    }).toList();

    setState(() => _isLoading = false);
  } catch (e) {
    setState(() {
      _isLoading = false;
      _searchResults = [];
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching location: $e')),
      );
    }
  }
}
```

---

## Comparison

| Feature | Current (Geocoding) | Google Places | Nominatim (OSM) |
|---------|---------------------|---------------|-----------------|
| **Autocomplete** | ❌ No | ✅ Yes | ✅ Yes |
| **Search Quality** | ⭐⭐ Poor | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐ Good |
| **Speed** | ⚡ Fast | ⚡⚡⚡ Very Fast | ⚡⚡ Medium |
| **Cost** | 🆓 Free | 💰 $200 free/month | 🆓 Free |
| **Rate Limits** | None | High | 1 req/sec |
| **Setup** | ✅ Easy | 🔧 Medium | ✅ Easy |
| **API Key** | ❌ Not needed | ✅ Required | ❌ Not needed |

---

## Recommendation

### For Production (Best UX):
✅ **Use Google Places API**
- Industry standard
- Best search results
- Free tier covers most apps
- Users expect Google Maps-like experience

### For MVP/Testing:
✅ **Use OpenStreetMap Nominatim**
- Completely free
- No API key required
- Good enough for testing
- Easy to implement

### For Budget-Conscious:
✅ **Use Mapbox Search API**
- Better than OSM
- Generous free tier (100k requests/month)
- Good alternative to Google

---

## Testing Checklist

### After Fixing Profile Edit:
- [ ] Navigate to Profile screen
- [ ] Tap "Edit Profile"
- [ ] Make changes (or don't)
- [ ] Tap back button
- [ ] **Expected:** Returns to profile screen
- [ ] **NOT:** White screen error

### After Implementing Location Search:
- [ ] Open location search screen
- [ ] Type "Accra"
- [ ] **Expected:** Multiple results with addresses
- [ ] Select a location
- [ ] **Expected:** Location saved
- [ ] Search for specific place like "Osu Oxford Street"
- [ ] **Expected:** Accurate results

---

## Deployment Priority

### Critical (Do First):
1. ✅ **Execute post_gifts migration** - Fixes profile edit crash
   ```bash
   supabase db push
   ```

### Important (Do Soon):
2. 🔄 **Improve location search** - Better UX
   - Choose: Google Places OR Nominatim
   - Implement autocomplete
   - Test thoroughly

---

## Files Summary

### Created:
- `supabase/migrations/20260603_create_post_gifts_table.sql` - Fixes profile edit error
- `PROFILE_AND_LOCATION_FIXES.md` - This document

### Need to Modify (for location):
- `lib/features/location/screens/select_location_screen.dart` - Add Google Places or Nominatim
- `pubspec.yaml` - Add location search package

---

## Quick Start

### Fix Profile Edit NOW (5 minutes):
```bash
# 1. Execute migration
cd supabase
supabase db push

# 2. Test
flutter run
# Navigate to profile edit → back
# Should work without white screen
```

### Improve Location Search (30-60 minutes):

**Option A: Google Places (Best)**
```bash
# 1. Get API key from Google Cloud Console
# 2. Add to pubspec.yaml: google_places_flutter: ^3.0.0
# 3. flutter pub get
# 4. Update select_location_screen.dart
# 5. Test
```

**Option B: Nominatim (Free)**
```bash
# 1. Add to pubspec.yaml: dio: ^5.0.0
# 2. flutter pub get
# 3. Create nominatim_service.dart
# 4. Update select_location_screen.dart
# 5. Test
```

---

**Status:**
- ✅ Profile Edit Fix: Ready (migration created)
- 🔄 Location Search: Implementation guide provided
- ⏳ Waiting for: Database migration execution + location API choice

🎯 **Next Step:** Execute the post_gifts migration to fix profile edit!
