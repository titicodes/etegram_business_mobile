import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/app_url.dart';
import '../../constants/reuseable.dart';
import '../../core/model/auth_response.dart';
import '../../core/model/subscription_model.dart';
import '../../locator.dart';
import '../../utils/snack_message.dart';
import '../local/storage_service.dart';
import '../local/user_service.dart';
import 'base_api.dart';

class SubscriptionApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();
  final box = GetStorage();
  Customer? customer;
  SubscriptionModel? subscription;

  Future<void> fetchSubscriptionStatus() async {
    try {
      String? accessToken = box.read(DbTable.tokenTableName);
      if (accessToken == null) {
        subscription = null;
        return;
      }
      final response = await connect().get(
        '${AppUrls.baseUrl}subscriptions',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        subscription = SubscriptionModel.fromJson(response.data);
      }
    } catch (e) {
      print('CustomerService: Error fetching subscription: $e');
      subscription = null;
    }
  }

  Future<void> subscribeToPremium(String type) async {
    try {
      String? accessToken = box.read(DbTable.tokenTableName);
      if (accessToken == null) {
        showCustomToast('Please log in to subscribe', success: false);
        return;
      }
      final response = await connect().patch(
        '${AppUrls.baseUrl}subscriptions/premium/$type',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        subscription = SubscriptionModel.fromJson(response.data);
        showCustomToast('Subscribed to $type plan', success: true);
      }
    } catch (e) {
      showCustomToast('Failed to subscribe to premium', success: false);
    }
  }

  Future<void> cancelSubscription() async {
    try {
      String? accessToken = box.read(DbTable.tokenTableName);
      if (accessToken == null) {
        showCustomToast('Please log in to cancel subscription', success: false);
        return;
      }
      final response = await connect().delete(
        '${AppUrls.baseUrl}subscriptions',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        subscription = SubscriptionModel.fromJson(response.data);
        showCustomToast('Subscription cancelled', success: true);
      }
    } catch (e) {
      showCustomToast('Failed to cancel subscription', success: false);
    }
  }

}
