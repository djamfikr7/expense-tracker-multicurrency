import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_localizations.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;
  double _memory = 0.0;

  void _onNumberPressed(String number) {
    setState(() {
      if (_shouldResetDisplay) {
        _display = number;
        _shouldResetDisplay = false;
      } else {
        _display = _display == '0' ? number : _display + number;
      }
    });
  }

  void _onOperatorPressed(String operator) {
    setState(() {
      if (_firstOperand == null) {
        _firstOperand = double.tryParse(_display);
        _operator = operator;
        _expression = '$_display $operator';
        _shouldResetDisplay = true;
      } else {
        _calculate();
        _operator = operator;
        _expression = '$_display $operator';
        _shouldResetDisplay = true;
      }
    });
  }

  void _calculate() {
    if (_firstOperand == null || _operator == null) return;

    final secondOperand = double.tryParse(_display);
    if (secondOperand == null) return;

    double result = 0;
    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case '×':
        result = _firstOperand! * secondOperand;
        break;
      case '÷':
        if (secondOperand != 0) {
          result = _firstOperand! / secondOperand;
        } else {
          _display = 'Error';
          _firstOperand = null;
          _operator = null;
          _expression = '';
          return;
        }
        break;
    }

    setState(() {
      _display = result.toString();
      if (_display.endsWith('.0')) {
        _display = _display.substring(0, _display.length - 2);
      }
      _firstOperand = result;
      _expression = '';
    });
  }

  void _onEqualsPressed() {
    _calculate();
    setState(() {
      _operator = null;
      _shouldResetDisplay = true;
    });
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _onDecimal() {
    if (!_display.contains('.')) {
      setState(() {
        _display = '$_display.';
      });
    }
  }

  void _onDelete() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _onMemoryClear() {
    setState(() {
      _memory = 0.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memory Cleared'),
        duration: Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onMemoryRecall() {
    setState(() {
      _display = _memory.toString();
      if (_display.endsWith('.0')) {
        _display = _display.substring(0, _display.length - 2);
      }
      _shouldResetDisplay = true;
    });
  }

  void _onMemoryAdd() {
    final value = double.tryParse(_display) ?? 0.0;
    setState(() {
      _memory += value;
      _shouldResetDisplay = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to Memory'),
        duration: Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onMemorySubtract() {
    final value = double.tryParse(_display) ?? 0.0;
    setState(() {
      _memory -= value;
      _shouldResetDisplay = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subtracted from Memory'),
        duration: Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyToClipboard() {
    if (_display != '0' && _display != 'Error') {
      Clipboard.setData(ClipboardData(text: _display));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied: $_display'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('calculator')),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy),
            tooltip: 'Copy result',
            onPressed: _copyToClipboard,
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Use this amount',
            onPressed: () {
              final value = double.tryParse(_display);
              if (value != null) {
                Navigator.pop(context, value);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Display Area
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_memory != 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'M',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (_expression.isNotEmpty)
                    Text(
                      _expression,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _display,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 64,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Keypad Area
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildButtonRow(['MC', 'MR', 'M+', 'M-']),
                  _buildButtonRow(['C', '⌫', '.', '÷']),
                  _buildButtonRow(['7', '8', '9', '×']),
                  _buildButtonRow(['4', '5', '6', '-']),
                  _buildButtonRow(['1', '2', '3', '+']),
                  _buildButtonRow(['0', '00', '=', '']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels) {
    return Expanded(
      child: Row(
        children: labels.map((label) {
          if (label.isEmpty) return const Expanded(child: SizedBox());

          final isOperator = ['+', '-', '×', '÷'].contains(label);
          final isSpecial = ['C', '⌫', '='].contains(label);
          final isMemory = ['MC', 'MR', 'M+', 'M-'].contains(label);
          final isEquals = label == '=';

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onButtonPressed(label),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: isEquals
                          ? LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.tertiary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isEquals
                          ? null
                          : isOperator
                          ? Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.5)
                          : isSpecial
                          ? Theme.of(
                              context,
                            ).colorScheme.errorContainer.withOpacity(0.3)
                          : isMemory
                          ? Theme.of(
                              context,
                            ).colorScheme.secondaryContainer.withOpacity(0.3)
                          : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        if (isEquals)
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: isMemory ? 18 : 24,
                          fontWeight: isOperator || isSpecial || isMemory
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isEquals
                              ? Colors.white
                              : isOperator
                              ? Theme.of(context).colorScheme.primary
                              : isSpecial
                              ? Theme.of(context).colorScheme.error
                              : isMemory
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onButtonPressed(String label) {
    HapticFeedback.lightImpact(); // Add haptic feedback
    switch (label) {
      case 'C':
        _onClear();
        break;
      case '⌫':
        _onDelete();
        break;
      case '.':
        _onDecimal();
        break;
      case '=':
        _onEqualsPressed();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        _onOperatorPressed(label);
        break;
      case 'MC':
        _onMemoryClear();
        break;
      case 'MR':
        _onMemoryRecall();
        break;
      case 'M+':
        _onMemoryAdd();
        break;
      case 'M-':
        _onMemorySubtract();
        break;
      default:
        _onNumberPressed(label);
    }
  }
}
