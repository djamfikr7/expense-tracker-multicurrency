import 'package:flutter/material.dart';
import '../services/app_localizations.dart';
import '../main.dart';
import 'currency_rates_screen.dart';

class SettingsTab extends StatelessWidget {
  final String currency;
  final Function(String) onCurrencyChanged;

  const SettingsTab({
    super.key,
    required this.currency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final appState = ExpenseTrackerApp.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //Language
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(localizations.translate('language')),
              trailing: DropdownButton<String>(
                value: localizations.locale.languageCode,
                underline: Container(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  DropdownMenuItem(value: 'zh', child: Text('中文')),
                ],
                onChanged: (value) {
                  if (value != null && appState != null) {
                    appState.setLocale(Locale(value));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Theme
          Card(
            child: SwitchListTile(
              secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: Text(localizations.translate('darkMode')),
              value: isDarkMode,
              onChanged: (value) {
                if (appState != null) {
                  appState.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // Currency
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money),
              title: Text(localizations.translate('currency')),
              trailing: DropdownButton<String>(
                value: currency,
                underline: Container(),
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  DropdownMenuItem(value: 'JPY', child: Text('JPY')),
                  DropdownMenuItem(value: 'CNY', child: Text('CNY')),
                  DropdownMenuItem(value: 'CAD', child: Text('CAD')),
                  DropdownMenuItem(value: 'AUD', child: Text('AUD')),
                  DropdownMenuItem(value: 'SAR', child: Text('SAR')),
                  DropdownMenuItem(value: 'AED', child: Text('AED')),
                  DropdownMenuItem(value: 'EGP', child: Text('EGP')),
                  DropdownMenuItem(value: 'DZD', child: Text('DZD')),
                  DropdownMenuItem(value: 'TND', child: Text('TND')),
                  DropdownMenuItem(value: 'MAD', child: Text('MAD')),
                  DropdownMenuItem(value: 'LYD', child: Text('LYD')),
                  DropdownMenuItem(value: 'MRU', child: Text('MRU')),
                  DropdownMenuItem(value: 'XOF', child: Text('XOF')),
                  DropdownMenuItem(value: 'XAF', child: Text('XAF')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onCurrencyChanged(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Manage Exchange Rates
          Card(
            child: ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: Text(localizations.translate('manageRates')),
              subtitle: Text(localizations.translate('manageRatesSubtitle')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CurrencyRatesScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // App Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('appTitle'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${localizations.translate('version')} 1.0.0',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(localizations.translate('appDescription')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
