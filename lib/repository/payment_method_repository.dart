import 'dart:convert';

import 'package:etegram_business/service/web/payment_method_api_service.dart';

import '../constants/reuseable.dart';
import '../core/model/payment_method_response.dart';
import '../locator.dart';
import '../service/local/cache.dart';
import '../service/local/storage_service.dart';

class PaymentMethodRepository {
  StorageService storageService = locator<StorageService>();
  AppCache appCache = locator<AppCache>();
  PaymentMethodApiService paymentMethodApiService =
      locator<PaymentMethodApiService>();

  Future<List<PaymentMethod>?> getPaymentMethods() async {
    var response = await paymentMethodApiService.getPaymentMethods();
    if (response != null) {
      await storePaymentMethods(response);
    }
    return response;
  }

  storePaymentMethods(List<PaymentMethod> response) async {
    print("Storing Payment methods: ${response.length}");
    if (response.isNotEmpty) {
      // Convert each PaymentMethod to JSON and store the list
      await storageService.storeItem(
        key: DbTable.paymentMethodTable,
        value: jsonEncode(response
            .map((method) => method.toJson())
            .toList()), // Correctly convert each method to JSON
      );
    }
  }

  Future<PaymentMethod?> createPaymentMethod(
      PaymentMethod paymentMethod) async {
    return paymentMethodApiService.createPaymentMethod(paymentMethod);
  }
}
