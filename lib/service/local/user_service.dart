// customer_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:etegram_business/service/local/storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_url.dart';
import '../../constants/reuseable.dart';
import '../../core/model/auth_response.dart';
import '../../core/model/customer_response.dart';
import '../../core/model/payment_method_response.dart';
import '../../core/model/store_model.dart';
import '../../locator.dart';
import '../../routes/routes.dart';
import '../../utils/snack_message.dart';
import '../web/base_api.dart';
import '../web/store_api_service.dart';
import 'cache.dart';

class CustomerService {
  CustomerData customerResponse = CustomerData();
  final StorageService storageService = locator<StorageService>();
  final AppCache cache = locator<AppCache>();
  final StoreApiService storeApiService = locator<StoreApiService>();
  bool isUserLoggedIn = false;
  bool isUserServiceProvider = false;
  AuthResponse loginResponse = AuthResponse();
  List<Store> stores = [];
  String? activeStoreId;
  Customer? _customer;

  Customer? get customer => _customer;

  Future<void> storeToken(AuthResponse? response) async {
    if (response == null || response.data == null) {
      print(
          "CustomerService: Response or response data is null in storeToken.");
      return;
    }
    final box = GetStorage();

    if (response.data?.accessToken != null) {
      box.write(DbTable.tokenTableName, response.data?.accessToken);
      // Ensure storageService.storeItem also gets just the token for this key
      await storageService.storeItem(
          key: DbTable.tokenTableName, value: response.data?.accessToken!);
      print(
          "Stored Access Token: ${response.data!.accessToken?.substring(0, 10)}...");
    }

    // --- CRITICAL: Set the _customer property from the response's user data ---
    if (response.data?.user != null) {
      _customer = response.data?.user;
      // Also persist the full customer object for app restarts
      await storageService.storeItem(
          key: DbTable.customerTableName,
          value: jsonEncode(_customer?.toJson()));
      print(
          "CustomerService: _customer set from login response: ${_customer?.email}");
    } else {
      _customer = null; // Ensure it's null if no user data is found
      print(
          "CustomerService: No user data found in login response, _customer remains null.");
    }

    // Save ownerId
    if (_customer?.id != null) {
      box.write('ownerId', _customer?.id!);
      await storageService.storeItem(key: 'ownerId', value: _customer?.id!);
      print("SAVED OWNER ID: ${_customer?.id}");
    }

    loginResponse = response;

    await fetchStores();
    print("CustomerService: Finished storeToken operation.");
  }

  Future<void> fetchStores() async {
    try {
      final response = await storeApiService.getStoresByOwner();
      stores = response ?? [];
      activeStoreId = stores.isNotEmpty ? stores.first.id : null;
      print("Fetched stores: ${stores.length}, ActiveStoreId: $activeStoreId");
    } catch (e) {
      print("Error fetching stores: $e");
      stores = [];
    }
  }

  Future<String?> getOwnerId() async {
    final box = GetStorage();
    String? ownerIdFromBox = box.read('ownerId');
    if (ownerIdFromBox != null) return ownerIdFromBox;
    return await storageService.readItem(key: 'ownerId');
  }

  Future<String?> getActiveStoreId() async {
    final box = GetStorage();
    String? storeIdFromBox = box.read('activeStoreId');
    if (storeIdFromBox != null) return storeIdFromBox;
    return await storageService.readItem(key: 'activeStoreId');
  }

  void setActiveStore(String storeId) {
    activeStoreId = storeId;
    final box = GetStorage();
    box.write('activeStoreId', storeId);
    storageService.storeItem(key: 'activeStoreId', value: storeId);
    print("SET ACTIVE STORE ID: $storeId");
  }

  Future<void> storeUser(Customer? response) async {
    if (response == null) {
      print("CustomerService: Attempted to store null user.");
      return;
    }
    try {
      final userJson = jsonEncode(response.toJson());
      await storageService.storeItem(
          key: DbTable.customerTableName, value: userJson);
      _customer = response;
      print("CustomerService: Stored user: ${response.email}");
      print("CustomerService: Stored user JSON: $userJson");
    } catch (e) {
      print("CustomerService: Error storing user: $e");
    }
  }

