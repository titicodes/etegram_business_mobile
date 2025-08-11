
class GetScanResponse {
  final bool? success;
  final ScanData? data;
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
          : ScanData.fromJson(
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

class ScanData {
  final ScanProduct? product;
  final List<Cart>? cart;

  ScanData({
    this.product,
    this.cart,
  });

  factory ScanData.fromJson(Map<String, dynamic> json) {
    return ScanData(
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
    this.description,
    this.brands,
    this.expiryDate,
    this.costPrice,
    this.createdBy,
    this.store,
    this.owner,
    this.stock,
    this.imageUrl, // Added imageUrl field
    this.minQuantity, // Added minQuantity field to align with Product
  });

  final String? id;
  final String? name;
  final double? price;
  final String? code;
  final int? quantity;
  final String? size;
  final String? categoryId;
  final int availableQuantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? description;
  final List<String>? brands;
  final DateTime? expiryDate;
  final double? costPrice;
  final String? createdBy;
  final String? store;
  final String? owner;
  final int? stock;
  final String? imageUrl; // New field
  final int? minQuantity; // New field

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
      description: json["description"],
      brands: json["brands"] == null ? null : List<String>.from(json["brands"]),
      expiryDate: DateTime.tryParse(json["expiryDate"] ?? ""),
      costPrice: (json["costPrice"] as num?)?.toDouble(),
      createdBy: json["createdBy"],
      store: json["store"],
      owner: json["owner"],
      stock: (json["stock"] as num?)?.toInt() ?? 0,
      imageUrl: json["imageUrl"]?.toString(), // Parse imageUrl
      minQuantity:
          (json["minQuantity"] as num?)?.toInt() ?? 1, // Parse minQuantity
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
        "stock": stock,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "description": description,
        "brands": brands,
        "expiryDate": expiryDate?.toIso8601String(),
        "costPrice": costPrice,
        "createdBy": createdBy,
        "store": store,
        "owner": owner,
        "imageUrl": imageUrl,
        "minQuantity": minQuantity,
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
      availableQuantity: (json["quantity"] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "price": price,
        "code": code,
        "quantity": quantity,
        "subtotal": subtotal,
        "stock": availableQuantity,
        "size": size,
      };
}
