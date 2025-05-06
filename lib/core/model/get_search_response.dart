class SearchProductResponse {
  SearchProductResponse({
     this.success,
     this.data,
     this.message,
  });

  final bool? success;
  final Data? data;
  final String? message;

  factory SearchProductResponse.fromJson(Map<String, dynamic> json){
    return SearchProductResponse(
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
    required this.data,
    required this.metadata,
  });

  final List<ProductData> data;
  final Metadata? metadata;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      data: json["data"] == null ? [] : List<ProductData>.from(json["data"]!.map((x) => ProductData.fromJson(x))),
      metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data.map((x) => x?.toJson()).toList(),
    "metadata": metadata?.toJson(),
  };

}

class ProductData {
  ProductData({
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
     this.unitId,
     this.size,
     this.totalQuantity,
     this.totalCost,
     this.unitPrice,
     this.minQuantity,
     this.expiryDate,
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
  final int? unitId;
  final String? size;
  final int? totalQuantity;
  final int? totalCost;
  final int? unitPrice;
  final int? minQuantity;
  final String? expiryDate;

  factory ProductData.fromJson(Map<String, dynamic> json){
    return ProductData(
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
      unitId: json["unitId"],
      size: json["size"],
      totalQuantity: json["totalQuantity"],
      totalCost: json["totalCost"],
      unitPrice: json["unitPrice"],
      minQuantity: json["minQuantity"],
      expiryDate: json["expiryDate"],
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
    "unitId": unitId,
    "size": size,
    "totalQuantity": totalQuantity,
    "totalCost": totalCost,
    "unitPrice": unitPrice,
    "minQuantity": minQuantity,
    "expiryDate": expiryDate,
  };

}

class Metadata {
  Metadata({
     this.total,
     this.page,
     this.limit,
     this.totalPages,
  });

  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  factory Metadata.fromJson(Map<String, dynamic> json){
    return Metadata(
      total: json["total"],
      page: json["page"],
      limit: json["limit"],
      totalPages: json["totalPages"],
    );
  }

  Map<String, dynamic> toJson() => {
    "total": total,
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
  };

}
