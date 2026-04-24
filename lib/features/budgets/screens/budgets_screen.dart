import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sovereign_ledger/core/constants/app_colors.dart';
import 'package:sovereign_ledger/core/utils/currency_formatter.dart';
import 'package:sovereign_ledger/data/models/budget_model.dart';
import 'package:sovereign_ledger/data/models/category_model.dart';
import 'package:sovereign_ledger/data/repositories/category_repository.dart';
import 'package:sovereign_ledger/features/budgets/screens/add_budget_screen.dart';
import 'package:sovereign_ledger/providers/budget_provider.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = context.select<BudgetProvider, List<BudgetModel>>(
      (provider) => provider.budgets,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BudgetHeader(),
              const SizedBox(height: 18),
              _BudgetSummaryCard(budgets: budgets),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddBudgetScreen(),
                      ),
                    );

                    if (!context.mounted) return;
                    context.read<BudgetProvider>().loadBudgets();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Category'),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Categories',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (budgets.isEmpty)
                const _EmptyBudgetState()
              else
                ...budgets.map((budget) => _BudgetTile(budget: budget)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryLight,
          child: Icon(
            Icons.account_balance_wallet,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Budgets & Categories',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  final List<BudgetModel> budgets;

  const _BudgetSummaryCard({required this.budgets});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BudgetProvider>();

    final totalLimit = budgets.fold<double>(
      0,
      (sum, budget) => sum + budget.amountLimit,
    );

    final totalSpent = budgets.fold<double>(
      0,
      (sum, budget) => sum + provider.spentAmount(budget),
    );

    final progress = totalLimit == 0 ? 0.0 : (totalSpent / totalLimit);
    final isOverLimit = totalSpent > totalLimit && totalLimit > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MONTHLY BUDGET',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            CurrencyFormatter.format(totalLimit),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${CurrencyFormatter.format(totalSpent)} used',
            style: TextStyle(
              color: isOverLimit ? AppColors.expense : AppColors.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverLimit ? AppColors.expense : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  final BudgetModel budget;

  const _BudgetTile({required this.budget});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BudgetProvider>();
    final category = CategoryRepository()
        .getAllCategories()
        .firstWhere((item) => item.id == budget.categoryId);

    final spent = provider.spentAmount(budget);
    final remaining = provider.remainingAmount(budget);
    final progress = provider.progress(budget);
    final isOverLimit = provider.isOverLimit(budget);

    final progressColor = isOverLimit ? AppColors.expense : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _CategoryIcon(category: category),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                isOverLimit ? 'OVER LIMIT' : 'ON TRACK',
                style: TextStyle(
                  color: isOverLimit ? AppColors.expense : AppColors.income,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                CurrencyFormatter.format(spent),
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                ' of ${CurrencyFormatter.format(budget.amountLimit)}',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                isOverLimit
                    ? '${CurrencyFormatter.format(remaining.abs())} over'
                    : '${CurrencyFormatter.format(remaining)} left',
                style: TextStyle(
                  color: isOverLimit ? AppColors.expense : AppColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final CategoryModel category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Color(category.colorValue).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        Icons.category_outlined,
        color: Color(category.colorValue),
        size: 20,
      ),
    );
  }
}

class _EmptyBudgetState extends StatelessWidget {
  const _EmptyBudgetState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
            size: 36,
          ),
          SizedBox(height: 10),
          Text(
            'No budgets yet',
            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Create a category budget to start tracking your spending limits.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}