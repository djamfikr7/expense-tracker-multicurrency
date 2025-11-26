import 'transaction.dart';

/// Filter model for advanced transaction filtering
class TransactionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String> categoryIds;
  final Set<String> paymentMethods;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;
  final String? projectId;
  final String? transactionType; // 'income', 'expense', or null for all

  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.categoryIds = const {},
    this.paymentMethods = const {},
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
    this.projectId,
    this.transactionType,
  });

  /// Apply filter to transaction list
  List<Transaction> apply(List<Transaction> transactions) {
    return transactions.where((t) {
      // Date range filter
      if (startDate != null && t.date.isBefore(startDate!)) return false;
      if (endDate != null && t.date.isAfter(endDate!)) return false;

      // Category filter
      if (categoryIds.isNotEmpty && !categoryIds.contains(t.categoryId)) {
        return false;
      }

      // Payment method filter
      if (paymentMethods.isNotEmpty &&
          !paymentMethods.contains(t.paymentMethod)) {
        return false;
      }

      // Amount range filter
      if (minAmount != null && t.amount < minAmount!) return false;
      if (maxAmount != null && t.amount > maxAmount!) return false;

      // Search query (description, category, payment method)
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final query = searchQuery!.toLowerCase();
        final matches =
            t.description?.toLowerCase().contains(query) == true ||
            t.category.toLowerCase().contains(query) ||
            t.paymentMethod.toLowerCase().contains(query);
        if (!matches) return false;
      }

      // Project filter
      if (projectId != null && t.projectId != projectId) return false;

      // Transaction type filter
      if (transactionType != null && t.type != transactionType) return false;

      return true;
    }).toList();
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        categoryIds.isNotEmpty ||
        paymentMethods.isNotEmpty ||
        minAmount != null ||
        maxAmount != null ||
        (searchQuery != null && searchQuery!.isNotEmpty) ||
        projectId != null ||
        transactionType != null;
  }

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (startDate != null || endDate != null) count++;
    if (categoryIds.isNotEmpty) count++;
    if (paymentMethods.isNotEmpty) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (projectId != null) count++;
    if (transactionType != null) count++;
    return count;
  }

  /// Create a copy with modifications
  TransactionFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    Set<String>? categoryIds,
    Set<String>? paymentMethods,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    String? projectId,
    String? transactionType,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
    bool clearSearchQuery = false,
    bool clearProjectId = false,
    bool clearTransactionType = false,
  }) {
    return TransactionFilter(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      categoryIds: categoryIds ?? this.categoryIds,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      transactionType: clearTransactionType
          ? null
          : (transactionType ?? this.transactionType),
    );
  }

  /// Clear all filters
  static const TransactionFilter empty = TransactionFilter();
}
