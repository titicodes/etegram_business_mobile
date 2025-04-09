import 'package:flutter/material.dart';
import '../../../base/base_vm.dart';
import '../../../utils/snack_message.dart';

class NewPasswordViewModel extends BaseViewModel {
  var emailController = TextEditingController();
  var otpController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  onChange(String? val) {
    formKey.currentState?.validate();
    notifyListeners();
  }

  Future<void> submit() async {
    startLoader();

    // Ensure all fields are filled
    if (emailController.text.isEmpty ||
        otpController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showCustomToast("All fields are required!", success: false);
      stopLoader();
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showCustomToast("Passwords do not match!", success: false);
      stopLoader();
      return;
    }

    try {
      var response = await authRepository.resetPassword(
        email: emailController.text.trim(),
        newPassword: passwordController.text.trim(),
        code: int.tryParse(otpController.text.trim()) ?? 0, // Ensure OTP is an integer
        confirmPassword: confirmPasswordController.text.trim(),
      );

      if (response == true) {
        showCustomToast( "Password reset successful!", success: true);

        // Clear fields after successful reset
        emailController.clear();
        otpController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        stopLoader();
        notifyListeners();

        // Navigate back to login
        navigationService.goBack(); // Reset Page
        navigationService.goBack(); // OTP Page
        navigationService.goBack(); // Login Page
      } else {
        showCustomToast("Failed to reset password", success: false);
        stopLoader();
        notifyListeners();
      }
    } catch (err) {
      showCustomToast("An error occurred. Please try again.", success: false);
      stopLoader();
      notifyListeners();
    }
  }

}
