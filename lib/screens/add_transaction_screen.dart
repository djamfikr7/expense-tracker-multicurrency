import 'package:flutter/material.dart';
import '../models/transaction.dart' as models;
import '../services/app_localizations.dart';
import '../data/categories.dart';
import 'calculator_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'expense';
  double? _amount;
  String? _categoryId;
  DateTime _date = DateTime.now();
  String? _description;
  String _paymentMethod = 'cash';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final categories = _type == 'income'
        ? Categories.incomeCategories
        : Categories.expenseCategories;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('addTransaction'))),
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
                    _categoryId = null;
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
                        setState(() {
                          _amount = result;
                        });
                      }
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _amount?.toString() ?? '',
                ),
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
                initialValue: _categoryId,
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
                        Text(localizations.translate(category.id)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _date = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: localizations.translate('date'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                decoration: InputDecoration(
                  labelText: localizations.translate('description'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 16),

              // Payment Method
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: localizations.translate('paymentMethod'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.payment),
                ),
                initialValue: _paymentMethod,
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
                    value: 'bankTransfer',
                    child: Text(localizations.translate('bankTransfer')),
                  ),
                  DropdownMenuItem(
                    value: 'digitalWallet',
                    child: Text(localizations.translate('digitalWallet')),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final category = categories.firstWhere(
                      (c) => c.id == _categoryId,
                    );
                    final transaction = models.Transaction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: _type,
                      amount: _amount!,
                      categoryId: _categoryId!,
                      category: category.name,
                      icon: category.icon,
                      date: _date,
                      description: _description,
                      paymentMethod: _paymentMethod,
                    );

                    Navigator.pop(context, transaction);
                  }
                },
                icon: const Icon(Icons.save),
                label: Text(localizations.translate('save')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
