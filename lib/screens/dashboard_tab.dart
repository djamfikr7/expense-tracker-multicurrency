import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart' as models;
import '../services/app_localizations.dart';
import '../data/categories.dart';

class DashboardTab extends StatelessWidget {
  final List<models.Transaction> transactions;
  final List<models.Budget> budgets;
  final String currency;

  const DashboardTab({
    super.key,
    required this.transactions,
    required this.budgets,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // Filter transactions for current month
    final monthTransactions = transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();

    final totalIncome = monthTransactions
        .where((t) => t.type == 'income')
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalExpenses = monthTransactions
        .where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);

    final netBalance = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('dashboard'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _SummaryCard(
              title: localizations.translate('totalIncome'),
              amount: totalIncome,
              currency: currency,
              color: Colors.green,
              icon: Icons.arrow_downward,
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              title: localizations.translate('totalExpenses'),
              amount: totalExpenses,
              currency: currency,
              color: Colors.red,
              icon: Icons.arrow_upward,
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              title: localizations.translate('netBalance'),
              amount: netBalance,
              currency: currency,
              color: Colors.blue,
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 24),

            // Income vs Expense Chart
            if (totalIncome > 0 || totalExpenses > 0) ...[
              Text(
                'Income vs Expense',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: totalIncome,
                        title:
                            '${((totalIncome / (totalIncome + totalExpenses)) * 100).toStringAsFixed(1)}%',
                        color: Colors.green,
                        radius: 80,
                      ),
                      PieChartSectionData(
                        value: totalExpenses,
                        title:
                            '${((totalExpenses / (totalIncome + totalExpenses)) * 100).toStringAsFixed(1)}%',
                        color: Colors.red,
                        radius: 80,
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Expense Breakdown
            if (monthTransactions
                .where((t) => t.type == 'expense')
                .isNotEmpty) ...[
              Text(
                'Expense Breakdown',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _ExpenseBreakdown(
                transactions: monthTransactions
                    .where((t) => t.type == 'expense')
                    .toList(),
                currency: currency,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: getCurrencySymbol(currency),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter.format(amount),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getCurrencySymbol(String currency) {
    const Map<String, String> symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'SAR': 'SR',
      'AED': 'AED',
      'CAD': 'C\$',
      'AUD': 'A\$',
    };
    return symbols[currency] ?? currency;
  }
}

class _ExpenseBreakdown extends StatelessWidget {
  final List<models.Transaction> transactions;
  final String currency;

  const _ExpenseBreakdown({required this.transactions, required this.currency});

  @override
  Widget build(BuildContext context) {
    // Group by category
    final Map<String, double> categoryTotals = {};

    for (final transaction in transactions) {
      categoryTotals[transaction.categoryId] =
          (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
    }

    final total = categoryTotals.values.fold<double>(
      0,
      (sum, amount) => sum + amount,
    );
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
    );

    return Column(
      children: categoryTotals.entries.map((entry) {
        final category = Categories.getCategory(entry.key, 'expense');
        final percentage = (entry.value / total) * 100;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        category?.icon ?? '💸',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category?.name ?? entry.key,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Text(
                    formatter.format(entry.value),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(category?.color ?? 0xFF6366f1),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getCurrencySymbol(String currency) {
    const Map<String, String> symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'SAR': 'SR',
      'AED': 'AED',
      'CAD': 'C\$',
      'AUD': 'A\$',
    };
    return symbols[currency] ?? currency;
  }
}
