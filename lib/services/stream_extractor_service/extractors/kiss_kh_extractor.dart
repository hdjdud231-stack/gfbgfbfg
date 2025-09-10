import "dart:async";

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:logger/logger.dart";
import "package:pretty_dio_logger/pretty_dio_logger.dart";
import "package:index/models/media_stream.dart";
import "package:index/models/stream_extractor_options.dart";
import "package:index/services/stream_extractor_service/extractors/base_stream_extractor.dart";
import "package:index/services/stream_extractor_service/extractors/streaming_server_base_url_extractor.dart";

class KissKhExtractor implements BaseStreamExtractor {
  KissKhExtractor() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
        enabled: kDebugMode,
      ),
    );
  }

  final String _providerKey = "kissKh";

  final StreamingServerBaseUrlExtractor _streamingServerBaseUrlExtractor = StreamingServerBaseUrlExtractor();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 45),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.9,ar;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
      },
    ),
  );
  final Logger _logger = Logger();

  Future<String?> _findExternalId(String baseUrl, StreamExtractorOptions options) async {
    String searchQuery = options.title;
    String searchUrl = "$baseUrl/api/DramaList/Search?q=$searchQuery&type=0";

    final Response<dynamic> response = await _dio.get(searchUrl);
    final List<Map<String, dynamic>> searchResults = (response.data as List<dynamic>).cast<Map<String, dynamic>>();

    if (searchResults.isEmpty) {
      throw Exception("No search results found for $searchQuery");
    }

    List<String> referenceTitles = <String>[];
    if (options.season != null && options.episode != null) {
      referenceTitles.add("${options.title} - Season ${options.season}");
    } else {
      referenceTitles.add("${options.title} (${options.movieReleaseYear})");
      referenceTitles.add(options.title);
    }

    for (String title in referenceTitles) {
      try {
        Map<String, dynamic> result = searchResults.firstWhere((Map<String, dynamic> result) => result["title"] == title);
        int? id = result["id"];
        return id?.toString();
      } catch (_) {}
    }

    // Fallback
    Map<String, dynamic> result = searchResults.firstWhere((Map<String, dynamic> result) => result["title"].contains(options.title));
    int? id = result["id"];
    return id?.toString();
  }

  Future<String?> _findEpisodeId(String baseUrl, String externalId, StreamExtractorOptions options) async {
    String url = "$baseUrl/api/DramaList/Drama/$externalId?isq=false";

    final Response<dynamic> response = await _dio.get(url);
    final Map<String, dynamic> results = response.data as Map<String, dynamic>;

    if (results.isEmpty) {
      throw Exception("Failed to retrieve info for $externalId");
    }

    List<Map<String, dynamic>>? episodes = (results["episodes"] as List<dynamic>).cast<Map<String, dynamic>>();

    if (episodes.isEmpty) {
      throw Exception("No episodes found for $externalId");
    }

    try {
      Map<String, dynamic> episode = episodes.firstWhere((Map<String, dynamic> episode) => episode["number"] == (options.episode ?? 1));
      int? id = episode["id"];
      return id?.toString();
    } catch(e, s) {
      _logger.e("Error finding episode ID for external ID: $externalId", error: e, stackTrace: s);
    }

    return null;
  }

  @override
  Future<MediaStream?> getStream(StreamExtractorOptions options) async {
    try {
      final String? baseUrl = await _streamingServerBaseUrlExtractor.getBaseUrl(_providerKey);
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("Failed to get base URL for $_providerKey");
      }

      final String? externalId = await _findExternalId(baseUrl, options);

      if (externalId == null || externalId.isEmpty) {
        throw Exception("Failed to find external ID for $_providerKey");
      }

      final String? episodeId = await _findEpisodeId(baseUrl, externalId, options);

      if (episodeId == null || episodeId.isEmpty) {
        throw Exception("Failed to extract episode ID for $_providerKey with external ID: $externalId");
      }

      final String streamUrl = "https://adorable-salamander-ecbb21.netlify.app/api/kisskh/video?id=$episodeId";
      final Response<dynamic> response = await _dio.get(streamUrl);

      final String? videoUrl = response.data?["source"]?["Video"] as String?;
      if (videoUrl == null || videoUrl.isEmpty) {
        throw Exception("No video URL found for $_providerKey id=$episodeId");
      }

      return MediaStream(
        url: videoUrl,
        headers: <String, String>{
          "Referer": baseUrl,
        },
      );
    } catch (e, s) {
      _logger.e("Error in KissKhExtractor", error: e, stackTrace: s);
    }

    return null;
  }
}
