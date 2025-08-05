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
