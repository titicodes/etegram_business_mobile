import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/app_url.dart';

import '../../constants/reuseable.dart';
import '../../core/model/payment_method_response.dart';
import '../../locator.dart';
import '../local/storage_service.dart';
import '../local/user_service.dart';
import 'base_api.dart';

class PaymentMethodApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();

  Future<String?> _getToken() async {
    final box = GetStorage();
    String? accessToken = box.read(DbTable.tokenTableName);
    print("SAVED TOKEN::: $accessToken");

    if (accessToken == null) {
      print("❌ getToken: Access token is null");
      return null;
    }
    return accessToken; // Return the token if found
  }

  Future<PaymentMethod?> createPaymentMethod(
      PaymentMethod paymentMethod) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    final payload = {
      "name": paymentMethod.name,
      "bank": paymentMethod.bank,
      "accountNumber": paymentMethod.accountNumber,
      "accountName": paymentMethod.accountName,
      "extraInfo": paymentMethod.extraInfo,
    };
    try {
      Response response = await connect().post(
        AppUrls.createPaymentMethod,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );


      PaymentMethod responseData = PaymentMethod.fromJson(response.data);
      return responseData;
    } on DioException catch (e) {
      print(e.response);
      if (e.response != null) {
        print(
            "❌ Payment Method: Dio error: ${e.response!.statusCode}, ${e.response!.data}");
      } else {
        print("❌ getUser: Dio error: ${e.message}");
      }
      return null;
    }
  }

  Future<List<PaymentMethod>?> getPaymentMethods() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      Response response = await connect().get(
        AppUrls.getPaymentMethod,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.data);
        if (responseData['success'] == true && responseData['data'] != null) {
          if (responseData['data'] is List) { // Check if data is a list.
            final List<dynamic> data = responseData['data'];
            List<PaymentMethod> paymentMethods =
            data.map((json) => PaymentMethod.fromJson(json)).toList();

            // Store all payment methods at once
            await storageService.storeItem(
              key: DbTable.paymentMethodTable,
              value: jsonEncode(
                  paymentMethods.map((method) => method.toJson()).toList()),
            );

            return paymentMethods;
          } else if (responseData['data'] is Map && responseData['data']['data'] is List) {
            final List<dynamic> data = responseData['data']['data'];
            List<PaymentMethod> paymentMethods =
            data.map((json) => PaymentMethod.fromJson(json)).toList();

            // Store all payment methods at once
            await storageService.storeItem(
              key: DbTable.paymentMethodTable,
              value: jsonEncode(
                  paymentMethods.map((method) => method.toJson()).toList()),
            );

            return paymentMethods;
          } else {
            // Handle the case where responseData['data'] is not a list.
            print("Warning: responseData['data'] is not a list.");
            return []; // Return an empty list, or handle as needed.
          }
        }
      }

      throw Exception('Failed to load payment methods: ${response.data}');
    } on DioException catch (e) {
      if (e.response != null) {
        print(
            "❌ Payment Method: Dio error: ${e.response!.statusCode}, ${e.response!.data}");
      } else {
        print("❌ getUser: Dio error: ${e.message}");
      }
      return null;
    }
  }
}
