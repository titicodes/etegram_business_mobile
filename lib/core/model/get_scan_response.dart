class GetScanResponse {
  final bool? success;
  final Data? data;
  final String? message;

  GetScanResponse({
    this.success,
    this.data,
    this.message,
  });

  factory GetScanResponse.fromJson(Map<String, dynamic> json) {
    return GetScanResponse(
      success: json["success"] ?? false,
      data: json["data"] == null
          ? null
          : Data.fromJson(
        json["data"] is Map<String, dynamic> &&
            json["data"]["product"] == null
            ? {"product": json["data"], "cart": []}
            : json["data"],
      ),
      message: json["message"] ?? "Unknown error",
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  final ScanProduct? product;
  final List<Cart>? cart;

  Data({
    this.product,
    this.cart,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      product: json["product"] == null
          ? null
          : ScanProduct.fromJson(json["product"]),
      cart: json["cart"] == null
          ? []
          : List<Cart>.from(json["cart"].map((x) => Cart.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "product": product?.toJson(),
    "cart": cart?.map((x) => x.toJson()).toList(),
  };
}

class ScanProduct {
  ScanProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.code,
    this.quantity,
    this.size,
    required this.categoryId,
    required this.availableQuantity,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? name;
  final double? price;
  final String? code;
  int? quantity;
  String? size;
  final String? categoryId;
  final int availableQuantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory ScanProduct.fromJson(Map<String, dynamic> json) {
    return ScanProduct(
      id: json["_id"] ?? "",
      name: json["name"] ?? "Unknown Product",
      price: (json["price"] as num?)?.toDouble() ?? 0.0,
      code: json["code"] ?? "",
      quantity: (json["quantity"] as num?)?.toInt() ?? 0,
      size: json["size"] ?? "",
      categoryId: json["categoryId"] ?? "",
      availableQuantity: (json["quantity"] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: (json["__v"] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "price": price,
    "code": code,
    "quantity": quantity,
    "size": size,
    "categoryId": categoryId,
    "availableQuantity": availableQuantity,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
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
    required this.availableQuantity,
    this.size,
  });

  final String id;
  final String name;
  final double price;
  final String code;
  int quantity;
  double subtotal;
  final int availableQuantity;
  final String? size;

  factory Cart.fromJson(Map<String, dynamic> json) {
    final quantity = (json["quantity"] as num?)?.toInt() ?? 1;
    final price = (json["price"] as num?)?.toDouble() ?? 0.0;

    return Cart(
      id: json["_id"] ?? "",
      name: json["name"] ?? "Unknown Product",
      price: price,
      code: json["code"] ?? "",
      size: json["size"] ?? "",
      quantity: quantity,
      subtotal: (json["subtotal"] as num?)?.toDouble() ?? quantity * price,
      availableQuantity: (json["availableQuantity"] as num?)?.toInt() ??
          (json["quantity"] as num?)?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "price": price,
    "code": code,
    "quantity": quantity,
    "subtotal": subtotal,
    "availableQuantity": availableQuantity,
    "size": size,
  };
}
