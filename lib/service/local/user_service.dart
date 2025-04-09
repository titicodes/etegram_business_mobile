import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/core/model/auth_response.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/core/model/payment_method_response.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/module/auth/views/widgets/payment_method_view.dart';
import 'package:etegram_business/module/sales/view/widgets/payment_screen.dart';
import 'package:etegram_business/service/local/cache.dart';
import 'package:etegram_business/service/local/storage_service.dart';
import 'package:etegram_business/service/web/base_api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/reuseable.dart';
import '../../core/model/login_response.dart';
import '../../locator.dart';
import '../../routes/routes.dart';
import '../../utils/snack_message.dart';

class CustomerService {
  Customer customer = Customer();
  CustomerData customerResponse = CustomerData();
  StorageService storageService = locator<StorageService>();
  AppCache cache = locator<AppCache>();
  bool isUserLoggedIn = false;
  bool isUserServiceProvider = false;
  AuthResponse loginResponse = AuthResponse();
  Product product = Product();
  PaymentMethod paymentMethod = PaymentMethod();

  storeToken(AuthResponse? response) async {
    final box = GetStorage();
    box.write(DbTable.tokenTableName, response?.data?.accessToken);
    await storageService.storeItem(
        key: DbTable.tokenTableName, value: jsonEncode(response));
    loginResponse = response ?? AuthResponse();
    String? userToken = box.read(DbTable.tokenTableName);
    print("SAVED TOKEN::: $userToken");
    locator<CustomerService>().initializer();
  }

  storeCustomer(CustomerData? response) async {
    if (response == null) return;
    print("✅ Storing user: ${jsonEncode(response.toJson())}");
    await storageService.storeItem(
        key: DbTable.customerTableName,
        value: jsonEncode(response.toJson()) // ✅ Convert object to JSON map
        );

    customerResponse = response;
  }

  Future<void> storeUser(Customer? response) async {
    if (response == null) return;
    print("✅ Storing user: ${jsonEncode(response.toJson())}");
    await storageService.storeItem(
        key: DbTable.customerTableName, // ✅ Use a different key
        value: jsonEncode(response.toJson()));
    customer = response;
  }

  storePaymentMethod(PaymentMethod? response) async {
    if (response == null) return;

    // Read existing payment methods
    List<PaymentMethod> existingMethods = await getStoredPaymentMethods() ?? [];

    // Add the new payment method
    existingMethods.add(response);

    // Store the updated list
    await storageService.storeItem(
      key: DbTable.paymentMethodTable,
      value:
          jsonEncode(existingMethods.map((method) => method.toJson()).toList()),
    );

    print("✅ Storing payment method: ${jsonEncode(response.toJson())}");

    // Navigate to dashboard after saving
    navigationService.navigateToAndRemoveUntil(dashboardRoute);
  }

  Future<void> logout() async {
    final box = GetStorage();
    String? token = loginResponse.data?.accessToken;
    if (token != null) {
      bool logoutSuccess = await auth.logout(token);

      if (!logoutSuccess) {
        showCustomToast(
          "Logout failed. Please try again.",
        );
        return;
      }
    }

    await box.erase();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing shared preferences: $e');
    }

    await storageService.deleteItem(key: DbTable.customerTableName);
    await storageService.deleteItem(key: DbTable.tokenTableName);
    await storageService.deleteItem(key: DbTable.loginTableName);
    isUserLoggedIn = false;
    customer = Customer();
    navigationService.navigateToAndRemoveUntil(loginScreenRoute);
    showCustomToast("Session Has Ended, Log In to proceed");
  }

  initializer() async {
    final box = GetStorage();
    String? userToken = box.read(DbTable.tokenTableName);
    String? userData =
        await storageService.readItem(key: DbTable.loginTableName);

    if (userToken == null) {
      customer = Customer();
      isUserLoggedIn = false;
    }

    if (userData != null) {
      loginResponse = AuthResponse.fromJson(jsonDecode(userData));
    }
    isUserLoggedIn = true;
    await getStoreUser();

    final isFirstLogin = await _isFirstLogin();
    final hasMethods = await hasPaymentMethods();

    if (isFirstLogin && !hasMethods) {
      // navigationService.navigateToAndRemoveUntil(addPaymentMethodRoute);
      navigationService.navigateToWidget(AddPaymentMethodView());
      await _setFirstLogin(false);
    } else {
      navigationService.navigateToAndRemoveUntil(dashboardRoute);
    }

    print("ACCESS TOKEN:::: $userToken");
    print("Is User Logged In:::: $isUserLoggedIn");
    print("Is User Service Provider = $isUserServiceProvider");
  }

  Future<Customer?> getStoreUser() async {
    String? data =
        await storageService.readItem(key: DbTable.customerTableName);
    if (data == null) {
      try {
        var response =
            await auth.getUser(); // Ensure token is included in the request
        if (response == null) {
          customer = Customer();
          await logout();
          return null;
        } else {
          customer = response;
          return customer;
        }
      } on DioException catch (e) {
        print(
            '❌ get:User  Dio error: ${e.response?.statusCode}, ${e.response?.data}');
        print('Dio Error: ${e.error}');
        customer = Customer();
        await logout();
        return null;
      } catch (e) {
        print('❌ get:User  General error: $e');
        customer = Customer();
        await logout();
        return null;
      }
    } else {
      try {
        Customer userResponse = Customer.fromJson(jsonDecode(data));
        customer = userResponse;
        return userResponse;
      } catch (e) {
        print("❌ Error parsing stored user data: $e");
        return null;
      }
    }
  }

  Future<List<PaymentMethod>?> getStoredPaymentMethods() async {
    try {
      final storedJson = GetStorage().read(DbTable.paymentMethodTable);

      if (storedJson == null) return null;

      final decoded = jsonDecode(storedJson);

      if (decoded is List) {
        return decoded
            .map<PaymentMethod>((e) => PaymentMethod.fromJson(e))
            .toList();
      } else {
        print(
            '❌ getStoredPaymentMethods: Expected a list but got ${decoded.runtimeType}');
        return null;
      }
    } catch (e) {
      print('❌ getStoredPaymentMethods: Error decoding stored data: $e');
      return null;
    }
  }

  Future<bool> hasPaymentMethods() async {
    List<PaymentMethod>? methods = await getStoredPaymentMethods();
    return methods != null && methods.isNotEmpty;
  }

  Future<void> _setFirstLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLogin', value);
  }

  Future<bool> _isFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstLogin') ?? true; // Default to true if not set
  }

  Future<void> setFirstLogin(bool value) async {
    await _setFirstLogin(value);
  }

  Future<bool> isFirstLogin() async {
    return await _isFirstLogin();
  }
}
