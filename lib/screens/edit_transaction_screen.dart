import 'package:flutter/material.dart';
import '../models/transaction.dart' as models;
import '../services/app_localizations.dart';
import '../data/categories.dart';
import 'calculator_screen.dart';

class EditTransactionScreen extends StatefulWidget {
  final models.Transaction transaction;
  final String currency;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.currency,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late double _amount;
  late String _categoryId;
  late DateTime _date;
  late String? _description;
  late String _paymentMethod;
  late bool _isRecurring;
  late String? _frequency;

  @override
  void initState() {
    super.initState();
    // Initialize with existing transaction values
    _type = widget.transaction.type;
    _amount = widget.transaction.amount;
    _categoryId = widget.transaction.categoryId;
    _date = widget.transaction.date;
    _description = widget.transaction.description;
    _paymentMethod = widget.transaction.paymentMethod;
    _isRecurring = widget.transaction.isRecurring;
    _frequency = widget.transaction.frequency;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final categories = _type == 'income'
        ? Categories.incomeCategories
        : Categories.expenseCategories;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('editTransaction'))),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Toggle
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'expense',
                    label: Text(localizations.translate('expense')),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text(localizations.translate('income')),
                    icon: const Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _type = selection.first;
                    // Reset category when type changes
                    final newCategories = _type == 'income'
                        ? Categories.incomeCategories
                        : Categories.expenseCategories;
                    if (!newCategories.any((c) => c.id == _categoryId)) {
                      _categoryId = newCategories.first.id;
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              // Amount
              TextFormField(
                decoration: InputDecoration(
                  labelText: localizations.translate('amount'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calculate),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalculatorScreen(),
                        ),
                      );
                      if (result != null && result is double) {
                        setState(() => _amount = result);
                      }
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
                initialValue: _amount.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: localizations.translate('category'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                value: categories.any((c) => c.id == _categoryId)
                    ? _categoryId
                    : categories.first.id,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Row(
                      children: [
                        Text(
                          category.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(localizations.translate(category.name)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _categoryId = value!);
                },
                validator: (value) {
                  if (value == null) return 'Please select a category';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(localizations.translate('date')),
                subtitle: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _date = picked);
                  }
                },
              ),
              const Divider(),

              // Description
              TextFormField(
                decoration: InputDecoration(
                  labelText: localizations.translate('description'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                  hintText: 'Optional',
                ),
                initialValue: _description,
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 16),

              // Payment Method
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: localizations.translate('paymentMethod'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.payment),
                ),
                value: _paymentMethod,
                items: [
                  DropdownMenuItem(
                    value: 'cash',
                    child: Text(localizations.translate('cash')),
                  ),
                  DropdownMenuItem(
                    value: 'card',
                    child: Text(localizations.translate('card')),
                  ),
                  DropdownMenuItem(
                    value: 'bank',
                    child: Text(localizations.translate('bank')),
                  ),
                  DropdownMenuItem(
                    value: 'mobile',
                    child: Text(localizations.translate('mobile')),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text(localizations.translate('other')),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _paymentMethod = value!);
                },
              ),
              const SizedBox(height: 16),

              // Recurring Toggle
              SwitchListTile(
                title: Text(localizations.translate('recurring')),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                    if (!value) _frequency = null;
                  });
                },
              ),

              // Frequency (shown only if recurring)
              if (_isRecurring)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: localizations.translate('frequency'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.repeat),
                  ),
                  value: _frequency ?? 'monthly',
                  items: [
                    DropdownMenuItem(
                      value: 'daily',
                      child: Text(localizations.translate('daily')),
                    ),
                    DropdownMenuItem(
                      value: 'weekly',
                      child: Text(localizations.translate('weekly')),
                    ),
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text(localizations.translate('monthly')),
                    ),
                    DropdownMenuItem(
                      value: 'yearly',
                      child: Text(localizations.translate('yearly')),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _frequency = value);
                  },
                ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  localizations.translate('save'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Find the selected category details
      final categories = _type == 'income'
          ? Categories.incomeCategories
          : Categories.expenseCategories;
      final selectedCategory = categories.firstWhere(
        (c) => c.id == _categoryId,
      );

      final updatedTransaction = models.Transaction(
        id: widget.transaction.id, // Keep same ID
        type: _type,
        amount: _amount,
        categoryId: _categoryId,
        category: selectedCategory.name,
        icon: selectedCategory.icon,
        date: _date,
        description: _description,
        paymentMethod: _paymentMethod,
        isRecurring: _isRecurring,
        frequency: _frequency,
        currency: widget.transaction.currency, // Keep original currency
      );

      Navigator.pop(context, updatedTransaction);
    }
  }
}
