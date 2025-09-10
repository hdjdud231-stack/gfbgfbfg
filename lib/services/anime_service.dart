import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:index/models/anime.dart';
import 'package:index/models/anime_episode.dart';

class AnimeService {
  static const String _boxName = 'anime_cache';
  static const String _episodesBoxName = 'anime_episodes_cache';
  static const String _anilistApiUrl = 'https://graphql.anilist.co';
  static const String _consumetApiUrl = 'https://api.consumet.org/anime/gogoanime';
  
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  late Box<Anime> _animeBox;
  late Box<AnimeEpisode> _episodesBox;

  static final AnimeService _instance = AnimeService._internal();
  factory AnimeService() => _instance;
  AnimeService._internal();

  Future<void> init() async {
    try {
      Hive.registerAdapter(AnimeAdapter());
      Hive.registerAdapter(AnimeEpisodeAdapter());
      Hive.registerAdapter(AnimeStreamSourceAdapter());
      
      _animeBox = await Hive.openBox<Anime>(_boxName);
      _episodesBox = await Hive.openBox<AnimeEpisode>(_episodesBoxName);
      
      _logger.i('Anime Service initialized');
    } catch (e, s) {
      _logger.e('Failed to initialize Anime Service', error: e, stackTrace: s);
    }
  }

