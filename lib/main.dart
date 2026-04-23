import 'package:flutter/material.dart';
import 'package:sovereign_ledger/core/services/hive_service.dart';
import 'package:sovereign_ledger/data/repositories/category_repository.dart';

Future<void> main() async {
  await HiveService.init();

  final categoryRepository = CategoryRepository();
  await categoryRepository.seedDefaultCategories();

  final categories = categoryRepository.getAllCategories();
debugPrint('Total categories: ${categories.length}');

for (final category in categories) {
  debugPrint(
    'Category => ${category.name} | type: ${category.categoryType.name} | icon: ${category.iconKey}',
  );
}

  runApp(const SovereignLedgerApp());
}

class SovereignLedgerApp extends StatelessWidget {
  const SovereignLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sovereign Ledger',
      debugShowCheckedModeBanner: false,
      home:FutureBuilder<List<dynamic>>(
  future: Future.value(CategoryRepository().getAllCategories()),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = snapshot.data!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seeded Categories'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category.name),
            subtitle: Text(category.categoryType.name),
            trailing: Text(category.iconKey),
          );
        },
      ),
    );
  },
),
    );
  }
}