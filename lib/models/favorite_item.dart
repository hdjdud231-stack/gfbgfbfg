import 'package:hive/hive.dart';

part 'favorite_item.g.dart';

@HiveType(typeId: 0)
class FavoriteItem extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterPath;

  @HiveField(3)
  final String mediaType;

  @HiveField(4)
  final DateTime addedAt;

  FavoriteItem({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.mediaType,
    required this.addedAt,
  });

  int get mediaId => id;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'poster_path': posterPath,
    'media_type': mediaType,
    'added_at': addedAt.toIso8601String(),
  };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
    id: json['id'],
    title: json['title'] ?? json['name'] ?? '',
    posterPath: json['poster_path'] ?? '',
    mediaType: json['media_type'] ?? 'movie',
    addedAt: DateTime.tryParse(json['added_at'] ?? '') ?? DateTime.now(),
  );
}