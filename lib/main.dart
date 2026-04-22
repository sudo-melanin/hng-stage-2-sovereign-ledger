import 'package:flutter/material.dart';

void main() {
  runApp(const SovereignLedgerApp());
}

class SovereignLedgerApp extends StatelessWidget {
  const SovereignLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sovereign Ledger',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('Sovereign Ledger'),
        ),
      ),
    );
  }
}