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
//   bool _isChecked = false;
//   bool get isChecked => _isChecked;
//
//   void onInit() {
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
//   void onCheckedChanged(bool value) {
//     _isChecked = value;
//     notifyListeners();
//   }
//
//   Future<void> submit() async {
//     if (!formKey.currentState!.validate() || !isFormValid.value) {
//       print("Form validation failed");
//       showCustomToast("Please fill all required fields");
//       return;
//     }
//
//     startLoader(message: "Logging in...");
//
//     try {
//       var userData = Customer(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
//
//       print("Attempting login with: ${userData.email}");
//       final response = await authRepository.login(customer: userData);
//       print("Login response: ${response.toJson()}");
//
//       if (response.success == true) {
//         await customerService.storeToken(response);
//         appCache.registerResponse = response;
//
//         if (response.data?.user?.emailVerified == false) {
//           print("Email not verified, navigating to verifyEmailView");
//           navigationService.navigateTo(verifyEmailView);
//           showCustomToast("Please verify your email");
//           return;
//         }
//
//         await customerService.checkUserSetup();
//
//         if (customerService.stores.isEmpty) {
//           print("No stores found, navigating to createStoreRoute");
//           navigationService.navigateToAndRemoveUntil(createStoreRoute);
//           return;
//         }
//
//         print("Login successful, navigating to dashboardRoute");
//         navigationService.navigateToAndRemoveUntil(dashboardRoute);
//         showCustomToast("Login successful", success: true);
//       } else {
//         print("Login failed: Response success is false");
//         showCustomToast("Login failed: Invalid response");
//       }
//     } on DioException catch (e) {
//       print("Caught DioException in LoginViewModel: ${e.message}");
//       String errorMessage = "An error occurred during login";
//       if (e.response != null && e.response!.data is Map) {
//         final statusCode = e.response!.statusCode;
//         final data = e.response!.data as Map;
//         print("Login Dio Error: $data");
//         errorMessage = data['message'] ?? "Server error: $statusCode";
//         if (statusCode == 401 ||
//             data['message']?.toLowerCase().contains('email not verified') ==
//                 true) {
//           print(
//               "Email not verified or unauthorized, navigating to verifyEmailView");
//           navigationService.navigateTo(verifyEmailView);
//         }
//       } else {
//         errorMessage = "Network error, please check your connection";
//       }
//       print("Calling showCustomToast with: $errorMessage");
//       showCustomToast(errorMessage);
//     } catch (e) {
//       print("Unexpected error in LoginViewModel: $e");
//       showCustomToast("Unexpected error during login");
//     } finally {
//       stopLoader();
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

  Future<void> onInit() async {
    if (appCache.isRememberMeEnabled) {
      emailController.text = (await appCache.getRememberedEmail()) ?? '';
      passwordController.text = (await appCache.getRememberedPassword()) ?? '';
      _isChecked = true;
    }
    emailController.addListener(validateForm);
    passwordController.addListener(validateForm);
    notifyListeners();
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

    startLoader(message: "Logging in...");

    try {
      var userData = Customer(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("Attempting login with: ${userData.email}");
      final response = await authRepository.login(customer: userData);
      print("Login response: ${response.toJson()}");

      if (response.success == true) {
        // Save credentials if "Remember Me" is checked
        appCache.saveCredentials(
          userData.email??'',
          userData.password??'',
          isChecked,
        );

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

        if (statusCode == 401) {
          if (data['message']?.toLowerCase().contains('email not verified') == true) {
            print("Email not verified, navigating to verifyEmailView");
            navigationService.navigateTo(verifyEmailView);
            errorMessage = "Please verify your email";
          } else {
            errorMessage = "Invalid email or password";
          }
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
      stopLoader();
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