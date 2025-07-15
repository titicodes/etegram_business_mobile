// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import '../../base/base_vm.dart';
// import '../../constants/reuseable.dart';
// import '../../locator.dart';
// import '../../routes/routes.dart';
// import '../../service/local/cache.dart';
// import '../../service/local/navigation_service.dart';
// import '../../service/local/storage_service.dart';
// import '../../service/local/user_service.dart'; // <--- Import CustomerService (user_service.dart)
// import '../../utils/snack_message.dart';
//
// class SplashScreenViewModel extends BaseViewModel {
//   final AppCache appCache = locator<AppCache>();
//   final StorageService storageService = locator<StorageService>();
//   final NavigationService navigationService = locator<NavigationService>();
//   final CustomerService customerService =
//       locator<CustomerService>(); // <--- Get CustomerService instance
//
//   Future<void> checkUserSetup() async {
//     try {
//       startLoader();
//       print("SplashScreen: Checking user setup");
//       final box = GetStorage();
//       String? accessToken = box.read(DbTable.tokenTableName);
//       await Future.delayed(const Duration(seconds: 2)); // Simulate loading
//
//       if (accessToken == null) {
//         print("SplashScreen: No token, navigating to login");
//         navigationService.navigateToAndRemoveUntil(onBoardingScreenRoute);
//       } else {
//         print(
//             "SplashScreen: Token found, delegating to CustomerService.checkUserSetup");
//         // *** Call the actual setup logic here ***
//         await customerService.getStoreUser(); // Ensure _customer is loaded
//         await customerService
//             .checkUserSetup(); // This will handle the navigation based on stores
//       }
//     } catch (e) {
//       print("SplashScreen Error: $e");
//       showCustomToast("Error checking setup: $e");
//       navigationService.navigateToAndRemoveUntil(loginScreenRoute);
//     } finally {
//       stopLoader();
//       notifyListeners();
//     }
//   }
// }

import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenViewModel extends BaseViewModel {
  final CustomerService _customerService = locator<CustomerService>();

  Future<void> checkUserSetup() async {
    try {
      startLoader();
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (isFirstTime) {
        // First-time installation: navigate to onboarding screen
        await prefs.setBool('isFirstTime', false);
        print(
            "SplashScreenViewModel: First-time launch, navigating to onboarding");
        navigationService.navigateToAndRemoveUntil(onBoardingScreenRoute);
      } else {
        // Subsequent launches: check user setup
        print("SplashScreenViewModel: Subsequent launch, checking user setup");
        await _customerService.checkUserSetup();
      }
    } catch (e) {
      print("SplashScreenViewModel: Error during setup check: $e");
      navigationService.navigateToAndRemoveUntil(loginScreenRoute);
    } finally {
      stopLoader();
    }
  }
}
