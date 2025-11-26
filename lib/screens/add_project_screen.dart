import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/storage_service.dart';
import '../services/app_localizations.dart';

class AddProjectScreen extends StatefulWidget {
  final Project? project;

  const AddProjectScreen({super.key, this.project});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  String _selectedIcon = '📁';
  int _selectedColor = 0xFF2196F3;
  DateTime? _deadline;

  final List<String> _iconOptions = [
    '📁',
    '🏢',
    '🌴',
    '🎯',
    '💼',
    '🏠',
    '✈️',
    '🎓',
    '🏥',
    '🛒',
    '🎨',
    '⚙️',
    '📊',
    '💡',
    '🚀',
    '🎉',
  ];

  final List<int> _colorOptions = [
    0xFF2196F3,
    0xFF4CAF50,
    0xFFFF9800,
    0xFFF44336,
    0xFF9C27B0,
    0xFF00BCD4,
    0xFFFFEB3B,
    0xFF795548,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _budgetController.text = widget.project!.budget?.toString() ?? '';
      _selectedIcon = widget.project!.icon;
      _selectedColor = widget.project!.colorValue;
      _deadline = widget.project!.deadline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final storage = StorageService();
    final project = Project(
      id: widget.project?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      icon: _selectedIcon,
      colorValue: _selectedColor,
      budget: _budgetController.text.isEmpty
          ? null
          : double.tryParse(_budgetController.text),
      deadline: _deadline,
      createdDate: widget.project?.createdDate,
    );

    if (widget.project == null) {
      await storage.addProject(project);
    } else {
      await storage.updateProject(project);
    }

    if (mounted) {
      Navigator.pop(context, project);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project != null
              ? localizations.translate('editProject')
              : localizations.translate('newProject'),
        ),
        actions: [
          TextButton(
            onPressed: _saveProject,
            child: Text(
              localizations.translate('save').toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              localizations.translate('icon'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconOptions.map((icon) {
                final isSelected = icon == _selectedIcon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.translate('color'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((colorValue) {
                final isSelected = colorValue == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = colorValue),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 4,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Color(colorValue), blurRadius: 8)]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${localizations.translate('projectName')} *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.label),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? localizations.translate('enterProjectName')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: localizations.translate('descriptionOptional'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              decoration: InputDecoration(
                labelText: localizations.translate('budgetOptional'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null) {
                  return localizations.translate('enterValidNumber');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(localizations.translate('deadlineOptional')),
              subtitle: Text(
                _deadline != null
                    ? '${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}'
                    : localizations.translate('noDeadlineSet'),
              ),
              trailing: _deadline != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _deadline = null),
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) setState(() => _deadline = date);
              },
            ),
          ],
        ),
      ),
    );
  }
}
