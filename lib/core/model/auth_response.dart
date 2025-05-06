// class AuthResponse {
//   final bool? success;
//   final Customer? data;
//   final String? message;
//
//   AuthResponse({
//     this.success,
//     this.data,
//     this.message,
//   });
//
//   factory AuthResponse.fromJson(Map<String, dynamic> json) {
//     return AuthResponse(
//       success: json["success"],
//       data: json["data"] != null ? Customer.fromJson(json["data"]) : null,
//       message: json["message"],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "success": success,
//     "data": data?.toJson(),
//     "message": message,
//   };
// }

// class Customer {
//   final bool? success;
//   final String? id;
//   final String? deviceToken;
//   final String? email;
//   final String? phone;
//   final int? point;
//   final dynamic image;
//   final bool? isAdmin;
//   final int? balance;
//   final bool? emailVerified;
//   final String? password;
//   final String? country;
//   final String? state;
//   final String? city;
//   final String? area;
//   final String? firstName;
//   final int? pin;
//   final bool? defaultPinChanged;
//   final String? lastName;
//   final String? bio;
//   final String? currency;
//   final String? businessType;
//   final String? businessName;
//   final String? profilePhoto;
//   final List<dynamic>? interests;
//   final int? wallet;
//   final bool? isGoogleAuth;
//   final bool? isPremium;
//   final dynamic subscriptionType;
//   final dynamic subscriptionStartDate;
//   final dynamic subscriptionEndDate;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final int? v;
//   final String? refreshToken;
//   final String? accessToken;
//
//   Customer({
//     this.success,
//     this.id,
//     this.deviceToken,
//     this.email,
//     this.phone,
//     this.point,
//     this.image,
//     this.isAdmin,
//     this.balance,
//     this.emailVerified,
//     this.password,
//     this.country,
//     this.state,
//     this.city,
//     this.area,
//     this.firstName,
//     this.pin,
//     this.defaultPinChanged,
//     this.lastName,
//     this.bio,
//     this.currency,
//     this.businessType,
//     this.businessName,
//     this.profilePhoto,
//     this.interests,
//     this.wallet,
//     this.isGoogleAuth,
//     this.isPremium,
//     this.subscriptionType,
//     this.subscriptionStartDate,
//     this.subscriptionEndDate,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//     this.refreshToken,
//     this.accessToken,
//   });
//
//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       success: json["success"],
//       id: json["_id"],
//       deviceToken: json["deviceToken"],
//       email: json["email"],
//       phone: json["phone"],
//       point: json["point"],
//       image: json["image"],
//       isAdmin: json["isAdmin"],
//       balance: json["balance"],
//       emailVerified: json["emailVerified"],
//       password: json["password"],
//       country: json["country"],
//       state: json["state"],
//       city: json["city"],
//       area: json["area"],
//       firstName: json["firstName"],
//       pin: json["pin"],
//       defaultPinChanged: json["defaultPinChanged"],
//       lastName: json["lastName"],
//       bio: json["bio"],
//       currency: json["currency"],
//       businessType: json["businessType"],
//       businessName: json["businessName"],
//       profilePhoto: json["profilePhoto"],
//       interests: json["interests"] == null
//           ? []
//           : List<dynamic>.from(json["interests"]!.map((x) => x)),
//       wallet: json["wallet"],
//       isGoogleAuth: json["isGoogleAuth"],
//       isPremium: json["isPremium"],
//       subscriptionType: json["subscriptionType"],
//       subscriptionStartDate: json["subscriptionStartDate"],
//       subscriptionEndDate: json["subscriptionEndDate"],
//       createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
//       updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
//       v: json["__v"],
//       refreshToken: json["refreshToken"],
//       accessToken: json["accessToken"],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "success": success,
//     "_id": id,
//     "deviceToken": deviceToken,
//     "email": email,
//     "phone": phone,
//     "point": point,
//     "image": image,
//     "isAdmin": isAdmin,
//     "balance": balance,
//     "emailVerified": emailVerified,
//     "password": password,
//     "country": country,
//     "state": state,
//     "city": city,
//     "area": area,
//     "firstName": firstName,
//     "pin": pin,
//     "defaultPinChanged": defaultPinChanged,
//     "lastName": lastName,
//     "bio": bio,
//     "currency": currency,
//     "businessType": businessType,
//     "businessName": businessName,
//     "profilePhoto": profilePhoto,
//     "interests": interests?.map((x) => x).toList(),
//     "wallet": wallet,
//     "isGoogleAuth": isGoogleAuth,
//     "isPremium": isPremium,
//     "subscriptionType": subscriptionType,
//     "subscriptionStartDate": subscriptionStartDate,
//     "subscriptionEndDate": subscriptionEndDate,
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//     "__v": v,
//     "refreshToken": refreshToken,
//     "accessToken": accessToken,
//   };
// }

