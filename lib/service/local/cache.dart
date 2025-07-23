// import 'dart:io';
//
// import 'package:etegram_business/core/model/auth_response.dart';
// import 'package:etegram_business/core/model/customer_response.dart';
// import 'package:etegram_business/core/model/delivery_response.dart';
//
// class AppCache {
//   clearCheckoutData() {
//     totalAmount = 0.0;
//     quantityOfItems = 0;
//   }
//
//   bool? firstTimeKYC;
//
//   double totalAmount = 0.0;
//   String chatID = "";
//   // ALL.Category category = ALL.Category();
//   // GetChatDetailResponse chatDetailResponse = GetChatDetailResponse();
// //  ProviderUserResponse serviceProvider = ProviderUserResponse();
//   int quantityOfItems = 0;
//   int initialIndex = 0;
//   bool isEdit = false;
//   bool comingFromChangePin = false;
//
//   String? dateOfBirth;
//   File? userImage;
//
//   String? email;
//   String? userType;
//   String? firstName;
//   String? lastName;
//   String? referralCode;
//   String? password;
//   String? phoneNumber;
//   String? businessPhone;
//   String? username;
//   DateTime dob = DateTime.now();
//   String? state;
//   String? storeClassification;
//   String? area;
//   // GetOtpResponse forgetPasswordResponse = GetOtpResponse();
//   AuthResponse registerResponse = AuthResponse();
//   CustomerResponse customerResponse = CustomerResponse();
//
//   Customer userData = Customer();
//   CustomerData customerData = CustomerData();
//   DeliveryData deliveryData = DeliveryData();
// }

import 'dart:io';

import 'package:etegram_business/core/model/auth_response.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/core/model/delivery_response.dart';

class AppCache {
  static final AppCache _instance = AppCache._internal();
  factory AppCache() => _instance;
  AppCache._internal();

  clearCheckoutData() {
    totalAmount = 0.0;
    quantityOfItems = 0;
  }

  bool? firstTimeKYC;

  double totalAmount = 0.0;
  String chatID = "";
// ALL.Category category = ALL.Category();
// GetChatDetailResponse chatDetailResponse = GetChatDetailResponse();
// ProviderUserResponse serviceProvider = ProviderUserResponse();
  int quantityOfItems = 0;
  int initialIndex = 0;
  bool isEdit = false;
  bool comingFromChangePin = false;

  String? dateOfBirth;
  File? userImage;

  String? email;
  String? userType;
  String? firstName;
  String? lastName;
  String? referralCode;
  String? password;
  String? phoneNumber;
  String? businessPhone;
  String? username;
  DateTime dob = DateTime.now();
  String? state;
  String? storeClassification;
  String? area;
// GetOtpResponse forgetPasswordResponse = GetOtpResponse();
  AuthResponse registerResponse = AuthResponse();
  CustomerResponse customerResponse = CustomerResponse();

  Customer? userData;
  CustomerData customerData = CustomerData();
  DeliveryData deliveryData = DeliveryData();
}
