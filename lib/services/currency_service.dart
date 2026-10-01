class CurrencyService {
  // Exchange rates relative to 1.0 USD
  static const Map<String, double> ratesToUsd = {
    '\$': 1.0,      // USD ($)
    '₹': 84.0,      // INR (₹)
    '€': 0.92,      // EUR (€)
    '£': 0.78,      // GBP (£)
    '¥': 152.0,     // JPY (¥)
    'C\$': 1.38,    // CAD (C$)
    'A\$': 1.52,    // AUD (A$)
  };

  static const List<Map<String, String>> supportedCurrencies = [
    {'symbol': '\$', 'code': 'USD', 'name': 'US Dollar (\$)'},
    {'symbol': '₹', 'code': 'INR', 'name': 'Indian Rupee (₹)'},
    {'symbol': '€', 'code': 'EUR', 'name': 'Euro (€)'},
    {'symbol': '£', 'code': 'GBP', 'name': 'British Pound (£)'},
    {'symbol': '¥', 'code': 'JPY', 'name': 'Japanese Yen (¥)'},
    {'symbol': 'C\$', 'code': 'CAD', 'name': 'Canadian Dollar (C\$)'},
    {'symbol': 'A\$', 'code': 'AUD', 'name': 'Australian Dollar (A\$)'},
  ];

  static double convert({
    required double amount,
    required String fromSymbol,
    required String toSymbol,
  }) {
    if (fromSymbol == toSymbol || amount <= 0) return amount;
    final fromRate = ratesToUsd[fromSymbol] ?? 1.0;
    final toRate = ratesToUsd[toSymbol] ?? 1.0;

    // Convert to base USD, then to target currency
    final inUsd = amount / fromRate;
    final inTarget = inUsd * toRate;

    // Clean formatting without fractional pennies for large currencies
    if (toSymbol == '¥') {
      return inTarget.roundToDouble();
    } else if (toSymbol == '₹') {
      return (inTarget >= 100) ? inTarget.roundToDouble() : double.parse(inTarget.toStringAsFixed(1));
    } else {
      return double.parse(inTarget.toStringAsFixed(2));
    }
  }

  // Pre-configured real-world monthly and yearly charges for top services
  static final List<Map<String, dynamic>> presetServices = [
    {
      'name': 'YouTube Premium',
      'category': 'Entertainment',
      'monthly': <String, double>{
        '\$': 13.99,
        '₹': 149.0,
        '€': 12.99,
        '£': 12.99,
        '¥': 1280.0,
        'C\$': 17.99,
        'A\$': 16.99,
      },
      'yearly': <String, double>{
        '\$': 139.99,
        '₹': 1490.0,
        '€': 129.99,
        '£': 129.99,
        '¥': 12800.0,
        'C\$': 179.99,
        'A\$': 169.99,
      },
    },
    {
      'name': 'Spotify Premium',
      'category': 'Music',
      'monthly': <String, double>{
        '\$': 11.99,
        '₹': 119.0,
        '€': 10.99,
        '£': 11.99,
        '¥': 980.0,
        'C\$': 12.99,
        'A\$': 13.99,
      },
      'yearly': <String, double>{
        '\$': 119.00,
        '₹': 1189.0,
        '€': 109.00,
        '£': 119.00,
        '¥': 9800.0,
        'C\$': 129.00,
        'A\$': 139.00,
      },
    },
    {
      'name': 'Netflix Standard',
      'category': 'Entertainment',
      'monthly': <String, double>{
        '\$': 15.49,
        '₹': 499.0,
        '€': 13.49,
        '£': 10.99,
        '¥': 1490.0,
        'C\$': 16.49,
        'A\$': 18.99,
      },
      'yearly': <String, double>{
        '\$': 185.88,
        '₹': 4990.0,
        '€': 149.99,
        '£': 129.99,
        '¥': 17800.0,
        'C\$': 197.88,
        'A\$': 227.88,
      },
    },
    {
      'name': 'Amazon Prime',
      'category': 'Shopping & Media',
      'monthly': <String, double>{
        '\$': 14.99,
        '₹': 299.0,
        '€': 8.99,
        '£': 8.99,
        '¥': 600.0,
        'C\$': 9.99,
        'A\$': 9.99,
      },
      'yearly': <String, double>{
        '\$': 139.00,
        '₹': 1499.0,
        '€': 89.90,
        '£': 95.00,
        '¥': 5900.0,
        'C\$': 99.00,
        'A\$': 79.00,
      },
    },
    {
      'name': 'ChatGPT Plus',
      'category': 'Intelligence & Work',
      'monthly': <String, double>{
        '\$': 20.00,
        '₹': 1999.0,
        '€': 21.99,
        '£': 19.00,
        '¥': 3000.0,
        'C\$': 27.99,
        'A\$': 30.99,
      },
      'yearly': <String, double>{
        '\$': 240.00,
        '₹': 23999.0,
        '€': 240.00,
        '£': 220.00,
        '¥': 35000.0,
        'C\$': 320.00,
        'A\$': 350.00,
      },
    },
    {
      'name': 'Apple One',
      'category': 'Cloud & Storage',
      'monthly': <String, double>{
        '\$': 19.95,
        '₹': 195.0,
        '€': 19.95,
        '£': 18.95,
        '¥': 1200.0,
        'C\$': 22.95,
        'A\$': 24.95,
      },
      'yearly': <String, double>{
        '\$': 239.40,
        '₹': 2340.0,
        '€': 239.00,
        '£': 220.00,
        '¥': 14000.0,
        'C\$': 260.00,
        'A\$': 280.00,
      },
    },
    {
      'name': 'iCloud+ 200GB',
      'category': 'Cloud & Storage',
      'monthly': <String, double>{
        '\$': 2.99,
        '₹': 75.0,
        '€': 2.99,
        '£': 2.99,
        '¥': 400.0,
        'C\$': 3.99,
        'A\$': 4.49,
      },
      'yearly': <String, double>{
        '\$': 35.88,
        '₹': 900.0,
        '€': 35.88,
        '£': 35.88,
        '¥': 4800.0,
        'C\$': 47.88,
        'A\$': 53.88,
      },
    },
    {
      'name': 'Gym & Fitness',
      'category': 'Wellness',
      'monthly': <String, double>{
        '\$': 65.00,
        '₹': 2500.0,
        '€': 55.00,
        '£': 49.00,
        '¥': 9000.0,
        'C\$': 80.00,
        'A\$': 85.00,
      },
      'yearly': <String, double>{
        '\$': 650.00,
        '₹': 24000.0,
        '€': 550.00,
        '£': 490.00,
        '¥': 90000.0,
        'C\$': 800.00,
        'A\$': 850.00,
      },
    },
  ];

  static double getPresetCost({
    required Map<String, dynamic> preset,
    required String cycle,
    required String currencySymbol,
  }) {
    final isYearly = cycle.toLowerCase() == 'yearly';
    final cycleMap = isYearly
        ? (preset['yearly'] as Map<String, double>?)
        : (preset['monthly'] as Map<String, double>?);

    if (cycleMap != null && cycleMap.containsKey(currencySymbol)) {
      return cycleMap[currencySymbol]!;
    }

    // Fallback: convert from USD
    final Map<String, dynamic>? sourceMap = isYearly ? preset['yearly'] : preset['monthly'];
    final usdCost = sourceMap != null ? sourceMap['\$'] : null;

    if (usdCost != null) {
      return convert(
        amount: (usdCost as num).toDouble(),
        fromSymbol: '\$',
        toSymbol: currencySymbol,
      );
    }

    return isYearly ? 120.0 : 10.0;
  }
}
