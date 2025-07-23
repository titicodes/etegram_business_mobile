//
//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../../../base/base_vm.dart';
// import '../../../routes/routes.dart';
// import '../../../utils/snack_message.dart';
//
// class VerifyEmailViewModel extends BaseViewModel {
//   var pinCodeController = TextEditingController();
//   int secondsRemaining = 60;
//   Timer? timer;
//   String email = "";
//
//   bool _isDisposed = false;
//
//   String formatTime(int seconds) {
//     Duration duration = Duration(seconds: seconds);
//     return DateFormat('mm:ss').format(DateTime(0, 1, 1, 0, 0, 0).add(duration));
//   }
//
//   void startTimer() {
//     const oneSecond = Duration(seconds: 1);
//     secondsRemaining = 60;
//     timer?.cancel();
//     timer = Timer.periodic(oneSecond, (Timer t) {
//       if (secondsRemaining > 0) {
//         secondsRemaining--;
//         if (!_isDisposed) notifyListeners();
//       } else {
//         t.cancel();
//         if (!_isDisposed) notifyListeners();
//       }
//     });
//   }
//
//   void onChange(String? val) {
//     formKey.currentState?.validate();
//     if (!_isDisposed) notifyListeners();
//   }
//
//   void goToUserLogin() {
//     navigationService.navigateTo(loginScreenRoute);
//   }
//
//   Future<void> verifyOTP() async {
//     if (!formKey.currentState!.validate()) return;
//
//     startLoader();
//     try {
//       String email = appCache.userData.email ?? "";
//       int code = int.tryParse(pinCodeController.text) ?? 0;
//
//       var response = await authRepository.verifyEmail(email: email, code: code);
//       stopLoader();
//       if (response?.success == true) {
//         showCustomToast("Account Verified Successfully", success: true);
//         navigationService.navigateToAndRemoveUntil(loginScreenRoute);
//       } else {
//         showCustomToast("Verification failed: Invalid code");
//       }
//       if (!_isDisposed) notifyListeners();
//     } catch (e) {
//       stopLoader();
//       if (!_isDisposed) notifyListeners();
//       showCustomToast("Verification failed: $e");
//     }
//   }
//
//   Future<void> resendOTP() async {
//     startLoader();
//     try {
//       String email = appCache.userData.email ?? "";
//       var response = await authRepository.resendOTP(email: email);
//       stopLoader();
//       if (response?.success == true) {
//         showCustomToast("OTP resent successfully", success: true);
//         startTimer(); // Restart the timer
//         pinCodeController.clear(); // Clear the input field
//       } else {
//         showCustomToast("Failed to resend OTP");
//       }
//       if (!_isDisposed) notifyListeners();
//     } catch (e) {
//       stopLoader();
//       showCustomToast("Failed to resend OTP: $e");
//       if (!_isDisposed) notifyListeners();
//     }
//   }
//
//   @override
//   void onModelReady() {
//     email = appCache.userData.email ?? "";
//     startTimer();
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     timer?.cancel();
//     pinCodeController.dispose();
//     super.dispose();
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../base/base_vm.dart';
import '../../../constants/reuseable.dart';
import '../../../routes/routes.dart';
import '../../../utils/snack_message.dart';

class VerifyEmailViewModel extends BaseViewModel {
  var pinCodeController = TextEditingController();
  int secondsRemaining = 60;
  Timer? timer;
  String email = "";
  bool _isDisposed = false;

  String formatTime(int seconds) {
    Duration duration = Duration(seconds: seconds);
    return DateFormat('mm:ss').format(DateTime(0, 1, 1, 0, 0, 0).add(duration));
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    secondsRemaining = 60;
    timer?.cancel();
    timer = Timer.periodic(oneSecond, (Timer t) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        if (!_isDisposed) notifyListeners();
      } else {
        t.cancel();
        if (!_isDisposed) notifyListeners();
      }
    });
  }

  void onChange(String? val) {
    formKey.currentState?.validate();
    if (!_isDisposed) notifyListeners();
  }

  void goToUserLogin() {
    navigationService.navigateTo(loginScreenRoute);
  }

  void goToSignUpView({bool isWrongEmail = false}) {
    print("Navigating to signUpScreenRoute with isWrongEmail: $isWrongEmail");
    navigationService.navigateTo(signUpScreenRoute,
        arguments: {'isWrongEmail': isWrongEmail});
  }

  Future<void> verifyOTP() async {
    if (!formKey.currentState!.validate()) return;

    startLoader();
    try {
      String email = appCache.userData?.email ?? "";
      int code = int.tryParse(pinCodeController.text) ?? 0;

      var response = await authRepository.verifyEmail(email: email, code: code);
      stopLoader();
      if (response.success == true) {
        final box = GetStorage();
        box.remove(DbTable.customerTableName);
        appCache.userData = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCustomToast("Account Verified Successfully", success: true);
          navigationService.navigateToAndRemoveUntil(loginScreenRoute);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCustomToast("Verification failed: Invalid code");
        });
      }
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      stopLoader();
      if (!_isDisposed) notifyListeners();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomToast("Verification failed: $e");
      });
    }
  }

  Future<void> resendOTP() async {
    startLoader();
    try {
      String email = appCache.userData?.email ?? "";
      var response = await authRepository.resendOTP(email: email);
      stopLoader();
      if (response.success == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCustomToast("OTP resent successfully", success: true);
        });
        startTimer();
        pinCodeController.clear();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCustomToast("Failed to resend OTP");
        });
      }
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      stopLoader();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomToast("Failed to resend OTP: $e");
      });
      if (!_isDisposed) notifyListeners();
    }
  }

  @override
  void onModelReady() {
    email = appCache.userData?.email ?? "";
    startTimer();
  }

  @override
  void dispose() {
    _isDisposed = true;
    timer?.cancel();
    pinCodeController.dispose();
    super.dispose();
  }
}
