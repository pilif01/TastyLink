// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_text.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeTextAdapter extends TypeAdapter<RecipeText> {
  @override
  final int typeId = 2;

  @override
  RecipeText read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeText(
      original: fields[0] as String,
      ro: fields[1] as String?,
      en: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeText obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.original)
      ..writeByte(1)
      ..write(obj.ro)
      ..writeByte(2)
      ..write(obj.en);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeTextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
