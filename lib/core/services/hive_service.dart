import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sovereign_ledger/core/constants/hive_boxes.dart';
import 'package:sovereign_ledger/core/enums/category_type.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';
import 'package:sovereign_ledger/data/models/category_model.dart';
import 'package:sovereign_ledger/data/models/transaction_model.dart';
import 'package:sovereign_ledger/core/enums/budget_period_type.dart';
import 'package:sovereign_ledger/data/models/budget_model.dart';

/// Centralized Hive setup for the app.
/// Keeps adapter registration and box opening in one place.
class HiveService {
  static Future<void> init() async {
    // Required before initializing platform services in Flutter.
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();

    _registerAdapters();
    await _openBoxes();
  }

  /// Registers all Hive adapters needed before box access.
  static void _registerAdapters() {
    // Guard against duplicate registration during hot reload/restart.
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryTypeAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }

    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(BudgetPeriodTypeAdapter());
    }

    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(BudgetModelAdapter());
    }
  }

  /// Opens all app boxes used during startup.
  static Future<void> _openBoxes() async {
    await Hive.openBox<CategoryModel>(HiveBoxes.categories);
    await Hive.openBox<TransactionModel>(HiveBoxes.transactions);
    await Hive.openBox<BudgetModel>(HiveBoxes.budgets);
  }
}