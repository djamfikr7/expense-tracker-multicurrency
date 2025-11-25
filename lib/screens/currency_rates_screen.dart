import 'package:flutter/material.dart';
import '../models/currency_rate.dart';
import '../services/storage_service.dart';
import '../services/currency_rate_service.dart';
import '../services/app_localizations.dart';

class CurrencyRatesScreen extends StatefulWidget {
  const CurrencyRatesScreen({super.key});

  @override
  State<CurrencyRatesScreen> createState() => _CurrencyRatesScreenState();
}

class _CurrencyRatesScreenState extends State<CurrencyRatesScreen> {
  final _storageService = StorageService();
  Map<String, Map<String, double>> _customRates = {};
  bool _useParallelRates = false;
  bool _isUpdating = false;
  DateTime? _lastUpdated;
  String _selectedCurrency = 'USD';
  double _baseRate = 1.0; // Rate of selected currency per USD

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final rates = await _storageService.getCurrencyRates();
    final useParallel = await _storageService.getUseParallelRates();
    final currency = await _storageService.getCurrency();

    setState(() {
      _customRates = rates.map(
        (key, value) => MapEntry(key, {
          'official': (value['official'] ?? 0.0).toDouble(),
          'parallel': (value['parallel'] ?? 0.0).toDouble(),
        }),
      );
      _useParallelRates = useParallel;
      _selectedCurrency = currency;
      _updateBaseRate();
    });
  }

  void _updateBaseRate() {
    if (_selectedCurrency == 'USD') {
      _baseRate = 1.0;
      return;
    }

    // Find the rate of the selected currency (per USD)
    // We check custom rates first, then default rates
    double? rate;

    // Check custom rates
    if (_customRates.containsKey(_selectedCurrency)) {
      rate = _customRates[_selectedCurrency]?['official'];
    }

    // Check default rates if not found in custom
    if (rate == null) {
      try {
        final currency = CurrencyData.defaultCurrencies.firstWhere(
          (c) => c.code == _selectedCurrency,
        );
        rate = currency.officialRate;
      } catch (e) {
        // Selected currency not found in list, default to USD
        rate = 1.0;
      }
    }

    _baseRate = rate ?? 1.0;
  }

  Future<void> _saveRateModeToggle(bool value) async {
    await _storageService.setUseParallelRates(value);
    setState(() {
      _useParallelRates = value;
    });
  }

  Future<void> _autoUpdateRates() async {
    final localizations = AppLocalizations.of(context);
    setState(() {
      _isUpdating = true;
    });

    try {
      final fetchedRates = await CurrencyRateService.fetchParallelRates();

      if (fetchedRates.isNotEmpty) {
        for (final entry in fetchedRates.entries) {
          final code = entry.key;
          final data = entry.value;

          await _storageService.updateCurrencyRate(
            code,
            data['official'] ?? 0.0,
            data['parallel'] ?? 0.0,
          );
        }

        await _loadSettings();

        setState(() {
          _lastUpdated = DateTime.now();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ ${localizations.translate('ratesUpdated')}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.translate('updateFailed')}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  String _formatLastUpdated(AppLocalizations localizations) {
    if (_lastUpdated == null)
      return '${localizations.translate('lastUpdated')}: Never';
    final diff = DateTime.now().difference(_lastUpdated!);
    String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeAgo = '${diff.inHours}h ago';
    } else {
      timeAgo = '${diff.inDays}d ago';
    }
    return '${localizations.translate('lastUpdated')}: $timeAgo';
  }

  void _editCurrencyRate(CurrencyRate currency) {
    final localizations = AppLocalizations.of(context);
    final existingOfficialUSD =
        _customRates[currency.code]?['official'] ?? currency.officialRate;
    final existingParallelUSD =
        _customRates[currency.code]?['parallel'] ?? currency.parallelRate;

    // Convert to selected currency base for display
    final existingOfficial = existingOfficialUSD / _baseRate;
    final existingParallel = existingParallelUSD / _baseRate;

    final officialController = TextEditingController(
      text: existingOfficial.toStringAsFixed(4),
    );
    final parallelController = TextEditingController(
      text: existingParallel.toStringAsFixed(4),
    );

    final premium = CurrencyData.getPremium(currency);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${localizations.translate('edit')} ${currency.name}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (premium > 5)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Premium: +${premium.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            TextField(
              controller: officialController,
              decoration: InputDecoration(
                labelText:
                    '${localizations.translate('officialRate')} ($_selectedCurrency)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: parallelController,
              decoration: InputDecoration(
                labelText:
                    '${localizations.translate('parallelRate')} ($_selectedCurrency)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              final officialInput =
                  double.tryParse(officialController.text) ?? existingOfficial;
              final parallelInput =
                  double.tryParse(parallelController.text) ?? existingParallel;

              // Convert back to USD base for storage
              final officialUSD = officialInput * _baseRate;
              final parallelUSD = parallelInput * _baseRate;

              await _storageService.updateCurrencyRate(
                currency.code,
                officialUSD,
                parallelUSD,
              );
              await _loadSettings();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${currency.code} updated')),
                );
              }
            },
            child: Text(localizations.translate('save')),
          ),
        ],
      ),
    );
  }

  double _getCurrentRate(CurrencyRate currency) {
    final customOfficial = _customRates[currency.code]?['official'];
    final customParallel = _customRates[currency.code]?['parallel'];

    double rateInUSD;
    if (_useParallelRates) {
      rateInUSD = customParallel ?? currency.parallelRate;
    } else {
      rateInUSD = customOfficial ?? currency.officialRate;
    }

    // Convert to selected base currency
    return rateInUSD / _baseRate;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('exchangeRates'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_lastUpdated != null)
              Text(
                _formatLastUpdated(localizations),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          if (_isUpdating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.cloud_download),
              tooltip: localizations.translate('autoUpdate'),
              onPressed: _autoUpdateRates,
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(localizations.translate('aboutRates')),
                  content: Text(localizations.translate('ratesInfo')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Rate Mode Toggle Card
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              title: Text(
                localizations.translate('useParallelRates'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _useParallelRates
                    ? localizations.translate('usingParallel')
                    : localizations.translate('usingOfficial'),
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _useParallelRates ? Icons.trending_up : Icons.account_balance,
                  color: theme.colorScheme.primary,
                ),
              ),
              value: _useParallelRates,
              onChanged: _saveRateModeToggle,
            ),
          ),

          // Currency List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: CurrencyData.defaultCurrencies.length,
              itemBuilder: (context, index) {
                final currency = CurrencyData.defaultCurrencies[index];
                final currentRate = _getCurrentRate(currency);
                final hasCustomRate = _customRates.containsKey(currency.code);
                final premium = CurrencyData.getPremium(currency);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: hasCustomRate
                          ? theme.colorScheme.primary.withOpacity(0.3)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      child: Text(
                        currency.code.substring(0, 2),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          currency.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (premium > 10)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: premium > 50
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: premium > 50
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.orange.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              '+${premium.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: premium > 50
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${currency.code} • ${_useParallelRates ? localizations.translate('parallelRate') : localizations.translate('officialRate')}: ${currentRate.toStringAsFixed(2)} $_selectedCurrency',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasCustomRate)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              localizations.translate('custom'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                    onTap: () => _editCurrencyRate(currency),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
