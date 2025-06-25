import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../base/base_vm.dart';
import '../../../core/model/auth_response.dart';
import '../../../locator.dart';
import '../../../routes/routes.dart';
import '../../../service/local/cache.dart';
import '../../../service/local/user_service.dart';
import '../../../utils/snack_message.dart';

class LoginViewModel extends BaseViewModel {
  final CustomerService customerService = locator<CustomerService>();
  final AppCache appCache = locator<AppCache>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;
  final isFormValid = ValueNotifier<bool>(false);
  bool _isChecked = false; // Commented out as unused in SigninView
  bool get isChecked => _isChecked;
  void onCheckedChanged(bool value) {
    _isChecked = value;
    notifyListeners();
  }

  void init() {
    emailController.addListener(validateForm);
    passwordController.addListener(validateForm);
  }

  void validateForm() {
    isFormValid.value =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate() || !isFormValid.value) {
      showCustomToast("Please fill all required fields");
      return;
    }

    startLoader();
    try {
      var userData = Customer(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final response = await authRepository.login(customer: userData);

      if (response?.success == true) {
        await customerService.storeToken(response);
        appCache.registerResponse = response ?? AuthResponse();

        if (response?.data?.user?.emailVerified == false) {
          navigationService.navigateTo(verifyEmailView);
          showCustomToast("Please verify your email");
          return;
        }

        // Setup check
        await customerService.checkUserSetup();

        // 🔍 Add store check here if no navigation occurred
        if (customerService.stores.isEmpty) {
          print(
              "LoginViewModel: No stores found. Navigating to createStoreRoute.");
          navigationService.navigateToAndRemoveUntil(createStoreRoute);
          return;
        }

        // checkUserSetup will already handle dashboard or addPaymentMethod navigation
      } else {
        showCustomToast(response?.message ?? "Login failed");
      }
    } catch (e) {
      showCustomToast("Login failed: $e");
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  void goToSignUpView() {
    print("Navigating to signupRoute");
    navigationService.navigateTo(signUpScreenRoute);
  }

  void goToForgotPasswordView() {
    print("Navigating to forgotPasswordRoute");
    navigationService.navigateTo(forgetPasswordRoute);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isFormValid.dispose();
    super.dispose();
  }
}
