/// Represents a project for grouping related transactions
class Project {
  final String id;
  final String name;
  final String? description;
  final String icon; // Emoji
  final int colorValue; // Store as int for JSON serialization
  final double? budget;
  final DateTime createdDate;
  final DateTime? deadline;
  final bool isActive;

  Project({
    String? id,
    required this.name,
    this.description,
    this.icon = '📁', // Default folder emoji
    this.colorValue = 0xFF2196F3, // Default blue
    this.budget,
    DateTime? createdDate,
    this.deadline,
    this.isActive = true,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdDate = createdDate ?? DateTime.now();

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'colorValue': colorValue,
      'budget': budget,
      'createdDate': createdDate.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'] ?? '📁',
      colorValue: json['colorValue'] ?? 0xFF2196F3,
      budget: json['budget']?.toDouble(),
      createdDate: DateTime.parse(json['createdDate']),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  /// Create a copy with modifications
  Project copyWith({
    String? name,
    String? description,
    String? icon,
    int? colorValue,
    double? budget,
    DateTime? deadline,
    bool? isActive,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      budget: budget ?? this.budget,
      createdDate: createdDate,
      deadline: deadline ?? this.deadline,
      isActive: isActive ?? this.isActive,
    );
  }
}
