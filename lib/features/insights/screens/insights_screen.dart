import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sovereign_ledger/core/constants/app_colors.dart';
import 'package:sovereign_ledger/core/utils/currency_formatter.dart';
import 'package:sovereign_ledger/providers/insights_provider.dart';
import 'package:sovereign_ledger/core/constants/app_currencies.dart';
import 'package:sovereign_ledger/providers/settings_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightsProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _InsightsHeader(),
              const SizedBox(height: 18),
              _InsightSummaryCards(provider: provider),
              const SizedBox(height: 22),
              const Text(
                'Spending Allocation',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (provider.categorySpend.isEmpty)
                const _EmptyInsightsState()
              else ...[
                _SpendingPieChart(provider: provider),
                const SizedBox(height: 16),
                const SizedBox(height: 18),
                _CategorySpendList(provider: provider),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InsightsHeader extends StatelessWidget {
  const _InsightsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryLight,
          child: Icon(
            Icons.insights,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Financial Insights',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<InsightsProvider>().loadInsights();
          },
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

class _InsightSummaryCards extends StatelessWidget {
  final InsightsProvider provider;

  const _InsightSummaryCards({required this.provider});

  @override
  Widget build(BuildContext context) {

    final currency = context.select<SettingsProvider, AppCurrency>(
      (provider) => provider.currency,
    );

    final net = provider.totalIncome - provider.totalExpense;
    final savingsRate =
        provider.totalIncome == 0 ? 0 : (net / provider.totalIncome) * 100;

    return Row(
      children: [
        Expanded(
          child: _InsightCard(
            title: 'Income',
            value: CurrencyFormatter.format(provider.totalIncome, currency: currency),
            color: AppColors.income,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InsightCard(
            title: 'Expense',
            value: CurrencyFormatter.format(provider.totalExpense, currency: currency),
            color: AppColors.expense,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InsightCard(
            title: 'Savings',
            value: '${savingsRate.clamp(-999, 999).toStringAsFixed(0)}%',
            color: net < 0 ? AppColors.expense : AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
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
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingPieChart extends StatelessWidget {
  final InsightsProvider provider;

  const _SpendingPieChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final total = provider.categorySpend.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 48,
                sections: provider.categorySpend.map((item) {
                  final percent = total == 0 ? 0 : (item.amount / total) * 100;

                  return PieChartSectionData(
                    value: item.amount,
                    title: '${percent.toStringAsFixed(0)}%',
                    radius: 58,
                    color: Color(item.colorValue),
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 15),
          _CompactChartLegend(provider: provider),
          const SizedBox(height: 10),
          // Text(
          //   'Total Spend: ${CurrencyFormatter.format(total)}',
          //   style: const TextStyle(
          //     color: AppColors.darkText,
          //     fontWeight: FontWeight.w900,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _CompactChartLegend extends StatelessWidget {
  final InsightsProvider provider;

  const _CompactChartLegend({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: provider.categorySpend.take(5).map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Color(item.colorValue),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              item.categoryName,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _CategorySpendList extends StatelessWidget {
  final InsightsProvider provider;

  const _CategorySpendList({required this.provider});

  @override
  Widget build(BuildContext context) {

    final currency = context.select<SettingsProvider, AppCurrency>(
      (provider) => provider.currency,
    );

    return Column(
      children: provider.categorySpend.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Color(item.colorValue).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: Color(item.colorValue),
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.categoryName,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.format(item.amount, currency: currency),
                style: const TextStyle(
                  color: AppColors.expense,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyInsightsState extends StatelessWidget {
  const _EmptyInsightsState();

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
            Icons.pie_chart_outline_rounded,
            color: AppColors.primary,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'No spending data yet',
            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add expense transactions to generate spending insights.',
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