import 'package:flutter/material.dart';

import '../../../app_widget/bottom_sheet.dart';
import '../../../app_widget/success_pupup_widget.dart';
import '../../../base/base_vm.dart';
import '../../../constants/reuseable.dart';
import '../../../utils/snack_message.dart';

class ChangePinViewModel extends BaseViewModel {
  var otpTextController = TextEditingController();
  var pinCodeController = TextEditingController();
  var newPinController = TextEditingController();
  var confirmNewPinController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isFormValid = false;

  ChangePinViewModel() {
    // Listen to input changes
    pinCodeController.addListener(_validateForm);
    newPinController.addListener(_validateForm);
    confirmNewPinController.addListener(_validateForm);
  }

  void onChange(String? val) {
    _validateForm();
  }

  void _validateForm() {
    isFormValid = pinCodeController.text.trim().isNotEmpty &&
        newPinController.text.trim().isNotEmpty &&
        confirmNewPinController.text.trim().isNotEmpty &&
        newPinController.text.trim() == confirmNewPinController.text.trim();
    notifyListeners();
  }

  @override
  void dispose() {
    pinCodeController.dispose();
    newPinController.dispose();
    confirmNewPinController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!isFormValid) return;

    FocusManager.instance.primaryFocus?.unfocus();
    startLoader();

    try {
      var response = await authRepository.changePin(
        userId: userService.customer?.id ?? '',
        newPin: newPinController.text.trim(),
        oldPin: pinCodeController.text.trim(),
      );
      if (response == true) {
        showCustomToast("Pin Changed Successfully", success: true);
        stopLoader();
        await showSuccessPopup();
      }
    } catch (err) {
      print(err);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  showSuccessPopup() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: navigationService.navigatorKey.currentState!.context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
        child: SuccessfulPopUpWidget(
          title: "Pin changed successfully!",
          subTitle: "Your pin has been changed successfully.",
          onTap: navigationService.goBack,
        ),
      ),
    ).whenComplete(navigationService.goBack);
  }
}
