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

  Future<String> _getToken() async {
    final box = GetStorage();
    String? accessToken = box.read(DbTable.tokenTableName);

    if (accessToken == null) {
      throw Exception('No token found');
    }
    return accessToken;
  }

  Future<GetScanResponse?> getScanProduct({
    required String code,
    required String ownerId,
    required String storeId,
  }) async {
    if (code.isEmpty) {
      print('Barcode cannot be empty');
      return GetScanResponse(
        success: false,
        message: 'Barcode cannot be empty',
        data: null,
      );
    }

    final token = await _getToken();

    try {
      print('Checking product with barcode: $code, Owner ID: $ownerId, Store ID: $storeId');

      final endpoint = "checkout/check-product/$code";
      print('Request URL: ${AppUrls.baseUrl}$endpoint');
      print('Query Parameters: storeId=$storeId, ownerId=$ownerId');

      Response response = await connect().get(
        endpoint,
        queryParameters: {
          'storeId': storeId,
          'ownerId': ownerId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true,
        ),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }
        if (responseData is Map<String, dynamic>) {
          return GetScanResponse.fromJson(responseData);
        }
        return GetScanResponse(
          success: false,
          message: 'Unexpected response format',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return GetScanResponse(
          success: false,
          message: 'Product with barcode $code not found in store',
          data: null,
        );
      } else {
        return GetScanResponse(
          success: false,
          message: 'Error ${response.statusCode}: ${response.statusMessage}',
          data: null,
        );
      }
    } on DioException catch (e) {
      print('DioException in getScanProduct: ${e.message}');
      print('Error Status: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');

      return GetScanResponse(
        success: false,
        message: 'Failed to scan product: ${e.message ?? "Unknown error"}',
        data: null,
      );
    } catch (e) {
      print('Unexpected error in getScanProduct: $e');

      return GetScanResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  Future<CheckoutResponse?> checkout({
    required List<Map<String, dynamic>> cartItems,
    double discount = 0.0,
    double tax = 0.0,
    required String paymentMethod,
    required String storeId,
  }) async {
    final token = await _getToken();
    var payload = {
      'cart': cartItems,
      'paymentMethod': paymentMethod,
      'storeId': storeId,
    };

    if (discount != 0.0) {
      payload['discount'] = discount;
    }
    if (tax != 0.0) {
      payload['tax'] = tax;
    }

    try {
      print('Checkout Request URL: ${AppUrls.baseUrl}${AppUrls.createCheckout}');
      print('Checkout Payload: $payload');

      Response response = await connect().post(
        AppUrls.createCheckout,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true,
        ),
        data: payload,
      );

      print('Checkout Response Status: ${response.statusCode}');
      print('Checkout Response Data: ${response.data}');

      dynamic responseData = response.data;
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CheckoutResponse.fromJson(responseData);
      } else {
        return CheckoutResponse(
          success: false,
          message: responseData['message'] ?? 'Checkout failed with status code ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      print('DioException in checkout: ${e.message}');
      print('Error Status: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');

      return CheckoutResponse(
        success: false,
        message: 'Checkout failed: ${e.response?.data?['message'] ?? e.message}',
        data: null,
      );
    } catch (e) {
      print('Unexpected error in checkout: $e');

      return CheckoutResponse(
        success: false,
        message: 'Unexpected error during checkout: $e',
        data: null,
      );
    }
  }

  Future<void> sendFcmToken(String userId, String fcmToken) async {
    final token = await _getToken();
    try {
      await connect().post(
        'users/$userId/fcm-token',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'fcmToken': fcmToken},
      );
    } on DioException catch (e) {
      throw Exception('Failed to send FCM token: ${e.message}');
    }
  }
}