import 'package:hive/hive.dart';

part 'transaction_type.g.dart';

/// Defines whether a transaction adds money to the user balance
/// or reduces it.
@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,
}