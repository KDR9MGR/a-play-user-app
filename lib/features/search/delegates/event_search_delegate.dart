import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:a_play/features/booking/screens/event_details_screen.dart';
import 'package:a_play/features/home/providers/events_provider.dart';
import 'package:a_play/data/models/event_model.dart';


class EventSearchDelegate extends SearchDelegate<EventModel?> {
  final WidgetRef ref;
  final SharedPreferences prefs;
  Timer? _debounceTimer;
  final _recentSearchesKey = 'recent_searches';
  final _cacheTimeout = const Duration(minutes: 30);
  final Map<String, List<EventModel>> _searchCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  EventSearchDelegate({
    required this.ref,
    required this.prefs,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }
    return _buildSearchResults(context);
  }

  Widget _buildRecentSearches(BuildContext context) {
    final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    final theme = Theme.of(context);

    if (recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent searches',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: recentSearches.length,
      itemBuilder: (context, index) {
        final search = recentSearches[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(search),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _removeRecentSearch(search),
          ),
          onTap: () {
            query = search;
            showResults(context);
          },
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_debounceTimer?.isActive ?? false) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check cache first
    if (_hasValidCache(query)) {
      final cachedResults = _searchCache[query]!;
      return _buildResultsList(context, cachedResults);
    }

    return StreamBuilder<List<EventModel>>(
      stream: _performSearch(query),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data!;
        return _buildResultsList(context, results);
      },
    );
  }

  Widget _buildResultsList(BuildContext context, List<EventModel> events) {
    if (events.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: event.coverImage ?? '',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          title: Text(event.title),
          subtitle: Text(
            event.startDate.toString().split(' ')[0],
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          onTap: () {
            _addToRecentSearches(query);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsScreen(event: event),
              ),
            );
          },
        );
      },
    );
  }

  Stream<List<EventModel>> _performSearch(String query) {
    _debounceTimer?.cancel();

    return Stream.fromFuture(Future.delayed(const Duration(milliseconds: 500)))
        .asyncMap((_) async {
      final events = await ref.read(eventsProvider.future);
      final results = events.where((event) {
        final title = event.title.toLowerCase();
        final description = (event.description ?? '').toLowerCase();
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) || description.contains(searchQuery);
      }).toList();

      // Cache the results
      _searchCache[query] = results;
      _cacheTimestamps[query] = DateTime.now();

      return results;
    });
  }

  void _addToRecentSearches(String query) {
    if (query.isEmpty) return;

    final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    if (recentSearches.contains(query)) {
      recentSearches.remove(query);
    }
    recentSearches.insert(0, query);
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }
    prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  void _removeRecentSearch(String query) {
    final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    recentSearches.remove(query);
    prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  bool _hasValidCache(String query) {
    if (!_searchCache.containsKey(query)) return false;
    final timestamp = _cacheTimestamps[query];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheTimeout;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
} 