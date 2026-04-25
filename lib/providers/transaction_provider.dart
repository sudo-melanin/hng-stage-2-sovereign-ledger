import 'package:flutter/foundation.dart';
import 'package:sovereign_ledger/core/enums/recurrence_frequency.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';
import 'package:sovereign_ledger/data/models/transaction_model.dart';
import 'package:sovereign_ledger/data/repositories/recurring_repository.dart';
import 'package:sovereign_ledger/data/repositories/transaction_repository.dart';

/// Manages transaction state for the UI layer.
/// Responsible for loading, creating, and exposing transaction summaries.
class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final RecurringRepository _recurringRepository = RecurringRepository();

  TransactionProvider(this._transactionRepository);

  List<TransactionModel> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _balance = 0.0;

  List<TransactionModel> get transactions => _transactions;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _balance;

  /// Loads the latest transaction data from storage into memory.
  /// Recurring rules are processed first so due entries appear immediately.
  Future<void> loadTransactions() async {
    await _recurringRepository.processDueRules();

    _transactions = _transactionRepository.getRecentTransactions();
    _totalIncome = _transactionRepository.getTotalIncome();
    _totalExpense = _transactionRepository.getTotalExpense();
    _balance = _transactionRepository.getBalance();

    notifyListeners();
  }

  /// Adds a transaction, optionally creates a recurring rule,
  /// then refreshes all transaction summaries.
  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? note,
    bool isRecurring = false,
    String? recurringRuleId,
    RecurrenceFrequency? recurrenceFrequency,
  }) async {
    await _transactionRepository.addTransaction(
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      note: note,
      isRecurring: isRecurring,
      recurringRuleId: recurringRuleId,
    );

    if (isRecurring && recurrenceFrequency != null) {
      await _recurringRepository.addRule(
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId,
        frequency: recurrenceFrequency,
        nextDueDate: _calculateInitialNextDueDate(
          date,
          recurrenceFrequency,
        ),
        note: note,
      );
    }

    await loadTransactions();
  }

  /// Calculates the first future date for a recurring transaction.
  DateTime _calculateInitialNextDueDate(
    DateTime currentDate,
    RecurrenceFrequency frequency,
  ) {
    switch (frequency) {
      case RecurrenceFrequency.weekly:
        return currentDate.add(const Duration(days: 7));

      case RecurrenceFrequency.monthly:
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
    }
  }

  /// Clears local transaction data and refreshes the provider state.
  Future<void> clearTransactions() async {
    await _transactionRepository.clearTransactions();
    await loadTransactions();
  }
}