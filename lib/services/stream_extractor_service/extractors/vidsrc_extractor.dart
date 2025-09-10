import "dart:async";

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:logger/logger.dart";
import "package:pretty_dio_logger/pretty_dio_logger.dart";
import "package:index/models/media_stream.dart";
import "package:index/models/stream_extractor_options.dart";
import "package:index/services/stream_extractor_service/extractors/base_stream_extractor.dart";

class VidSrcExtractor implements BaseStreamExtractor {
  VidSrcExtractor() {
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

  final String _providerKey = "vidSrc";
  final String _baseUrl = "https://vidsrc.to/embed";

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
        'Referer': 'https://vidsrc.to/',
      },
    ),
  );
  final Logger _logger = Logger();

  String _buildStreamUrl(StreamExtractorOptions options) {
    String tmdbId = options.tmdbId.toString();
    
    if (options.season != null && options.episode != null) {
      // TV Show format: https://vidsrc.to/embed/tv/{tmdb_id}/{season}/{episode}
      return "$_baseUrl/tv/$tmdbId/${options.season}/${options.episode}";
    } else {
      // Movie format: https://vidsrc.to/embed/movie/{tmdb_id}
      return "$_baseUrl/movie/$tmdbId";
    }
  }

  @override
  Future<MediaStream?> getStream(StreamExtractorOptions options) async {
    try {
      _logger.i("Attempting to get stream from VidSrc for TMDB ID: ${options.tmdbId}");
      
      String streamUrl = _buildStreamUrl(options);
      _logger.i("VidSrc stream URL: $streamUrl");

      // Return the stream URL that can be used in an iframe or webview
      return MediaStream(
        url: streamUrl,
        headers: <String, String>{
          "Referer": "https://vidsrc.to/",
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        },
      );
    } catch (e, s) {
      _logger.e("Error in VidSrcExtractor", error: e, stackTrace: s);
    }

    return null;
  }
}