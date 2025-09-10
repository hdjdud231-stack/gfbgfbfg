import 'package:hive/hive.dart';

part 'watch_progress.g.dart';

@HiveType(typeId: 1)
class WatchProgress extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterPath;

  @HiveField(3)
  final String mediaType;

  @HiveField(4)
  final int position; // in seconds

  @HiveField(5)
  final int duration; // in seconds

  @HiveField(6)
  final DateTime lastWatched;

  @HiveField(7)
  final int? seasonNumber;

  @HiveField(8)
  final int? episodeNumber;

  WatchProgress({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.mediaType,
    required this.position,
    required this.duration,
    required this.lastWatched,
    this.seasonNumber,
    this.episodeNumber,
  });

  int get mediaId => id;
  int get progress => position;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'poster_path': posterPath,
    'media_type': mediaType,
    'position': position,
    'duration': duration,
    'last_watched': lastWatched.toIso8601String(),
    'season_number': seasonNumber,
    'episode_number': episodeNumber,
  };

  factory WatchProgress.fromJson(Map<String, dynamic> json) => WatchProgress(
    id: json['id'],
    title: json['title'] ?? json['name'] ?? '',
    posterPath: json['poster_path'] ?? '',
    mediaType: json['media_type'] ?? 'movie',
    position: json['position'] ?? 0,
    duration: json['duration'] ?? 0,
    lastWatched: DateTime.tryParse(json['last_watched'] ?? '') ?? DateTime.now(),
    seasonNumber: json['season_number'],
    episodeNumber: json['episode_number'],
  );
}