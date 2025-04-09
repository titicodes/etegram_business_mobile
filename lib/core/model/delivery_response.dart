class DeliveryResponse {
  DeliveryResponse({
     this.success,
     this.data,
     this.message,
  });

  final bool? success;
  final DeliveryResponseData? data;
  final String? message;

  factory DeliveryResponse.fromJson(Map<String, dynamic> json){
    return DeliveryResponse(
      success: json["success"],
      data: json["data"] == null ? null : DeliveryResponseData.fromJson(json["data"]),
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
  };

}

class DeliveryResponseData {
  DeliveryResponseData({
     this.succes,
     this.data,
     this.message,
  });

  final bool? succes;
  final DeliveryData? data;
  final String? message;

  factory DeliveryResponseData.fromJson(Map<String, dynamic> json){
    return DeliveryResponseData(
      succes: json["succes"],
      data: json["data"] == null ? null : DeliveryData.fromJson(json["data"]),
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
    "succes": succes,
    "data": data?.toJson(),
    "message": message,
  };

}

class DeliveryData {
  DeliveryData({
     this.id,
     this.firstName,
     this.lastName,
     this.email,
     this.phoneNumber,
     this.estate,
     this.country,
     this.area,
     this.extraPhone,
     this.supplierType,
     this.extraDetails,
     this.user,
     this.createdAt,
     this.updatedAt,
     this.v,
    this.state,
    this.city
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? state;
  final String? email;
  final String? phoneNumber;
  final String? estate;
  final String? country;
  final String? area;
  final String? extraPhone;
  final String? supplierType;
  final String? extraDetails;
  final String? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? city;
  final int? v;

  factory DeliveryData.fromJson(Map<String, dynamic> json){
    return DeliveryData(
      id: json["_id"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      email: json["email"],
      phoneNumber: json["phoneNumber"],
      estate: json["estate"],
      country: json["country"],
      area: json["area"],
      extraPhone: json["extraPhone"],
      supplierType: json["supplierType"],
      extraDetails: json["extraDetails"],
      user: json["user"],
      state: json["state"],
      city: json["city"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phoneNumber": phoneNumber,
    "estate": estate,
    "country": country,
    "area": area,
    "extraPhone": extraPhone,
    "supplierType": supplierType,
    "extraDetails": extraDetails,
    "user": user,
    "city":city,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

}
