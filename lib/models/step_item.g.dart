// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StepItemAdapter extends TypeAdapter<StepItem> {
  @override
  final int typeId = 1;

  @override
  StepItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepItem(
      index: fields[0] as int,
      text: fields[1] as String,
      durationSec: fields[2] as int?,
      imageUrl: fields[3] as String?,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StepItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.index)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.durationSec)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
