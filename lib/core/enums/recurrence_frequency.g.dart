// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_frequency.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurrenceFrequencyAdapter extends TypeAdapter<RecurrenceFrequency> {
  @override
  final int typeId = 6;

  @override
  RecurrenceFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceFrequency.weekly;
      case 1:
        return RecurrenceFrequency.monthly;
      default:
        return RecurrenceFrequency.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceFrequency obj) {
    switch (obj) {
      case RecurrenceFrequency.weekly:
        writer.writeByte(0);
        break;
      case RecurrenceFrequency.monthly:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
