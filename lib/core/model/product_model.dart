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
  final String? code;
  final String? category;
  final double? price;
  final double? costPrice;
  final int? quantity;
  final int? minQuantity;
  final String? expiryDate;
  final String? description;
  final String? size;
  final String? brands;
  final String? storeId;
  final String? owner;
  final String? imageUrl;

  Product({
    this.id,
    this.name,
    this.code,
    this.category,
    this.price,
    this.costPrice,
    this.quantity,
    this.minQuantity,
    this.expiryDate,
    this.description,
    this.size,
    this.brands,
    this.storeId,
    this.owner,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      category: json['category']?.toString(),
      price: _parseDouble(json['price']),
      costPrice: _parseDouble(json['costPrice']),
      quantity: _parseInt(json['quantity']),
      minQuantity: _parseInt(json['minQuantity']),
      expiryDate: json['expiryDate']?.toString(),
      description: json['description']?.toString(),
      size: json['size']?.toString(),
      brands: json['brands']?.toString(),
      storeId: json['storeId']?.toString(),
      owner: json['owner']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (category != null) 'category': category,
      if (price != null) 'price': price,
      if (costPrice != null) 'costPrice': costPrice,
      if (quantity != null) 'quantity': quantity,
      if (minQuantity != null) 'minQuantity': minQuantity,
      if (expiryDate != null) 'expiryDate': expiryDate,
      if (description != null) 'description': description,
      if (size != null) 'size': size,
      if (brands != null) 'brands': brands,
      if (storeId != null) 'storeId': storeId,
      if (owner != null) 'owner': owner,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name ?? '',
      'category': category ?? 'Uncategorized',
      'price': price ?? 1.0,
      'costPrice': costPrice ?? 0.0,
      'quantity': quantity ?? 1,
      'minQuantity': minQuantity ?? 1,
      'storeId': storeId ?? '',
      if (expiryDate != null) 'expiryDate': expiryDate,
      if (description != null) 'description': description,
      if (size != null) 'size': size,
      if (brands != null) 'brands': brands,
      if (imageUrl != null) 'imageUrl': imageUrl,
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
