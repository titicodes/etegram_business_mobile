//
//
// import 'package:flutter/material.dart';
//
// class ProductHistory {
//   final String? id;
//   final String productId;
//   final String action;
//   final int quantity;
//   final int stock;
//   final double price;
//   final DateTime timestamp;
//   final String? type;
//   final String? notes;
//   final String? deliveryAgentId;
//
//   ProductHistory({
//     this.id,
//     required this.productId,
//     required this.action,
//     required this.quantity,
//     required this.stock,
//     required this.price,
//     required this.timestamp,
//     this.type,
//     this.notes,
//     this.deliveryAgentId,
//   });
//
//   factory ProductHistory.fromJson(Map<String, dynamic> json) {
//     return ProductHistory(
//       id: json['_id'],
//       productId: json['productId']?.toString() ?? '',
//       action: json['action'] ?? '',
//       quantity: (json['quantity'] as num?)?.toInt() ?? 0,
//       stock: (json['stock'] as num?)?.toInt() ?? 0,
//       price: (json['price'] as num?)?.toDouble() ?? 0.0,
//       timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
//           DateTime.now(),
//       type: json['type'],
//       deliveryAgentId: json['deliveryAgentId'],
//       notes: json['notes'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'productId': productId,
//       'action': action,
//       'quantity': quantity,
//       'stock': stock,
//       'price': price,
//       'timestamp': timestamp.toIso8601String(),
//       'type': type,
//       'notes': notes,
//       'deliveryAgentId': deliveryAgentId,
//     };
//   }
// }

import 'package:flutter/material.dart';

class ProductHistory {
  final String? id;
  final String? productId;
  final String? action;
  final int? quantity;
  final int? stock;
  final double? price;
  final DateTime timestamp;
  final String? type;
  final String? notes;
  final String? deliveryAgentId;

  ProductHistory({
    this.id,
    this.productId,
    required this.action,
    required this.quantity,
    this.stock,
    this.price,
    required this.timestamp,
    this.type,
    this.notes,
    this.deliveryAgentId,
  });

  factory ProductHistory.fromJson(Map<String, dynamic> json) {
    print('Parsing ProductHistory JSON: $json'); // Debug log
    return ProductHistory(
      id: json['_id']?.toString(),
      productId: json['product']?.toString() ?? json['productId']?.toString(),
      action: json['type']?.toString() ?? json['action']?.toString() ?? 'UNKNOWN',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      timestamp: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      type: json['type']?.toString(),
      notes: json['notes']?.toString(),
      deliveryAgentId: json['deliveryAgentId']?.toString(),
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