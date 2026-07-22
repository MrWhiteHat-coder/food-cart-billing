import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/storage_service.dart';
import '../../../../core/models/bill.dart';
import '../../../../core/models/cart_item.dart';

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier();
});

class CheckoutState {
  final String customerName;
  final String customerPhone;
  final String paymentMethod;
  final bool isWhatsAppSent;

  CheckoutState({
    this.customerName = '',
    this.customerPhone = '',
    this.paymentMethod = 'Cash',
    this.isWhatsAppSent = false,
  });

  CheckoutState copyWith({
    String? customerName,
    String? customerPhone,
    String? paymentMethod,
    bool? isWhatsAppSent,
  }) {
    return CheckoutState(
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isWhatsAppSent: isWhatsAppSent ?? this.isWhatsAppSent,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(const CheckoutState());

  void updateName(String name) {
    state = state.copyWith(customerName: name);
  }

  void updatePhone(String phone) {
    state = state.copyWith(customerPhone: phone);
  }

  void updatePaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  Future<String?> completeOrder(
    List<CartItem> cart,
    double subtotal,
    double discount,
    int discountType,
    double gstRate,
    double gstAmount,
    double total,
    StorageService storage,
  ) async {
    final bill = Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      items: cart,
      subtotal: subtotal,
      discount: discount,
      discountType: discountType.toDouble(),
      gstRate: gstRate,
      gstAmount: gstAmount,
      total: total,
      customerName: state.customerName.isEmpty ? null : state.customerName,
      customerPhone: state.customerPhone.isEmpty ? null : state.customerPhone,
      paymentMethod: state.paymentMethod,
      createdAt: DateTime.now(),
    );
    await storage.saveBill(bill);
    return bill.id;
  }
}