  Future<List<Anime>> getTrendingAnime({int page = 1, int perPage = 20}) async {
    try {
      final query = '''
        query (\$page: Int, \$perPage: Int) {
          Page(page: \$page, perPage: \$perPage) {
            media(type: ANIME, sort: TRENDING_DESC) {
              id
              title {
                romaji
                english
                native
              }
              description
              coverImage {
                large
                medium
              }
              bannerImage
              genres
              averageScore
              episodes
              status
              format
              seasonYear
              season
              duration
              trailer {
                id
              }
            }
          }
        }
      ''';

      final response = await _dio.post(
        _anilistApiUrl,
        data: {
          'query': query,
          'variables': {
            'page': page,
            'perPage': perPage,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['Page']['media'] as List;
        final animeList = data.map((json) => Anime.fromAnilistJson(json)).toList();
        
        // Cache anime
        for (final anime in animeList) {
          await _animeBox.put(anime.id, anime);
        }
        
        return animeList;
      }
      
      return [];
    } catch (e, s) {
      _logger.e('Failed to get trending anime', error: e, stackTrace: s);
      return _getCachedAnime();
    }
  }

  Future<List<Anime>> getPopularAnime({int page = 1, int perPage = 20}) async {
    try {
      final query = '''
        query (\$page: Int, \$perPage: Int) {
          Page(page: \$page, perPage: \$perPage) {
            media(type: ANIME, sort: POPULARITY_DESC) {
              id
              title {
                romaji
                english
                native
              }
              description
              coverImage {
                large
                medium
              }
              bannerImage
              genres
              averageScore
              episodes
              status
              format
              seasonYear
              season
              duration
              trailer {
                id
              }
            }
          }
        }
      ''';

      final response = await _dio.post(
        _anilistApiUrl,
        data: {
          'query': query,
          'variables': {
            'page': page,
            'perPage': perPage,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['Page']['media'] as List;
        return data.map((json) => Anime.fromAnilistJson(json)).toList();
      }
      
      return [];
    } catch (e, s) {
      _logger.e('Failed to get popular anime', error: e, stackTrace: s);
      return [];
    }
  }

  Future<List<Anime>> getTopRatedAnime({int page = 1, int perPage = 20}) async {
    try {
      final query = '''
        query (\$page: Int, \$perPage: Int) {
          Page(page: \$page, perPage: \$perPage) {
            media(type: ANIME, sort: SCORE_DESC) {
              id
              title {
                romaji
                english
                native
              }
              description
              coverImage {
                large
                medium
              }
              bannerImage
              genres
              averageScore
              episodes
              status
              format
              seasonYear
              season
              duration
              trailer {
                id
              }
            }
          }
        }
      ''';

      final response = await _dio.post(
        _anilistApiUrl,
        data: {
          'query': query,
          'variables': {
            'page': page,
            'perPage': perPage,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['Page']['media'] as List;
        return data.map((json) => Anime.fromAnilistJson(json)).toList();
      }
      
      return [];
    } catch (e, s) {
      _logger.e('Failed to get top rated anime', error: e, stackTrace: s);
      return [];
    }
  }

  Future<List<Anime>> searchAnime(String query, {int page = 1, int perPage = 20}) async {
    try {
      final searchQuery = '''
        query (\$search: String, \$page: Int, \$perPage: Int) {
          Page(page: \$page, perPage: \$perPage) {
            media(type: ANIME, search: \$search) {
              id
              title {
                romaji
                english
                native
              }
              description
              coverImage {
                large
                medium
              }
              bannerImage
              genres
              averageScore
              episodes
              status
              format
              seasonYear
              season
              duration
              trailer {
                id
              }
            }
          }
        }
      ''';

      final response = await _dio.post(
        _anilistApiUrl,
        data: {
          'query': searchQuery,
          'variables': {
            'search': query,
            'page': page,
            'perPage': perPage,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['Page']['media'] as List;
        return data.map((json) => Anime.fromAnilistJson(json)).toList();
      }
      
      return [];
    } catch (e, s) {
      _logger.e('Failed to search anime', error: e, stackTrace: s);
      return [];
    }
  }

  Future<Anime?> getAnimeDetails(int id) async {
    try {
      // Check cache first
      final cachedAnime = _animeBox.get(id);
      if (cachedAnime != null) {
        return cachedAnime;
      }

      final query = '''
        query (\$id: Int) {
          Media(id: \$id, type: ANIME) {
            id
            title {
              romaji
              english
              native
            }
            description
            coverImage {
              large
              medium
            }
            bannerImage
            genres
            averageScore
            episodes
            status
            format
            seasonYear
            season
            duration
            trailer {
              id
            }
          }
        }
      ''';

      final response = await _dio.post(
        _anilistApiUrl,
        data: {
          'query': query,
          'variables': {'id': id},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['Media'];
        final anime = Anime.fromAnilistJson(data);
        
        // Cache anime
        await _animeBox.put(anime.id, anime);
        
        return anime;
      }
      
      return null;
    } catch (e, s) {
      _logger.e('Failed to get anime details', error: e, stackTrace: s);
      return null;
    }
  }

  Future<List<AnimeEpisode>> getAnimeEpisodes(int animeId, String animeTitle) async {
    try {
      // Check cache first
      final cachedEpisodes = _episodesBox.values
          .where((episode) => episode.animeId == animeId)
          .toList();

      if (cachedEpisodes.isNotEmpty) {
        return cachedEpisodes;
      }

      // Search for anime on GogoAnime via Consumet API
      final searchResponse = await _dio.get(
        '$_consumetApiUrl/$animeTitle',
        queryParameters: {'page': 1},
      );

      if (searchResponse.statusCode == 200) {
        final searchResults = searchResponse.data['results'] as List;
        if (searchResults.isNotEmpty) {
          final animeInfo = searchResults.first;
          final animeInfoResponse = await _dio.get(
            '$_consumetApiUrl/info/${animeInfo['id']}',
          );

          if (animeInfoResponse.statusCode == 200) {
            final episodes = animeInfoResponse.data['episodes'] as List;
            final animeEpisodes = <AnimeEpisode>[];

            for (int i = 0; i < episodes.length; i++) {
              final episode = episodes[i];
              final animeEpisode = AnimeEpisode(
                id: episode['id'],
                animeId: animeId,
                episodeNumber: episode['number'] ?? i + 1,
                title: episode['title'] ?? 'Episode ${i + 1}',
                description: episode['description'],
                thumbnail: episode['image'],
              );

              animeEpisodes.add(animeEpisode);
              await _episodesBox.put(animeEpisode.id, animeEpisode);
            }

            return animeEpisodes;
          }
        }
      }

      return [];
    } catch (e, s) {
      _logger.e('Failed to get anime episodes', error: e, stackTrace: s);
      return [];
    }
  }

  Future<List<AnimeStreamSource>> getEpisodeStreamSources(String episodeId) async {
    try {
      final response = await _dio.get('$_consumetApiUrl/watch/$episodeId');

      if (response.statusCode == 200) {
        final sources = response.data['sources'] as List;
        return sources.map((source) => AnimeStreamSource(
          url: source['url'],
          quality: source['quality'] ?? 'default',
          server: 'GogoAnime',
          isM3U8: source['isM3U8'] ?? false,
        )).toList();
      }

      return [];
    } catch (e, s) {
      _logger.e('Failed to get episode stream sources', error: e, stackTrace: s);
      return [];
    }
  }

  List<Anime> _getCachedAnime() {
    return _animeBox.values.toList();
  }

  Future<void> clearCache() async {
    try {
      await _animeBox.clear();
      await _episodesBox.clear();
      _logger.i('Anime cache cleared');
    } catch (e, s) {
      _logger.e('Failed to clear anime cache', error: e, stackTrace: s);
    }
  }
}