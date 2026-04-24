import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sovereign_ledger/core/constants/app_colors.dart';
import 'package:sovereign_ledger/core/enums/budget_period_type.dart';
import 'package:sovereign_ledger/core/enums/category_type.dart';
import 'package:sovereign_ledger/core/utils/input_formatters.dart';
import 'package:sovereign_ledger/data/models/category_model.dart';
import 'package:sovereign_ledger/data/repositories/category_repository.dart';
import 'package:sovereign_ledger/providers/budget_provider.dart';

import '../../../data/repositories/budget_repository.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime? _customEndDate;

  late final List<CategoryModel> _expenseCategories;

  CategoryModel? _selectedCategory;
  BudgetPeriodType _periodType = BudgetPeriodType.monthly;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _expenseCategories =
        CategoryRepository().getCategoriesByType(CategoryType.expense);
    _selectedCategory =
        _expenseCategories.isNotEmpty ? _expenseCategories.first : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  DateTime get _endDate {
  switch (_periodType) {
    case BudgetPeriodType.weekly:
      return _startDate.add(const Duration(days: 6));

    case BudgetPeriodType.monthly:
      return DateTime(
        _startDate.year,
        _startDate.month + 1,
        _startDate.day,
      ).subtract(const Duration(days: 1));

    case BudgetPeriodType.custom:
      return _customEndDate ?? _startDate;
  }
}

  Future<void> _pickStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      _startDate = pickedDate;
    });
  }

  Future<void> _pickEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _customEndDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      _customEndDate = pickedDate;
    });
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0 || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget.')),
      );
      return;
    }

   final repository = BudgetRepository();

    final hasConflict = repository.hasOverlappingBudget(
      categoryId: _selectedCategory!.id,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (hasConflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A budget already exists for this category in the selected period.',
          ),
        ),
      );
      return;
    }

    await context.read<BudgetProvider>().addBudget(
      categoryId: _selectedCategory!.id,
      amountLimit: amount,
      periodType: _periodType,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget created successfully.')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Budget'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _BudgetCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Category'),
                    DropdownButtonFormField<CategoryModel>(
                      initialValue: _selectedCategory,
                      items: _expenseCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (category) {
                        setState(() => _selectedCategory = category);
                      },
                      validator: (value) {
                        if (value == null) return 'Select a category';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const _Label('Budget amount'),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: AppInputFormatters.positiveDecimal,
                      decoration: const InputDecoration(
                        prefixText: '₦ ',
                        hintText: '0.00',
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Enter an amount greater than zero';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _BudgetCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Timeframe'),
                    SegmentedButton<BudgetPeriodType>(
                      segments: const [
                        ButtonSegment(
                          value: BudgetPeriodType.weekly,
                          label: Text('Weekly'),
                        ),
                        ButtonSegment(
                          value: BudgetPeriodType.monthly,
                          label: Text('Monthly'),
                        ),
                        ButtonSegment(
                          value: BudgetPeriodType.custom,
                          label: Text('Custom'),
                        ),
                      ],
                      selected: {_periodType},
                      onSelectionChanged: (value) {
                        setState(() {
                          _periodType = value.first;

                          if (_periodType != BudgetPeriodType.custom) {
                            _customEndDate = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const _Label('Start date'),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickStartDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_periodType == BudgetPeriodType.custom)
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _pickEndDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          child: Text(
                            '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      )
                    else
                      Text(
                        'Ends: ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _saveBudget,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Save Budget'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Widget child;

  const _BudgetCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.mutedText,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}