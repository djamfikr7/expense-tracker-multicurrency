import 'package:flutter/material.dart';
import '../models/transaction_filter.dart';
import '../models/project.dart';
import '../services/app_localizations.dart';

class TransactionFilterDialog extends StatefulWidget {
  final TransactionFilter initialFilter;
  final List<Project> projects;
  final Function(TransactionFilter) onApply;

  const TransactionFilterDialog({
    super.key,
    required this.initialFilter,
    required this.projects,
    required this.onApply,
  });

  @override
  State<TransactionFilterDialog> createState() =>
      _TransactionFilterDialogState();
}

class _TransactionFilterDialogState extends State<TransactionFilterDialog> {
  late String? _transactionType;
  late String? _projectId;

  @override
  void initState() {
    super.initState();
    _transactionType = widget.initialFilter.transactionType;
    _projectId = widget.initialFilter.projectId;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations.translate('filterTransactions')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Transaction Type
            DropdownButtonFormField<String?>(
              decoration: InputDecoration(
                labelText: localizations.translate('type'),
                border: const OutlineInputBorder(),
              ),
              value: _transactionType,
              items: [
                DropdownMenuItem(
                  value: null,
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
                setState(() => _transactionType = value);
              },
            ),
            const SizedBox(height: 16),

            // Project
            if (widget.projects.isNotEmpty)
              DropdownButtonFormField<String?>(
                decoration: InputDecoration(
                  labelText: localizations.translate('project'),
                  border: const OutlineInputBorder(),
                ),
                value: _projectId,
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(localizations.translate('allProjects')),
                  ),
                  ...widget.projects.map((project) {
                    return DropdownMenuItem(
                      value: project.id,
                      child: Row(
                        children: [
                          Text(project.icon),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              project.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _projectId = value);
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Reset filters
            setState(() {
              _transactionType = null;
              _projectId = null;
            });
          },
          child: Text(localizations.translate('reset')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            final newFilter = widget.initialFilter.copyWith(
              transactionType: _transactionType,
              projectId: _projectId,
              clearTransactionType: _transactionType == null,
              clearProjectId: _projectId == null,
            );
            widget.onApply(newFilter);
            Navigator.pop(context);
          },
          child: Text(localizations.translate('apply')),
        ),
      ],
    );
  }
}
