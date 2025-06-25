class AddProductResponse {
  final bool success;
  final Product? data;
  final String? message;

  AddProductResponse({required this.success, this.data, this.message});

  factory AddProductResponse.fromJson(Map<String, dynamic> json) {
    return AddProductResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? Product.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class Product {
  final String? id;
  final String? name;
  final String? imageUrl;
  final String? code;
  final String? category;
  final String? categoryId;
  final int? price;
  final int? costPrice;
  final int? quantity;
  final String? size;
  final String? expiryDate;
  final String? brands;
  final String? store;
  final String? owner;
  final int? stock;
  final int? minQuantity;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    this.name,
    this.imageUrl = "PR",
    this.code,
    this.category,
    this.categoryId,
    this.price,
    this.costPrice,
    this.quantity,
    this.size,
    this.expiryDate,
    this.brands,
    this.store,
    this.owner,
    this.stock,
    this.minQuantity,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id']?.toString(),
      name: json['name'],
      code: json['code'],
      category: json['category'],
      categoryId: json['categoryId'] is Map
          ? json['categoryId']['_id']?.toString()
          : json['categoryId']?.toString(),
      price: json['price']?.toInt(),
      costPrice: json['costPrice']?.toInt(),
      quantity: json['quantity']?.toInt(),
      size: json['size'],
      expiryDate: json['expiryDate'],
      brands:
          json['brands'] is List ? json['brands'].join(', ') : json['brands'],
      store: json['store']?.toString(),
      owner: json['owner']?.toString(),
      stock: json['stock']?.toInt(),
      minQuantity: json['minQuantity']?.toInt(),
      description: json['description'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'code': code,
      'category': category,
      'categoryId': categoryId,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
      'size': size,
      'expiryDate': expiryDate,
      'brands': brands,
      'store': store,
      'owner': owner,
      'stock': stock,
      'minQuantity': minQuantity,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Category {
  final String? id;
  final String? name;
  final int? v;

  Category({this.id, this.name, this.v});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "__v": v,
      };
}
