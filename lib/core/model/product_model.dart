class AddProductResponse {
  final bool? success;
  final Product? data;
  final String? message;

  AddProductResponse({
     this.success,
     this.data,
     this.message,
  });

  factory AddProductResponse.fromJson(Map<String, dynamic> json) {
    return AddProductResponse(
      success: json['success'] ?? false,
      data: Product.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}


class Product {
  Product({
    this.name,
    this.price,
    this.category,
    this.code,
    this.quantity,
    this.categoryId,
    this.unitId,
    this.stock,
    this.size,
    this.totalQuantity,
    this.totalCost,
    this.unitPrice,
    this.minQuantity,
    this.expiryDate,
    this.brands,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  final String? name;
  final int? price;
  final String? category;
  final String? code;
  final int? quantity;
  final Category? categoryId; // Changed from String? to Category?
  final int? unitId;
  final int? stock;
  final String? size;
  final int? totalQuantity;
  final int? totalCost;
  final int? unitPrice;
  final int? minQuantity;
  final String? expiryDate;
  final String? brands;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json["name"],
      price: json["price"],
      category: json["category"],
      code: json["code"],
      quantity: json["quantity"],
      categoryId: json["categoryId"] == null
          ? null
          : Category.fromJson(json["categoryId"]),
      unitId: json["unitId"],
      stock: json["stock"],
      size: json["size"],
      totalQuantity: json["totalQuantity"],
      totalCost: json["totalCost"],
      unitPrice: json["unitPrice"],
      minQuantity: json["minQuantity"],
      expiryDate: json["expiryDate"],
      brands: json["brands"],
      id: json["_id"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "category": category,
    "code": code,
    "quantity": quantity,
    "categoryId": categoryId?.toJson(),
    "unitId": unitId,
    "stock": stock,
    "size": size,
    "totalQuantity": totalQuantity,
    "totalCost": totalCost,
    "unitPrice": unitPrice,
    "minQuantity": minQuantity,
    "expiryDate": expiryDate,
    "brands": brands,
    "_id": id,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

  // Add the copyWith method
  Product copyWith({
    String? name,
    int? price,
    String? category,
    String? code,
    int? quantity,
    Category? categoryId,
    int? unitId,
    int? stock,
    String? size,
    int? totalQuantity,
    int? totalCost,
    int? unitPrice,
    int? minQuantity,
    String? expiryDate,
    String? brands,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return Product(
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      code: code ?? this.code,
      quantity: quantity ?? this.quantity,
      categoryId: categoryId ?? this.categoryId,
      unitId: unitId ?? this.unitId,
      stock: stock ?? this.stock,
      size: size ?? this.size,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalCost: totalCost ?? this.totalCost,
      unitPrice: unitPrice ?? this.unitPrice,
      minQuantity: minQuantity ?? this.minQuantity,
      expiryDate: expiryDate ?? this.expiryDate,
      brands: brands ?? this.brands,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}



class Category {
  final String? id;
  final String? name;
  final int? v;

  Category( { this.id,  this.name, this.v});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'] ?? 'Unknown', // fallback if name is missing
      v: json['__v'] ?? 0,
    );
  }


  Map<String, dynamic> toJson() =>{
    "_id": id,
    "name": name,
    "__v": v,
  };
}


