// import 'package:etegram_business/app_widget/app_button.dart';
// import 'package:etegram_business/app_widget/app_text.dart';
// import 'package:etegram_business/app_widget/custom_appbar.dart';
// import 'package:etegram_business/app_widget/input_fields.dart';
// import 'package:etegram_business/base/base_ui.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/constants/strings.dart';
// import 'package:etegram_business/constants/style.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
//
// import '../viewmodel/change_password_vm.dart';
//
// class ChangePasswordView extends StatelessWidget {
//   const ChangePasswordView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseView<ChangePasswordViewModel>(
//       builder: (_, logic, child) => Scaffold(
//         extendBody: true,
//         backgroundColor: ColorValues.backgroundColor,
//         appBar: CustomAppBar(
//           title: StringValues.changePassword,
//           onBackPressed: () {
//             navigationService.goBack();
//           },
//           showNotificationIcon: false,
//           showMenuIcon: true,
//           onMenuPressed: () {},
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Form(
//               key: logic.formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   20.0.sbH,
//                   AppText(
//                     StringValues.fillChangedPasswordForm,
//                     style: normalTextStyle,
//                   ),
//                   30.0.sbH,
//                   AppTextField(
//                     prefix: const Icon(Icons.lock_person_rounded),
//                     hint: StringValues.oldPassword,
//                     isPassword: true,
//                     controller: logic.oldPasswordController,
//                     onChanged: logic.onChange,
//                     keyboardType: TextInputType.text,
//                     validator: (val) {
//                       if (val == null || val.isEmpty) {
//                         return "Old Password cannot be empty";
//                       }
//                       return null;
//                     },
//                   ),
//                   16.0.sbH,
//                   AppTextField(
//                     prefix: const Icon(Icons.lock_person_rounded),
//                     hint: StringValues.newPassword,
//                     isPassword: true,
//                     controller: logic.newPasswordController,
//                     onChanged: logic.onChange,
//                     keyboardType: TextInputType.text,
//                     validator: (val) {
//                       if (val == null || val.isEmpty) {
//                         return "New Password cannot be empty";
//                       }
//                       final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$');
//                       if (!passwordRegex.hasMatch(val)) {
//                         return "Password must be at least 8 characters, include a capital letter, a number, and a special character";
//                       }
//                       return null;
//                     },
//                   ),
//                   20.0.sbH,
//                   AppTextField(
//                     prefix: const Icon(Icons.lock_person_rounded),
//                     hint: StringValues.confirmPassword,
//                     isPassword: true,
//                     controller: logic.confirmNewPasswordController,
//                     onChanged: logic.onChange,
//                     keyboardType: TextInputType.text,
//                     validator: (val) {
//                       if (val == null || val.isEmpty) {
//                         return "Confirm Password cannot be empty";
//                       } else if (val != logic.newPasswordController.text.trim()) {
//                         return "Confirm Password must match New Password";
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         bottomNavigationBar: Container(
//           width: MediaQuery.of(context).size.width,
//           height: 184,
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//           child: Column(
//             children: [
//               20.0.sbH,
//               AppButton(
//                 text: "Change Password",
//                 backGroundColor: logic.isFormValid
//                     ? ColorValues.primaryColor
//                     : Colors.grey,
//                 onTap: logic.isFormValid ? logic.submit : null,
//                 isLoading: logic.isLoading.value,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

import '../viewmodel/change_password_vm.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ChangePasswordViewModel>(
      builder: (_, logic, child) => Scaffold(
        extendBody: true,
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: StringValues.changePassword,
          onBackPressed: () {
            navigationService.goBack();
          },
          showNotificationIcon: false,
          showMenuIcon: true,
          onMenuPressed: () {},
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: logic.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  20.0.sbH,
                  AppText(
                    StringValues.fillChangedPasswordForm,
                    style: normalTextStyle,
                  ),
                  30.0.sbH,
                  AppTextField(
                    prefix: const Icon(Icons.lock_person_rounded),
                    hint: StringValues.oldPassword,
                    isPassword: true,
                    controller: logic.oldPasswordController,
                    onChanged: logic.onChange,
                    keyboardType: TextInputType.text,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Old Password cannot be empty";
                      }
                      return null;
                    },
                  ),
                  16.0.sbH,
                  AppTextField(
                    prefix: const Icon(Icons.lock_person_rounded),
                    hint: StringValues.newPassword,
                    isPassword: true,
                    controller: logic.newPasswordController,
                    onChanged: logic.onChange,
                    keyboardType: TextInputType.text,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "New Password cannot be empty";
                      }
                      final passwordRegex = RegExp(
                          r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$');
                      if (!passwordRegex.hasMatch(val.trim())) {
                        return "Password must be at least 8 characters, include a capital letter, a number, and a special character";
                      }
                      return null;
                    },
                  ),
                  20.0.sbH,
                  AppTextField(
                    prefix: const Icon(Icons.lock_person_rounded),
                    hint: StringValues.confirmPassword,
                    isPassword: true,
                    controller: logic.confirmNewPasswordController,
                    onChanged: logic.onChange,
                    keyboardType: TextInputType.text,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Confirm Password cannot be empty";
                      }
                      if (val.trim() !=
                          logic.newPasswordController.text.trim()) {
                        return "Confirm Password must match New Password";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: 184,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              20.0.sbH,
              AppButton(
                text: "Change Password",
                backGroundColor:
                    logic.isFormValid ? ColorValues.primaryColor : Colors.grey,
                onTap: logic.isFormValid ? logic.submit : null,
                isLoading: logic.isLoading.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
