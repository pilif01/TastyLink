// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 4;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      title: fields[1] as String,
      creatorHandle: fields[2] as String,
      sourceLink: fields[3] as String,
      lang: fields[4] as String,
      text: fields[5] as RecipeText,
      media: fields[6] as RecipeMedia,
      ingredients: (fields[7] as List).cast<Ingredient>(),
      ingredientsRo: (fields[8] as List).cast<Ingredient>(),
      steps: (fields[9] as List).cast<StepItem>(),
      stepsRo: (fields[10] as List).cast<StepItem>(),
      tags: (fields[11] as List).cast<String>(),
      likes: fields[12] as int,
      saves: fields[13] as int,
      createdByUid: fields[14] as String?,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.creatorHandle)
      ..writeByte(3)
      ..write(obj.sourceLink)
      ..writeByte(4)
      ..write(obj.lang)
      ..writeByte(5)
      ..write(obj.text)
      ..writeByte(6)
      ..write(obj.media)
      ..writeByte(7)
      ..write(obj.ingredients)
      ..writeByte(8)
      ..write(obj.ingredientsRo)
      ..writeByte(9)
      ..write(obj.steps)
      ..writeByte(10)
      ..write(obj.stepsRo)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.likes)
      ..writeByte(13)
      ..write(obj.saves)
      ..writeByte(14)
      ..write(obj.createdByUid)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
