import 'dart:convert';

import 'package:etegram_business/core/model/auth_response.dart';
import 'package:etegram_business/core/model/login_response.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/reuseable.dart';
import '../locator.dart';
import '../service/local/cache.dart';
import '../service/local/storage_service.dart';
import '../service/web/auth_api.dart';

class AuthRepository {
  AppCache appCache = locator<AppCache>();
  AuthenticationApiService auth = locator<AuthenticationApiService>();
  CustomerService customerService = locator<CustomerService>();
  StorageService storageService = locator<StorageService>();

  Future<AuthResponse?> register({required Customer data}) async {
    return await auth.register(data: data);
  }

  Future<AuthResponse?> verifyEmail(
      {required String email, required int code}) async {
    print("Email to verify: $email");
    print("Code to verify: $code");

    return await auth.emailVerify(email: email, code: code);
  }

  Future<AuthResponse?> login({required Customer data}) async {
    var response = await auth.login(data: data);
    if (response?.customer?.emailVerified == true) {
      await userService.storeToken(response);
    }
    return response;
  }

  Future<bool> forgetPassword({required String email}) async {
    return auth.forgotPassword(email: email);
  }

  Future<bool> resetPassword(
      {required String email,
      required String newPassword,
      required int code,
      required String confirmPassword}) async {
    return auth.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        confirmPassword: confirmPassword);
  }

  Future<Customer?> getUser() async {
    var response = await auth.getUser();
    if (response?.id != null) {
      userService.storeUser(response);
    }
    return response;
  }

  Future<Customer?> getLocalServiceDetail() async {
    try {
      String? storedData =
          await storageService.readItem(key: DbTable.customerTableName);

      print("📦 STORED USER DATA: $storedData");

      if (storedData == null || storedData.isEmpty) return null;

      var jsonData = jsonDecode(storedData);
      return Customer.fromJson(jsonData);
    } catch (e) {
      print("❌ Error parsing stored user data: $e");
      return null;
    }
  }

  Future<bool> changePin(
      {required String userId,
      required String newPin,
      required String oldPin}) async {
    return auth.changePin(userId: userId, newPin: newPin, oldPin: oldPin);
  }
}
