import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:index/models/tv_channel.dart';

class IptvService {
  static const String _boxName = 'iptv_channels';
  static const String _githubBaseUrl = 'https://raw.githubusercontent.com/iptv-org/iptv/master/streams';
  
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  late Box<TvChannel> _channelsBox;

  static final IptvService _instance = IptvService._internal();
  factory IptvService() => _instance;
  IptvService._internal();

  Future<void> init() async {
    try {
      Hive.registerAdapter(TvChannelAdapter());
      _channelsBox = await Hive.openBox<TvChannel>(_boxName);
      _logger.i('IPTV Service initialized');
    } catch (e, s) {
      _logger.e('Failed to initialize IPTV Service', error: e, stackTrace: s);
    }
  }

  Future<List<TvChannel>> getChannelsByCountry(String countryCode) async {
    try {
      // Check cache first
      final cachedChannels = _channelsBox.values
          .where((channel) => channel.country?.toLowerCase() == countryCode.toLowerCase())
          .toList();

      if (cachedChannels.isNotEmpty) {
        return cachedChannels;
      }

      // Fetch from GitHub
      final url = '$_githubBaseUrl/${countryCode.toLowerCase()}.m3u';
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        final channels = _parseM3uContent(response.data, countryCode);
        
        // Cache channels
        for (final channel in channels) {
          await _channelsBox.put(channel.id, channel);
        }
        
        return channels;
      }
      
      return [];
    } catch (e, s) {
      _logger.e('Failed to get channels for country: $countryCode', error: e, stackTrace: s);
      return [];
    }
  }

  Future<List<TvChannel>> getAllChannels() async {
    try {
      final cachedChannels = _channelsBox.values.toList();
      if (cachedChannels.isNotEmpty) {
        return cachedChannels;
      }

      // Popular countries for Arabic content
      final arabicCountries = ['ar', 'sa', 'ae', 'eg', 'jo', 'lb', 'sy', 'iq', 'kw', 'qa', 'bh', 'om', 'ye', 'ps'];
      final allChannels = <TvChannel>[];

      for (final country in arabicCountries) {
        final channels = await getChannelsByCountry(country);
        allChannels.addAll(channels);
      }

      return allChannels;
    } catch (e, s) {
      _logger.e('Failed to get all channels', error: e, stackTrace: s);
      return [];
    }
  }

  Future<List<TvChannel>> getChannelsByCategory(String category) async {
    try {
      final allChannels = await getAllChannels();
      return allChannels
          .where((channel) => 
              channel.category?.toLowerCase().contains(category.toLowerCase()) == true)
          .toList();
    } catch (e, s) {
      _logger.e('Failed to get channels by category: $category', error: e, stackTrace: s);
      return [];
    }
  }

  Future<List<TvChannel>> searchChannels(String query) async {
    try {
      final allChannels = await getAllChannels();
      final lowerQuery = query.toLowerCase();
      
      return allChannels.where((channel) =>
          channel.name.toLowerCase().contains(lowerQuery) ||
          (channel.category?.toLowerCase().contains(lowerQuery) == true) ||
          (channel.country?.toLowerCase().contains(lowerQuery) == true)
      ).toList();
    } catch (e, s) {
      _logger.e('Failed to search channels', error: e, stackTrace: s);
      return [];
    }
  }

  List<TvChannel> _parseM3uContent(String content, String country) {
    final channels = <TvChannel>[];
    final entries = content.split('#EXTINF:');
    
    for (int i = 1; i < entries.length; i++) {
      try {
        final entry = '#EXTINF:${entries[i]}';
        final channel = TvChannel.fromM3uEntry(entry, country);
        channels.add(channel);
      } catch (e) {
        _logger.w('Failed to parse M3U entry: $e');
      }
    }
    
    return channels;
  }

  Future<List<String>> getAvailableCountries() async {
    return [
      'ar', 'sa', 'ae', 'eg', 'jo', 'lb', 'sy', 'iq', 'kw', 'qa', 'bh', 'om', 'ye', 'ps',
      'us', 'uk', 'fr', 'de', 'it', 'es', 'tr', 'in', 'pk', 'bd', 'my', 'id'
    ];
  }

  Future<Map<String, String>> getCountryNames() async {
    return {
      'ar': 'الأرجنتين',
      'sa': 'السعودية',
      'ae': 'الإمارات',
      'eg': 'مصر',
      'jo': 'الأردن',
      'lb': 'لبنان',
      'sy': 'سوريا',
      'iq': 'العراق',
      'kw': 'الكويت',
      'qa': 'قطر',
      'bh': 'البحرين',
      'om': 'عمان',
      'ye': 'اليمن',
      'ps': 'فلسطين',
      'us': 'الولايات المتحدة',
      'uk': 'المملكة المتحدة',
      'fr': 'فرنسا',
      'de': 'ألمانيا',
      'it': 'إيطاليا',
      'es': 'إسبانيا',
      'tr': 'تركيا',
      'in': 'الهند',
      'pk': 'باكستان',
      'bd': 'بنغلاديش',
      'my': 'ماليزيا',
      'id': 'إندونيسيا',
    };
  }

  Future<void> clearCache() async {
    try {
      await _channelsBox.clear();
      _logger.i('IPTV cache cleared');
    } catch (e, s) {
      _logger.e('Failed to clear IPTV cache', error: e, stackTrace: s);
    }
  }

  Future<void> refreshChannels() async {
    await clearCache();
    await getAllChannels();
  }
}