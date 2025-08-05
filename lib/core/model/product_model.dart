// class AddProductResponse {
//   final bool success;
//   final Product? data;
//   final String? message;
//
//   AddProductResponse({required this.success, this.data, this.message});
//
//   factory AddProductResponse.fromJson(Map<String, dynamic> json) {
//     return AddProductResponse(
//       success: json['success'] ?? false,
//       data: json['data'] != null ? Product.fromJson(json['data']) : null,
//       message: json['message'],
//     );
//   }
// }
//
// class Product {
//   final String? id;
//   final String? name;
//   final String? code;
//   final String? category;
//   final double? price;
//   final double? costPrice;
//   final int? quantity;
//   final int? minQuantity;
//   final String? expiryDate;
//   final String? description;
//   final String? size;
//   final String? brands;
//   final String? storeId;
//   final String? owner;
//   final String? imageUrl;
//
//   Product({
//     this.id,
//     this.name,
//     this.code,
//     this.category,
//     this.price,
//     this.costPrice,
//     this.quantity,
//     this.minQuantity,
//     this.expiryDate,
//     this.description,
//     this.size,
//     this.brands,
//     this.storeId,
//     this.owner,
//     this.imageUrl,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['_id']?.toString(),
//       name: json['name']?.toString(),
//       code: json['code']?.toString(),
//       category: json['category']?.toString(),
//       price: _parseDouble(json['price']),
//       costPrice: _parseDouble(json['costPrice']),
//       quantity: _parseInt(json['quantity']),
//       minQuantity: _parseInt(json['minQuantity']),
//       expiryDate: json['expiryDate']?.toString(),
//       description: json['description']?.toString(),
//       size: json['size']?.toString(),
//       brands: json['brands']?.toString(),
//       storeId: json['storeId']?.toString(),
//       owner: json['owner']?.toString(),
//       imageUrl: json['imageUrl']?.toString(),
//     );
//   }
//
//   static double? _parseDouble(dynamic value) {
//     if (value == null) return null;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value);
//     return null;
//   }
//
//   static int? _parseInt(dynamic value) {
//     if (value == null) return null;
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value);
//     if (value is double) return value.toInt();
//     return null;
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       if (id != null) '_id': id,
//       if (name != null) 'name': name,
//       if (code != null) 'code': code,
//       if (category != null) 'category': category,
//       if (price != null) 'price': price,
//       if (costPrice != null) 'costPrice': costPrice,
//       if (quantity != null) 'quantity': quantity,
//       if (minQuantity != null) 'minQuantity': minQuantity,
//       if (expiryDate != null) 'expiryDate': expiryDate,
//       if (description != null) 'description': description,
//       if (size != null) 'size': size,
//       if (brands != null) 'brands': brands,
//       if (storeId != null) 'storeId': storeId,
//       if (owner != null) 'owner': owner,
//       if (imageUrl != null) 'imageUrl': imageUrl,
//     };
//   }
//
//   Map<String, dynamic> toCreateJson() {
//     return {
//       'name': name ?? '',
//       'category': category ?? 'Uncategorized',
//       'price': price ?? 1.0,
//       'costPrice': costPrice ?? 0.0,
//       'quantity': quantity ?? 1,
//       'minQuantity': minQuantity ?? 1,
//       'storeId': storeId ?? '',
//       if (expiryDate != null) 'expiryDate': expiryDate,
//       if (description != null) 'description': description,
//       if (size != null) 'size': size,
//       if (brands != null) 'brands': brands,
//       if (imageUrl != null) 'imageUrl': imageUrl,
//     };
//   }
// }
//
// class Category {
//   final String? id;
//   final String? name;
//   final int? v;
//
//   Category({this.id, this.name, this.v});
//
//   factory Category.fromJson(Map<String, dynamic> json) {
//     return Category(
//       id: json['_id'] as String?,
//       name: json['name'] as String?,
//       v: json['__v'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "name": name,
//         "__v": v,
//       };
// }
import 'package:equatable/equatable.dart';

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


class Product extends Equatable {
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
  final List<String>? brands;
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
    List<String>? parseBrands(dynamic brands) {
      if (brands == null) return null;
      if (brands is String) return brands.split(',').map((e) => e.trim()).toList();
      if (brands is List) {
        List<String> flattened = [];
        for (var item in brands) {
          if (item is String) {
            flattened.add(item);
          } else if (item is List) {
            flattened.addAll(parseBrands(item) ?? []);
          }
        }
        return flattened.isEmpty ? null : flattened;
      }
      return null;
    }

    return Product(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      category: json['category'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      quantity: json['quantity'] as int? ?? json['stock'] as int?,
      minQuantity: json['minQuantity'] as int?,
      expiryDate: json['expiryDate'] as String?,
      description: json['description'] as String?,
      size: json['size'] as String?,
      brands: parseBrands(json['brands']),
      storeId: json['store'] as String?,
      owner: json['owner'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
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

  String get displayBrands => brands?.isNotEmpty == true ? brands!.join(', ') : 'No Brand';

  Product copyWith({
    String? id,
    String? name,
    String? code,
    String? category,
    double? price,
    double? costPrice,
    int? quantity,
    int? minQuantity,
    String? expiryDate,
    String? description,
    String? size,
    List<String>? brands,
    String? storeId,
    String? owner,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      size: size ?? this.size,
      brands: brands ?? this.brands,
      storeId: storeId ?? this.storeId,
      owner: owner ?? this.owner,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    category,
    price,
    costPrice,
    quantity,
    minQuantity,
    expiryDate,
    description,
    size,
    brands,
    storeId,
    owner,
    imageUrl,
  ];
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
