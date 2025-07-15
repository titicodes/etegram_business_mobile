// // auth_api.dart
// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get_storage/get_storage.dart';
// import '../../constants/app_url.dart';
// import '../../constants/reuseable.dart';
// import '../../core/model/auth_response.dart';
// import '../../locator.dart';
// import '../../service/local/storage_service.dart';
// import '../../service/local/user_service.dart';
// import 'base_api.dart';
//
// class AuthenticationApiService {
//   final StorageService storageService = locator<StorageService>();
//   final CustomerService customerService = locator<CustomerService>();
//
//   Future<AuthResponse?> register({required Customer customer}) async {
//     try {
//       Response response = await connect().post(AppUrls.registerUrl, data: {
//         "email": customer.email,
//         "password": customer.password,
//         "firstName": customer.firstName,
//         "lastName": customer.lastName,
//         "phoneNumber": customer.phoneNumber,
//         "country": customer.country,
//         "state": customer.state,
//         "city": customer.city,
//         "area": customer.area,
//         "currency": customer.currency,
//         "businessType": customer.businessType,
//         "businessName": customer.businessName,
//       });
//       // Assuming AuthResponse.fromJson expects the *entire* response.data
//       final data =
//           response.data is String ? jsonDecode(response.data) : response.data;
//       return AuthResponse.fromJson(data);
//     } on DioException catch (e) {
//       print("Register Dio Error: ${e.response?.data}");
//
//       rethrow; // Rethrow the exception to be caught by the calling ViewModel
//     }
//   }
//
//   Future<AuthResponse?> emailVerifier(
//       {required String email, required int code}) async {
//     try {
//       Response response = await connect().post(
//         AppUrls.verifyEmailUrl,
//         data: {"email": email, "code": code},
//       );
//       final data =
//       response.data is String ? jsonDecode(response.data) : response.data;
//       return AuthResponse.fromJson(data);
//     } on DioException catch (e) {
//       print("Verify Email Dio Error: ${e.response?.data}");
//       rethrow; // Rethrow the exception
//     }
//   }
//
//   Future<AuthResponse?> login(
//       {required Customer customer}) async {
//     try {
//       Response response = await connect().post(
//         AppUrls.loginUrl,
//         data: {"email": customer.email, "password": customer.password},
//       );
//       final data =
//       response.data is String ? jsonDecode(response.data) : response.data;
//       return AuthResponse.fromJson(data);
//     } on DioException catch (e) {
//       print("Login Dio Error: ${e.response?.data}");
//       rethrow; // Rethrow the exception
//     }
//   }
//
//   Future<bool> forgotPassword({required String email}) async {
//     try {
//       Response response = await connect().post(
//         AppUrls.forgotPasswordUrl,
//         data: {"email": email},
//       );
//       return response.statusCode == 200;
//     } on DioException catch (e) {
//       print("Forgot Password Dio Error: ${e.response?.data}");
//       return false;
//     }
//   }
//
//   Future<bool> resetPassword({
//     required String email,
//     required int code,
//     required String newPassword,
//     required String confirmPassword,
//   }) async {
//     try {
//       Response response = await connect().post(
//         AppUrls.resetPasswordUrl,
//         data: {
//           "email": email,
//           "code": code,
//           "password": newPassword,
//           "confirmPassword": confirmPassword,
//         },
//       );
//       return response.statusCode == 200;
//     } on DioException catch (e) {
//       print("Reset Password Dio Error: ${e.response?.data}");
//       return false;
//     }
//   }
//
//   Future<Customer?> getUser() async {
//     final box = GetStorage();
//     String? accessToken = box.read(DbTable.tokenTableName);
//     if (accessToken == null) {
//       print("getUser: No access token");
//       return null;
//     }
//     try {
//       Response response = await connect().get(
//         AppUrls.getUserUrl,
//         options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
//       );
//
//       // Parse the full AuthResponse first
//       final data = response.data is String ? jsonDecode(response.data) : response.data;
//       AuthResponse authResponse = AuthResponse.fromJson(data);
//
//       if (authResponse.success == true && authResponse.data?.user != null) {
//         return authResponse.data?.user; // Now 'user' will be the correctly parsed Customer
//       }
//       return null;
//     } on DioException catch (e) {
//       print("getUser Dio Error: ${e.response?.data}");
//       if (e.response?.statusCode == 403) {
//         await customerService.logout();
//       }
//       return null;
//     }
//   }
//
//   Future<bool> logout(String token) async {
//     try {
//       Response response = await connect().post(
//         AppUrls.logoutUrl,
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//       return response.statusCode == 200;
//     } on DioException catch (e) {
//       print("Logout Dio Error: ${e.response?.data}");
//       return false;
//     }
//   }
//
//   Future<bool> changePin({
//     required String userId,
//     required String newPin,
//     required String oldPin,
//   }) async {
//     try {
//       Response response = await connect().put(
//         "user/change-pin/$userId",
//         data: {"newPin": newPin, "oldPin": oldPin},
//       );
//       return response.statusCode == 200;
//     } on DioException catch (e) {
//       print("Change PIN Dio Error: ${e.response?.data}");
//       return false;
//     }
//   }
//
//   Future<bool> updatePin({
//     required String userId,
//     required String pin,
//     required String confirmPin,
//   }) async {
//     try {
//       Response response = await connect().put(
//         "user/change-pin/$userId",
//         data: {"pin": pin, "confirmPin": confirmPin},
//       );
//       return response.statusCode == 200;
//     } on DioException catch (e) {
//       print("Update PIN Dio Error: ${e.response?.data}");
//       return false;
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mime/mime.dart';
import '../../constants/app_url.dart';
import '../../constants/reuseable.dart';
import '../../core/model/auth_response.dart';
import '../../locator.dart';
import '../../service/local/storage_service.dart';
import '../../utils/snack_message.dart';
import '../local/user_service.dart';
import 'base_api.dart';

