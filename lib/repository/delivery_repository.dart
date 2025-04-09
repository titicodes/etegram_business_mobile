import 'package:etegram_business/service/web/delivery_api_service.dart';

import '../core/model/delivery_response.dart';
import '../locator.dart';
import '../service/local/cache.dart';
import '../service/local/storage_service.dart';
import '../service/local/user_service.dart';

class DeliveryRepository {
  AppCache appCache = locator<AppCache>();
  DeliveryApiService deliveryApiService = locator<DeliveryApiService>();
  CustomerService customerService = locator<CustomerService>();
  StorageService storageService = locator<StorageService>();

  Future<DeliveryData?> createDelivery(DeliveryData expense) async {
    return deliveryApiService.createDelivery(expense);
  }

  Future<List<DeliveryData>?> getAllDelivery() async {
    return deliveryApiService.getAllDelivery();
  }

  Future<DeliveryData?> getDeliveryById(String id, String userId) async {
    return deliveryApiService.getDeliveryById(id, userId);
  }

  Future<DeliveryData?> updateDelivery(DeliveryData expense) async {
    return deliveryApiService.updateDelivery(expense);
  }

  Future<bool> deleteDelivery(String id, String userId) async {
    return deliveryApiService.deleteDelivery(id, userId);
  }
}
