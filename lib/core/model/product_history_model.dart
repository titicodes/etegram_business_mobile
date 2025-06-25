import 'package:etegram_business/core/model/product_model.dart';

class ProductHistory {
  final String? id;
  final String type; // e.g., 'restock', 'adjustment'
  final int quantity;
  final String? notes;
  final String? productId;
  final String? storeId;
  final String? userId;
  final DateTime? createdAt;

  ProductHistory({
    this.id,
    required this.type,
    required this.quantity,
    this.notes,
    this.productId,
    this.storeId,
    this.userId,
    this.createdAt,
  });

  factory ProductHistory.fromJson(Map<String, dynamic> json) {
    return ProductHistory(
      id: json['_id']?.toString(),
      type: json['type'] ?? '',
      quantity: json['quantity']?.toInt() ?? 0,
      notes: json['notes'],
      productId: json['product']?.toString(),
      storeId: json['store']?.toString(),
      userId: json['userId']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'quantity': quantity,
      'notes': notes,
      'product': productId,
      'store': storeId,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}