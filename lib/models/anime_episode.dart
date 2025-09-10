import 'package:hive/hive.dart';

part 'anime_episode.g.dart';

@HiveType(typeId: 12)
class AnimeEpisode extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int animeId;

  @HiveField(2)
  final int episodeNumber;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final String? thumbnail;

  @HiveField(6)
  final int? duration;

  @HiveField(7)
  final DateTime? airDate;

  @HiveField(8)
  final List<AnimeStreamSource> streamSources;

  AnimeEpisode({
    required this.id,
    required this.animeId,
    required this.episodeNumber,
    required this.title,
    this.description,
    this.thumbnail,
    this.duration,
    this.airDate,
    this.streamSources = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'animeId': animeId,
    'episodeNumber': episodeNumber,
    'title': title,
    'description': description,
    'thumbnail': thumbnail,
    'duration': duration,
    'airDate': airDate?.toIso8601String(),
    'streamSources': streamSources.map((s) => s.toJson()).toList(),
  };

  factory AnimeEpisode.fromJson(Map<String, dynamic> json) => AnimeEpisode(
    id: json['id'],
    animeId: json['animeId'],
    episodeNumber: json['episodeNumber'],
    title: json['title'],
    description: json['description'],
    thumbnail: json['thumbnail'],
    duration: json['duration'],
    airDate: json['airDate'] != null ? DateTime.parse(json['airDate']) : null,
    streamSources: (json['streamSources'] as List?)
        ?.map((s) => AnimeStreamSource.fromJson(s))
        .toList() ?? [],
  );

  @override
  String toString() => 'AnimeEpisode(id: $id, episode: $episodeNumber, title: $title)';
}

@HiveType(typeId: 13)
class AnimeStreamSource extends HiveObject {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final String quality;

  @HiveField(2)
  final String server;

  @HiveField(3)
  final bool isM3U8;

  @HiveField(4)
  final Map<String, String>? headers;

  AnimeStreamSource({
    required this.url,
    required this.quality,
    required this.server,
    this.isM3U8 = false,
    this.headers,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'quality': quality,
    'server': server,
    'isM3U8': isM3U8,
    'headers': headers,
  };

  factory AnimeStreamSource.fromJson(Map<String, dynamic> json) => AnimeStreamSource(
    url: json['url'],
    quality: json['quality'],
    server: json['server'],
    isM3U8: json['isM3U8'] ?? false,
    headers: json['headers'] != null 
        ? Map<String, String>.from(json['headers']) 
        : null,
  );

  @override
  String toString() => 'AnimeStreamSource(server: $server, quality: $quality)';
}