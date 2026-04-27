import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sovereign_ledger/core/constants/app_colors.dart';
import 'package:sovereign_ledger/core/enums/transaction_type.dart';
import 'package:sovereign_ledger/core/utils/currency_formatter.dart';
import 'package:sovereign_ledger/core/utils/security_guard.dart';
import 'package:sovereign_ledger/data/models/transaction_model.dart';
import 'package:sovereign_ledger/providers/security_provider.dart';
import 'package:sovereign_ledger/providers/transaction_provider.dart';
import 'package:sovereign_ledger/providers/settings_provider.dart';
import 'package:sovereign_ledger/core/constants/app_currencies.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
     final isUnlocked = context.select<SecurityProvider, bool>(
      (provider) => provider.isUnlocked,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const SizedBox(height: 18),
          _BalanceCard(isUnlocked: isUnlocked),
          const SizedBox(height: 18),
          _SummaryRow(isUnlocked: isUnlocked),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Recent Ledger', actionText: 'View All'),
          const SizedBox(height: 12),
          if (isUnlocked) const _RecentLedgerList() else const _LockedLedgerState(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
            'Sovereign Ledger',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
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

class _BalanceCard extends StatelessWidget {
  final bool isUnlocked;

  const _BalanceCard({
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.select<SettingsProvider, AppCurrency>(
      (provider) => provider.currency,
    );

    final balance = context.select<TransactionProvider, double>(
      (provider) => provider.balance,
    );

    final isNegative = balance < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF004AAD),
            Color(0xFF0F5ED7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIQUID WEALTH PORTFOLIO',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isUnlocked ? CurrencyFormatter.format(balance, currency: currency) : '••••••••',
            style: TextStyle(
              color: isUnlocked && isNegative
                  ? const Color(0xFFFFD1D1)
                  : Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            !isUnlocked
                ? 'Verify liveness to view dashboard data'
                : isNegative
                    ? 'Balance is currently below zero'
                    : 'Market valuation as of today',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          if (!isUnlocked)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
                onPressed: () async {
                  await ensureSecurityUnlocked(context);
                },
                child: const Text('Unlock Dashboard'),
              ),
            )
          else
            Row(
              children: [
                _BalanceActionButton(
                  label: 'DEPOSIT',
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                _BalanceActionButton(
                  label: 'WITHDRAW',
                  onTap: () {},
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BalanceActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BalanceActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 38,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final bool isUnlocked;

  const _SummaryRow({
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.select<SettingsProvider, AppCurrency>(
      (provider) => provider.currency,
    );
    final totalIncome = context.select<TransactionProvider, double>(
      (provider) => provider.totalIncome,
    );

    final totalExpense = context.select<TransactionProvider, double>(
      (provider) => provider.totalExpense,
    );

    final balance = context.select<TransactionProvider, double>(
      (provider) => provider.balance,
    );

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Income',
            value: isUnlocked ? CurrencyFormatter.format(totalIncome, currency: currency) : '••••',
            icon: Icons.arrow_downward_rounded,
            color: AppColors.income,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Expense',
            value: isUnlocked ? CurrencyFormatter.format(totalExpense, currency: currency) : '••••',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.expense,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Net',
            value: isUnlocked ? CurrencyFormatter.format(balance, currency: currency) : '••••',
            icon: Icons.account_balance_wallet_outlined,
            color: isUnlocked && balance < 0 ? AppColors.expense : AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(13),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;

  const _SectionTitle({
    required this.title,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.darkText,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: Text(
            actionText.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _LockedLedgerState extends StatelessWidget {
  const _LockedLedgerState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lock_outline,
            color: AppColors.primary,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'Ledger is locked',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Verify liveness to view recent financial activity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () async {
              await ensureSecurityUnlocked(context);
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }
}

class _RecentLedgerList extends StatelessWidget {
  const _RecentLedgerList();

  @override
  Widget build(BuildContext context) {
    final transactions = context.select<TransactionProvider, List<TransactionModel>>(
      (provider) => provider.transactions.take(8).toList(),
    );

    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
              size: 34,
            ),
            SizedBox(height: 10),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Use the quick action button to add your first ledger entry.',
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

    return Column(
      children: transactions.map((transaction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _TransactionTile(transaction: transaction),
        );
      }).toList(),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.select<SettingsProvider, AppCurrency>(
      (provider) => provider.currency,
    );

    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final sign = isIncome ? '+' : '-';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.type.name.toUpperCase()} • ${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$sign${CurrencyFormatter.format(transaction.amount, currency: currency)}',
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}