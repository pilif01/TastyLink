// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_media.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeMediaAdapter extends TypeAdapter<RecipeMedia> {
  @override
  final int typeId = 3;

  @override
  RecipeMedia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeMedia(
      coverImageUrl: fields[0] as String?,
      stepPhotos: (fields[1] as List).cast<String>(),
      videoUrl: fields[2] as String?,
      audioUrl: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeMedia obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.coverImageUrl)
      ..writeByte(1)
      ..write(obj.stepPhotos)
      ..writeByte(2)
      ..write(obj.videoUrl)
      ..writeByte(3)
      ..write(obj.audioUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeMediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
