import 'package:etegram_business/core/model/cart_item.dart';

class SalesRecord {
  final String id;
  final List<CartItem> cartItems;
  final double totalPrice;
  final double discountedPrice;
  final double totalPriceWithTax;
  final String userId;
  final String status;
  final String paymentMethod;
  final String storeId;
  final bool isCredit;
  final String? customerId;
  final String? supplierId;
  final DateTime createdAt;

  SalesRecord({
    required this.id,
    required this.cartItems,
    required this.totalPrice,
    required this.discountedPrice,
    required this.totalPriceWithTax,
    required this.userId,
    required this.status,
    required this.paymentMethod,
    required this.storeId,
    required this.isCredit,
    this.customerId,
    this.supplierId,
    required this.createdAt,
  });

  factory SalesRecord.fromJson(Map<String, dynamic> json) {
    return SalesRecord(
      id: json['_id'] ?? '',
      cartItems: (json['cartItems'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble() ?? 0.0,
      totalPriceWithTax: (json['totalPriceWithTax'] as num?)?.toDouble() ?? 0.0,
      userId: json['user'] ?? '',
      status: json['status'] ?? 'Pending',
      paymentMethod: json['paymentMethod'] ?? '',
      storeId: json['store'] ?? '',
      isCredit: json['isCredit'] ?? false,
      customerId: json['customerId'] as String?,
      supplierId: json['supplierId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'discountedPrice': discountedPrice,
      'totalPriceWithTax': totalPriceWithTax,
      'user': userId,
      'status': status,
      'paymentMethod': paymentMethod,
      'store': storeId,
      'isCredit': isCredit,
      'customerId': customerId,
      'supplierId': supplierId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}