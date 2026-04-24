import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:sovereign_ledger/core/constants/hive_boxes.dart';
import 'package:sovereign_ledger/core/enums/budget_period_type.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';
import 'package:sovereign_ledger/data/models/budget_model.dart';
import 'package:sovereign_ledger/data/models/transaction_model.dart';

/// Handles budget storage and budget usage calculations.
/// Budget progress is calculated from matching expense transactions.
class BudgetRepository {
  final Box<BudgetModel> _budgetBox = Hive.box<BudgetModel>(HiveBoxes.budgets);
  final Box<TransactionModel> _transactionBox =
      Hive.box<TransactionModel>(HiveBoxes.transactions);

  final Uuid _uuid = const Uuid();

  List<BudgetModel> getAllBudgets() {
    final budgets = _budgetBox.values.toList();
    budgets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return budgets;
  }

  Future<void> addBudget({
    required String categoryId,
    required double amountLimit,
    required BudgetPeriodType periodType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final budget = BudgetModel(
      id: _uuid.v4(),
      categoryId: categoryId,
      amountLimit: amountLimit,
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
    );

    await _budgetBox.put(budget.id, budget);
  }

  double getSpentAmount(BudgetModel budget) {
    return _transactionBox.values.where((transaction) {
      final isSameCategory = transaction.categoryId == budget.categoryId;
      final isExpense = transaction.type == TransactionType.expense;
      final isWithinPeriod =
          !transaction.date.isBefore(budget.startDate) &&
          !transaction.date.isAfter(budget.endDate);

      return isSameCategory && isExpense && isWithinPeriod;
    }).fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double getRemainingAmount(BudgetModel budget) {
    return budget.amountLimit - getSpentAmount(budget);
  }

  double getProgress(BudgetModel budget) {
    if (budget.amountLimit <= 0) return 0;
    return getSpentAmount(budget) / budget.amountLimit;
  }

  bool isOverLimit(BudgetModel budget) {
    return getSpentAmount(budget) > budget.amountLimit;
  }

  Future<void> clearBudgets() async {
    await _budgetBox.clear();
  }
}