class AuthResponse {
  bool? success;
  Customer? customer;
  String? message;

  AuthResponse({this.success, this.customer, this.message});

  AuthResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    customer = json['data'] != null ? Customer.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.customer != null) {
      data['data'] = this.customer!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Customer {
  bool? success;
  String? id;
  String? deviceToken;
  String? email;
  String? phone;
  int? point;
  String? image;
  bool? isAdmin;
  int? balance;
  bool? emailVerified;
  String? password;
  String? country;
  String? state;
  String? city;
  String? area;
  String? firstName;
  int? pin;
  bool? defaultPinChanged;
  String? lastName;
  String? bio;
  String? currency;
  String? businessType;
  String? businessName;
  String? profilePhoto;
  List<dynamic>? interests; // Or a more specific type if you have an Interest model
  int? wallet;
  bool? isGoogleAuth;
  bool? isPremium;
  String? subscriptionType;
  DateTime? subscriptionStartDate;
  DateTime? subscriptionEndDate;
  List<dynamic>? stores; // This is the empty stores array
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? refreshToken;
  String? accessToken;

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
    this.stores,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.refreshToken,
    this.accessToken,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    id = json['_id'];
    deviceToken = json['deviceToken'];
    email = json['email'];
    phone = json['phone'];
    point = json['point'];
    image = json['image'];
    isAdmin = json['isAdmin'];
    balance = json['balance'];
    emailVerified = json['emailVerified'];
    password = json['password'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    area = json['area'];
    firstName = json['firstName'];
    pin = json['pin'];
    defaultPinChanged = json['defaultPinChanged'];
    lastName = json['lastName'];
    bio = json['bio'];
    currency = json['currency'];
    businessType = json['businessType'];
    businessName = json['businessName'];
    profilePhoto = json['profilePhoto'];
    if (json['interests'] != null) {
      interests = <dynamic>[]; // Adjust if you have a specific Interest model
      json['interests'].forEach((v) {
        interests!.add(v); // Adjust based on your Interest model
      });
    }
    wallet = json['wallet'];
    isGoogleAuth = json['isGoogleAuth'];
    isPremium = json['isPremium'];
    subscriptionType = json['subscriptionType'];
    subscriptionStartDate = json['subscriptionStartDate'] != null
        ? DateTime.parse(json['subscriptionStartDate'])
        : null;
    subscriptionEndDate = json['subscriptionEndDate'] != null
        ? DateTime.parse(json['subscriptionEndDate'])
        : null;
    if (json['stores'] != null) {
      stores = <dynamic>[]; // This will likely be a list of store IDs (strings)
      json['stores'].forEach((v) {
        stores!.add(v);
      });
    }
    createdAt =
    json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt =
    json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    v = json['__v'];
    refreshToken = json['refreshToken'];
    accessToken = json['accessToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['_id'] = id;
    data['deviceToken'] = deviceToken;
    data['email'] = email;
    data['phone'] = phone;
    data['point'] = point;
    data['image'] = image;
    data['isAdmin'] = isAdmin;
    data['balance'] = balance;
    data['emailVerified'] = emailVerified;
    data['password'] = password;
    data['country'] = country;
    data['state'] = state;
    data['city'] = city;
    data['area'] = area;
    data['firstName'] = firstName;
    data['pin'] = pin;
    data['defaultPinChanged'] = defaultPinChanged;
    data['lastName'] = lastName;
    data['bio'] = bio;
    data['currency'] = currency;
    data['businessType'] = businessType;
    data['businessName'] = businessName;
    data['profilePhoto'] = profilePhoto;
    if (interests != null) {
      data['interests'] = interests!.map((v) => v).toList(); // Adjust based on your Interest model
    }
    data['wallet'] = wallet;
    data['isGoogleAuth'] = isGoogleAuth;
    data['isPremium'] = isPremium;
    data['subscriptionType'] = subscriptionType;
    data['subscriptionStartDate'] = subscriptionStartDate?.toIso8601String();
    data['subscriptionEndDate'] = subscriptionEndDate?.toIso8601String();
    if (stores != null) {
      data['stores'] = stores!.map((v) => v).toList();
    }
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    data['__v'] = v;
    data['refreshToken'] = refreshToken;
    data['accessToken'] = accessToken;
    return data;
  }
}