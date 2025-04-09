import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/service/web/customer_api_service.dart';

import '../core/model/customer_response.dart';
import '../locator.dart';
import '../service/local/cache.dart';
import '../service/local/storage_service.dart';
import '../service/local/user_service.dart';

class CustomerRepository {
  AppCache appCache = locator<AppCache>();
  CustomerApiService customerApiService = locator<CustomerApiService>();
  CustomerService customerService = locator<CustomerService>();
  StorageService storageService = locator<StorageService>();

  Future<CustomerResponse?> createCustomer({required CustomerData data}) async {
    return customerApiService.createCustomer(data: data);
  }

  Future<List<CustomerData>?> getAllCustomer() async {
    return customerApiService.getAllCustomer();
  }

  Future<CustomerData?> getACustomer(String customerId) async {
    var response =
        await customerApiService.getACustomer(customerId); // Await here
    if (response != null) {
      await storeCustomer(response);
    }
    return response;
  }

  storeCustomer(CustomerData? response) async {
    print("Customer Details: $response");
    await userService.storeCustomer(response);
  }
}
