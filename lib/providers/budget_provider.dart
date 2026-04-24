import 'package:flutter/foundation.dart';
import 'package:sovereign_ledger/core/enums/budget_period_type.dart';
import 'package:sovereign_ledger/data/models/budget_model.dart';
import 'package:sovereign_ledger/data/repositories/budget_repository.dart';

/// Manages budget state and exposes derived budget calculations to the UI.
class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _budgetRepository;

  BudgetProvider(this._budgetRepository);

  List<BudgetModel> _budgets = [];

  List<BudgetModel> get budgets => _budgets;

  void loadBudgets() {
    _budgets = _budgetRepository.getAllBudgets();
    notifyListeners();
  }

  Future<void> addBudget({
    required String categoryId,
    required double amountLimit,
    required BudgetPeriodType periodType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _budgetRepository.addBudget(
      categoryId: categoryId,
      amountLimit: amountLimit,
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
    );

    loadBudgets();
  }

  double spentAmount(BudgetModel budget) {
    return _budgetRepository.getSpentAmount(budget);
  }

  double remainingAmount(BudgetModel budget) {
    return _budgetRepository.getRemainingAmount(budget);
  }

  double progress(BudgetModel budget) {
    return _budgetRepository.getProgress(budget);
  }

  bool isOverLimit(BudgetModel budget) {
    return _budgetRepository.isOverLimit(budget);
  }
}