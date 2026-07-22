class CartItem {
  final String id;
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final double gstRate;
  final String? imageAsset;

  CartItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.gstRate,
    this.imageAsset,
  });

  CartItem copyWith({
    String? id,
    String? menuItemId,
    String? name,
    double? price,
    int? quantity,
    double? gstRate,
    String? imageAsset,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      gstRate: gstRate ?? this.gstRate,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }

  double get lineTotal => price * quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'menuItemId': menuItemId,
    'name': name,
    'price': price,
    'quantity': quantity,
    'gstRate': gstRate,
    'imageAsset': imageAsset,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] as String,
    menuItemId: json['menuItemId'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    quantity: json['quantity'] as int,
    gstRate: (json['gstRate'] as num).toDouble(),
    imageAsset: json['imageAsset'] as String?,
  );
}