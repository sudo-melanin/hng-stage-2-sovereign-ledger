import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sovereign_ledger/providers/transaction_provider.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = context.select<TransactionProvider, double>(
      (provider) => provider.balance,
    );

    return Center(
      child: Text(
        'Balance: ₦${balance.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}