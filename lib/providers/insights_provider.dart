import 'package:flutter/foundation.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';
import 'package:sovereign_ledger/data/models/transaction_model.dart';
import 'package:sovereign_ledger/data/repositories/category_repository.dart';
import 'package:sovereign_ledger/data/repositories/transaction_repository.dart';

class CategorySpendData {
  final String categoryName;
  final double amount;
  final int colorValue;

  CategorySpendData({
    required this.categoryName,
    required this.amount,
    required this.colorValue,
  });
}

/// Prepares transaction data for charts and insight cards.
class InsightsProvider extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  InsightsProvider(
    this._transactionRepository,
    this._categoryRepository,
  );

  List<CategorySpendData> _categorySpend = [];
  double _totalIncome = 0;
  double _totalExpense = 0;

  List<CategorySpendData> get categorySpend => _categorySpend;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;

  void loadInsights() {
    final transactions = _transactionRepository.getAllTransactions();

    _totalIncome = transactions
        .where((item) => item.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);

    _totalExpense = transactions
        .where((item) => item.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);

    _categorySpend = _buildCategorySpend(transactions);

    notifyListeners();
  }

  List<CategorySpendData> _buildCategorySpend(
    List<TransactionModel> transactions,
  ) {
    final expenseTransactions = transactions.where(
      (item) => item.type == TransactionType.expense,
    );

    final Map<String, double> groupedSpend = {};

    for (final transaction in expenseTransactions) {
      groupedSpend.update(
        transaction.categoryId,
        (currentAmount) => currentAmount + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final categories = _categoryRepository.getAllCategories();

    final result = groupedSpend.entries.map((entry) {
      final category = categories.firstWhere(
        (item) => item.id == entry.key,
      );

      return CategorySpendData(
        categoryName: category.name,
        amount: entry.value,
        colorValue: category.colorValue,
      );
    }).toList();

    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }
}