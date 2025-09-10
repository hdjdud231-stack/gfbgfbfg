// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_channel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TvChannelAdapter extends TypeAdapter<TvChannel> {
  @override
  final int typeId = 10;

  @override
  TvChannel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TvChannel(
      id: fields[0] as String,
      name: fields[1] as String,
      streamUrl: fields[2] as String,
      logo: fields[3] as String?,
      country: fields[4] as String?,
      language: fields[5] as String?,
      category: fields[6] as String?,
      description: fields[7] as String?,
      isActive: fields[8] as bool,
      quality: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TvChannel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.streamUrl)
      ..writeByte(3)
      ..write(obj.logo)
      ..writeByte(4)
      ..write(obj.country)
      ..writeByte(5)
      ..write(obj.language)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.quality);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TvChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
