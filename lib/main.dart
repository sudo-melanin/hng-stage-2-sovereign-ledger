import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sovereign_ledger/core/services/hive_service.dart';
import 'package:sovereign_ledger/data/repositories/category_repository.dart';
import 'package:sovereign_ledger/data/repositories/transaction_repository.dart';
import 'package:sovereign_ledger/providers/transaction_provider.dart';

import 'core/enums/transaction_type.dart';

Future<void> main() async {
  await HiveService.init();
  await CategoryRepository().seedDefaultCategories();

  final transactionRepository = TransactionRepository();
  final categories = CategoryRepository().getAllCategories();

  if (categories.isNotEmpty) {
    await transactionRepository.clearTransactions();

    await transactionRepository.addTransaction(
      title: 'April Salary',
      amount: 250000,
      type: TransactionType.income,
      categoryId: categories.firstWhere((c) => c.name == 'Salary').id,
      date: DateTime.now(),
      note: 'Monthly salary payment',
    );

    await transactionRepository.addTransaction(
      title: 'Lunch',
      amount: 3500,
      type: TransactionType.expense,
      categoryId: categories.firstWhere((c) => c.name == 'Food').id,
      date: DateTime.now(),
      note: 'Office lunch',
    );

    debugPrint('Total income: ${transactionRepository.getTotalIncome()}');
    debugPrint('Total expense: ${transactionRepository.getTotalExpense()}');
    debugPrint('Balance: ${transactionRepository.getBalance()}');
  }

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
      ],
      child: MaterialApp(
        title: 'Sovereign Ledger',
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: Text('Sovereign Ledger'),
          ),
        ),
      ),
    );
  }
}