class GetScanResponse {
  GetScanResponse({
    this.success,
    this.data,
    this.message,
  });

  final bool? success;
  final Data? data;
  final String? message;

  factory GetScanResponse.fromJson(Map<String, dynamic> json) {
    return GetScanResponse(
      success: json["success"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class Data {
  Data({
    this.product,
    this.cart,
  });

  final ScanProduct? product;
  final List<Cart>? cart;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      product: json["product"] == null
          ? null
          : ScanProduct.fromJson(json["product"]),
      cart: json["cart"] == null
          ? []
          : List<Cart>.from(json["cart"]!.map((x) => Cart.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "product": product?.toJson(),
        "cart": cart?.map((x) => x.toJson()).toList(),
      };
}

class Cart {
  Cart({
    required this.id,
    required this.name,
    required this.price,
    required this.code,
    required this.quantity,
    required this.subtotal,
  });

  final String id;
  final String name;
  final int price;
  final String code;
  int quantity;
  int subtotal;

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json["_id"] ?? "",
      name: json["name"] ?? "Unknown Product",
      price: json["price"] ?? 0,
      code: json["code"] ?? "",
      quantity: json["quantity"] ?? 1,
      subtotal:
          json["subtotal"] ?? (json["quantity"] ?? 1) * (json["price"] ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "price": price,
        "code": code,
        "quantity": quantity,
        "subtotal": subtotal,
      };

  @override
  String toString() {
    return 'Cart(id: $id, name: $name, code: $code, quantity: $quantity, price: $price, subtotal: $subtotal)';
  }
}

class ScanProduct {
  ScanProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.code,
    this.quantity,
    required this.categoryId,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? name;
  final int? price;
  final String? code;
  int? quantity;
  final String? categoryId;
  final int? stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory ScanProduct.fromJson(Map<String, dynamic> json) {
    return ScanProduct(
      id: json["_id"],
      name: json["name"],
      price: json["price"],
      code: json["code"],
      quantity: json["quantity"],
      categoryId: json["categoryId"],
      stock: json["stock"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "price": price,
        "code": code,
        "quantity": quantity,
        "categoryId": categoryId,
        "stock": stock,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
