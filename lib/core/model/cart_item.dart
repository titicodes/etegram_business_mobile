import 'package:etegram_business/core/model/product_model.dart';

class CartItem {
  final String code;
  int quantity;
  double price;
  int? size; // Optional size property
  final Product product; // Reference to Product object

  CartItem({
    required this.code,
    required this.quantity,
    required this.price,
    this.size,
    required this.product,
  });

  // Convert CartItem instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'quantity': quantity,
      'price': price,
      'size': size,
      'product': product.toJson(),
    };
  }

  // Create CartItem instance from JSON map
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      code: json['code'] as String,
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      size: json['size'] as int?,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );
  }
}
