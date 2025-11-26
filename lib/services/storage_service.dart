import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/project.dart';

class StorageService {
  static const String _transactionsKey = 'transactions';
  static const String _budgetsKey = 'budgets';
  static const String _currencyKey = 'currency';

  // Transactions
  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString(_transactionsKey);

    if (transactionsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(transactionsJson);
    return decoded.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      transactions.map((t) => t.toJson()).toList(),
    );
    await prefs.setString(_transactionsKey, encoded);
  }

  Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    await saveTransactions(transactions);
  }

  // Budgets
  Future<List<Budget>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? budgetsJson = prefs.getString(_budgetsKey);

    if (budgetsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(budgetsJson);
    return decoded.map((json) => Budget.fromJson(json)).toList();
  }

  Future<void> saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(budgets.map((b) => b.toJson()).toList());
    await prefs.setString(_budgetsKey, encoded);
  }

  Future<void> addBudget(Budget budget) async {
    final budgets = await getBudgets();
    // Remove existing budget for this category
    budgets.removeWhere((b) => b.categoryId == budget.categoryId);
    budgets.add(budget);
    await saveBudgets(budgets);
  }

  // Currency
  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'USD';
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  // Currency Rates
  static const String _currencyRatesKey = 'currencyRates';
  static const String _rateModeKey = 'rateMode';

  Future<Map<String, dynamic>> getCurrencyRates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ratesJson = prefs.getString(_currencyRatesKey);

    if (ratesJson == null) return {};

    return jsonDecode(ratesJson) as Map<String, dynamic>;
  }

  Future<void> saveCurrencyRates(Map<String, dynamic> rates) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(rates);
    await prefs.setString(_currencyRatesKey, encoded);
  }

  Future<void> updateCurrencyRate(
    String currencyCode,
    double officialRate,
    double parallelRate,
  ) async {
    final rates = await getCurrencyRates();
    rates[currencyCode] = {'official': officialRate, 'parallel': parallelRate};
    await saveCurrencyRates(rates);
  }

  // Rate Mode (official or parallel)
  Future<bool> getUseParallelRates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rateModeKey) ??
        false; // false = official, true = parallel
  }

  Future<void> setUseParallelRates(bool useParallel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rateModeKey, useParallel);
  }

  // Projects
  static const String _projectsKey = 'projects';

  Future<List<Project>> getProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final String? projectsJson = prefs.getString(_projectsKey);

    if (projectsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(projectsJson);
    return decoded.map((json) => Project.fromJson(json)).toList();
  }

  Future<void> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString(_projectsKey, encoded);
  }

  Future<void> addProject(Project project) async {
    final projects = await getProjects();
    projects.add(project);
    await saveProjects(projects);
  }

  Future<void> updateProject(Project project) async {
    final projects = await getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
      await saveProjects(projects);
    }
  }

  Future<void> deleteProject(String id) async {
    final projects = await getProjects();
    projects.removeWhere((p) => p.id == id);
    await saveProjects(projects);

    // Optional: Remove project reference from transactions
    final transactions = await getTransactions();
    final updated = transactions.map((t) {
      if (t.projectId == id) {
        // Create new transaction without project
        return Transaction(
          id: t.id,
          type: t.type,
          amount: t.amount,
          categoryId: t.categoryId,
          category: t.category,
          icon: t.icon,
          date: t.date,
          description: t.description,
          paymentMethod: t.paymentMethod,
          isRecurring: t.isRecurring,
          frequency: t.frequency,
          currency: t.currency,
          projectId: null, // Remove project reference
        );
      }
      return t;
    }).toList();
    await saveTransactions(updated);
  }

  // Project query methods
  Future<List<Transaction>> getProjectTransactions(String projectId) async {
    final transactions = await getTransactions();
    return transactions.where((t) => t.projectId == projectId).toList();
  }

  Future<Map<String, double>> getProjectStats(String projectId) async {
    final transactions = await getProjectTransactions(projectId);

    double totalIncome = 0;
    double totalExpenses = 0;

    for (final transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
      'count': transactions.length.toDouble(),
    };
  }

  Future<Project?> getProjectById(String id) async {
    final projects = await getProjects();
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
