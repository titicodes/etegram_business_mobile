class AllProduct {
  AllProduct({
    required this.success,
    required this.data,
    required this.message,
  });

  final bool? success;
  final Data? data;
  final String? message;

  factory AllProduct.fromJson(Map<String, dynamic> json){
    return AllProduct(
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
     this.data,
     this.metadata,
  });

  final List<Datum>? data;
  final Metadata? metadata;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data?.map((x) => x.toJson()).toList(),
    "metadata": metadata?.toJson(),
  };

}

class Datum {
  Datum({
     this.id,
     this.name,
     this.price,
     this.category,
     this.code,
     this.quantity,
     this.owner,
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
     this.createdAt,
     this.updatedAt,
     this.v,
  });

  final String? id;
  final String? name;
  final int? price;
  final String? category;
  final String? code;
  final int? quantity;
  final String? owner;
  final CategoryId? categoryId;
  final int? unitId;
  final int? stock;
  final String? size;
  final int? totalQuantity;
  final int? totalCost;
  final int? unitPrice;
  final int? minQuantity;
  final String? expiryDate;
  final String? brands;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory Datum.fromJson(Map<String, dynamic> json){
    return Datum(
      id: json["_id"],
      name: json["name"],
      price: json["price"],
      category: json["category"],
      code: json["code"],
      quantity: json["quantity"],
      owner: json["owner"],
      categoryId: json["categoryId"] == null ? null : CategoryId.fromJson(json["categoryId"]),
      unitId: json["unitId"],
      stock: json["stock"],
      size: json["size"],
      totalQuantity: json["totalQuantity"],
      totalCost: json["totalCost"],
      unitPrice: json["unitPrice"],
      minQuantity: json["minQuantity"],
      expiryDate: json["expiryDate"],
      brands: json["brands"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "price": price,
    "category": category,
    "code": code,
    "quantity": quantity,
    "owner": owner,
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
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

}

class CategoryId {
  CategoryId({
    required this.id,
    required this.name,
    required this.v,
  });

  final String? id;
  final String? name;
  final int? v;

  factory CategoryId.fromJson(Map<String, dynamic> json){
    return CategoryId(
      id: json["_id"],
      name: json["name"],
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "__v": v,
  };

}

class Metadata {
  Metadata({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
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
