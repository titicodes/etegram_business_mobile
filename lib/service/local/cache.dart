import 'dart:io';

import 'package:etegram_business/core/model/auth_response.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/core/model/delivery_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/reuseable.dart';

class AppCache {
  static final AppCache _instance = AppCache._internal();
  factory AppCache() => _instance;
  AppCache._internal();

  final box = GetStorage();
  final secureStorage = FlutterSecureStorage();
  static const String _emailKey = 'remembered_email';
  static const String _passwordKey = 'remembered_password';
  static const String _rememberMeKey = 'remember_me';

  AuthResponse? _registerResponse;
  AuthResponse? get registerResponse => _registerResponse;
  set registerResponse(AuthResponse? value) {
    _registerResponse = value;
    box.write(DbTable.customerTableName, value?.toJson());
  }

  Future<void> saveCredentials(
      String email, String password, bool rememberMe) async {
    if (rememberMe) {
      box.write(_emailKey, email);
      await secureStorage.write(key: _passwordKey, value: password);
      box.write(_rememberMeKey, true);
    } else {
      box.remove(_emailKey);
      await secureStorage.delete(key: _passwordKey);
      box.write(_rememberMeKey, false);
    }
  }

  Future<String?> getRememberedEmail() async => box.read(_emailKey);
  Future<String?> getRememberedPassword() async =>
      await secureStorage.read(key: _passwordKey);
  bool get isRememberMeEnabled => box.read(_rememberMeKey) ?? false;

  Future<void> clearCredentials() async {
    box.remove(_emailKey);
    await secureStorage.delete(key: _passwordKey);
    box.write(_rememberMeKey, false);
  }

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
  //AuthResponse registerResponse = AuthResponse();
  CustomerResponse customerResponse = CustomerResponse();

  Customer? userData;
  CustomerData customerData = CustomerData();
  DeliveryData deliveryData = DeliveryData();
}
