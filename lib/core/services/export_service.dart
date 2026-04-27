import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';
import 'package:sovereign_ledger/data/models/transaction_model.dart';

class ExportService {
  Future<File> exportTransactionsToCsv(
    List<TransactionModel> transactions,
  ) async {
    final rows = <List<dynamic>>[
      [
        'Title',
        'Type',
        'Amount',
        'Date',
        'Note',
        'Recurring',
      ],
      ...transactions.map((transaction) {
        return [
          transaction.title,
          transaction.type == TransactionType.income ? 'Income' : 'Expense',
          transaction.amount,
          DateFormat('yyyy-MM-dd').format(transaction.date),
          transaction.note ?? '',
          transaction.isRecurring ? 'Yes' : 'No',
        ];
      }),
    ];

    final csvContent = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      '${directory.path}/sovereign_ledger_transactions.csv',
    );

    return file.writeAsString(csvContent);
  }
}