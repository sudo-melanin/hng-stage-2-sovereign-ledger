import 'package:hive/hive.dart';
import 'package:sovereign_ledger/core/enums/budget_period_type.dart';

part 'budget_model.g.dart';

/// Represents a spending limit assigned to a category.
/// Actual usage is calculated from expense transactions in the same period.
@HiveType(typeId: 5)
class BudgetModel extends HiveObject {
  /// Unique identifier used as the Hive key.
  @HiveField(0)
  final String id;

  /// Category this budget belongs to.
  @HiveField(1)
  final String categoryId;

  /// Maximum amount allowed for this budget period.
  @HiveField(2)
  final double amountLimit;

  /// Weekly, monthly, or custom period.
  @HiveField(3)
  final BudgetPeriodType periodType;

  /// Budget start date.
  @HiveField(4)
  final DateTime startDate;

  /// Budget end date.
  @HiveField(5)
  final DateTime endDate;

  /// Creation timestamp for ordering/debugging.
  @HiveField(6)
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amountLimit,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });
}