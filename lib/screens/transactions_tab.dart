import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart' as models;
import '../services/app_localizations.dart';
import '../services/currency_rate_service.dart';
import '../data/categories.dart';

class TransactionsTab extends StatefulWidget {
  final List<models.Transaction> transactions;
  final String currency;
  final Map<String, Map<String, dynamic>> rates;
  final bool useParallel;
  final Function(String) onDelete;
  final Function(models.Transaction) onUpdate;

  const TransactionsTab({
    super.key,
    required this.transactions,
    required this.currency,
    required this.rates,
    required this.useParallel,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  String _filterType = 'all';
  String _sortBy = 'newest';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Filter and sort
    var filteredTransactions = widget.transactions.where((t) {
      if (_filterType == 'all') return true;
      return t.type == _filterType;
    }).toList();

    filteredTransactions.sort((a, b) {
      switch (_sortBy) {
        case 'oldest':
          return a.date.compareTo(b.date);
        case 'highest':
          return b.amount.compareTo(a.amount);
        case 'lowest':
          return a.amount.compareTo(b.amount);
        default: // newest
          return b.date.compareTo(a.date);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('transactions'))),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterType,
                    decoration: InputDecoration(
                      labelText: localizations.translate('filter'),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text(localizations.translate('all')),
                      ),
                      DropdownMenuItem(
                        value: 'income',
                        child: Text(localizations.translate('income')),
                      ),
                      DropdownMenuItem(
                        value: 'expense',
                        child: Text(localizations.translate('expense')),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sortBy,
                    decoration: InputDecoration(
                      labelText: localizations.translate('sortBy'),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'newest',
                        child: Text(localizations.translate('newest')),
                      ),
                      DropdownMenuItem(
                        value: 'oldest',
                        child: Text(localizations.translate('oldest')),
                      ),
                      DropdownMenuItem(
                        value: 'highest',
                        child: Text(localizations.translate('highestAmount')),
                      ),
                      DropdownMenuItem(
                        value: 'lowest',
                        child: Text(localizations.translate('lowestAmount')),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.translate('noTransactions'),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return _TransactionCard(
                        transaction: transaction,
                        currency: widget.currency,
                        rates: widget.rates,
                        useParallel: widget.useParallel,
                        onDelete: () => widget.onDelete(transaction.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final models.Transaction transaction;
  final String currency;
  final Map<String, Map<String, dynamic>> rates;
  final bool useParallel;
  final VoidCallback onDelete;

  const _TransactionCard({
    required this.transaction,
    required this.currency,
    required this.rates,
    required this.useParallel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final category = Categories.getCategory(
      transaction.categoryId,
      transaction.type,
    );
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
    );

    final convertedAmount = CurrencyRateService.convertAmount(
      amount: transaction.amount,
      fromCurrency: transaction.currency,
      toCurrency: currency,
      rates: rates,
      useParallel: useParallel,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (transaction.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().format(transaction.date),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Amount and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}${formatter.format(convertedAmount)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Transaction'),
                          content: const Text(
                            'Are you sure you want to delete this transaction?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                onDelete();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transaction deleted'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
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
