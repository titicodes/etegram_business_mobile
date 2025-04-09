class AuthResponse {
  final bool? success;
  final Customer? data;
  final String? message;

  AuthResponse({
    this.success,
    this.data,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json["success"],
      data: json["data"] != null ? Customer.fromJson(json["data"]) : null,
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
  };
}

class Customer {
  final bool? success;
  final String? id;
  final String? deviceToken;
  final String? email;
  final String? phone;
  final int? point;
  final dynamic image;
  final bool? isAdmin;
  final int? balance;
  final bool? emailVerified;
  final String? password;
  final String? country;
  final String? state;
  final String? city;
  final String? area;
  final String? firstName;
  final int? pin;
  final bool? defaultPinChanged;
  final String? lastName;
  final String? bio;
  final String? currency;
  final String? businessType;
  final String? businessName;
  final String? profilePhoto;
  final List<dynamic>? interests;
  final int? wallet;
  final bool? isGoogleAuth;
  final bool? isPremium;
  final dynamic subscriptionType;
  final dynamic subscriptionStartDate;
  final dynamic subscriptionEndDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? refreshToken;
  final String? accessToken;

  Customer({
    this.success,
    this.id,
    this.deviceToken,
    this.email,
    this.phone,
    this.point,
    this.image,
    this.isAdmin,
    this.balance,
    this.emailVerified,
    this.password,
    this.country,
    this.state,
    this.city,
    this.area,
    this.firstName,
    this.pin,
    this.defaultPinChanged,
    this.lastName,
    this.bio,
    this.currency,
    this.businessType,
    this.businessName,
    this.profilePhoto,
    this.interests,
    this.wallet,
    this.isGoogleAuth,
    this.isPremium,
    this.subscriptionType,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.refreshToken,
    this.accessToken,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      success: json["success"],
      id: json["_id"],
      deviceToken: json["deviceToken"],
      email: json["email"],
      phone: json["phone"],
      point: json["point"],
      image: json["image"],
      isAdmin: json["isAdmin"],
      balance: json["balance"],
      emailVerified: json["emailVerified"],
      password: json["password"],
      country: json["country"],
      state: json["state"],
      city: json["city"],
      area: json["area"],
      firstName: json["firstName"],
      pin: json["pin"],
      defaultPinChanged: json["defaultPinChanged"],
      lastName: json["lastName"],
      bio: json["bio"],
      currency: json["currency"],
      businessType: json["businessType"],
      businessName: json["businessName"],
      profilePhoto: json["profilePhoto"],
      interests: json["interests"] == null
          ? []
          : List<dynamic>.from(json["interests"]!.map((x) => x)),
      wallet: json["wallet"],
      isGoogleAuth: json["isGoogleAuth"],
      isPremium: json["isPremium"],
      subscriptionType: json["subscriptionType"],
      subscriptionStartDate: json["subscriptionStartDate"],
      subscriptionEndDate: json["subscriptionEndDate"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
      refreshToken: json["refreshToken"],
      accessToken: json["accessToken"],
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "_id": id,
    "deviceToken": deviceToken,
    "email": email,
    "phone": phone,
    "point": point,
    "image": image,
    "isAdmin": isAdmin,
    "balance": balance,
    "emailVerified": emailVerified,
    "password": password,
    "country": country,
    "state": state,
    "city": city,
    "area": area,
    "firstName": firstName,
    "pin": pin,
    "defaultPinChanged": defaultPinChanged,
    "lastName": lastName,
    "bio": bio,
    "currency": currency,
    "businessType": businessType,
    "businessName": businessName,
    "profilePhoto": profilePhoto,
    "interests": interests?.map((x) => x).toList(),
    "wallet": wallet,
    "isGoogleAuth": isGoogleAuth,
    "isPremium": isPremium,
    "subscriptionType": subscriptionType,
    "subscriptionStartDate": subscriptionStartDate,
    "subscriptionEndDate": subscriptionEndDate,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "refreshToken": refreshToken,
    "accessToken": accessToken,
  };
}