class AuthenticationApiService {
  final StorageService storageService = locator<StorageService>();
  final CustomerService customerService = locator<CustomerService>();

  Future<String?> _getToken() async {
    final box = GetStorage();
    String? token = box.read(DbTable.tokenTableName);
    if (token == null) {
      showCustomToast('No authentication token found.');
      return null;
    }
    return token;
  }

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
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      print("Register Dio Error: ${e.response?.data}");
      rethrow;
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
      rethrow;
    }
  }

  Future<AuthResponse?> resendOTP({required String email}) async {
    try {
      Response response = await connect().post(
        AppUrls.resendOtpUrl,
        data: {"email": email},
      );
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      print("Resend OTP Dio Error: ${e.response?.data}");
      rethrow;
    }
  }

  Future<AuthResponse?> login({required Customer customer}) async {
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
      rethrow;
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

  Future<AuthResponse?> getUser() async {
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
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
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
        "${AppUrls.baseUrl}/user/change-pin/$userId",
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

  Future<Customer?> uploadProfileImage(String userId, String filePath, {String? fileName}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        showCustomToast('Authentication token missing. Please log in again.', success: false);
        return null;
      }

      final file = File(filePath);
      if (!await file.exists() || await file.length() == 0) {
        showCustomToast('Invalid or empty file.', success: false);
        return null;
      }

      final fileExtension = fileName?.split('.').last.toLowerCase() ?? filePath.split('.').last.toLowerCase();
      final supportedFormats = ['jpeg', 'jpg', 'png', 'gif', 'webp', 'bmp'];
      if (!supportedFormats.contains(fileExtension)) {
        showCustomToast('Unsupported file format. Please use JPEG, PNG, GIF, WebP, or BMP.', success: false);
        return null;
      }

      String? contentType;
      switch (fileExtension) {
        case 'jpeg':
        case 'jpg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        case 'bmp':
          contentType = 'image/bmp';
          break;
      }

      final mimeType = contentType ?? lookupMimeType(filePath);
      if (mimeType == null) {
        showCustomToast('Unable to determine file type.', success: false);
        return null;
      }

      final effectiveFileName = fileName ?? 'profile_image_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: effectiveFileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final url = 'user/$userId/profile-image';
      print('Request URL: $url');
      print('Request Data: FormData, File: $effectiveFileName, Content-Type: $mimeType, File Size: ${await file.length() / 1024} KB');

      final response = await connect().post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;
        responseData['profileImageUrl'] = responseData['imageUrl'];
        return Customer.fromJson(responseData);
      }
      showCustomToast('Unexpected response status: ${response.statusCode}', success: false);
      return null;
    } on DioException catch (e) {
      print('DioError uploading profile image: ${e.response?.data}');
      print('Error Status: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');
      final errorMessage = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Failed to upload profile image: ${e.response?.statusCode}'
          : 'Server error: ${e.response?.statusCode}';
      showCustomToast(errorMessage, success: false);
      return null;
    } catch (e) {
      print('Error uploading profile image: $e');
      showCustomToast('Error uploading profile image: $e', success: false);
      return null;
    }
  }
}
