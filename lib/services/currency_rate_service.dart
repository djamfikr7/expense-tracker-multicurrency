import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';

class CurrencyRateService {
  // Free API endpoints for exchange rates
  static const String _exchangeRateApiUrl =
      'https://api.exchangerate-api.com/v4/latest/USD';

  /// Fetch latest parallel market rates from multiple sources
  /// STRATEGY: Fetch base USD rates from free API and calculate cross-rates locally.
  /// We only prioritize major international currencies and specific regional ones.
  static Future<Map<String, Map<String, double>>> fetchParallelRates() async {
    try {
      print('📡 Fetching rates from API...');

      // Fetch official rates from free API with timeout
      final response = await http
          .get(Uri.parse(_exchangeRateApiUrl))
          .timeout(const Duration(seconds: 10));

      print('📥 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final officialRates = data['rates'] as Map<String, dynamic>;

        // Apply parallel market adjustments based on real-world premiums
        final parallelRates = <String, Map<String, double>>{};

        // Algeria - significant parallel market (USD ~240 DZD vs official ~134)
        if (officialRates.containsKey('DZD')) {
          final officialDzd = officialRates['DZD'].toDouble();
          parallelRates['DZD'] = {
            'official': officialDzd,
            'parallel': officialDzd * 1.89, // ~89% premium (EUR ~283)
            'confidence': 0.90,
          };
        }

        // Egypt - moderate parallel market
        if (officialRates.containsKey('EGP')) {
          final officialEgp = officialRates['EGP'].toDouble();
          parallelRates['EGP'] = {
            'official': officialEgp,
            'parallel': officialEgp * 2.35, // ~135% premium
            'confidence': 0.85,
          };
        }

        // Tunisia
        if (officialRates.containsKey('TND')) {
          final officialTnd = officialRates['TND'].toDouble();
          parallelRates['TND'] = {
            'official': officialTnd,
            'parallel': officialTnd * 1.65, // ~65% premium
            'confidence': 0.80,
          };
        }

        // Libya
        if (officialRates.containsKey('LYD')) {
          final officialLyd = officialRates['LYD'].toDouble();
          parallelRates['LYD'] = {
            'official': officialLyd,
            'parallel': officialLyd * 1.42, // ~42% premium
            'confidence': 0.70,
          };
        }

        // Mauritania
        if (officialRates.containsKey('MRU')) {
          final officialMru = officialRates['MRU'].toDouble();
          parallelRates['MRU'] = {
            'official': officialMru,
            'parallel': officialMru * 1.08, // ~8% premium
            'confidence': 0.65,
          };
        }

        // Add currencies with no parallel market
        for (final code in [
          'USD',
          'EUR',
          'GBP',
          'JPY',
          'CNY',
          'CAD',
          'AUD',
          'SAR',
          'AED',
          'MAD',
          'XOF',
          'XAF',
        ]) {
          if (officialRates.containsKey(code)) {
            final rate = officialRates[code].toDouble();
            parallelRates[code] = {
              'official': rate,
              'parallel': rate,
              'confidence': 1.0,
            };
          }
        }

        return parallelRates;
      } else {
        print('❌ API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching rates: $e');
      print('Stack trace: ${StackTrace.current}');
    }

    print('⚠️ Using default fallback rates');
    return {};
  }

  /// Fetch enhanced rates with multiple source validation (future implementation)
  static Future<Map<String, dynamic>> fetchEnhancedRates(
    String currencyCode,
  ) async {
    // This would aggregate from multiple sources like:
    // - exchangerate-api.com (official rates)
    // - xe.com scraping (market rates)
    // - Social media monitoring (community rates)
    // - News API for rate mentions

    // For now, return basic structure
    return {
      'currency': currencyCode,
      'sources': [
        {'name': 'Official API', 'rate': 0.0, 'weight': 0.3},
        {'name': 'Market Data', 'rate': 0.0, 'weight': 0.7},
      ],
      'confidence': 0.8,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Calculate weighted average from multiple sources
  static double calculateWeightedRate(List<Map<String, dynamic>> sources) {
    double totalWeight = 0;
    double weightedSum = 0;

    for (final source in sources) {
      final rate = (source['rate'] ?? 0.0) as double;
      final weight = (source['weight'] ?? 0.5) as double;

      weightedSum += rate * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 0;
  }

  /// Get confidence level (0.0 - 1.0) based on source diversity
  static double getConfidenceScore(int sourceCount, double rateVariance) {
    // More sources = higher confidence
    double sourceScore = (sourceCount / 5).clamp(0.0, 1.0);

    // Lower variance = higher confidence
    double varianceScore = (1.0 - rateVariance).clamp(0.0, 1.0);

    return (sourceScore * 0.6 + varianceScore * 0.4);
  }

  /// Convert amount from one currency to another
  static double convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required Map<String, Map<String, dynamic>> rates,
    required bool useParallel,
  }) {
    if (fromCurrency == toCurrency) return amount;

    // Helper to get rate in USD
    double getRateInUSD(String code) {
      if (code == 'USD') return 1.0;

      // Check custom rates first
      if (rates.containsKey(code)) {
        final rateData = rates[code]!;
        if (useParallel) {
          return (rateData['parallel'] ?? 0.0).toDouble();
        } else {
          return (rateData['official'] ?? 0.0).toDouble();
        }
      }

      // Fallback to default rates
      try {
        final currency = CurrencyData.defaultCurrencies.firstWhere(
          (c) => c.code == code,
        );
        return useParallel ? currency.parallelRate : currency.officialRate;
      } catch (e) {
        return 1.0; // Default to 1.0 if not found
      }
    }

    final fromRateUSD = getRateInUSD(fromCurrency);
    final toRateUSD = getRateInUSD(toCurrency);

    if (fromRateUSD == 0) return amount;

    return (amount / fromRateUSD) * toRateUSD;
  }
}
