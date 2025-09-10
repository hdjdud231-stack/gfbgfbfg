import 'package:hive/hive.dart';

part 'tv_channel.g.dart';

@HiveType(typeId: 10)
class TvChannel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String streamUrl;

  @HiveField(3)
  final String? logo;

  @HiveField(4)
  final String? country;

  @HiveField(5)
  final String? language;

  @HiveField(6)
  final String? category;

  @HiveField(7)
  final String? description;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final String? quality;

  TvChannel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logo,
    this.country,
    this.language,
    this.category,
    this.description,
    this.isActive = true,
    this.quality,
  });

  factory TvChannel.fromM3uEntry(String entry, String country) {
    final lines = entry.split('\n');
    if (lines.length < 2) {
      throw ArgumentError('Invalid M3U entry');
    }

    final extinf = lines[0];
    final url = lines[1];

    // Parse EXTINF line
    final nameMatch = RegExp(r',(.+)$').firstMatch(extinf);
    final name = nameMatch?.group(1)?.trim() ?? 'Unknown Channel';

    final tvgIdMatch = RegExp(r'tvg-id="([^"]*)"').firstMatch(extinf);
    final id = tvgIdMatch?.group(1) ?? name.replaceAll(' ', '_').toLowerCase();

    final logoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(extinf);
    final logo = logoMatch?.group(1);

    final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(extinf);
    final category = groupMatch?.group(1);

    // Extract quality from name
    final qualityMatch = RegExp(r'\((\d+p)\)').firstMatch(name);
    final quality = qualityMatch?.group(1);

    return TvChannel(
      id: id,
      name: name,
      streamUrl: url.trim(),
      logo: logo,
      country: country,
      category: category,
      quality: quality,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'streamUrl': streamUrl,
    'logo': logo,
    'country': country,
    'language': language,
    'category': category,
    'description': description,
    'isActive': isActive,
    'quality': quality,
  };

  factory TvChannel.fromJson(Map<String, dynamic> json) => TvChannel(
    id: json['id'],
    name: json['name'],
    streamUrl: json['streamUrl'],
    logo: json['logo'],
    country: json['country'],
    language: json['language'],
    category: json['category'],
    description: json['description'],
    isActive: json['isActive'] ?? true,
    quality: json['quality'],
  );

  @override
  String toString() => 'TvChannel(id: $id, name: $name, country: $country)';
}