  Future<void> storeCustomer(CustomerData? response) async {
    if (response == null) return;
    await storageService.storeItem(
        key: DbTable.customerTableName, value: jsonEncode(response.toJson()));
    customerResponse = response;
    print("STORED CUSTOMER DATA: ${response.id}");
  }

  Future<void> storePaymentMethod(PaymentMethod? response) async {
    if (response == null) return;
    List<PaymentMethod> existingMethods = await getStoredPaymentMethods() ?? [];
    existingMethods.add(response);
    await storageService.storeItem(
      key: DbTable.paymentMethodTable,
      value:
          jsonEncode(existingMethods.map((method) => method.toJson()).toList()),
    );
    print("STORED PAYMENT METHOD: ${response.id}");
  }

  Future<void> logout() async {
    final box = GetStorage();
    String? token = loginResponse.data?.accessToken;
    if (token != null) {
      bool logoutSuccess = await auth.logout(token);
      if (!logoutSuccess) {
        showCustomToast("Logout failed. Please try again.");
        return;
      }
    }
    await box.erase();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await storageService.deleteItem(key: DbTable.customerTableName);
    await storageService.deleteItem(key: DbTable.tokenTableName);
    await storageService.deleteItem(key: DbTable.loginTableName);
    await storageService.deleteItem(key: DbTable.storeTableName);
    await storageService.deleteItem(key: DbTable.activeStoreId);
    isUserLoggedIn = false;
    _customer = Customer();
    stores = [];
    activeStoreId = null;
    navigationService.navigateToAndRemoveUntil(loginScreenRoute);
    showCustomToast("Session Has Ended, Log In to proceed");
  }

  Future<void> checkUserSetup() async {
    print("CustomerService.checkUserSetup called for navigation.");

    // Ensure customer data is loaded (especially for app restarts)
    if (_customer == null) {
      print(
          "CustomerService: _customer is null. Attempting to load from storage/API.");
      _customer = await getStoreUser(); // Try to load it
      if (_customer == null) {
        print(
            "CustomerService: Failed to load customer. Redirecting to login.");
        navigationService.navigateToAndRemoveUntil(loginScreenRoute);
        return;
      }
    }

    try {
      // 1. Check for Stores
      final List<Store>? userStores = await storeApiService.getStoresByOwner();
      print("CustomerService: Fetched ${userStores?.length ?? 0} stores.");

      if (userStores == null || userStores.isEmpty) {
        print(
            "CustomerService: User has no stores. Navigating to createStoreRoute.");
        navigationService.navigateToAndRemoveUntil(createStoreRoute);
        return; // Important: Return after navigation
      }

      // If user has stores, set the active store
      // Ensure the store is not null before accessing its ID
      if (userStores.first.id != null) {
        setActiveStore(userStores.first.id!);
        print("CustomerService: Active store set to ${userStores.first.id}");
      } else {
        print(
            "CustomerService: First store in list has a null ID. Cannot set active store.");
        // Consider a fallback, e.g., show an error or go to a generic create store page
        showCustomToast(
            "Error: Store ID is missing. Please create a new store.",
            success: false);
        navigationService.navigateToAndRemoveUntil(createStoreRoute);
        return;
      }

      // 2. If stores exist, check for Payment Methods
      final bool hasPayments = await hasPaymentMethods();
      print("CustomerService: User has payment methods: $hasPayments");

      if (!hasPayments) {
        print(
            "CustomerService: User has stores but no payment methods. Navigating to addPaymentMethodRoute.");
        navigationService.navigateToAndRemoveUntil(addPaymentMethodRoute);
        return; // Important: Return after navigation
      }

      // 3. If both stores and payment methods exist, navigate to Dashboard
      print(
          "CustomerService: User has stores and payment methods. Navigating to dashboardRoute.");
      navigationService.navigateToAndRemoveUntil(dashboardRoute);
    } on DioException catch (e) {
      print(
          "CustomerService: DioError during user setup check: ${e.response?.data ?? e.message}");
      showCustomToast(
          "Error loading user data: ${e.response?.data['message'] ?? e.message}",
          success: false);
      navigationService
          .navigateToAndRemoveUntil(loginScreenRoute); // Fallback to login
    } catch (e) {
      print("CustomerService: Unexpected error during user setup check: $e");
      showCustomToast("An unexpected error occurred during setup: $e",
          success: false);
      navigationService
          .navigateToAndRemoveUntil(loginScreenRoute); // Fallback to login
    }
  }

