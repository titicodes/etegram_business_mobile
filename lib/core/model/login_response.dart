// class LoginResponse {
//   LoginResponse({
//      this.success,
//      this.data,
//      this.message,
//   });
//
//   final bool? success;
//   final Data? data;
//   final String? message;
//
//   factory LoginResponse.fromJson(Map<String, dynamic> json){
//     return LoginResponse(
//       success: json["success"],
//       data: json["data"] == null ? null : Data.fromJson(json["data"]),
//       message: json["message"],
//     );
//   }
//
// }
//
// class Data {
//   Data({
//      this.success,
//      this.id,
//      this.deviceToken,
//      this.email,
//      this.phone,
//      this.point,
//      this.image,
//      this.isAdmin,
//      this.emailVerified,
//      this.password,
//      this.country,
//      this.state,
//      this.area,
//      this.firstName,
//      this.pin,
//      this.defaultPinChanged,
//      this.lastName,
//      this.bio,
//      this.profilePhoto,
//      this.interests,
//      this.wallet,
//      this.isGoogleAuth,
//      this.isPremium,
//      this.subscriptionType,
//      this.subscriptionStartDate,
//      this.subscriptionEndDate,
//      this.createdAt,
//      this.updatedAt,
//      this.v,
//      this.refreshToken,
//      this.accessToken,
//   });
//
//   final bool? success;
//   final String? id;
//   final String? deviceToken;
//   final String? email;
//   final String? phone;
//   final int? point;
//   final dynamic image;
//   final bool? isAdmin;
//   final bool? emailVerified;
//   final String? password;
//   final String? country;
//   final String? state;
//   final String? area;
//   final String? firstName;
//   final int? pin;
//   final bool? defaultPinChanged;
//   final String? lastName;
//   final String? bio;
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
//   factory Data.fromJson(Map<String, dynamic> json){
//     return Data(
//       success: json["success"],
//       id: json["_id"],
//       deviceToken: json["deviceToken"],
//       email: json["email"],
//       phone: json["phone"],
//       point: json["point"],
//       image: json["image"],
//       isAdmin: json["isAdmin"],
//       emailVerified: json["emailVerified"],
//       password: json["password"],
//       country: json["country"],
//       state: json["state"],
//       area: json["area"],
//       firstName: json["firstName"],
//       pin: json["pin"],
//       defaultPinChanged: json["defaultPinChanged"],
//       lastName: json["lastName"],
//       bio: json["bio"],
//       profilePhoto: json["profilePhoto"],
//       interests: json["interests"] == null ? [] : List<dynamic>.from(json["interests"]!.map((x) => x)),
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
// }
