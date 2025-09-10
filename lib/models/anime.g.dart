// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimeAdapter extends TypeAdapter<Anime> {
  @override
  final int typeId = 11;

  @override
  Anime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Anime(
      id: fields[0] as int,
      title: fields[1] as String,
      englishTitle: fields[2] as String?,
      nativeTitle: fields[3] as String?,
      description: fields[4] as String?,
      coverImage: fields[5] as String?,
      bannerImage: fields[6] as String?,
      genres: (fields[7] as List).cast<String>(),
      averageScore: fields[8] as double?,
      episodes: fields[9] as int?,
      status: fields[10] as String?,
      format: fields[11] as String?,
      year: fields[12] as int?,
      season: fields[13] as String?,
      duration: fields[14] as int?,
      trailer: fields[15] as String?,
      streamingEpisodes: (fields[16] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Anime obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.englishTitle)
      ..writeByte(3)
      ..write(obj.nativeTitle)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.coverImage)
      ..writeByte(6)
      ..write(obj.bannerImage)
      ..writeByte(7)
      ..write(obj.genres)
      ..writeByte(8)
      ..write(obj.averageScore)
      ..writeByte(9)
      ..write(obj.episodes)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.format)
      ..writeByte(12)
      ..write(obj.year)
      ..writeByte(13)
      ..write(obj.season)
      ..writeByte(14)
      ..write(obj.duration)
      ..writeByte(15)
      ..write(obj.trailer)
      ..writeByte(16)
      ..write(obj.streamingEpisodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
