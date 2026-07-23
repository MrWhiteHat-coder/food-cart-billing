import 'cart_item.dart';

class Bill {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double discountType;
  final double gstRate;
  final double gstAmount;
  final double total;
  final String? customerName;
  final String? customerPhone;
  final String paymentMethod;
  final DateTime createdAt;

  Bill({
    required this.id,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.discountType = 0,
    required this.gstRate,
    required this.gstAmount,
    required this.total,
    this.customerName,
    this.customerPhone,
    this.paymentMethod = 'Cash',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'discountType': discountType,
      'gstRate': gstRate,
      'gstAmount': gstAmount,
      'total': total,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      discountType: (json['discountType'] as num).toDouble(),
      gstRate: (json['gstRate'] as num).toDouble(),
      gstAmount: (json['gstAmount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
