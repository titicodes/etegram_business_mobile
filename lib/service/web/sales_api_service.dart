import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:etegram_business/core/model/checkout_response.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/storage_service.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/service/web/base_api.dart';
import 'package:get_storage/get_storage.dart';
import '../../constants/app_url.dart';
import '../../constants/reuseable.dart';

class SalesApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();
  final Dio dio = connect(); // Use connect() directly

  Future<String> _getToken() async {
    final box = GetStorage();
    String? accessToken = box.read(DbTable.tokenTableName);

    if (accessToken == null) {
      throw Exception('No token found');
    }
    return accessToken;
  }

  Future<GetScanResponse?> getScanProduct({required int? code}) async {
    final token = await _getToken();
    try {
      Response response = await connect().get(
        "checkout/scan/$code",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // DEBUG PRINT
      print('Raw Response Data: ${response.data}');

      if (response.data is String) {
        // Parse the string as JSON
        final parsed = jsonDecode(response.data);
        return GetScanResponse.fromJson(parsed);
      } else if (response.data is Map<String, dynamic>) {
        return GetScanResponse.fromJson(response.data);
      } else {
        throw Exception('Unexpected response type: ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to scan product: ${e.message}');
    }
  }


  Future<CheckoutResponse?> checkout({
    required List<Map<String, dynamic>> cartItems,
    double discount = 0.0,
    double tax = 0.0,
    required String paymentMethod,
  }) async {
    final token = await _getToken();
    var payload = {
      'cart': cartItems,
      'paymentMethod': paymentMethod,
    };

    if (discount != 0.0) {
      payload['discount'] = discount;
    }
    if (tax != 0.0) {
      payload['tax'] = tax;
    }

    try {
      Response response = await connect().post(
        AppUrls.createCheckout,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload,
      );

      dynamic responseData = response.data;

      // 🔍 Decode manually if response.data is a String
      if (responseData is String) {
        print("Received string response: $responseData");
        responseData = jsonDecode(responseData);
      }

      // ✅ Now safely parse
      return CheckoutResponse.fromJson(responseData);
    } on DioException catch (e) {
      if (e.response != null) {
        print('Dio Error: ${e.response!.statusCode}, ${e.response!.data}');
        throw Exception('Checkout failed: ${e.response!.data}');
      } else {
        print('Dio Error (Network): ${e.message}');
        throw Exception('Checkout failed: Network error - ${e.message}');
      }
    }
  }

  Future<void> sendFcmToken(String userId, String fcmToken) async {
    final token = await _getToken();
    try {
      await dio.post(
        'users/$userId/fcm-token', // Use correct URL (or AppUrls constant)
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'fcmToken': fcmToken},
      );
    } on DioException catch (e) {
      throw Exception('Failed to send FCM token: ${e.message}');
    }
  }
}
