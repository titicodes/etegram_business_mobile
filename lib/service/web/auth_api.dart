// auth_api.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../../constants/app_url.dart';
import '../../constants/reuseable.dart';
import '../../core/model/auth_response.dart';
import '../../locator.dart';
import '../../service/local/storage_service.dart';
import '../../service/local/user_service.dart';
import 'base_api.dart';

class AuthenticationApiService {
  final StorageService storageService = locator<StorageService>();
  final CustomerService customerService = locator<CustomerService>();

  Future<AuthResponse?> register({required Customer customer}) async {
    try {
      Response response = await connect().post(AppUrls.registerUrl, data: {
        "email": customer.email,
        "password": customer.password,
        "firstName": customer.firstName,
        "lastName": customer.lastName,
        "phoneNumber": customer.phoneNumber,
        "country": customer.country,
        "state": customer.state,
        "city": customer.city,
        "area": customer.area,
        "currency": customer.currency,
        "businessType": customer.businessType,
        "businessName": customer.businessName,
      });
      // Assuming AuthResponse.fromJson expects the *entire* response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      print("Register Dio Error: ${e.response?.data}");

      rethrow; // Rethrow the exception to be caught by the calling ViewModel
    }
  }

  Future<AuthResponse?> emailVerifier(
      {required String email, required int code}) async {
    try {
      Response response = await connect().post(
        AppUrls.verifyEmailUrl,
        data: {"email": email, "code": code},
      );
      final data =
      response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      print("Verify Email Dio Error: ${e.response?.data}");
      rethrow; // Rethrow the exception
    }
  }

  Future<AuthResponse?> login(
      {required Customer customer}) async {
    try {
      Response response = await connect().post(
        AppUrls.loginUrl,
        data: {"email": customer.email, "password": customer.password},
      );
      final data =
      response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      print("Login Dio Error: ${e.response?.data}");
      rethrow; // Rethrow the exception
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    try {
      Response response = await connect().post(
        AppUrls.forgotPasswordUrl,
        data: {"email": email},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Forgot Password Dio Error: ${e.response?.data}");
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required int code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      Response response = await connect().post(
        AppUrls.resetPasswordUrl,
        data: {
          "email": email,
          "code": code,
          "password": newPassword,
          "confirmPassword": confirmPassword,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Reset Password Dio Error: ${e.response?.data}");
      return false;
    }
  }

  Future<Customer?> getUser() async {
    final box = GetStorage();
    String? accessToken = box.read(DbTable.tokenTableName);
    if (accessToken == null) {
      print("getUser: No access token");
      return null;
    }
    try {
      Response response = await connect().get(
        AppUrls.getUserUrl,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      // Parse the full AuthResponse first
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      AuthResponse authResponse = AuthResponse.fromJson(data);

      if (authResponse.success == true && authResponse.data?.user != null) {
        return authResponse.data?.user; // Now 'user' will be the correctly parsed Customer
      }
      return null;
    } on DioException catch (e) {
      print("getUser Dio Error: ${e.response?.data}");
      if (e.response?.statusCode == 403) {
        await customerService.logout();
      }
      return null;
    }
  }

  Future<bool> logout(String token) async {
    try {
      Response response = await connect().post(
        AppUrls.logoutUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Logout Dio Error: ${e.response?.data}");
      return false;
    }
  }

  Future<bool> changePin({
    required String userId,
    required String newPin,
    required String oldPin,
  }) async {
    try {
      Response response = await connect().put(
        "user/change-pin/$userId",
        data: {"newPin": newPin, "oldPin": oldPin},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Change PIN Dio Error: ${e.response?.data}");
      return false;
    }
  }

  Future<bool> updatePin({
    required String userId,
    required String pin,
    required String confirmPin,
  }) async {
    try {
      Response response = await connect().put(
        "user/change-pin/$userId",
        data: {"pin": pin, "confirmPin": confirmPin},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Update PIN Dio Error: ${e.response?.data}");
      return false;
    }
  }
}