  Future<Customer?> getStoreUser() async {
    if (_customer != null &&
        _customer!.email != null &&
        _customer!.id != null) {
      print("CustomerService: Returning cached _customer: ${_customer!.email}");
      print("CustomerService: Cached user data: ${_customer!.toJson()}");
      return _customer;
    }

    String? data =
        await storageService.readItem(key: DbTable.customerTableName);
    if (data == null) {
      print(
          "CustomerService: No customer data in local storage. Fetching from API.");
      try {
        final response = await auth.getUser();
        if (response == null) {
          print("CustomerService: Failed to fetch user from API. Logging out.");
          await logout();
          return null;
        }
        _customer = response;
        await storeUser(response);
        print(
            "CustomerService: Fetched and stored user from API: ${_customer?.email}");
        print("CustomerService: User data: ${_customer?.toJson()}");
        return _customer;
      } catch (e) {
        print("CustomerService: Error fetching user from API: $e");
        await logout();
        return null;
      }
    } else {
      try {
        final userResponse = Customer.fromJson(jsonDecode(data));
        if (userResponse.email == null || userResponse.id == null) {
          print("CustomerService: Invalid customer data in storage: $data");
          await storageService.deleteItem(key: DbTable.customerTableName);
          return await getStoreUser(); // Retry by fetching from API
        }
        _customer = userResponse;
        print(
            "CustomerService: Loaded customer from storage: ${_customer?.email}");
        print("CustomerService: User data: ${_customer?.toJson()}");
        return userResponse;
      } catch (e) {
        print("CustomerService: Error parsing user data from storage: $e");
        print("CustomerService: Corrupted data: $data");
        await storageService.deleteItem(key: DbTable.customerTableName);
        return await getStoreUser(); // Retry by fetching from API
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
      }
      return null;
    } catch (e) {
      print("Error decoding payment methods: $e");
      return null;
    }
  }

  Future<bool> hasPaymentMethods() async {
    try {
      final box = GetStorage();
      String? accessToken = box.read(DbTable.tokenTableName);
      if (accessToken == null) {
        print("hasPaymentMethods: No access token found.");
        return false;
      }

      Response response = await connect().get(
        AppUrls.getPaymentMethod,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        // response.data is expected to be Map<String, dynamic> because of ResponseType.json
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          // Check if it contains the 'data' key and if 'data' is a List
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            List<dynamic> paymentMethodsList = responseData['data'];
            print(
                "hasPaymentMethods: Found ${paymentMethodsList.length} payment methods in 'data' key.");
            return paymentMethodsList.isNotEmpty;
          } else {
            // Handle cases where 'data' key might be missing or not a list
            print(
                "hasPaymentMethods: Response does not contain a 'data' list or 'data' is not a List.");
            // You might want to inspect responseData further here to see its actual structure
            print("hasPaymentMethods: Full response data: $responseData");
            return false;
          }
        } else {
          // This case should ideally not happen if ResponseType.json is working correctly
          print(
              "hasPaymentMethods: Unexpected response data type: ${responseData.runtimeType}. Expected Map.");
          return false;
        }
      }
      print(
          "hasPaymentMethods: API call failed with status: ${response.statusCode}");
      return false;
    } on DioException catch (e) {
      print("Error checking payment methods (DioException): ${e.message}");
      // Accessing error data safely if it's a Map
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        print("Error response data: ${e.response!.data}");
        showCustomToast(
            "Failed to check payment methods: ${e.response!.data['message'] ?? 'Unknown error'}",
            success: false);
      } else {
        showCustomToast("Failed to check payment methods: ${e.message}",
            success: false);
      }
      return false;
    } catch (e) {
      print("Error checking payment methods (General): $e");
      showCustomToast(
          "Failed to check payment methods due to an unexpected error.",
          success: false);
      return false;
    }
  }
}
