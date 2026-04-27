import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sovereign_ledger/core/constants/app_colors.dart';
import 'package:sovereign_ledger/core/enums/category_type.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';
import 'package:sovereign_ledger/core/utils/input_formatters.dart';
import 'package:sovereign_ledger/data/models/category_model.dart';
import 'package:sovereign_ledger/data/repositories/category_repository.dart';
import 'package:sovereign_ledger/providers/transaction_provider.dart';
import 'package:sovereign_ledger/providers/insights_provider.dart';
import 'package:sovereign_ledger/providers/budget_provider.dart';
import 'package:sovereign_ledger/core/enums/recurrence_frequency.dart';
import 'package:sovereign_ledger/core/constants/app_currencies.dart';
import 'package:sovereign_ledger/providers/settings_provider.dart';

class ManualTransactionTab extends StatefulWidget {
  const ManualTransactionTab({super.key});

  @override
  State<ManualTransactionTab> createState() => _ManualTransactionTabState();
}

class _ManualTransactionTabState extends State<ManualTransactionTab> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;

  RecurrenceFrequency _recurrenceFrequency = RecurrenceFrequency.weekly;

  List<CategoryModel> get _categories {
    final categoryType = _selectedType == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;

    return CategoryRepository().getCategoriesByType(categoryType);
  }

  @override
  void initState() {
    super.initState();
    _setDefaultCategory();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setDefaultCategory() {
    final categories = _categories;
    _selectedCategory = categories.isNotEmpty ? categories.first : null;
  }

  void _changeType(TransactionType type) {
    setState(() {
      _selectedType = type;
      _setDefaultCategory();
    });
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0 || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid transaction.')),
      );
      return;
    }

    await context.read<TransactionProvider>().addTransaction(
          title: _titleController.text.trim(),
          amount: amount,
          type: _selectedType,
          categoryId: _selectedCategory!.id,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          isRecurring: _isRecurring,
          recurrenceFrequency: _isRecurring ? _recurrenceFrequency : null,
        );

    if (!mounted) return;

    context.read<InsightsProvider>().loadInsights();
    context.read<BudgetProvider>().loadBudgets();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedType == TransactionType.income
              ? 'Income saved successfully.'
              : 'Expense saved successfully.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    final currency = context.select<SettingsProvider, AppCurrency>(
      (provider) => provider.currency,
    );

    final isIncome = _selectedType == TransactionType.income;
    final activeColor = isIncome ? AppColors.income : AppColors.expense;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _TypeToggle(
              selectedType: _selectedType,
              onChanged: _changeType,
            ),
            const SizedBox(height: 16),

            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('Transaction title'),
                  TextFormField(
                    controller: _titleController,
                    inputFormatters: AppInputFormatters.text(maxLength: 40),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Lunch, Salary, Transport',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a transaction title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  const _FieldLabel('Amount'),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: AppInputFormatters.positiveDecimal,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      prefixText: '${currency.symbol} ',
                      suffixIcon: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isIncome ? 'ADD' : 'SUBTRACT',
                          style: TextStyle(
                            color: activeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
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

            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('Category'),
                  DropdownButtonFormField<CategoryModel>(
                    initialValue: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Select a category';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  const _FieldLabel('Date'),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('Notes'),
                  TextFormField(
                    controller: _noteController,
                    inputFormatters: AppInputFormatters.note,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'What was this for?',
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile.adaptive(
                    value: _isRecurring,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Recurring Transaction',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Repeat this transaction weekly or monthly.',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isRecurring = value;
                      });
                    },
                  ),
                  if (_isRecurring) ...[
                    const SizedBox(height: 10),
                    SegmentedButton<RecurrenceFrequency>(
                      segments: const [
                        ButtonSegment(
                          value: RecurrenceFrequency.weekly,
                          label: Text('Weekly'),
                        ),
                        ButtonSegment(
                          value: RecurrenceFrequency.monthly,
                          label: Text('Monthly'),
                        ),
                      ],
                      selected: {_recurrenceFrequency},
                      onSelectionChanged: (value) {
                        setState(() {
                          _recurrenceFrequency = value.first;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _saveTransaction,
                icon: const Icon(Icons.check_circle),
                label: const Text('Save Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = selectedType == TransactionType.expense;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Expense',
              selected: isExpense,
              color: AppColors.expense,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Income',
              selected: !isExpense,
              color: AppColors.income,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.mutedText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

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