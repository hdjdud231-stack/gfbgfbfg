import "package:hive_flutter/hive_flutter.dart";
import "package:index/models/favorite_item.dart";

class FavoritesService {
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  static final FavoritesService _instance = FavoritesService._internal();
  static const String _favoritesBoxName = 'favorites';
  
  Box<FavoriteItem>? _favoritesBox;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FavoriteItemAdapter());
    }
    _favoritesBox = await Hive.openBox<FavoriteItem>(_favoritesBoxName);
  }

  Box<FavoriteItem> get _box {
    if (_favoritesBox == null || !_favoritesBox!.isOpen) {
      throw Exception('Favorites box is not initialized');
    }
    return _favoritesBox!;
  }

  Future<List<FavoriteItem>> getFavorites() async {
    try {
      return _box.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<FavoriteItem>> getMovies() async {
    try {
      return _box.values.where((item) => item.mediaType == 'movie').toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<FavoriteItem>> getTvShows() async {
    try {
      return _box.values.where((item) => item.mediaType == 'tv').toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addFavorite(FavoriteItem item) async {
    try {
      final key = '${item.mediaType}_${item.id}';
      await _box.put(key, item);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> addMovie(int movieId, String title, String posterPath) async {
    final item = FavoriteItem(
      id: movieId,
      title: title,
      posterPath: posterPath,
      mediaType: 'movie',
      addedAt: DateTime.now(),
    );
    await addFavorite(item);
  }

  Future<void> addTvShow(int tvShowId, String title, String posterPath) async {
    final item = FavoriteItem(
      id: tvShowId,
      title: title,
      posterPath: posterPath,
      mediaType: 'tv',
      addedAt: DateTime.now(),
    );
    await addFavorite(item);
  }

  Future<void> removeFavorite(String mediaType, int id) async {
    try {
      final key = '${mediaType}_$id';
      await _box.delete(key);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> removeMovie(int movieId) async {
    await removeFavorite('movie', movieId);
  }

  Future<void> removeTvShow(int tvShowId) async {
    await removeFavorite('tv', tvShowId);
  }

  bool isFavorite(String mediaType, int id) {
    try {
      final key = '${mediaType}_$id';
      return _box.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e) {
      // Handle error silently
    }
  }
}