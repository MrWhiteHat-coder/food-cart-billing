class Bill {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double gstRate;
  final double gstAmount;
  final double total;
  final String? customerName;
  final String paymentMethod;
  final DateTime createdAt;
  final String? receiptPath;

  Bill({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.gstRate,
    required this.gstAmount,
    required this.total,
    this.customerName,
    this.paymentMethod = 'Cash',
    required this.createdAt,
    this.receiptPath,
  });

  Bill copyWith({
    String? id,
    List<CartItem>? items,
    double? subtotal,
    double? gstRate,
    double? gstAmount,
    double? total,
    String? customerName,
    String? paymentMethod,
    DateTime? createdAt,
    String? receiptPath,
  }) {
    return Bill(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      gstRate: gstRate ?? this.gstRate,
      gstAmount: gstAmount ?? this.gstAmount,
      total: total ?? this.total,
      customerName: customerName ?? this.customerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items.map((i) => i.toJson()).toList(),
    'subtotal': subtotal,
    'gstRate': gstRate,
    'gstAmount': gstAmount,
    'total': total,
    'customerName': customerName,
    'paymentMethod': paymentMethod,
    'createdAt': createdAt.toIso8601String(),
    'receiptPath': receiptPath,
  };

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    id: json['id'] as String,
    items: (json['items'] as List).map((i) => CartItem.fromJson(i)).toList(),
    subtotal: (json['subtotal'] as num).toDouble(),
    gstRate: (json['gstRate'] as num).toDouble(),
    gstAmount: (json['gstAmount'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
    customerName: json['customerName'] as String?,
    paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
    createdAt: DateTime.parse(json['createdAt'] as String),
    receiptPath: json['receiptPath'] as String?,
  );
}