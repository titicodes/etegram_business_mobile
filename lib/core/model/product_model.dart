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
    Map<String, dynamic>? productData = json['data'] as Map<String, dynamic>?;

    return AddProductResponse(
      success: json['success'] as bool? ?? false,
      data: productData != null ? Product.fromJson(productData) : null,
      message: json['message'] as String? ?? '',
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
    this.owner,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  final String? name;
  final int? price;
  final String? category;
  final String? code;
  final int? quantity;
  final Category? categoryId;
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
  final String? owner;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json["name"] as String?,
      price: int.tryParse(json["price"]?.toString() ?? ''),
      category: json["category"] as String?,
      code: json["code"] as String?,
      quantity: int.tryParse(json["quantity"]?.toString() ?? ''),
      categoryId: json["categoryId"] is Map<String, dynamic>
          ? Category.fromJson(json["categoryId"])
          : (json["categoryId"] is String
          ? Category(id: json["categoryId"])
          : null),
      unitId: int.tryParse(json["unitId"]?.toString() ?? ''),
      stock: int.tryParse(json["stock"]?.toString() ?? ''),
      size: json["size"]?.toString(),
      totalQuantity: int.tryParse(json["totalQuantity"]?.toString() ?? ''),
      totalCost: int.tryParse(json["totalCost"]?.toString() ?? ''),
      unitPrice: int.tryParse(json["unitPrice"]?.toString() ?? ''),
      minQuantity: int.tryParse(json["minQuantity"]?.toString() ?? ''),
      expiryDate: json["expiryDate"]?.toString(),
      brands: json["brands"]?.toString(),
      id: json["_id"]?.toString(),
      owner: json["owner"]?.toString(),
      createdAt: DateTime.tryParse(json["createdAt"]?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json["updatedAt"]?.toString() ?? ''),
      v: int.tryParse(json["__v"]?.toString() ?? ''),
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
    "owner":owner,
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
    String? owner,
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
      owner: owner ?? this.owner,
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
      id: json['_id'] as String?,
      name: json['name'] as String?,
      v: json['__v'] ?? 0,
    );
  }


  Map<String, dynamic> toJson() =>{
    "_id": id,
    "name": name,
    "__v": v,
  };
}




