import "package:hive_flutter/hive_flutter.dart";
import "package:index/models/watch_progress.dart";

class RecentlyWatchedService {
  factory RecentlyWatchedService() => _instance;
  RecentlyWatchedService._internal();

  static final RecentlyWatchedService _instance = RecentlyWatchedService._internal();
  static const String _watchProgressBoxName = 'watch_progress';
  
  Box<WatchProgress>? _watchProgressBox;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WatchProgressAdapter());
    }
    _watchProgressBox = await Hive.openBox<WatchProgress>(_watchProgressBoxName);
  }

  Box<WatchProgress> get _box {
    if (_watchProgressBox == null || !_watchProgressBox!.isOpen) {
      throw Exception('Watch progress box is not initialized');
    }
    return _watchProgressBox!;
  }

  Future<List<WatchProgress>> getRecentlyWatched() async {
    try {
      return _box.values.toList()
        ..sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
    } catch (e) {
      return [];
    }
  }

  Future<List<WatchProgress>> getMovies() async {
    try {
      return _box.values
          .where((item) => item.mediaType == 'movie')
          .toList()
        ..sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
    } catch (e) {
      return [];
    }
  }

  Future<List<WatchProgress>> getTvShows() async {
    try {
      return _box.values
          .where((item) => item.mediaType == 'tv')
          .toList()
        ..sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
    } catch (e) {
      return [];
    }
  }

  int getMovieProgress(int movieId) {
    try {
      final key = 'movie_$movieId';
      final progress = _box.get(key);
      return progress?.position ?? 0;
    } catch (e) {
      return 0;
    }
  }

  int getEpisodeProgress(int tvShowId, int seasonNumber, int episodeNumber) {
    try {
      final key = 'tv_${tvShowId}_${seasonNumber}_$episodeNumber';
      final progress = _box.get(key);
      return progress?.position ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> updateMovieProgress(int movieId, String title, String posterPath, int position, int duration) async {
    try {
      final key = 'movie_$movieId';
      final progress = WatchProgress(
        id: movieId,
        title: title,
        posterPath: posterPath,
        mediaType: 'movie',
        position: position,
        duration: duration,
        lastWatched: DateTime.now(),
      );
      await _box.put(key, progress);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> updateEpisodeProgress(int tvShowId, String title, String posterPath, int seasonNumber, int episodeNumber, int position, int duration) async {
    try {
      final key = 'tv_${tvShowId}_${seasonNumber}_$episodeNumber';
      final progress = WatchProgress(
        id: tvShowId,
        title: title,
        posterPath: posterPath,
        mediaType: 'tv',
        position: position,
        duration: duration,
        lastWatched: DateTime.now(),
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );
      await _box.put(key, progress);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> removeMovie(int movieId) async {
    try {
      final key = 'movie_$movieId';
      await _box.delete(key);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> removeEpisode(int tvShowId, int seasonNumber, int episodeNumber) async {
    try {
      final key = 'tv_${tvShowId}_${seasonNumber}_$episodeNumber';
      await _box.delete(key);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> removeTvShow(int tvShowId) async {
    try {
      final keys = _box.keys.where((key) => key.toString().startsWith('tv_${tvShowId}_')).toList();
      for (final key in keys) {
        await _box.delete(key);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> removeEpisodeProgress(int tvShowId, int seasonId, int episodeId) async {
    try {
      final key = 'tv_${tvShowId}_${seasonId}_$episodeId';
      await _box.delete(key);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> hideTvShow(int tvShowId) async {
    // For now, same as remove
    await removeTvShow(tvShowId);
  }

  // Methods for compatibility with old API
  int getMovieProgressWithState(int movieId, dynamic recentlyWatched) {
    return getMovieProgress(movieId);
  }

  int getEpisodeProgressWithState(int tvShowId, int seasonId, int episodeId, dynamic recentlyWatched) {
    return getEpisodeProgress(tvShowId, seasonId, episodeId);
  }
}