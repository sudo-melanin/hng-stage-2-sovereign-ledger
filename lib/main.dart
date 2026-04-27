import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sovereign_ledger/core/routes/app_shell.dart';
import 'package:sovereign_ledger/core/services/hive_service.dart';
import 'package:sovereign_ledger/core/theme/app_theme.dart';
import 'package:sovereign_ledger/data/repositories/category_repository.dart';
import 'package:sovereign_ledger/data/repositories/transaction_repository.dart';
import 'package:sovereign_ledger/providers/transaction_provider.dart';
import 'package:sovereign_ledger/data/repositories/budget_repository.dart';
import 'package:sovereign_ledger/providers/budget_provider.dart';
import 'package:sovereign_ledger/providers/insights_provider.dart';
import 'package:sovereign_ledger/providers/security_provider.dart';
import 'package:sovereign_ledger/providers/settings_provider.dart';

Future<void> main() async {
  await HiveService.init();
  await CategoryRepository().seedDefaultCategories();

  runApp(const SovereignLedgerApp());
}

class SovereignLedgerApp extends StatelessWidget {
  const SovereignLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(TransactionRepository())..loadTransactions(),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(BudgetRepository())..loadBudgets(),
        ),
        ChangeNotifierProvider(
          create: (_) => InsightsProvider(
            TransactionRepository(),
            CategoryRepository(),
          )..loadInsights(),
        ),
        ChangeNotifierProvider(
          create: (_) => SecurityProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
      ],
      child: MaterialApp(
        title: 'Sovereign Ledger',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppShell(),
      ),
    );
  }
}