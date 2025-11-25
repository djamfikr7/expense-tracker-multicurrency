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

  Budget({required this.id, required this.categoryId, required this.amount});

  Map<String, dynamic> toJson() {
    return {'id': id, 'categoryId': categoryId, 'amount': amount};
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: json['amount'].toDouble(),
    );
  }
}
