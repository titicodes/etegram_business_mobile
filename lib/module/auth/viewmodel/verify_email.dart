import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../base/base_vm.dart';
import '../../../routes/routes.dart';
import '../../../utils/snack_message.dart';

class VerifyEmailViewModel extends BaseViewModel {
  var pinCodeController = TextEditingController();
  String pinID = "";

  int secondsRemaining = 60;
  Timer? timer;
  String email = "";
  int? code;

  String formatTime(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String formattedTime =
    DateFormat('mm:ss').format(DateTime(0, 1, 1, 0, 0, 0).add(duration));
    return formattedTime;
  }

  startTimer() {
    const oneSecond = Duration(seconds: 1);
    secondsRemaining = 60;
    timer = Timer.periodic(oneSecond, (Timer timer) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel(); // Stop the timer when it reaches 0
        notifyListeners();
      }
    });
    print(secondsRemaining);
  }

  onChange(String? val) {
    formKey.currentState?.validate();
    notifyListeners();
  }

  goToUserLogin() {
    navigationService.navigateTo(loginScreenRoute);
  }

  verifyOTP() async {
    startLoader();
    try {
      // Get the email from appCache.userData.email
      String email = appCache.userData.email ?? "";

      // Get the code from the pinCodeController.text and convert it to int
      int code = int.tryParse(pinCodeController.text) ?? 0;

      var response =
      await authRepository.verifyEmail(email: email, code: code);
      stopLoader();
      if (response?.success == true) {
        showCustomToast("Account Verified Successfully", success: true);

        navigationService.navigateToAndRemoveUntil(loginScreenRoute);
      }
      notifyListeners();
    } catch (err) {
      stopLoader();
      notifyListeners();
    }
  }
}
