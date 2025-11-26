import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/transaction.dart' as models;
import '../services/storage_service.dart';
import '../services/app_localizations.dart';
import 'add_project_screen.dart';
import 'add_transaction_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final StorageService _storage = StorageService();
  List<models.Transaction> _transactions = [];
  Map<String, double> _stats = {};
  bool _isLoading = true;
  late Project _currentProject;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final transactions = await _storage.getProjectTransactions(
      _currentProject.id,
    );
    final stats = await _storage.getProjectStats(_currentProject.id);

    // Refresh project data in case it was updated
    final updatedProject = await _storage.getProjectById(_currentProject.id);

    setState(() {
      _transactions = transactions;
      _stats = stats;
      if (updatedProject != null) {
        _currentProject = updatedProject;
      }
      _isLoading = false;
    });
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('deleteProject')),
        content: Text(
          AppLocalizations.of(context).translate('deleteProjectConfirmation'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context).translate('cancel').toUpperCase(),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              AppLocalizations.of(context).translate('delete').toUpperCase(),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.deleteProject(_currentProject.id);
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    }
  }

  Future<void> _editProject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProjectScreen(project: _currentProject),
      ),
    );

    if (result != null && result is Project) {
      await _loadData();
    }
  }

  Future<void> _addTransaction() async {
    final currency = await _storage.getCurrency();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          currency: currency,
          initialProjectId: _currentProject.id,
        ),
      ),
    );

    if (result != null && result is models.Transaction) {
      await _storage.addTransaction(result);
      await _loadData();
    }
  }

  Future<void> _deleteTransaction(String id) async {
    await _storage.deleteTransaction(id);
    await _loadData();
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  Color get _budgetColor {
    if (_currentProject.budget == null) return Colors.grey;
    final expenses = _stats['expenses'] ?? 0;
    final progress = expenses / _currentProject.budget!;
    if (progress >= 1.0) return Colors.red;
    if (progress >= 0.8) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProject.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProject,
            tooltip: localizations.translate('editProject'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProject,
            tooltip: localizations.translate('deleteProject'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // Project Header
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(
                          _currentProject.colorValue,
                        ).withOpacity(0.1),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(_currentProject.colorValue),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Icon and Name
                          Row(
                            children: [
                              Text(
                                _currentProject.icon,
                                style: const TextStyle(fontSize: 48),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentProject.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall,
                                    ),
                                    if (_currentProject.description != null)
                                      Text(
                                        _currentProject.description!,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Stats Cards
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: localizations.translate('income'),
                                  value: _formatCurrency(_stats['income'] ?? 0),
                                  color: Colors.green,
                                  icon: Icons.arrow_downward,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  label: localizations.translate('expense'),
                                  value: _formatCurrency(
                                    _stats['expenses'] ?? 0,
                                  ),
                                  color: Colors.red,
                                  icon: Icons.arrow_upward,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: localizations.translate('netBalance'),
                                  value: _formatCurrency(
                                    _stats['balance'] ?? 0,
                                  ),
                                  color: (_stats['balance'] ?? 0) >= 0
                                      ? Colors.blue
                                      : Colors.orange,
                                  icon: Icons.account_balance_wallet,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  label: localizations.translate(
                                    'transactions',
                                  ),
                                  value: (_stats['count'] ?? 0)
                                      .toInt()
                                      .toString(),
                                  color: Colors.purple,
                                  icon: Icons.receipt_long,
                                ),
                              ),
                            ],
                          ),

                          // Budget Progress
                          if (_currentProject.budget != null) ...[
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      localizations.translate('budget'),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    Text(
                                      '${_formatCurrency(_stats['expenses'] ?? 0)} / ${_formatCurrency(_currentProject.budget!)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _budgetColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value:
                                        (_stats['expenses'] ?? 0) /
                                        _currentProject.budget!,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation(
                                      _budgetColor,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Transactions Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${localizations.translate('transactions')} (${_transactions.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),

                  // Transactions List
                  _transactions.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  localizations.translate('noTransactionsYet'),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  localizations.translate(
                                    'tapToAddTransaction',
                                  ),
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final transaction = _transactions[index];
                            return Dismissible(
                              key: Key(transaction.id),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      localizations.translate('delete'),
                                    ),
                                    content: Text(
                                      localizations.translate(
                                        'actionCannotBeUndone',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          localizations
                                              .translate('cancel')
                                              .toUpperCase(),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: Text(
                                          localizations
                                              .translate('delete')
                                              .toUpperCase(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) =>
                                  _deleteTransaction(transaction.id),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: transaction.type == 'income'
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                  child: Icon(
                                    transaction.type == 'income'
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: transaction.type == 'income'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            );
                          }, childCount: _transactions.length),
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTransaction,
        icon: const Icon(Icons.add),
        label: Text(localizations.translate('addTransaction')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
