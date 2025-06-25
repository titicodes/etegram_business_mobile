// lib/core/model/payment_method_type.dart (or wherever you prefer)

enum PaymentMethodType {
  CASH,
  CARD,
  TRANSFER,
}

extension PaymentMethodTypeExtension on PaymentMethodType {
  // For displaying in the UI dropdown
  String toDisplayName() {
    switch (this) {
      case PaymentMethodType.CASH:
        return 'Cash';
      case PaymentMethodType.CARD:
        return 'Card';
      case PaymentMethodType.TRANSFER:
        return 'Transfer';
    }
  }

  // For sending to the backend API
  String toBackendString() {
    return toString().split('.').last; // Returns 'CASH', 'CARD', 'TRANSFER'
  }
}

class PaymentResponse {
  PaymentResponse({
    this.success,
    this.data,
    this.message,
  });

  final bool? success;
  final PaymentMethod? data;
  final String? message;

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json["success"],
      data: json["data"] == null ? null : PaymentMethod.fromJson(json["data"]),
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class PaymentMethod {
  PaymentMethod({
    this.user,
    this.name,
    this.bank,
    this.accountNumber,
    this.accountName,
    this.extraInfo,
    this.store,
    this.id,
    this.v,
    this.type, // <<< ADD THIS FIELD
    this.details, // <<< ADD THIS OPTIONAL FIELD if you plan to use it
  });

  final User? user;
  final String? name;
  final String? bank;
  final String? accountNumber;
  final String? accountName;
  final String? extraInfo;
  final String? id;
  final int? v;
  final String? store;
  final PaymentMethodType? type; // <<< Type of the enum
  final String? details; // <<< Optional details field

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      name: json["name"],
      bank: json["bank"],
      accountNumber: json["accountNumber"],
      accountName: json["accountName"],
      extraInfo: json["extraInfo"],
      store:
          json["store"], // Correctly map 'storeId' from backend to 'store' here
      id: json["_id"],
      v: json["__v"],
      type: json["type"] != null
          ? PaymentMethodType.values.firstWhere(
              (e) => e.toBackendString() == json["type"],
              orElse: () =>
                  PaymentMethodType.TRANSFER, // Default or handle unknown type
            )
          : null, // <<< Parse type from JSON
      details: json["details"], // <<< Parse details from JSON
    );
  }

  Map<String, dynamic> toJson() => {
        "user": user
            ?.toJson(), // This 'user' field is likely not needed for *creation* payload
        "name": name,
        "bank": bank,
        "accountNumber": accountNumber,
        "accountName": accountName,
        "extraInfo": extraInfo,
        // _id and __v are typically not sent on creation
        // "_id": id,
        // "__v": v,
        "storeId": store,
        "type": type?.toBackendString(),
        "details": details, // <<< Include details if availabl
      };
}

class User {
  User({
    required this.id,
    required this.email,
    required this.isAdmin,
    required this.iat,
    required this.exp,
  });

  final String? id;
  final String? email;
  final bool? isAdmin;
  final int? iat;
  final int? exp;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"],
      email: json["email"],
      isAdmin: json["isAdmin"],
      iat: json["iat"],
      exp: json["exp"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "email": email,
        "isAdmin": isAdmin,
        "iat": iat,
        "exp": exp,
      };
}
