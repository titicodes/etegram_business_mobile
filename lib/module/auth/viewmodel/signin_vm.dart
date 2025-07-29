//
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import '../../../base/base_vm.dart';
// import '../../../core/model/auth_response.dart';
// import '../../../locator.dart';
// import '../../../routes/routes.dart';
// import '../../../service/local/cache.dart';
// import '../../../service/local/user_service.dart';
// import '../../../utils/snack_message.dart';
//
// class LoginViewModel extends BaseViewModel {
//   final CustomerService customerService = locator<CustomerService>();
//   final AppCache appCache = locator<AppCache>();
//
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool showPassword = false;
//   final isFormValid = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false); // Added isLoading
//   bool _isChecked = false; // Commented out as unused in SigninView
//   bool get isChecked => _isChecked;
//
//   void onCheckedChanged(bool value) {
//     _isChecked = value;
//     notifyListeners();
//   }
//
//   void init() {
//     emailController.addListener(validateForm);
//     passwordController.addListener(validateForm);
//   }
//
//   void validateForm() {
//     isFormValid.value =
//         emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
//     notifyListeners();
//   }
//
//   void togglePasswordVisibility() {
//     showPassword = !showPassword;
//     notifyListeners();
//   }
//
//   Future<void> submit(BuildContext context) async {
//     if (!formKey.currentState!.validate() || !isFormValid.value) {
//       showCustomToasts("Please fill all required fields", success: false);
//       return;
//     }
//
//     isLoading.value = true;
//     notifyListeners();
//
//     try {
//       var userData = Customer(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
//
//       final response = await authRepository.login(customer: userData);
//
//       if (response?.success == true) {
//         await customerService.storeToken(response);
//         appCache.registerResponse = response ?? AuthResponse();
//
//         if (response?.data?.user?.emailVerified == false) {
//           navigationService.navigateTo(verifyEmailView);
//           showCustomToasts("Please verify your email", success: false);
//           return;
//         }
//
//         // Setup check
//         await customerService.checkUserSetup();
//
//         if (customerService.stores.isEmpty) {
//           print("LoginViewModel: No stores found. Navigating to createStoreRoute.");
//           navigationService.navigateToAndRemoveUntil(createStoreRoute);
//           return;
//         }
//
//         // checkUserSetup handles dashboard or addPaymentMethod navigation
//       } else {
//         showCustomToasts(response?.message ?? "Login failed", success: false);
//       }
//     } on DioException catch (e) {
//       String errorMessage = "An error occurred during login";
//       if (e.response != null) {
//         final statusCode = e.response!.statusCode;
//         final data = e.response!.data;
//
//         if (statusCode == 401) {
//           errorMessage = "Incorrect email or password";
//         } else if (statusCode == 400) {
//           errorMessage = data['message'] ?? "Invalid input data";
//         } else if (statusCode == 403 && data['message']?.toLowerCase().contains('email not verified') == true) {
//           errorMessage = "Please verify your email before logging in";
//           navigationService.navigateTo(verifyEmailView);
//         } else {
//           errorMessage = data['message'] ?? "Server error, please try again later";
//         }
//       } else {
//         errorMessage = "Network error, please check your connection";
//       }
//       showCustomToasts(errorMessage, success: false);
//     } catch (e) {
//       showCustomToasts("Unexpected error: ${e.toString()}", success: false);
//     } finally {
//       isLoading.value = false;
//       notifyListeners();
//     }
//   }
//
//   void goToSignUpView() {
//     print("Navigating to signupRoute");
//     navigationService.navigateTo(signUpScreenRoute);
//   }
//
//   void goToForgotPasswordView() {
//     print("Navigating to forgotPasswordRoute");
//     navigationService.navigateTo(forgetPasswordRoute);
//   }
//
//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     isFormValid.dispose();
//     isLoading.dispose(); // Dispose isLoading
//     super.dispose();
//   }
// }

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
  bool _isChecked = false;
  bool get isChecked => _isChecked;

  void onInit() {
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

  void onCheckedChanged(bool value) {
    _isChecked = value;
    notifyListeners();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate() || !isFormValid.value) {
      print("Form validation failed");
      showCustomToast("Please fill all required fields");
      return;
    }

    startLoader(message: "Logging in..."); // Use BaseViewModel's startLoader

    try {
      var userData = Customer(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("Attempting login with: ${userData.email}");
      final response = await authRepository.login(customer: userData);
      print("Login response: ${response.toJson()}");

      if (response.success == true) {
        await customerService.storeToken(response);
        appCache.registerResponse = response;

        if (response.data?.user?.emailVerified == false) {
          print("Email not verified, navigating to verifyEmailView");
          navigationService.navigateTo(verifyEmailView);
          showCustomToast("Please verify your email");
          return;
        }

        await customerService.checkUserSetup();

        if (customerService.stores.isEmpty) {
          print("No stores found, navigating to createStoreRoute");
          navigationService.navigateToAndRemoveUntil(createStoreRoute);
          return;
        }

        print("Login successful, navigating to dashboardRoute");
        navigationService.navigateToAndRemoveUntil(dashboardRoute);
        showCustomToast("Login successful", success: true);
      } else {
        print("Login failed: Response success is false");
        showCustomToast("Login failed: Invalid response");
      }
    } on DioException catch (e) {
      print("Caught DioException in LoginViewModel: ${e.message}");
      String errorMessage = "An error occurred during login";
      if (e.response != null && e.response!.data is Map) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data as Map;
        print("Login Dio Error: $data");
        errorMessage = data['message'] ?? "Server error: $statusCode";
        if (statusCode == 401 ||
            data['message']?.toLowerCase().contains('email not verified') ==
                true) {
          print(
              "Email not verified or unauthorized, navigating to verifyEmailView");
          navigationService.navigateTo(verifyEmailView);
        }
      } else {
        errorMessage = "Network error, please check your connection";
      }
      print("Calling showCustomToast with: $errorMessage");
      showCustomToast(errorMessage);
    } catch (e) {
      print("Unexpected error in LoginViewModel: $e");
      showCustomToast("Unexpected error during login");
    } finally {
      stopLoader(); // Use BaseViewModel's stopLoader
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
