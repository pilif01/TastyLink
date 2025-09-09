// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlannerEntryAdapter extends TypeAdapter<PlannerEntry> {
  @override
  final int typeId = 10;

  @override
  PlannerEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannerEntry(
      id: fields[0] as String,
      meal: fields[1] as String,
      recipeId: fields[2] as String?,
      note: fields[3] as String?,
      date: fields[4] as DateTime,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlannerEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.meal)
      ..writeByte(2)
      ..write(obj.recipeId)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannerEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
