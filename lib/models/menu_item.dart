class MenuItem {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final String? description;
  final String? imageAsset;
  final bool isAvailable;
  final int sortOrder;

  MenuItem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    this.description,
    this.imageAsset,
    this.isAvailable = true,
    this.sortOrder = 0,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? categoryId,
    double? price,
    String? description,
    String? imageAsset,
    bool? isAvailable,
    int? sortOrder,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      description: description ?? this.description,
      imageAsset: imageAsset ?? this.imageAsset,
      isAvailable: isAvailable ?? this.isAvailable,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
    'price': price,
    'description': description,
    'imageAsset': imageAsset,
    'isAvailable': isAvailable,
    'sortOrder': sortOrder,
  };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    name: json['name'] as String,
    categoryId: json['categoryId'] as String,
    price: (json['price'] as num).toDouble(),
    description: json['description'] as String?,
    imageAsset: json['imageAsset'] as String?,
    isAvailable: json['isAvailable'] as bool? ?? true,
    sortOrder: json['sortOrder'] as int? ?? 0,
  );
}