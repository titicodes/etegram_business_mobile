// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:oktoast/oktoast.dart';
//
// Widget toast(String message, {bool? success}) {
//   return Align(
//     alignment: Alignment.topCenter,
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
//       width: double.infinity,
//       // height: 40.0,
//       color: !success! ? Colors.red : ColorValues.primaryColor,
//       child: SafeArea(
//         top: true,
//         bottom: false,
//         child: Row(
//           children: [
//             if (!success)
//               const Icon(
//                 Icons.error_outline,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             10.0.sbW,
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                     color: !success ? Colors.white : Colors.white,
//                     fontSize: 13.0,
//                     fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// // styled! ?:
//
// showCustomToasts(String message, {bool success = false, num? time}) {
//   // toast message
//   showToastWidget(
//     toast(message, success: success),
//     duration: const Duration(seconds: 5),
//     onDismiss: () {},
//   );
// }
//
// void showCustomToast(
//   String message, {
//   bool success = false,
//   int durationSeconds = 3,
// }) {
//   final context = navigatorKey.currentContext;
//   if (context == null) return;
//
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(message),
//       backgroundColor: success ? Colors.green : Colors.red,
//       duration: Duration(seconds: durationSeconds),
//     ),
//   );
// }
//
// final navigatorKey = GlobalKey<NavigatorState>();

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/utils/widget_extension.dart';

Widget toast(String message, {bool? success}) {
  return Align(
    alignment: Alignment.topCenter,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      width: double.infinity,
      color: success == true ? Colors.green : Colors.red,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Row(
          children: [
            if (success != true)
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 24,
              ),
            10.0.sbW,
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showCustomToast(String message, {bool success = false}) {
  print("showCustomToast called with message: $message, success: $success");

  if (navigatorKey.currentContext != null) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor:
            success ? ColorValues.successColor : ColorValues.errorColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  } else {
    print("navigatorKey.currentContext is null, using OKToast");
    showToast(
      message,
      duration: const Duration(seconds: 3),
      position: ToastPosition.top,
      backgroundColor:
          success ? ColorValues.successColor : ColorValues.errorColor,
      radius: 8.0,
      textStyle: const TextStyle(
        fontSize: 14.0,
        color: Colors.white,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
      textPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      dismissOtherToast: true,
    );
  }
}

final navigatorKey = GlobalKey<NavigatorState>();
