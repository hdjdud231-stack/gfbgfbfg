import "dart:async";

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:logger/logger.dart";
import "package:pretty_dio_logger/pretty_dio_logger.dart";
import "package:index/models/media_stream.dart";
import "package:index/models/stream_extractor_options.dart";
import "package:index/services/stream_extractor_service/extractors/base_stream_extractor.dart";

class SuperEmbedExtractor implements BaseStreamExtractor {
  SuperEmbedExtractor() {
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

  final String _providerKey = "superEmbed";
  final String _baseUrl = "https://multiembed.mov/?video_id=";
  final String _vipBaseUrl = "https://vidsrc.xyz/embed/movie/";

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
        'Referer': 'https://multiembed.mov/',
      },
    ),
  );
  final Logger _logger = Logger();

  String _buildStreamUrl(StreamExtractorOptions options, {bool useVip = true}) {
    String tmdbId = options.tmdbId.toString();
    
    if (useVip) {
      // Use vidsrc.xyz for better quality
      if (options.season != null && options.episode != null) {
        // TV Show format: https://vidsrc.xyz/embed/tv/{tmdb_id}/{season}/{episode}
        return "${_vipBaseUrl.replaceAll('/movie/', '/tv/')}$tmdbId/${options.season}/${options.episode}";
      } else {
        // Movie format: https://vidsrc.xyz/embed/movie/{tmdb_id}
        return "$_vipBaseUrl$tmdbId";
      }
    } else {
      // Use multiembed.mov as fallback
      String url = "$_baseUrl$tmdbId&tmdb=1";
      
      // Add season and episode for TV shows
      if (options.season != null && options.episode != null) {
        url += "&s=${options.season}&e=${options.episode}";
      }
      
      return url;
    }
  }

  Future<bool> _checkVipAvailability(StreamExtractorOptions options) async {
    // Always try VIP first (vidsrc.xyz is generally more reliable)
    return true;
  }

  @override
  Future<MediaStream?> getStream(StreamExtractorOptions options) async {
    try {
      _logger.i("Attempting to get stream from SuperEmbed for TMDB ID: ${options.tmdbId}");
      
      // First try VIP player (better quality, fewer ads)
      bool vipAvailable = await _checkVipAvailability(options);
      
      String streamUrl;
      if (vipAvailable) {
        streamUrl = _buildStreamUrl(options, useVip: true);
        _logger.i("Using VIP player for better quality");
      } else {
        streamUrl = _buildStreamUrl(options, useVip: false);
        _logger.i("VIP not available, using standard player");
      }

      _logger.i("SuperEmbed stream URL: $streamUrl");

      // Return the stream URL that can be used in an iframe or webview
      return MediaStream(
        url: streamUrl,
        headers: <String, String>{
          "Referer": vipAvailable ? "https://vidsrc.xyz/" : "https://multiembed.mov/",
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        },
      );
    } catch (e, s) {
      _logger.e("Error in SuperEmbedExtractor", error: e, stackTrace: s);
    }

    return null;
  }
}