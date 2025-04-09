class CheckoutResponse {
  CheckoutResponse({
     this.success,
     this.data,
     this.message,
  });

  final bool? success;
  final Data? data;
  final String? message;

  factory CheckoutResponse.fromJson(Map<String, dynamic> json){
    return CheckoutResponse(
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
    this.cartItems,
    this.totalPrice,
    this.discountedPrice,
    this.totalPriceWithTax,
    this.user,
    this.status,
    this.id,
    this.v,
  });

  final List<CartItem>? cartItems;
  final double? totalPrice;
  final double? discountedPrice;
  final double? totalPriceWithTax;
  final String? user;
  final String? status;
  final String? id;
  final int? v;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      cartItems: json["cartItems"] == null
          ? []
          : List<CartItem>.from(json["cartItems"]!.map((x) => CartItem.fromJson(x))),
      totalPrice: (json["totalPrice"] as num?)?.toDouble(),
      discountedPrice: (json["discountedPrice"] as num?)?.toDouble(),
      totalPriceWithTax: (json["totalPriceWithTax"] as num?)?.toDouble(),
      user: json["user"],
      status: json["status"],
      id: json["_id"],
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "cartItems": cartItems?.map((x) => x.toJson()).toList(),
    "totalPrice": totalPrice,
    "discountedPrice": discountedPrice,
    "totalPriceWithTax": totalPriceWithTax,
    "user": user,
    "status": status,
    "_id": id,
    "__v": v,
  };
}

class CartItem {
  CartItem({
     this.id,
     this.name,
     this.price,
     this.code,
     this.quantity,
     this.categoryId,
     this.stock,
     this.createdAt,
     this.updatedAt,
     this.v,
     this.subtotal,
  });

  final String? id;
  final String? name;
  final int? price;
  final String? code;
  final int? quantity;
  final String? categoryId;
  final int? stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final int? subtotal;

  factory CartItem.fromJson(Map<String, dynamic> json){
    return CartItem(
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
      subtotal: json["subtotal"],
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
    "subtotal": subtotal,
  };

}
