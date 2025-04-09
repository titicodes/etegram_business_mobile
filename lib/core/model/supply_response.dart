class SupplyResponse {
  SupplyResponse({
    this.success,
    this.data,
    this.message,
  });

  final bool? success;
  final SupplyData? data;
  final String? message;

  factory SupplyResponse.fromJson(Map<String, dynamic> json) {
    return SupplyResponse(
      success: json["success"],
      data: json["data"] == null ? null : SupplyData.fromJson(json["data"]),
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class SupplyData {
  SupplyData({
    this.id,
    this.businessName,
    this.contactName,
    this.email,
    this.phoneNumber,
    this.currency,
    this.accountDetails,
    this.address,
    this.country,
    this.state,
    this.lga,
    this.area,
    this.extraMobile,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  final String? id;
  final String? businessName;
  final String? contactName;
  final String? email;
  final String? phoneNumber;
  final String? currency;
  final String? accountDetails;
  final String? address;
  final String? country;
  final String? state;
  final String? lga;
  final String? area;
  final String? extraMobile;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory SupplyData.fromJson(Map<String, dynamic> json) {
    return SupplyData(
      id: json["_id"],
      businessName: json["businessName"],
      contactName: json["contactName"],
      email: json["email"],
      phoneNumber: json["phoneNumber"],
      currency: json["currency"],
      accountDetails: json["accountDetails"],
      address: json["address"],
      country: json["country"],
      state: json["state"],
      lga: json["lga"],
      area: json["area"],
      extraMobile: json["extraMobile"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "businessName": businessName,
        "contactName": contactName,
        "email": email,
        "phoneNumber": phoneNumber,
        "currency": currency,
        "accountDetails": accountDetails,
        "address": address,
        "country": country,
        "state": state,
        "lga": lga,
        "area": area,
        "extraMobile": extraMobile,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
