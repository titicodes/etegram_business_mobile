// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:etegram_business/core/model/subscription_model.dart';
// import 'package:etegram_business/service/local/storage_service.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../constants/app_url.dart';
// import '../../constants/reuseable.dart';
// import '../../core/model/auth_response.dart';
// import '../../core/model/customer_response.dart';
// import '../../core/model/payment_method_response.dart';
// import '../../core/model/store_model.dart';
// import '../../locator.dart';
// import '../../repository/auth_repository.dart';
// import '../../routes/routes.dart';
// import '../../utils/snack_message.dart';
// import '../web/auth_api.dart';
// import '../web/base_api.dart';
// import '../web/store_api_service.dart';
// import 'cache.dart';
//
// class CustomerService {
//   CustomerData customerResponse = CustomerData();
//   final StorageService storageService = locator<StorageService>();
//   final AppCache cache = locator<AppCache>();
//   final StoreApiService storeApiService = locator<StoreApiService>();
//   bool isUserLoggedIn = false;
//   bool isUserServiceProvider = false;
//   AuthResponse loginResponse = AuthResponse();
//   List<Store> stores = [];
//   String? activeStoreId;
//   Customer? _customer;
//   SubscriptionModel? _subscription;
//
//   Customer? get customer => _customer;
//   SubscriptionModel? get subscription => _subscription;
//
//   Future<void> initialize() async {
//     await _loadUser();
//     await fetchStores();
//     await fetchSubscriptionStatus();
//   }
//
//   Future<void> _loadUser() async {
//     try {
//       final authResponse = await locator<AuthRepository>().getUser();
//       if (authResponse?.success == true && authResponse?.data?.user != null) {
//         await storeUser(authResponse!.data!.user);
//         await storeToken(authResponse);
//       } else {
//         _customer = null;
//         _subscription = null;
//         print('CustomerService: No valid user data in authResponse');
//       }
//     } catch (e) {
//       print('CustomerService: Error loading user: $e');
//       _customer = null;
//       _subscription = null;
//     }
//   }
//
//   Future<void> storeToken(AuthResponse? response) async {
//     if (response == null || response.data == null) {
//       print(
//           "CustomerService: Response or response data is null in storeToken.");
//       return;
//     }
//     final box = GetStorage();
//
//     if (response.data?.accessToken != null) {
//       box.write(DbTable.tokenTableName, response.data?.accessToken);
//       await storageService.storeItem(
//           key: DbTable.tokenTableName, value: response.data?.accessToken!);
//       print(
//           "Stored Access Token: ${response.data!.accessToken?.substring(0, 10)}...");
//     }
//
//     if (response.data?.user != null) {
//       await storeUser(response.data!.user);
//     } else {
//       _customer = null;
//       print(
//           "CustomerService: No user data found in login response, _customer remains null.");
//     }
//
//     if (_customer?.id != null) {
//       box.write('ownerId', _customer?.id!);
//       await storageService.storeItem(key: 'ownerId', value: _customer?.id!);
//       print("SAVED OWNER ID: ${_customer?.id}");
//     }
//
//     loginResponse = response;
//
//     await fetchStores();
//     await fetchSubscriptionStatus();
//     print("CustomerService: Finished storeToken operation.");
//   }
//
//   Future<void> fetchStores() async {
//     try {
//       final response = await storeApiService.getStoresByOwner();
//       stores = response ?? [];
//       activeStoreId = stores.isNotEmpty ? stores.first.id : null;
//       print("Fetched stores: ${stores.length}, ActiveStoreId: $activeStoreId");
//     } catch (e) {
//       print("Error fetching stores: $e");
//       stores = [];
//     }
//   }
//
//   Future<void> fetchSubscriptionStatus() async {
//     try {
//       final box = GetStorage();
//       String? accessToken = box.read(DbTable.tokenTableName);
//       if (accessToken == null) {
//         print("CustomerService: No access token found for subscription fetch.");
//         _subscription = null;
//         return;
//       }
//
//       Response response = await connect().get(
//         '${AppUrls.baseUrl}subscriptions',
//         options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
//       );
//
//       if (response.statusCode == 200) {
//         _subscription = SubscriptionModel.fromJson(response.data);
//         await storageService.storeItem(
//             key: DbTable.subscriptionTableName,
//             value: jsonEncode(_subscription?.toJson()));
//         print(
//             "CustomerService: Fetched subscription: ${_subscription?.status}");
//       } else {
//         _subscription = null;
//         print(
//             "CustomerService: Failed to fetch subscription, status: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("CustomerService: Error fetching subscription status: $e");
//       _subscription = null;
//     }
//   }
//
//   Future<void> subscribeToPremium(String type) async {
//     try {
//       final box = GetStorage();
//       String? accessToken = box.read(DbTable.tokenTableName);
//       if (accessToken == null) {
//         print(
//             "CustomerService: No access token found for premium subscription.");
//         showCustomToast("Please log in to subscribe.", success: false);
//         return;
//       }
//
//       Response response = await connect().patch(
//         '${AppUrls.baseUrl}subscriptions/premium/$type',
//         options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
//       );
//
//       if (response.statusCode == 200) {
//         _subscription = SubscriptionModel.fromJson(response.data);
//         await storageService.storeItem(
//             key: DbTable.subscriptionTableName,
//             value: jsonEncode(_subscription?.toJson()));
//         showCustomToast("Successfully subscribed to $type plan", success: true);
//         print(
//             "CustomerService: Subscribed to premium: ${_subscription?.status}");
//       } else {
//         showCustomToast(
//             "Failed to subscribe to premium: ${response.statusMessage}",
//             success: false);
//       }
//     } catch (e) {
//       print("CustomerService: Error subscribing to premium: $e");
//       showCustomToast("Failed to subscribe to premium", success: false);
//     }
//   }
//
//   Future<void> cancelSubscription() async {
//     try {
//       final box = GetStorage();
//       String? accessToken = box.read(DbTable.tokenTableName);
//       if (accessToken == null) {
//         print(
//             "CustomerService: No access token found for subscription cancellation.");
//         showCustomToast("Please log in to cancel subscription.",
//             success: false);
//         return;
//       }
//
//       Response response = await connect().delete(
//         '${AppUrls.baseUrl}subscriptions',
//         options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
//       );
//
//       if (response.statusCode == 200) {
//         _subscription = SubscriptionModel.fromJson(response.data);
//         await storageService.storeItem(
//             key: DbTable.subscriptionTableName,
//             value: jsonEncode(_subscription?.toJson()));
//         showCustomToast("Subscription cancelled successfully", success: true);
//         print(
//             "CustomerService: Subscription cancelled: ${_subscription?.status}");
//       } else {
//         showCustomToast(
//             "Failed to cancel subscription: ${response.statusMessage}",
//             success: false);
//       }
//     } catch (e) {
//       print("CustomerService: Error cancelling subscription: $e");
//       showCustomToast("Failed to cancel subscription", success: false);
//     }
//   }
//
//   Future<void> updateFcmToken(String fcmToken) async {
//     try {
//       final box = GetStorage();
//       String? accessToken = box.read(DbTable.tokenTableName);
//       if (accessToken == null || _customer?.id == null) {
//         print(
//             "CustomerService: No access token or user ID for FCM token update.");
//         return;
//       }
//
//       await connect().patch(
//         '${AppUrls.baseUrl}users/fcm-token',
//         data: {'fcmToken': fcmToken},
//         options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
//       );
//       print("CustomerService: FCM token updated successfully");
//     } catch (e) {
//       print("CustomerService: Error updating FCM token: $e");
//     }
//   }
//
//   bool isPremiumFeatureAccessible() {
//     // During internal testing, allow access to all features regardless of subscription status
//     print(
//         "CustomerService: Allowing premium feature access for internal testing");
//     return true;
//   }
//
//   Future<String?> getOwnerId() async {
//     final box = GetStorage();
//     String? ownerIdFromBox = box.read('ownerId');
//     if (ownerIdFromBox != null) return ownerIdFromBox;
//     return await storageService.readItem(key: 'ownerId');
//   }
//
//   Future<String?> getActiveStoreId() async {
//     final box = GetStorage();
//     String? storeIdFromBox = box.read('activeStoreId');
//     if (storeIdFromBox != null) return storeIdFromBox;
//     return await storageService.readItem(key: 'activeStoreId');
//   }
//
//   void setActiveStore(String storeId) {
//     activeStoreId = storeId;
//     final box = GetStorage();
//     box.write('activeStoreId', storeId);
//     storageService.storeItem(key: 'activeStoreId', value: storeId);
//     print("SET ACTIVE STORE ID: $storeId");
//   }
//
//   Future<void> storeUser(Customer? response) async {
//     if (response == null) {
//       print("CustomerService: Attempted to store null user.");
//       return;
//     }
//     try {
//       final userJson = jsonEncode(response.toJson());
//       await storageService.storeItem(
//           key: DbTable.customerTableName, value: userJson);
//       _customer = response;
//       print("CustomerService: Stored user: ${response.email}");
//       print("CustomerService: Stored user JSON: $userJson");
//     } catch (e) {
//       print("CustomerService: Error storing user: $e");
//     }
//   }
//
//   Future<void> storeCustomer(CustomerData? response) async {
//     if (response == null) return;
//     await storageService.storeItem(
//         key: DbTable.customerTableName, value: jsonEncode(response.toJson()));
//     customerResponse = response;
//     print("STORED CUSTOMER DATA: ${response.id}");
//   }
//
//   Future<void> storePaymentMethod(PaymentMethod? response) async {
//     if (response == null) return;
//     List<PaymentMethod> existingMethods = await getStoredPaymentMethods() ?? [];
//     existingMethods.add(response);
//     await storageService.storeItem(
//       key: DbTable.paymentMethodTable,
//       value:
//           jsonEncode(existingMethods.map((method) => method.toJson()).toList()),
//     );
//     print("STORED PAYMENT METHOD: ${response.id}");
//   }
//
//   Future<void> logout() async {
//     final box = GetStorage();
//     String? token = loginResponse.data?.accessToken;
//     if (token != null) {
//       bool logoutSuccess =
//           await locator<AuthenticationApiService>().logout(token);
//       if (!logoutSuccess) {
//         showCustomToast("Logout failed. Please try again.", success: false);
//         return;
//       }
//     }
//     await box.erase();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     await storageService.deleteItem(key: DbTable.customerTableName);
//     await storageService.deleteItem(key: DbTable.tokenTableName);
//     await storageService.deleteItem(key: DbTable.loginTableName);
//     await storageService.deleteItem(key: DbTable.storeTableName);
//     await storageService.deleteItem(key: DbTable.activeStoreId);
//     await storageService.deleteItem(key: DbTable.subscriptionTableName);
//     isUserLoggedIn = false;
//     _customer = Customer();
//     _subscription = null;
//     stores = [];
//     activeStoreId = null;
//     navigationService.navigateToAndRemoveUntil(loginScreenRoute);
//     showCustomToast("Session Has Ended, Log In to proceed", success: true);
//   }
//
//   Future<void> checkUserSetup() async {
//     print("CustomerService.checkUserSetup called for navigation.");
//
//     if (_customer == null) {
//       print(
//           "CustomerService: _customer is null. Attempting to load from storage/API.");
//       _customer = await getStoreUser();
//       if (_customer == null) {
//         print(
//             "CustomerService: Failed to load customer. Redirecting to login.");
//         navigationService.navigateToAndRemoveUntil(loginScreenRoute);
//         return;
//       }
//     }
//
//     try {
//       final List<Store>? userStores = await storeApiService.getStoresByOwner();
//       print("CustomerService: Fetched ${userStores?.length ?? 0} stores.");
//
//       if (userStores == null || userStores.isEmpty) {
//         print(
//             "CustomerService: User has no stores. Navigating to createStoreRoute.");
//         navigationService.navigateToAndRemoveUntil(createStoreRoute);
//         return;
//       }
//
//       if (userStores.first.id != null) {
//         setActiveStore(userStores.first.id!);
//         print("CustomerService: Active store set to ${userStores.first.id}");
//       } else {
//         print(
//             "CustomerService: First store in list has a null ID. Cannot set active store.");
//         showCustomToast(
//             "Error: Store ID is missing. Please create a new store.",
//             success: false);
//         navigationService.navigateToAndRemoveUntil(createStoreRoute);
//         return;
//       }
//
//       final bool hasPayments = await hasPaymentMethods();
//       print("CustomerService: User has payment methods: $hasPayments");
//
//       if (!hasPayments) {
//         print(
//             "CustomerService: User has stores but no payment methods. Navigating to addPaymentMethodRoute.");
//         navigationService.navigateToAndRemoveUntil(addPaymentMethodRoute);
//         return;
//       }
//
//       await fetchSubscriptionStatus();
//       // During internal testing, allow access to dashboard even without an active subscription
//       print(
//           "CustomerService: Subscription status: ${_subscription?.status}, isActive: ${_subscription?.isActive}");
//       print(
//           "CustomerService: Navigating to dashboardRoute for internal testing.");
//       navigationService.navigateToAndRemoveUntil(dashboardRoute);
//     } on DioException catch (e) {
//       print(
//           "CustomerService: DioError during user setup check: ${e.response?.data ?? e.message}");
//       showCustomToast(
//           "Error loading user data: ${e.response?.data['message'] ?? e.message}",
//           success: false);
//       navigationService.navigateToAndRemoveUntil(loginScreenRoute);
//     } catch (e) {
//       print("CustomerService: Unexpected error during user setup check: $e");
//       showCustomToast("An unexpected error occurred during setup: $e",
//           success: false);
//       navigationService.navigateToAndRemoveUntil(loginScreenRoute);
//     }
//   }
//
//   Future<Customer?> getStoreUser() async {
//     if (_customer != null &&
//         _customer!.email != null &&
//         _customer!.id != null) {
//       print("CustomerService: Returning cached _customer: ${_customer!.email}");
//       print("CustomerService: Cached user data: ${_customer!.toJson()}");
//       return _customer;
//     }
//
//     String? data =
//         await storageService.readItem(key: DbTable.customerTableName);
//     if (data == null) {
//       print(
//           "CustomerService: No customer data in local storage. Fetching from API.");
//       try {
//         final authResponse = await locator<AuthRepository>().getUser();
//         if (authResponse == null || authResponse.data?.user == null) {
//           print("CustomerService: Failed to fetch user from API. Logging out.");
//           await logout();
//           return null;
//         }
//         await storeUser(authResponse.data!.user);
//         print(
//             "CustomerService: Fetched and stored user from API: ${_customer?.email}");
//         print("CustomerService: User data: ${_customer?.toJson()}");
//         return _customer;
//       } catch (e) {
//         print("CustomerService: Error fetching user from API: $e");
//         await logout();
//         return null;
//       }
//     } else {
//       try {
//         final userResponse = Customer.fromJson(jsonDecode(data));
//         if (userResponse.email == null || userResponse.id == null) {
//           print("CustomerService: Invalid customer data in storage: $data");
//           await storageService.deleteItem(key: DbTable.customerTableName);
//           return await getStoreUser();
//         }
//         _customer = userResponse;
//         print(
//             "CustomerService: Loaded customer from storage: ${_customer?.email}");
//         print("CustomerService: User data: ${_customer?.toJson()}");
//         return userResponse;
//       } catch (e) {
//         print("CustomerService: Error parsing user data from storage: $e");
//         print("CustomerService: Corrupted data: $data");
//         await storageService.deleteItem(key: DbTable.customerTableName);
//         return await getStoreUser();
//       }
//     }
//   }
//
//   Future<List<PaymentMethod>?> getStoredPaymentMethods() async {
//     try {
//       final storedJson = GetStorage().read(DbTable.paymentMethodTable);
//       if (storedJson == null) return null;
//       final decoded = jsonDecode(storedJson);
//       if (decoded is List) {
//         return decoded
//             .map<PaymentMethod>((e) => PaymentMethod.fromJson(e))
//             .toList();
//       }
//       return null;
//     } catch (e) {
//       print("Error decoding payment methods: $e");
//       return null;
//     }
//   }
//
//   Future<bool> hasPaymentMethods() async {
//     try {
//       final box = GetStorage();
//       String? accessToken = box.read(DbTable.tokenTableName);
//       if (accessToken == null) {
//         print("hasPaymentMethods: No access token found.");
//         return false;
//       }
//
//       Response response = await connect().get(
//         AppUrls.getPaymentMethod,
//         options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = response.data;
//
//         if (responseData is Map<String, dynamic> &&
//             responseData.containsKey('data') &&
//             responseData['data'] is List) {
//           List<dynamic> paymentMethodsList = responseData['data'];
//           print(
//               "hasPaymentMethods: Found ${paymentMethodsList.length} payment methods in 'data' key.");
//           return paymentMethodsList.isNotEmpty;
//         } else {
//           print(
//               "hasPaymentMethods: Response does not contain a 'data' list or 'data' is not a List.");
//           print("hasPaymentMethods: Full response data: $responseData");
//           return false;
//         }
//       }
//       print(
//           "hasPaymentMethods: API call failed with status: ${response.statusCode}");
//       return false;
//     } on DioException catch (e) {
//       print("Error checking payment methods (DioException): ${e.message}");
//       if (e.response != null && e.response!.data is Map<String, dynamic>) {
//         print("Error response data: ${e.response!.data}");
//         showCustomToast(
//             "Failed to check payment methods: ${e.response!.data['message'] ?? 'Unknown error'}",
//             success: false);
//       } else {
//         showCustomToast("Failed to check payment methods: ${e.message}",
//             success: false);
//       }
//       return false;
//     } catch (e) {
//       print("Error checking payment methods (General): $e");
//       showCustomToast(
//           "Failed to check payment methods due to an unexpected error.",
//           success: false);
//       return false;
//     }
//   }
// }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:etegram_business/core/model/subscription_model.dart';
import 'package:etegram_business/service/local/storage_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_url.dart';
import '../../constants/reuseable.dart';
import '../../core/model/auth_response.dart';
import '../../core/model/customer_response.dart';
import '../../core/model/payment_method_response.dart';
import '../../core/model/store_model.dart';
import '../../locator.dart';
import '../../repository/auth_repository.dart';
import '../../routes/routes.dart';
import '../../utils/snack_message.dart';
import '../web/auth_api.dart';
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
  SubscriptionModel? _subscription;

  Customer? get customer => _customer;
  SubscriptionModel? get subscription => _subscription;

  Future<void> initialize() async {
    await _loadUser();
    await fetchStores();
    await fetchSubscriptionStatus();
  }

  Future<void> _loadUser() async {
    try {
      final authResponse = await locator<AuthRepository>().getUser();
      if (authResponse?.success == true && authResponse?.data?.user != null) {
        await storeUser(authResponse!.data!.user);
        isUserLoggedIn = true;
      } else {
        _customer = null;
        _subscription = null;
        isUserLoggedIn = false;
        print('CustomerService: No valid user data in authResponse');
      }
    } catch (e) {
      print('CustomerService: Error loading user: $e');
      _customer = null;
      _subscription = null;
      isUserLoggedIn = false;
    }
  }

  Future<void> storeToken(AuthResponse? response) async {
    if (response == null || response.data == null) {
      print(
          "CustomerService: Response or response data is null in storeToken.");
      return;
    }
    final box = GetStorage();

    if (response.data?.accessToken != null) {
      box.write(DbTable.tokenTableName, response.data?.accessToken);
      await storageService.storeItem(
          key: DbTable.tokenTableName, value: response.data?.accessToken!);
      print(
          "Stored Access Token: ${response.data!.accessToken?.substring(0, 10)}...");
    }

    if (response.data?.user != null) {
      await storeUser(response.data!.user);
    } else {
      _customer = null;
      print(
          "CustomerService: No user data found in login response, _customer remains null.");
    }

    if (_customer?.id != null) {
      box.write('ownerId', _customer?.id!);
      await storageService.storeItem(key: 'ownerId', value: _customer?.id!);
      print("SAVED OWNER ID: ${_customer?.id}");
    }

    loginResponse = response;
    isUserLoggedIn = _customer != null;

    await fetchStores();
    await fetchSubscriptionStatus();
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
      activeStoreId = null;
    }
  }

  Future<void> fetchSubscriptionStatus() async {
    try {
      final box = GetStorage();
      String? accessToken = box.read(DbTable.tokenTableName);
      if (accessToken == null) {
        print("CustomerService: No access token found for subscription fetch.");
        _subscription = null;
        return;
      }

      Response response = await connect().get(
        '${AppUrls.baseUrl}subscriptions',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        _subscription = SubscriptionModel.fromJson(response.data);
        await storageService.storeItem(
            key: DbTable.subscriptionTableName,
            value: jsonEncode(_subscription?.toJson()));
        print(
            "CustomerService: Fetched subscription: ${_subscription?.status}");
      } else {
        _subscription = null;
        print(
            "CustomerService: Failed to fetch subscription, status: ${response.statusCode}");
      }
    } catch (e) {
      print("CustomerService: Error fetching subscription status: $e");
      _subscription = null;
    }
  }

  Future<void> subscribeToPremium(String type) async {
    try {
      final box = GetStorage();
      String? accessToken = box.read(DbTable.tokenTableName);
      if (accessToken == null) {
        print(
            "CustomerService: No access token found for premium subscription.");
        showCustomToast("Please log in to subscribe.", success: false);
        return;
      }

      Response response = await connect().patch(
        '${AppUrls.baseUrl}subscriptions/premium/$type',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        _subscription = SubscriptionModel.fromJson(response.data);
        await storageService.storeItem(
            key: DbTable.subscriptionTableName,
            value: jsonEncode(_subscription?.toJson()));
        showCustomToast("Successfully subscribed to $type plan", success: true);
        print(
            "CustomerService: Subscribed to premium: ${_subscription?.status}");
      } else {
        showCustomToast(
            "Failed to subscribe to premium: ${response.statusMessage}",
            success: false);
      }
    } catch (e) {
      print("CustomerService: Error subscribing to premium: $e");
      showCustomToast("Failed to subscribe to premium", success: false);
    }
  }

  Future<void> cancelSubscription() async {
    try {
      final box = GetStorage();
      String? accessToken = box.read(DbTable.tokenTableName);
      if (accessToken == null) {
        print(
            "CustomerService: No access token found for subscription cancellation.");
        showCustomToast("Please log in to cancel subscription.",
            success: false);
        return;
      }

      Response response = await connect().delete(
        '${AppUrls.baseUrl}subscriptions',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        _subscription = SubscriptionModel.fromJson(response.data);
        await storageService.storeItem(
            key: DbTable.subscriptionTableName,
            value: jsonEncode(_subscription?.toJson()));
        showCustomToast("Subscription cancelled successfully", success: true);
        print(
            "CustomerService: Subscription cancelled: ${_subscription?.status}");
      } else {
        showCustomToast(
            "Failed to cancel subscription: ${response.statusMessage}",
            success: false);
      }
    } catch (e) {
      print("CustomerService: Error cancelling subscription: $e");
      showCustomToast("Failed to cancel subscription", success: false);
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final box = GetStorage();
      String? accessToken = box.read(DbTable.tokenTableName);
      if (accessToken == null || _customer?.id == null) {
        print(
            "CustomerService: No access token or user ID for FCM token update.");
        return;
      }

      await connect().patch(
        '${AppUrls.baseUrl}users/fcm-token',
        data: {'fcmToken': fcmToken},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      print("CustomerService: FCM token updated successfully");
    } catch (e) {
      print("CustomerService: Error updating FCM token: $e");
    }
  }

  bool isPremiumFeatureAccessible() {
    // During internal testing, allow access to all features regardless of subscription status
    print(
        "CustomerService: Allowing premium feature access for internal testing");
    return true;
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
      isUserLoggedIn = true;
      print("CustomerService: Stored user: ${response.email}");
      print("CustomerService: Stored user JSON: $userJson");
    } catch (e) {
      print("CustomerService: Error storing user: $e");
      isUserLoggedIn = false;
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
      bool logoutSuccess =
          await locator<AuthenticationApiService>().logout(token);
      if (!logoutSuccess) {
        showCustomToast("Logout failed. Please try again.", success: false);
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
    await storageService.deleteItem(key: DbTable.subscriptionTableName);
    isUserLoggedIn = false;
    _customer = null;
    _subscription = null;
    stores = [];
    activeStoreId = null;
    navigationService.navigateToAndRemoveUntil(loginScreenRoute);
    showCustomToast("Session Has Ended, Log In to proceed", success: true);
  }

  Future<void> checkUserSetup() async {
    print("CustomerService.checkUserSetup called for navigation.");

    try {
      if (_customer == null) {
        _customer = await getStoreUser();
        if (_customer == null) {
          print("CustomerService: No user found. Navigating to login.");
          navigationService.navigateToAndRemoveUntil(loginScreenRoute);
          return;
        }
      }

      final List<Store>? userStores = await storeApiService.getStoresByOwner();
      print("CustomerService: Fetched ${userStores?.length ?? 0} stores.");

      if (userStores == null || userStores.isEmpty) {
        print(
            "CustomerService: User has no stores. Navigating to createStoreRoute.");
        navigationService.navigateToAndRemoveUntil(createStoreRoute);
        return;
      }

      if (userStores.first.id != null) {
        setActiveStore(userStores.first.id!);
        print("CustomerService: Active store set to ${userStores.first.id}");
      } else {
        print(
            "CustomerService: First store has null ID. Navigating to createStoreRoute.");
        showCustomToast(
            "Error: Store ID is missing. Please create a new store.",
            success: false);
        navigationService.navigateToAndRemoveUntil(createStoreRoute);
        return;
      }

      final bool hasPayments = await hasPaymentMethods();
      print("CustomerService: User has payment methods: $hasPayments");

      if (!hasPayments) {
        print(
            "CustomerService: User has no payment methods. Navigating to addPaymentMethodRoute.");
        navigationService.navigateToAndRemoveUntil(addPaymentMethodRoute);
        return;
      }

      await fetchSubscriptionStatus();
      print(
          "CustomerService: Subscription status: ${_subscription?.status}, isActive: ${_subscription?.isActive}");
      print(
          "CustomerService: Navigating to dashboardRoute for internal testing.");
      navigationService.navigateToAndRemoveUntil(dashboardRoute);
    } on DioException catch (e) {
      print(
          "CustomerService: DioError during user setup check: ${e.response?.data ?? e.message}");
      showCustomToast(
          "Error loading user data: ${e.response?.data['message'] ?? e.message}",
          success: false);
      navigationService.navigateToAndRemoveUntil(loginScreenRoute);
    } catch (e) {
      print("CustomerService: Unexpected error during user setup check: $e");
      showCustomToast("An unexpected error occurred during setup: $e",
          success: false);
      navigationService.navigateToAndRemoveUntil(loginScreenRoute);
    }
  }

  Future<Customer?> getStoreUser() async {
    if (_customer != null &&
        _customer!.email != null &&
        _customer!.id != null) {
      print("CustomerService: Returning cached _customer: ${_customer!.email}");
      return _customer;
    }

    String? data =
        await storageService.readItem(key: DbTable.customerTableName);
    if (data == null) {
      print(
          "CustomerService: No customer data in local storage. Fetching from API.");
      try {
        final authResponse = await locator<AuthRepository>().getUser();
        if (authResponse == null || authResponse.data?.user == null) {
          print("CustomerService: Failed to fetch user from API. Logging out.");
          await logout();
          return null;
        }
        await storeUser(authResponse.data!.user);
        print(
            "CustomerService: Fetched and stored user from API: ${_customer?.email}");
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
          return await getStoreUser();
        }
        _customer = userResponse;
        isUserLoggedIn = true;
        print(
            "CustomerService: Loaded customer from storage: ${_customer?.email}");
        return _customer;
      } catch (e) {
        print("CustomerService: Error parsing user data from storage: $e");
        await storageService.deleteItem(key: DbTable.customerTableName);
        return await getStoreUser();
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
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData['data'] is List) {
          List<dynamic> paymentMethodsList = responseData['data'];
          print(
              "hasPaymentMethods: Found ${paymentMethodsList.length} payment methods in 'data' key.");
          return paymentMethodsList.isNotEmpty;
        } else {
          print(
              "hasPaymentMethods: Response does not contain a 'data' list or 'data' is not a List.");
          return false;
        }
      }
      print(
          "hasPaymentMethods: API call failed with status: ${response.statusCode}");
      return false;
    } on DioException catch (e) {
      print("Error checking payment methods (DioException): ${e.message}");
      showCustomToast(
          "Failed to check payment methods: ${e.response?.data['message'] ?? e.message}",
          success: false);
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
