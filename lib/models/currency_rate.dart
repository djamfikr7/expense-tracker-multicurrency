class CurrencyRate {
  final String code;
  final String name;
  final double officialRate; // Rate to USD
  final double parallelRate; // Parallel market rate to USD

  CurrencyRate({
    required this.code,
    required this.name,
    required this.officialRate,
    this.parallelRate = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'officialRate': officialRate,
      'parallelRate': parallelRate,
    };
  }

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      code: json['code'],
      name: json['name'],
      officialRate: json['officialRate'].toDouble(),
      parallelRate: json['parallelRate']?.toDouble() ?? 0,
    );
  }
}

class CurrencyData {
  static final List<CurrencyRate> defaultCurrencies = [
    CurrencyRate(
      code: 'USD',
      name: 'US Dollar',
      officialRate: 1.0,
      parallelRate: 1.0,
    ),
    CurrencyRate(
      code: 'EUR',
      name: 'Euro',
      officialRate: 0.92,
      parallelRate: 0.92,
    ),
    CurrencyRate(
      code: 'GBP',
      name: 'British Pound',
      officialRate: 0.79,
      parallelRate: 0.79,
    ),
    CurrencyRate(
      code: 'JPY',
      name: 'Japanese Yen',
      officialRate: 149.5,
      parallelRate: 149.5,
    ),
    CurrencyRate(
      code: 'CNY',
      name: 'Chinese Yuan (RMB)',
      officialRate: 7.24,
      parallelRate: 7.24,
    ),
    CurrencyRate(
      code: 'CAD',
      name: 'Canadian Dollar',
      officialRate: 1.39,
      parallelRate: 1.39,
    ),
    CurrencyRate(
      code: 'AUD',
      name: 'Australian Dollar',
      officialRate: 1.52,
      parallelRate: 1.52,
    ),

    // Middle East & North Africa - REALISTIC PARALLEL MARKET RATES
    CurrencyRate(
      code: 'SAR',
      name: 'Saudi Riyal',
      officialRate: 3.75,
      parallelRate: 3.75,
    ),
    CurrencyRate(
      code: 'AED',
      name: 'UAE Dirham',
      officialRate: 3.67,
      parallelRate: 3.67,
    ),

    // Countries with significant parallel market premiums
    CurrencyRate(
      code: 'EGP',
      name: 'Egyptian Pound',
      officialRate: 30.9,
      parallelRate: 72.5,
    ), // Real parallel ~72
    CurrencyRate(
      code: 'DZD',
      name: 'Algerian Dinar',
      officialRate: 134.5,
      parallelRate: 254.0,
    ), // Real: USD~254, EUR~283
    CurrencyRate(
      code: 'TND',
      name: 'Tunisian Dinar',
      officialRate: 3.1,
      parallelRate: 5.1,
    ), // Real parallel ~5.1
    CurrencyRate(
      code: 'MAD',
      name: 'Moroccan Dirham',
      officialRate: 10.1,
      parallelRate: 10.1,
    ), // No significant parallel market
    CurrencyRate(
      code: 'LYD',
      name: 'Libyan Dinar',
      officialRate: 4.8,
      parallelRate: 6.8,
    ), // Real parallel ~6.5-7.0
    CurrencyRate(
      code: 'MRU',
      name: 'Mauritanian Ouguiya',
      officialRate: 39.5,
      parallelRate: 42.5,
    ),

    // West & Central Africa (CFA - pegged to EUR, minimal parallel market)
    CurrencyRate(
      code: 'XOF',
      name: 'CFA Franc BCEAO',
      officialRate: 607.0,
      parallelRate: 607.0,
    ),
    CurrencyRate(
      code: 'XAF',
      name: 'CFA Franc BEAC',
      officialRate: 607.0,
      parallelRate: 607.0,
    ),
  ];

  // Calculate premium percentage
  static double getPremium(CurrencyRate currency) {
    if (currency.officialRate == 0) return 0;
    return ((currency.parallelRate - currency.officialRate) /
        currency.officialRate *
        100);
  }
}
