import 'package:hive/hive.dart';

part 'anime.g.dart';

@HiveType(typeId: 11)
class Anime extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? englishTitle;

  @HiveField(3)
  final String? nativeTitle;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final String? coverImage;

  @HiveField(6)
  final String? bannerImage;

  @HiveField(7)
  final List<String> genres;

  @HiveField(8)
  final double? averageScore;

  @HiveField(9)
  final int? episodes;

  @HiveField(10)
  final String? status;

  @HiveField(11)
  final String? format;

  @HiveField(12)
  final int? year;

  @HiveField(13)
  final String? season;

  @HiveField(14)
  final int? duration;

  @HiveField(15)
  final String? trailer;

  @HiveField(16)
  final List<String> streamingEpisodes;

  Anime({
    required this.id,
    required this.title,
    this.englishTitle,
    this.nativeTitle,
    this.description,
    this.coverImage,
    this.bannerImage,
    this.genres = const [],
    this.averageScore,
    this.episodes,
    this.status,
    this.format,
    this.year,
    this.season,
    this.duration,
    this.trailer,
    this.streamingEpisodes = const [],
  });

  factory Anime.fromAnilistJson(Map<String, dynamic> json) {
    final title = json['title'] ?? {};
    final coverImage = json['coverImage'] ?? {};
    
    return Anime(
      id: json['id'],
      title: title['romaji'] ?? title['english'] ?? title['native'] ?? 'Unknown',
      englishTitle: title['english'],
      nativeTitle: title['native'],
      description: json['description'],
      coverImage: coverImage['large'] ?? coverImage['medium'],
      bannerImage: json['bannerImage'],
      genres: List<String>.from(json['genres'] ?? []),
      averageScore: json['averageScore']?.toDouble(),
      episodes: json['episodes'],
      status: json['status'],
      format: json['format'],
      year: json['seasonYear'],
      season: json['season'],
      duration: json['duration'],
      trailer: json['trailer']?['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'englishTitle': englishTitle,
    'nativeTitle': nativeTitle,
    'description': description,
    'coverImage': coverImage,
    'bannerImage': bannerImage,
    'genres': genres,
    'averageScore': averageScore,
    'episodes': episodes,
    'status': status,
    'format': format,
    'year': year,
    'season': season,
    'duration': duration,
    'trailer': trailer,
    'streamingEpisodes': streamingEpisodes,
  };

  String get displayTitle => englishTitle ?? title;
  
  String get statusText {
    switch (status) {
      case 'FINISHED':
        return 'مكتمل';
      case 'RELEASING':
        return 'يُعرض حالياً';
      case 'NOT_YET_RELEASED':
        return 'لم يُعرض بعد';
      case 'CANCELLED':
        return 'ملغي';
      case 'HIATUS':
        return 'متوقف مؤقتاً';
      default:
        return status ?? 'غير معروف';
    }
  }

  String get formatText {
    switch (format) {
      case 'TV':
        return 'مسلسل تلفزيوني';
      case 'TV_SHORT':
        return 'مسلسل قصير';
      case 'MOVIE':
        return 'فيلم';
      case 'SPECIAL':
        return 'حلقة خاصة';
      case 'OVA':
        return 'OVA';
      case 'ONA':
        return 'ONA';
      case 'MUSIC':
        return 'موسيقي';
      default:
        return format ?? 'غير معروف';
    }
  }

  @override
  String toString() => 'Anime(id: $id, title: $title)';
}