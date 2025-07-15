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
//   bool _isChecked = false; // Commented out as unused in SigninView
//   bool get isChecked => _isChecked;
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
//   // Future<void> submit() async {
//   //   if (!formKey.currentState!.validate() || !isFormValid.value) {
//   //     showCustomToast("Please fill all required fields");
//   //     return;
//   //   }
//   //
//   //   startLoader();
//   //   try {
//   //     var userData = Customer(
//   //       email: emailController.text.trim(),
//   //       password: passwordController.text.trim(),
//   //     );
//   //
//   //     final response = await authRepository.login(customer: userData);
//   //
//   //     if (response?.success == true) {
//   //       await customerService.storeToken(response);
//   //       appCache.registerResponse = response ?? AuthResponse();
//   //
//   //       if (response?.data?.user?.emailVerified == false) {
//   //         navigationService.navigateTo(verifyEmailView);
//   //         showCustomToast("Please verify your email");
//   //         return;
//   //       }
//   //
//   //       // Setup check
//   //       await customerService.checkUserSetup();
//   //
//   //       // 🔍 Add store check here if no navigation occurred
//   //       if (customerService.stores.isEmpty) {
//   //         print(
//   //             "LoginViewModel: No stores found. Navigating to createStoreRoute.");
//   //         navigationService.navigateToAndRemoveUntil(createStoreRoute);
//   //         return;
//   //       }
//   //
//   //       // checkUserSetup will already handle dashboard or addPaymentMethod navigation
//   //     } else {
//   //       showCustomToast(response?.message ?? "Login failed");
//   //     }
//   //   } catch (e) {
//   //     showCustomToast("Login failed: $e");
//   //   } finally {
//   //     stopLoader();
//   //     notifyListeners();
//   //   }
//   // }
//
//   Future<void> submit(BuildContext context) async {
//     if (!formKey.currentState!.validate() || !isFormValid.value) {
//       showCustomToast("Please fill all required fields", context: context);
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
//           showCustomToast("Please verify your email", context: context);
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
//         showCustomToast(response?.message ?? "Login failed", context: context);
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
//       showCustomToast(errorMessage, context: context);
//     } catch (e) {
//       showCustomToast("Unexpected error: ${e.toString()}", context: context);
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
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false); // Added isLoading
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

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate() || !isFormValid.value) {
      showCustomToasts("Please fill all required fields", success: false);
      return;
    }

    isLoading.value = true;
    notifyListeners();

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
          showCustomToasts("Please verify your email", success: false);
          return;
        }

        // Setup check
        await customerService.checkUserSetup();

        if (customerService.stores.isEmpty) {
          print("LoginViewModel: No stores found. Navigating to createStoreRoute.");
          navigationService.navigateToAndRemoveUntil(createStoreRoute);
          return;
        }

        // checkUserSetup handles dashboard or addPaymentMethod navigation
      } else {
        showCustomToasts(response?.message ?? "Login failed", success: false);
      }
    } on DioException catch (e) {
      String errorMessage = "An error occurred during login";
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;

        if (statusCode == 401) {
          errorMessage = "Incorrect email or password";
        } else if (statusCode == 400) {
          errorMessage = data['message'] ?? "Invalid input data";
        } else if (statusCode == 403 && data['message']?.toLowerCase().contains('email not verified') == true) {
          errorMessage = "Please verify your email before logging in";
          navigationService.navigateTo(verifyEmailView);
        } else {
          errorMessage = data['message'] ?? "Server error, please try again later";
        }
      } else {
        errorMessage = "Network error, please check your connection";
      }
      showCustomToasts(errorMessage, success: false);
    } catch (e) {
      showCustomToasts("Unexpected error: ${e.toString()}", success: false);
    } finally {
      isLoading.value = false;
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
    isLoading.dispose(); // Dispose isLoading
    super.dispose();
  }
}