import 'package:hive/hive.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';

part 'transaction_model.g.dart';

/// Represents a single financial record in the app.
/// This can be either income or expense.
@HiveType(typeId: 3)
class TransactionModel extends HiveObject {
  /// Unique identifier used as the storage key.
  @HiveField(0)
  final String id;

  /// Short user-facing title such as "Salary" or "Lunch".
  @HiveField(1)
  final String title;

  /// Positive amount value stored as a number.
  @HiveField(2)
  final double amount;

  /// Whether the transaction is income or expense.
  @HiveField(3)
  final TransactionType type;

  /// References the selected category by id.
  @HiveField(4)
  final String categoryId;

  /// Date the transaction occurred.
  @HiveField(5)
  final DateTime date;

  /// Optional note for extra context.
  @HiveField(6)
  final String? note;

  /// Indicates whether this transaction came from a recurring rule.
  @HiveField(7)
  final bool isRecurring;

  /// Optional recurring rule id for linked recurring transactions.
  @HiveField(8)
  final String? recurringRuleId;

  /// Creation timestamp for debugging and ordering support.
  @HiveField(9)
  final DateTime createdAt;

  /// Last update timestamp for future edit support.
  @HiveField(10)
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    required this.isRecurring,
    this.recurringRuleId,
    required this.createdAt,
    required this.updatedAt,
  });
}