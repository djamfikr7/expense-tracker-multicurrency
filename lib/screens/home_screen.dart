import 'package:flutter/material.dart';
import '../services/app_localizations.dart';
import '../services/storage_service.dart';
import '../models/transaction.dart' as models;
import 'dashboard_tab.dart';
import 'transactions_tab.dart';
import 'budgets_tab.dart';
import 'settings_tab.dart';
import 'add_transaction_screen.dart';
import 'calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final StorageService _storageService = StorageService();
  List<models.Transaction> _transactions = [];
  List<models.Budget> _budgets = [];
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await _storageService.getTransactions();
    final budgets = await _storageService.getBudgets();
    final currency = await _storageService.getCurrency();

    setState(() {
      _transactions = transactions;
      _budgets = budgets;
      _currency = currency;
    });
  }

  Future<void> _addTransaction(models.Transaction transaction) async {
    await _storageService.addTransaction(transaction);
    await _loadData();
  }

  Future<void> _updateTransaction(models.Transaction transaction) async {
    await _storageService.updateTransaction(transaction);
    await _loadData();
  }

  Future<void> _deleteTransaction(String id) async {
    await _storageService.deleteTransaction(id);
    await _loadData();
  }

  Future<void> _addBudget(models.Budget budget) async {
    await _storageService.addBudget(budget);
    await _loadData();
  }

  Future<void> _updateCurrency(String currency) async {
    await _storageService.setCurrency(currency);
    setState(() {
      _currency = currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final List<Widget> _pages = [
      DashboardTab(
        transactions: _transactions,
        budgets: _budgets,
        currency: _currency,
      ),
      TransactionsTab(
        transactions: _transactions,
        currency: _currency,
        onDelete: _deleteTransaction,
        onUpdate: _updateTransaction,
      ),
      BudgetsTab(
        budgets: _budgets,
        transactions: _transactions,
        currency: _currency,
        onAddBudget: _addBudget,
      ),
      const CalculatorScreen(),
      SettingsTab(currency: _currency, onCurrencyChanged: _updateCurrency),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: localizations.translate('dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: localizations.translate('transactions'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: localizations.translate('budgets'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calculate_outlined),
            selectedIcon: const Icon(Icons.calculate),
            label: localizations.translate('calculator'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: localizations.translate('settings'),
          ),
        ],
      ),
      floatingActionButton: _currentIndex < 3
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );

                if (result != null && result is models.Transaction) {
                  await _addTransaction(result);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localizations.translate('transactionAdded'),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: Text(localizations.translate('addTransaction')),
            )
          : null,
    );
  }
}
