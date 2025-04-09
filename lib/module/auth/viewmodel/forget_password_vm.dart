import 'package:etegram_business/module/auth/views/verify_email_view.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:flutter/material.dart';
import '../../../app_widget/bottom_sheet.dart';
import '../../../base/base_vm.dart';
import '../../../utils/snack_message.dart';

class ForgetPasswordViewModel extends BaseViewModel {
  late BuildContext context;

  init(BuildContext contexts) {
    context = contexts;
  }

  onChange(String? val) {
    formKey.currentState?.validate();
    notifyListeners();
  }

  var emailController = TextEditingController();

  submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    // ✅ Validate email
    if (emailController.text.isEmpty ||
        !emailController.text.trim().isValidEmail()) {
      showCustomToast("Please enter a valid email!", success: false);
      return;
    }

    startLoader();
    try {
      // ✅ Send only the email, not a Map
      var response = await authRepository.forgetPassword(
          email: emailController.text.trim());

      stopLoader();

      if (response == true) {
       // appCache.forgetPasswordResponse = response!;
        appCache.email = emailController.text.trim();

        showCustomToast("OTP sent to ${emailController.text.trim()}",
            success: true);

        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          builder: (_) => const BottomSheetScreen(child: VerifyEmailView()),
        );
      }
    } catch (err) {
      stopLoader();
      showCustomToast("Failed to send OTP. Try again.", success: false);
    }
    stopLoader();
  }
}
