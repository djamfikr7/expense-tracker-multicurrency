import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart' as models;
import '../services/app_localizations.dart';
import '../data/categories.dart';

class BudgetsTab extends StatelessWidget {
  final List<models.Budget> budgets;
  final List<models.Transaction> transactions;
  final String currency;
  final Function(models.Budget) onAddBudget;

  const BudgetsTab({
    super.key,
    required this.budgets,
    required this.transactions,
    required this.currency,
    required this.onAddBudget,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('budgets')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(context),
          ),
        ],
      ),
      body: budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets set',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                return _BudgetCard(
                  budget: budget,
                  transactions: transactions,
                  currency: currency,
                );
              },
            ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    String? selectedCategory;
    double? amount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(localizations.translate('setBudget')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: localizations.translate('category'),
                  border: const OutlineInputBorder(),
                ),
                initialValue: selectedCategory,
                items: Categories.expenseCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Row(
                      children: [
                        Text(category.icon),
                        const SizedBox(width: 8),
                        Text(localizations.translate(category.id)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: localizations.translate('budgetLimit'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.translate('cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (selectedCategory != null && amount != null) {
                  final budget = models.Budget(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    categoryId: selectedCategory!,
                    amount: amount!,
                  );
                  onAddBudget(budget);
                  Navigator.pop(context);
                }
              },
              child: Text(localizations.translate('save')),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final models.Budget budget;
  final List<models.Transaction> transactions;
  final String currency;

  const _BudgetCard({
    required this.budget,
    required this.transactions,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();

    // Calculate spent this month
    final spent = transactions
        .where(
          (t) =>
              t.type == 'expense' &&
              t.categoryId == budget.categoryId &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold<double>(0, (sum, t) => sum + t.amount);

    final remaining = budget.amount - spent;
    final percentage = (spent / budget.amount).clamp(0.0, 1.0);

    Color progressColor;
    if (percentage >= 1.0) {
      progressColor = Colors.red;
    } else if (percentage >= 0.9) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    final category = Categories.getCategory(budget.categoryId, 'expense');
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  category?.icon ?? '💸',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate(budget.categoryId),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatter.format(budget.amount),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${localizations.translate('spent')}: ${formatter.format(spent)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${localizations.translate('remaining')}: ${formatter.format(remaining)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
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
