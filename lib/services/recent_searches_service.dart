import "package:shared_preferences/shared_preferences.dart";
import "package:index/enums/media_type.dart";

class RecentSearchesService {
  factory RecentSearchesService() => _instance;
  RecentSearchesService._internal();

  static final RecentSearchesService _instance = RecentSearchesService._internal();
  static const String _movieSearchesKey = 'recent_movie_searches';
  static const String _tvSearchesKey = 'recent_tv_searches';

  Future<List<String>> getRecentSearches(MediaType mediaType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = mediaType == MediaType.movies ? _movieSearchesKey : _tvSearchesKey;
      return prefs.getStringList(key) ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> add(MediaType mediaType, String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = mediaType == MediaType.movies ? _movieSearchesKey : _tvSearchesKey;
      final searches = await getRecentSearches(mediaType);

      // Remove duplicate entry
      if (searches.contains(query)) {
        searches.remove(query);
      }

      // Add to beginning
      searches.insert(0, query);

      // Limit to 20 recent searches
      if (searches.length > 20) {
        searches.removeRange(20, searches.length);
      }

      await prefs.setStringList(key, searches);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> remove(MediaType mediaType, String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = mediaType == MediaType.movies ? _movieSearchesKey : _tvSearchesKey;
      final searches = await getRecentSearches(mediaType);

      if (searches.contains(query)) {
        searches.remove(query);
        await prefs.setStringList(key, searches);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_movieSearchesKey);
      await prefs.remove(_tvSearchesKey);
    } catch (e) {
      // Handle error silently
    }
  }
}