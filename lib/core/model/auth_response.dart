// No changes needed for AuthResponse itself, as it correctly points to AuthResponseData
class AuthResponse {
  final bool? success;
  final String? message;
  final AuthResponseData? data;

  AuthResponse({
    this.success,
    this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json["success"],
      message: json["message"],
      data:
          json["data"] == null ? null : AuthResponseData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class AuthResponseData {
  final Customer? user; // This will now parse from '_doc'
  final String? accessToken;
  final String? refreshToken;

  AuthResponseData({
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    print("AuthResponseData.fromJson: Raw JSON: $json"); // Debug log
    final rawUser = json["user"] ?? json;
    final userData =
        (rawUser is Map<String, dynamic> && rawUser.containsKey("_doc"))
            ? rawUser["_doc"]
            : rawUser;

    print(
        "AuthResponseData.fromJson: Parsed user data: $userData"); // Debug log

    return AuthResponseData(
      user: userData == null ? null : Customer.fromJson(userData),
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
    );
  }

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      };
}

class Customer {
  final String? id;
  final String? email;
  final String? phoneNumber;
  final List<String>? stores;
  final bool? emailVerified;
  final List<String>? role;

  final String? deviceToken;
  final int? point;
  final String? image;
  final bool? isAdmin;
  final int? balance;
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
  final String? subscriptionType;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final dynamic
      store; // This looks like it might be a single store ID or object
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Customer({
    this.stores,
    this.role,
    this.id,
    this.deviceToken,
    this.email,
    this.phoneNumber,
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
    this.store,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    print("Customer.fromJson: Parsing JSON data: $json"); // Debug log

    return Customer(
      id: json["_id"]?.toString(),
      deviceToken: json["deviceToken"],
      email: json["email"],
      phoneNumber: json["phoneNumber"],
      point:
          json["point"] != null ? int.tryParse(json["point"].toString()) : null,
      image: json["image"],
      isAdmin: json["isAdmin"],
      balance: json["balance"] != null
          ? int.tryParse(json["balance"].toString())
          : null,
      emailVerified: json["emailVerified"] ?? false,
      password: json["password"],
      country: json["country"],
      state: json["state"],
      city: json["city"],
      area: json["area"],
      firstName: json["firstName"],
      pin: json["pin"] != null ? int.tryParse(json["pin"].toString()) : null,
      defaultPinChanged: json["defaultPinChanged"] ?? false,
      lastName: json["lastName"],
      bio: json["bio"],
      currency: json["currency"],
      businessType: json["businessType"],
      businessName: json["businessName"],
      profilePhoto: json["profilePhoto"],
      interests: json["interests"] == null
          ? []
          : List<dynamic>.from(json["interests"].map((x) => x)),
      wallet: json["wallet"] != null
          ? int.tryParse(json["wallet"].toString())
          : null,
      isGoogleAuth: json["isGoogleAuth"],
      isPremium: json["isPremium"],
      subscriptionType: json["subscriptionType"],
      subscriptionStartDate: _parseDate(json["subscriptionStartDate"]),
      subscriptionEndDate: _parseDate(json["subscriptionEndDate"]),
      store: json["store"],
      createdAt: _parseDate(json["createdAt"]),
      updatedAt: _parseDate(json["updatedAt"]),
      v: json["__v"] != null ? int.tryParse(json["__v"].toString()) : null,
      stores: json["stores"] == null
          ? []
          : List<String>.from(json["stores"].map((x) => x.toString())),
      role: json["role"] == null
          ? []
          : List<String>.from(json["role"].map((x) => x.toString())),
    );
  }

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      print("Warning: Invalid date string provided: $dateStr");
      return null;
    }
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) {
      print("Warning: Failed to parse date string: $dateStr");
    }
    return parsed;
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "deviceToken": deviceToken,
        "email": email,
        "phoneNumber": phoneNumber,
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
        "subscriptionStartDate": subscriptionStartDate?.toIso8601String(),
        "subscriptionEndDate": subscriptionEndDate?.toIso8601String(),
        "store": store,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "stores": stores?.map((x) => x).toList(),
        "role": role?.map((x) => x).toList(),
      };
}
