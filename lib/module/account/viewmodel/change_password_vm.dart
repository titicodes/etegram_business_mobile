import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../app_widget/bottom_sheet.dart';
import '../../../app_widget/success_pupup_widget.dart';
import '../../../base/base_vm.dart';
import '../../../constants/reuseable.dart';
import '../../../utils/snack_message.dart';

class ChangePasswordViewModel extends BaseViewModel {
  var oldPasswordController = TextEditingController();
  var newPasswordController = TextEditingController();
  var confirmNewPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Timer? _debounce;

  bool isFormValid = false;

  ChangePasswordViewModel() {
    // Listen to input changes
    oldPasswordController.addListener(_validateForm);
    newPasswordController.addListener(_validateForm);
    confirmNewPasswordController.addListener(_validateForm);
  }

  void onChange(String? val) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _validateForm);
  }

  void _validateForm() {
    isFormValid = formKey.currentState?.validate() ?? false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _validatePassword(String password) async {
    return await compute(_checkPassword, password);
  }

  static bool _checkPassword(String password) {
    final passwordRegex =
        RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> submit() async {
    if (!isFormValid || !formKey.currentState!.validate()) {
      showCustomToast("Please fill out all fields correctly.", success: false);
      return;
    }

    final userId = userService.customer?.id;
    if (userId == null || userId.isEmpty) {
      showCustomToast("User not logged in. Please log in again.",
          success: false);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    startLoader();

    try {
      var response = await authRepository.changePassword(
        userId: userId,
        newPassword: newPasswordController.text.trim(),
        oldPassword: oldPasswordController.text.trim(),
      );
      if (response == true) {
        showCustomToast("Password Changed Successfully", success: true);
        await showSuccessPopup();
      } else {
        showCustomToast("Failed to change password.", success: false);
      }
    } catch (err) {
      print("ChangePasswordViewModel: Error changing password: $err");
      showCustomToast("Failed to change password: $err", success: false);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> showSuccessPopup() async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: navigationService.navigatorKey.currentState!.context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
        child: SuccessfulPopUpWidget(
          title: "Password changed successfully!",
          subTitle: "Your password has been changed successfully.",
          onTap: navigationService.goBack,
        ),
      ),
    );
    navigationService.goBack();
  }
}
