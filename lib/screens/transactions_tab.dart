import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart' as models;
import '../models/project.dart';
import '../services/app_localizations.dart';
import '../services/currency_rate_service.dart';
import '../services/storage_service.dart';
import '../models/transaction_filter.dart';
import '../widgets/transaction_filter_dialog.dart';
import 'edit_transaction_screen.dart';

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
  TransactionFilter _filter = const TransactionFilter();
  String _sortBy = 'newest';
  Map<String, Project> _projects = {};

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final storage = StorageService();
    final projects = await storage.getProjects();
    setState(() {
      _projects = {for (var p in projects) p.id: p};
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Filter and sort
    var filteredTransactions = _filter.apply(widget.transactions);

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
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => TransactionFilterDialog(
                          initialFilter: _filter,
                          projects: _projects.values.toList(),
                          onApply: (filter) {
                            setState(() => _filter = filter);
                          },
                        ),
                      );
                    },
                    icon: Icon(
                      _filter.hasActiveFilters
                          ? Icons.filter_list_alt
                          : Icons.filter_list,
                      color: _filter.hasActiveFilters
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                    label: Text(
                      _filter.hasActiveFilters
                          ? '${localizations.translate('filter')} (${_filter.activeFilterCount})'
                          : localizations.translate('filter'),
                      style: TextStyle(
                        color: _filter.hasActiveFilters
                            ? Theme.of(context).primaryColor
                            : null,
                        fontWeight: _filter.hasActiveFilters
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      side: _filter.hasActiveFilters
                          ? BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                        project: _projects[transaction.projectId],
                        onEdit: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTransactionScreen(
                                transaction: transaction,
                                currency: widget.currency,
                              ),
                            ),
                          );
                          if (result != null && result is models.Transaction) {
                            widget.onUpdate(result);
                          }
                        },
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
  final Project? project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionCard({
    required this.transaction,
    required this.currency,
    required this.rates,
    required this.useParallel,
    this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;
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
                    // Project chip
                    if (project != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(
                                project!.colorValue,
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(
                                  project!.colorValue,
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  project!.icon,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  project!.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(project!.colorValue),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Amount and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (transaction.currency != currency)
                    Text(
                      '${isIncome ? '+' : '-'}${formatter.format(convertedAmount)}',
                      style: TextStyle(
                        color: color.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                        color: Colors.blue,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: onDelete,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currencyCode) {
    try {
      return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
    } catch (_) {
      return currencyCode;
    }
  }
}
