class InventoryResponse {
  InventoryResponse({
    this.success,
    this.data,
    this.message,
  });

  final bool? success;
  final Inventory? data;
  final String? message;

  factory InventoryResponse.fromJson(Map<String, dynamic> json) {
    return InventoryResponse(
      success: json["success"],
      data: json["data"] == null ? null : Inventory.fromJson(json["data"]),
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class Inventory {
  Inventory({
    this.totalCost,
    this.totalSellingPrice,
    this.totalStock,
  });

  final int? totalCost;
  final int? totalSellingPrice;
  final int? totalStock;

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      totalCost: json["totalCost"],
      totalSellingPrice: json["totalSellingPrice"],
      totalStock: json["totalStock"],
    );
  }

  Map<String, dynamic> toJson() => {
        "totalCost": totalCost,
        "totalSellingPrice": totalSellingPrice,
        "totalStock": totalStock,
      };
}
