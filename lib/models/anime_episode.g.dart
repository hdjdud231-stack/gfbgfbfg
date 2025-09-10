// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_episode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimeEpisodeAdapter extends TypeAdapter<AnimeEpisode> {
  @override
  final int typeId = 12;

  @override
  AnimeEpisode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimeEpisode(
      id: fields[0] as String,
      animeId: fields[1] as int,
      episodeNumber: fields[2] as int,
      title: fields[3] as String,
      description: fields[4] as String?,
      thumbnail: fields[5] as String?,
      duration: fields[6] as int?,
      airDate: fields[7] as DateTime?,
      streamSources: (fields[8] as List).cast<AnimeStreamSource>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnimeEpisode obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.animeId)
      ..writeByte(2)
      ..write(obj.episodeNumber)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.thumbnail)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.airDate)
      ..writeByte(8)
      ..write(obj.streamSources);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeEpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnimeStreamSourceAdapter extends TypeAdapter<AnimeStreamSource> {
  @override
  final int typeId = 13;

  @override
  AnimeStreamSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimeStreamSource(
      url: fields[0] as String,
      quality: fields[1] as String,
      server: fields[2] as String,
      isM3U8: fields[3] as bool,
      headers: (fields[4] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnimeStreamSource obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.quality)
      ..writeByte(2)
      ..write(obj.server)
      ..writeByte(3)
      ..write(obj.isM3U8)
      ..writeByte(4)
      ..write(obj.headers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeStreamSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
