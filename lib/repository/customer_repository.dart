import 'package:etegram_business/service/web/customer_api_service.dart';
import '../core/model/customer_response.dart';
import '../core/model/store_model.dart';
import '../locator.dart';
import '../service/local/storage_service.dart';
import '../service/local/user_service.dart';

class CustomerRepository {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();
  CustomerApiService customerApiService = locator<CustomerApiService>();

  Future<Future<CustomerData?>> createCustomer({required CustomerData data}) async {
    return customerApiService.createCustomer(data: data);
  }

  Future<Future<CustomerData?>> updateCustomer(String customerId, CustomerData data) async {
    return customerApiService.updateCustomer(customerId, data);
  }

  Future<List<CustomerData>?> getAllCustomer(
      {String? storeId, String? keyword, int page = 1, int limit = 20}) async {
    return customerApiService.getAllCustomer(
        storeId: storeId, keyword: keyword, page: page, limit: limit);
  }

  Future<CustomerResponse?> getUpcomingBirthdays({String? storeId, int? month}) async {
    return customerApiService.getUpcomingBirthdays(storeId: storeId, month: month);
  }

  Future<CustomerData?> getACustomer(String customerId) async {
    return customerApiService.getACustomer(customerId);
  }

  Future<bool> deleteCustomer(String customerId) async {
    return customerApiService.deleteCustomer(customerId);
  }
}