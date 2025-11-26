class Transaction {
  final String id;
  final String type; // 'income' or 'expense'
  final double amount;
  final String categoryId;
  final String category;
  final String icon;
  final DateTime date;
  final String? description;
  final String paymentMethod;
  final bool isRecurring;
  final String? frequency; // 'daily', 'weekly', 'monthly', 'yearly'
  final String currency;
  final String? projectId; // Optional project assignment

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.category,
    required this.icon,
    required this.date,
    this.description,
    this.paymentMethod = 'cash',
    this.isRecurring = false,
    this.frequency,
    this.currency = 'USD',
    this.projectId, // Optional
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'category': category,
      'icon': icon,
      'date': date.toIso8601String(),
      'description': description,
      'paymentMethod': paymentMethod,
      'isRecurring': isRecurring,
      'frequency': frequency,
      'currency': currency,
      'projectId': projectId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      categoryId: json['categoryId'],
      category: json['category'],
      icon: json['icon'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      paymentMethod: json['paymentMethod'] ?? 'cash',
      isRecurring: json['isRecurring'] ?? false,
      frequency: json['frequency'],
      currency: json['currency'] ?? 'USD',
      projectId:
          json['projectId'], // Backward compatible - will be null for old data
    );
  }
}

class Category {
  final String id;
  final String name;
  final String icon;
  final int color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Budget {
  final String id;
  final String categoryId;
  final double amount;
  final String currency; // Added currency field

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.currency = 'USD', // Default to USD for backward compatibility
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'currency': currency,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'USD', // Backward compatibility
    );
  }
}
