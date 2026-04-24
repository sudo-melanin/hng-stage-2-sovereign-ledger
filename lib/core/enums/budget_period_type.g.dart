// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_period_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetPeriodTypeAdapter extends TypeAdapter<BudgetPeriodType> {
  @override
  final int typeId = 4;

  @override
  BudgetPeriodType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BudgetPeriodType.weekly;
      case 1:
        return BudgetPeriodType.monthly;
      case 2:
        return BudgetPeriodType.custom;
      default:
        return BudgetPeriodType.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, BudgetPeriodType obj) {
    switch (obj) {
      case BudgetPeriodType.weekly:
        writer.writeByte(0);
        break;
      case BudgetPeriodType.monthly:
        writer.writeByte(1);
        break;
      case BudgetPeriodType.custom:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetPeriodTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
