import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:sovereign_ledger/core/constants/hive_boxes.dart';
import 'package:sovereign_ledger/core/enums/recurrence_frequency.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';
import 'package:sovereign_ledger/data/models/recurring_rule_model.dart';
import 'package:sovereign_ledger/data/repositories/transaction_repository.dart';

/// Handles recurring transaction rules and generates due transactions.
/// This app processes recurrence on load instead of running background jobs.
class RecurringRepository {
  final Box<RecurringRuleModel> _recurringBox =
      Hive.box<RecurringRuleModel>(HiveBoxes.recurringRules);

  final TransactionRepository _transactionRepository = TransactionRepository();
  final Uuid _uuid = const Uuid();

  List<RecurringRuleModel> getActiveRules() {
    return _recurringBox.values.where((rule) => rule.isActive).toList();
  }

  Future<void> addRule({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required RecurrenceFrequency frequency,
    required DateTime nextDueDate,
    String? note,
  }) async {
    final rule = RecurringRuleModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      frequency: frequency,
      nextDueDate: nextDueDate,
      isActive: true,
      note: note,
      createdAt: DateTime.now(),
    );

    await _recurringBox.put(rule.id, rule);
  }

  Future<void> processDueRules() async {
    final now = DateTime.now();

    for (final rule in getActiveRules()) {
      if (rule.nextDueDate.isAfter(now)) continue;

      await _transactionRepository.addTransaction(
        title: rule.title,
        amount: rule.amount,
        type: rule.type,
        categoryId: rule.categoryId,
        date: rule.nextDueDate,
        note: rule.note,
        isRecurring: true,
        recurringRuleId: rule.id,
      );

      final updatedRule = rule.copyWith(
        nextDueDate: _calculateNextDueDate(
          rule.nextDueDate,
          rule.frequency,
        ),
      );

      await _recurringBox.put(rule.id, updatedRule);
    }
  }

  DateTime _calculateNextDueDate(
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
}