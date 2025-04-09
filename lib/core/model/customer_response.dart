import 'dart:convert';

// Helper function to decode the JSON string (optional, for testing)
CustomerResponse customerApiResponseFromJson(String str) =>
    CustomerResponse.fromJson(json.decode(str));

// Helper function to encode to JSON string (optional, for testing)
String customerApiResponseToJson(CustomerResponse data) =>
    json.encode(data.toJson());

class CustomerResponse {
  final bool? success;
  final List<CustomerData>? data; // ✅ Change data to a List
  final String? message;

  CustomerResponse({
    this.success,
    this.data,
    this.message,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) =>
      CustomerResponse(
        success: json["success"] ?? false,
        data: json["data"] == null
            ? null
            : (json["data"] as List) // ✅ Convert list elements to CustomerData
            .map((item) => CustomerData.fromJson(item))
            .toList(),
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.map((item) => item.toJson()).toList(), // ✅ Convert list back
    "message": message,
  };
}


class CustomerData {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? currency; // Nullable as it can be empty
  final String? phoneNumber; // Generally good practice to make it nullable
  final String? address;
  final String? country;
  final String? birthday; // Keep as String, or parse to DateTime if needed
  final String? state;
  final String? area;
  final String? extraPhone; // Nullable
  final String? supplierType; // Nullable
  final String? lga;
  final String? extraDetails; // Nullable
  final DateTime? createdAt; // Use DateTime for date fields
  final DateTime? updatedAt; // Use DateTime for date fields
  final int? v; // Version key, often an integer

  CustomerData({
     this.id,
     this.firstName,
     this.lastName,
     this.email,
    this.currency,
    this.phoneNumber,
    this.address,
    this.country,
    this.birthday,
    this.state,
    this.area,
    this.extraPhone,
    this.supplierType,
    this.lga,
    this.extraDetails,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) => CustomerData(
    id: json["_id"] ?? "", // Use default value if key is missing or null
    firstName: json["firstName"] ?? "",
    lastName: json["lastName"] ?? "",
    email: json["email"] ?? "",
    currency: json["currency"], // Allows null
    phoneNumber: json["phoneNumber"],
    address: json["address"],
    country: json["country"],
    birthday: json["birthday"],
    state: json["state"],
    area: json["area"],
    extraPhone: json["extraPhone"],
    supplierType: json["supplierType"],
    lga: json["lga"],
    extraDetails: json["extraDetails"],
    // Use tryParse for robust date parsing
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.tryParse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.tryParse(json["updatedAt"]),
    v: json["__v"], // Allows null
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "currency": currency,
    "phoneNumber": phoneNumber,
    "address": address,
    "country": country,
    "birthday": birthday,
    "state": state,
    "area": area,
    "extraPhone": extraPhone,
    "supplierType": supplierType,
    "lga": lga,
    "extraDetails": extraDetails,
    // Convert DateTime back to ISO 8601 string format for JSON
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

  @override
  String toString() {
    return 'CustomerData(id: $id, firstName: $firstName, lastName: $lastName, email: $email, currency: $currency, phoneNumber: $phoneNumber, address: $address, country: $country, birthday: $birthday, state: $state, area: $area, extraPhone: $extraPhone, supplierType: $supplierType, lga: $lga, extraDetails: $extraDetails, createdAt: $createdAt, updatedAt: $updatedAt, v: $v)';
  }
}