import 'package:hive/hive.dart';
import 'package:sovereign_ledger/core/enums/recurrence_frequency.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';

part 'recurring_rule_model.g.dart';

/// Stores the template for transactions that repeat over time.
/// Actual transactions are generated from this rule when they become due.
@HiveType(typeId: 7)
class RecurringRuleModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final RecurrenceFrequency frequency;

  @HiveField(6)
  final DateTime nextDueDate;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final String? note;

  @HiveField(9)
  final DateTime createdAt;

  RecurringRuleModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.frequency,
    required this.nextDueDate,
    required this.isActive,
    this.note,
    required this.createdAt,
  });

  RecurringRuleModel copyWith({
    DateTime? nextDueDate,
    bool? isActive,
  }) {
    return RecurringRuleModel(
      id: id,
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      frequency: frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      note: note,
      createdAt: createdAt,
    );
  }
}