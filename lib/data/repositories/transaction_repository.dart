import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:sovereign_ledger/core/constants/hive_boxes.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';
import 'package:sovereign_ledger/data/models/transaction_model.dart';

/// Handles transaction-related storage and query operations.
/// Keeps raw Hive access out of the UI layer.
class TransactionRepository {
  final Box<TransactionModel> _transactionBox =
      Hive.box<TransactionModel>(HiveBoxes.transactions);

  final Uuid _uuid = const Uuid();

  /// Returns all transactions currently stored.
  List<TransactionModel> getAllTransactions() {
    return _transactionBox.values.toList();
  }

  /// Returns transactions sorted by most recent date first.
  List<TransactionModel> getRecentTransactions() {
    final transactions = _transactionBox.values.toList();

    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  /// Saves a new transaction locally.
  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? note,
    bool isRecurring = false,
    String? recurringRuleId,
  }) async {
    final now = DateTime.now();

    final transaction = TransactionModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      note: note,
      isRecurring: isRecurring,
      recurringRuleId: recurringRuleId,
      createdAt: now,
      updatedAt: now,
    );

    await _transactionBox.put(transaction.id, transaction);
  }

  /// Returns the total income across all transactions.
  double getTotalIncome() {
    return _transactionBox.values
        .where((transaction) => transaction.type == TransactionType.income)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Returns the total expense across all transactions.
  double getTotalExpense() {
    return _transactionBox.values
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Calculates current balance as income minus expense.
  double getBalance() {
    return getTotalIncome() - getTotalExpense();
  }

  /// Clears all transactions.
  /// This is mainly useful during early development and testing.
  Future<void> clearTransactions() async {
    await _transactionBox.clear();
  }
}