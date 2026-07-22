class Category {
  final String id;
  final String name;
  final String emoji;
  final int sortOrder;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.emoji = '🍽️',
    this.sortOrder = 0,
    this.isActive = true,
  });

  Category copyWith({
    String? id,
    String? name,
    String? emoji,
    int? sortOrder,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'sortOrder': sortOrder,
    'isActive': isActive,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String? ?? '🍽️',
    sortOrder: json['sortOrder'] as int? ?? 0,
    isActive: json['isActive'] as bool? ?? true,
  );
}