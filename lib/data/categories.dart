import 'package:flutter/material.dart';
import '../models/transaction.dart';

class Categories {
  static const List<Category> incomeCategories = [
    Category(id: 'salary', name: 'Salary', icon: '💼', color: 0xFF10b981),
    Category(id: 'freelance', name: 'Freelance', icon: '💻', color: 0xFF3b82f6),
    Category(id: 'business', name: 'Business', icon: '🏢', color: 0xFFf59e0b),
    Category(
      id: 'investment',
      name: 'Investment',
      icon: '📈',
      color: 0xFF8b5cf6,
    ),
    Category(id: 'rental', name: 'Rental', icon: '🏠', color: 0xFFec4899),
    Category(id: 'dividends', name: 'Dividends', icon: '📊', color: 0xFF10b981),
    Category(id: 'gift', name: 'Gift', icon: '🎁', color: 0xFFec4899),
    Category(id: 'refund', name: 'Refund', icon: '↩️', color: 0xFF6366f1),
    Category(id: 'grant', name: 'Grant', icon: '🎓', color: 0xFF3b82f6),
    Category(id: 'other-income', name: 'Other', icon: '💰', color: 0xFF64748b),
  ];

  static const List<Category> expenseCategories = [
    Category(id: 'food', name: 'Food', icon: '🍔', color: 0xFFef4444),
    Category(id: 'transport', name: 'Transport', icon: '🚗', color: 0xFFf59e0b),
    Category(id: 'shopping', name: 'Shopping', icon: '🛍️', color: 0xFFec4899),
    Category(id: 'bills', name: 'Bills', icon: '📄', color: 0xFF6366f1),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: '🎮',
      color: 0xFF8b5cf6,
    ),
    Category(id: 'health', name: 'Health', icon: '🏥', color: 0xFF10b981),
    Category(id: 'education', name: 'Education', icon: '📚', color: 0xFF3b82f6),
    Category(id: 'other-expense', name: 'Other', icon: '💸', color: 0xFF64748b),
  ];

  static Category? getCategory(String id, String type) {
    final categories = type == 'income' ? incomeCategories : expenseCategories;
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  static Color getCategoryColor(String id, String type) {
    final category = getCategory(id, type);
    return Color(category?.color ?? 0xFF6366f1);
  }
}
