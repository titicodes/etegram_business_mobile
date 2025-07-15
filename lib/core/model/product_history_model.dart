// import 'package:etegram_business/core/model/product_model.dart';
//
// class ProductHistory {
//   final String? id;
//   final String type; // e.g., 'restock', 'adjustment'
//   final int quantity;
//   final String? notes;
//   final String? productId;
//   final String? storeId;
//   final String? userId;
//   final DateTime? createdAt;
//
//   ProductHistory({
//     this.id,
//     required this.type,
//     required this.quantity,
//     this.notes,
//     this.productId,
//     this.storeId,
//     this.userId,
//     this.createdAt,
//   });
//
//   factory ProductHistory.fromJson(Map<String, dynamic> json) {
//     return ProductHistory(
//       id: json['_id']?.toString(),
//       type: json['type'] ?? '',
//       quantity: json['quantity']?.toInt() ?? 0,
//       notes: json['notes'],
//       productId: json['product']?.toString(),
//       storeId: json['store']?.toString(),
//       userId: json['userId']?.toString(),
//       createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'type': type,
//       'quantity': quantity,
//       'notes': notes,
//       'product': productId,
//       'store': storeId,
//       'userId': userId,
//       'createdAt': createdAt?.toIso8601String(),
//     };
//   }
// }

import 'package:flutter/material.dart';

class ProductHistory {
  final String? id;
  final String productId;
  final String action;
  final int quantity;
  final int stock;
  final double price;
  final DateTime timestamp;
  final String? type;
  final String? notes;
  final String? deliveryAgentId;

  ProductHistory({
    this.id,
    required this.productId,
    required this.action,
    required this.quantity,
    required this.stock,
    required this.price,
    required this.timestamp,
    this.type,
    this.notes,
    this.deliveryAgentId,
  });

  factory ProductHistory.fromJson(Map<String, dynamic> json) {
    return ProductHistory(
      id: json['_id'],
      productId: json['productId']?.toString() ?? '',
      action: json['action'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      type: json['type'],
      deliveryAgentId: json['deliveryAgentId'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'action': action,
      'quantity': quantity,
      'stock': stock,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'notes': notes,
      'deliveryAgentId': deliveryAgentId,
    };
  }
}
