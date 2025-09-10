// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchProgressAdapter extends TypeAdapter<WatchProgress> {
  @override
  final int typeId = 1;

  @override
  WatchProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchProgress(
      id: fields[0] as int,
      title: fields[1] as String,
      posterPath: fields[2] as String,
      mediaType: fields[3] as String,
      position: fields[4] as int,
      duration: fields[5] as int,
      lastWatched: fields[6] as DateTime,
      seasonNumber: fields[7] as int?,
      episodeNumber: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WatchProgress obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.mediaType)
      ..writeByte(4)
      ..write(obj.position)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.lastWatched)
      ..writeByte(7)
      ..write(obj.seasonNumber)
      ..writeByte(8)
      ..write(obj.episodeNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
