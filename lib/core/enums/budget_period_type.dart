import 'package:hive/hive.dart';

part 'budget_period_type.g.dart';

/// Defines the active time window for a budget.
@HiveType(typeId: 4)
enum BudgetPeriodType {
  @HiveField(0)
  weekly,

  @HiveField(1)
  monthly,

  @HiveField(2)
  custom,
}