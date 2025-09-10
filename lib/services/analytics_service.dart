import 'package:amplitude_flutter/amplitude.dart';
import 'package:logger/logger.dart';

class AnalyticsService {
  static const String _apiKey = 'd378fab17e2b0902d1c733914afe0437';
  
  final Logger _logger = Logger();
  late Amplitude _amplitude;

  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Future<void> init() async {
    try {
      _amplitude = Amplitude.getInstance(instanceName: "index_app");
      await _amplitude.init(_apiKey);
      
      // Set user properties
      await _amplitude.setUserProperties({
        'platform': 'flutter',
        'app_name': 'Index',
        'app_version': '1.0.0',
      });
      
      _logger.i('Analytics Service initialized');
    } catch (e, s) {
      _logger.e('Failed to initialize Analytics Service', error: e, stackTrace: s);
    }
  }

  // Screen tracking
  Future<void> trackScreenView(String screenName) async {
    try {
      await _amplitude.logEvent('screen_view', eventProperties: {
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track screen view: $e');
    }
  }

  // App lifecycle events
  Future<void> trackAppStart() async {
    try {
      await _amplitude.logEvent('app_start', eventProperties: {
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track app start: $e');
    }
  }

  Future<void> trackAppBackground() async {
    try {
      await _amplitude.logEvent('app_background', eventProperties: {
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track app background: $e');
    }
  }

  Future<void> trackAppForeground() async {
    try {
      await _amplitude.logEvent('app_foreground', eventProperties: {
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track app foreground: $e');
    }
  }

  // Content interaction events
  Future<void> trackMovieView(String movieTitle, String movieId) async {
    try {
      await _amplitude.logEvent('movie_view', eventProperties: {
        'movie_title': movieTitle,
        'movie_id': movieId,
        'content_type': 'movie',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track movie view: $e');
    }
  }

  Future<void> trackTvShowView(String showTitle, String showId) async {
    try {
      await _amplitude.logEvent('tv_show_view', eventProperties: {
        'show_title': showTitle,
        'show_id': showId,
        'content_type': 'tv_show',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track TV show view: $e');
    }
  }

  Future<void> trackAnimeView(String animeTitle, int animeId) async {
    try {
      await _amplitude.logEvent('anime_view', eventProperties: {
        'anime_title': animeTitle,
        'anime_id': animeId,
        'content_type': 'anime',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track anime view: $e');
    }
  }

  Future<void> trackChannelView(String channelName, String channelId) async {
    try {
      await _amplitude.logEvent('tv_channel_view', eventProperties: {
        'channel_name': channelName,
        'channel_id': channelId,
        'content_type': 'tv_channel',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track channel view: $e');
    }
  }

  // Player events
  Future<void> trackVideoPlay(String contentTitle, String contentType, String server) async {
    try {
      await _amplitude.logEvent('video_play', eventProperties: {
        'content_title': contentTitle,
        'content_type': contentType,
        'server': server,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track video play: $e');
    }
  }

  Future<void> trackVideoPause(String contentTitle, String contentType, int watchTime) async {
    try {
      await _amplitude.logEvent('video_pause', eventProperties: {
        'content_title': contentTitle,
        'content_type': contentType,
        'watch_time_seconds': watchTime,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track video pause: $e');
    }
  }

  Future<void> trackVideoComplete(String contentTitle, String contentType, int totalWatchTime) async {
    try {
      await _amplitude.logEvent('video_complete', eventProperties: {
        'content_title': contentTitle,
        'content_type': contentType,
        'total_watch_time_seconds': totalWatchTime,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track video complete: $e');
    }
  }

  // Search events
  Future<void> trackSearch(String query, String searchType, int resultsCount) async {
    try {
      await _amplitude.logEvent('search', eventProperties: {
        'query': query,
        'search_type': searchType,
        'results_count': resultsCount,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track search: $e');
    }
  }

  // Favorites events
  Future<void> trackAddToFavorites(String contentTitle, String contentType) async {
    try {
      await _amplitude.logEvent('add_to_favorites', eventProperties: {
        'content_title': contentTitle,
        'content_type': contentType,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track add to favorites: $e');
    }
  }

  Future<void> trackRemoveFromFavorites(String contentTitle, String contentType) async {
    try {
      await _amplitude.logEvent('remove_from_favorites', eventProperties: {
        'content_title': contentTitle,
        'content_type': contentType,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track remove from favorites: $e');
    }
  }

  // Settings events
  Future<void> trackSettingsChange(String settingName, dynamic oldValue, dynamic newValue) async {
    try {
      await _amplitude.logEvent('settings_change', eventProperties: {
        'setting_name': settingName,
        'old_value': oldValue.toString(),
        'new_value': newValue.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track settings change: $e');
    }
  }

  // Error events
  Future<void> trackError(String errorType, String errorMessage, String? context) async {
    try {
      await _amplitude.logEvent('error', eventProperties: {
        'error_type': errorType,
        'error_message': errorMessage,
        'context': context ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to track error: $e');
    }
  }

  // Custom events
  Future<void> trackCustomEvent(String eventName, Map<String, dynamic>? properties) async {
    try {
      final eventProperties = properties ?? {};
      eventProperties['timestamp'] = DateTime.now().toIso8601String();
      
      await _amplitude.logEvent(eventName, eventProperties: eventProperties);
    } catch (e) {
      _logger.w('Failed to track custom event: $e');
    }
  }

  // User identification
  Future<void> setUserId(String userId) async {
    try {
      await _amplitude.setUserId(userId);
    } catch (e) {
      _logger.w('Failed to set user ID: $e');
    }
  }

  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    try {
      await _amplitude.setUserProperties(properties);
    } catch (e) {
      _logger.w('Failed to set user properties: $e');
    }
  }

  // Session management
  Future<void> startSession() async {
    try {
      await _amplitude.logEvent('session_start', eventProperties: {
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to start session: $e');
    }
  }

  Future<void> endSession() async {
    try {
      await _amplitude.logEvent('session_end', eventProperties: {
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.w('Failed to end session: $e');
    }
  }
}