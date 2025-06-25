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

  Future<DeliveryData?> createDeliveryAgent(DeliveryData delivery) {
    return deliveryApiService.createDeliveryAgent(delivery);
  }

  Future<DeliveryTransactionData?> createDeliveryTransaction(
      DeliveryTransactionData transaction) {
    return deliveryApiService.createDeliveryTransaction(transaction);
  }

  Future<List<DeliveryData>?> getAllDeliveryAgents({String? storeId}) {
    return deliveryApiService.getAllDeliveryAgents(storeId: storeId);
  }

  Future<List<DeliveryTransactionData>?> getAllDeliveryTransactions(
      {String? storeId}) {
    return deliveryApiService.getAllDeliveryTransactions(storeId: storeId);
  }

  Future<DeliveryData?> getDeliveryAgentById(String id) {
    return deliveryApiService.getDeliveryAgentById(id);
  }

  Future<DeliveryTransactionData?> getDeliveryTransactionById(String id) {
    return deliveryApiService.getDeliveryTransactionById(id);
  }

  Future<DeliveryData?> updateDeliveryAgent(DeliveryData delivery) {
    return deliveryApiService.updateDeliveryAgent(delivery);
  }

  Future<bool> deleteDeliveryAgent(String id) {
    return deliveryApiService.deleteDeliveryAgent(id);
  }
}
