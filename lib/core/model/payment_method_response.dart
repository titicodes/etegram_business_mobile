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
    this.id,
    this.v,
  });

  final User? user;
  final String? name;
  final String? bank;
  final String? accountNumber;
  final String? accountName;
  final String? extraInfo;
  final String? id;
  final int? v;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      name: json["name"],
      bank: json["bank"],
      accountNumber: json["accountNumber"],
      accountName: json["accountName"],
      extraInfo: json["extraInfo"],
      id: json["_id"],
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "name": name,
        "bank": bank,
        "accountNumber": accountNumber,
        "accountName": accountName,
        "extraInfo": extraInfo,
        "_id": id,
        "__v": v,
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
