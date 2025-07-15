import 'package:etegram_business/service/web/subscription_api_service.dart';

import '../locator.dart';
import '../service/local/cache.dart';
import '../service/local/storage_service.dart';
import '../service/local/user_service.dart';

class SubscriptionRepository {
  final AppCache appCache = locator<AppCache>();
  final SubscriptionApiService subscriptionApiService =
      locator<SubscriptionApiService>();
  final CustomerService customerService = locator<CustomerService>();
  final StorageService storageService = locator<StorageService>();

  Future<void> fetchSubscriptionStatus() async {
    return subscriptionApiService.fetchSubscriptionStatus();
  }

  Future<void> subscribeToPremium(String type) async {
    return subscriptionApiService.subscribeToPremium(type);
  }

  Future<void> cancelSubscription() async {
    return subscriptionApiService.cancelSubscription();
  }
}
