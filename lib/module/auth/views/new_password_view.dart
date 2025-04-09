import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app_widget/app_button.dart';
import '../../../app_widget/app_text.dart';
import '../../../app_widget/input_fields.dart';
import '../../../base/base_ui.dart';
import '../../../constants/style.dart';
import '../viewmodel/new_password_vm.dart';

class NewPasswordView extends StatelessWidget {
  const NewPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return OtherView<NewPasswordViewModel>(
      builder: (_, model, child) => Scaffold(
        body: Form(
          key: model.formKey,
          child: Column(
            children: [
              Padding(
                padding: 16.0.padH,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      "Create New Password".toTitleCase(),
                      size: 20.sp,
                      weight: FontWeight.w600,
                    ),
                    5.0.sbH,
                    AppText(
                      StringValues.createNewPassword,
                      style: subStyle.copyWith(
                          color: ColorValues.primaryDarkColor),
                      align: TextAlign.center,
                    ),
                    34.0.sbH,

                    // ✅ Email Field
                    AppTextField(
                      hint: "Enter your email",
                      prefix: const Icon(Icons.email),
                      controller: model.emailController,
                      onChanged: model.onChange,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Email cannot be empty";
                        } else if (!val.isValidEmail()) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    8.0.sbH,

                    // ✅ OTP Field
                    AppTextField(
                      hint: "Enter OTP Code",
                      keyboardType: TextInputType.number,
                      prefix: const Icon(Icons.security),
                      controller: model.otpController,
                      onChanged: model.onChange,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "OTP Code cannot be empty";
                        }
                        return null;
                      },
                    ),
                    8.0.sbH,

                    // ✅ Password Field
                    AppTextField(
                      hint: "Create new password",
                      isPassword: true,
                      prefix: const Icon(Icons.lock),
                      controller: model.passwordController,
                      onChanged: model.onChange,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Password cannot be empty";
                        }
                        return null;
                      },
                    ),
                    8.0.sbH,

                    // ✅ Confirm Password Field
                    AppTextField(
                      hint: "Confirm new password",
                      isPassword: true,
                      prefix: const Icon(Icons.lock),
                      controller: model.confirmPasswordController,
                      onChanged: model.onChange,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Confirm Password cannot be empty";
                        } else if (val.trim() !=
                            model.passwordController.text.trim()) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                    30.0.sbH,

                    // ✅ Submit Button
                    AppButton(
                      text: "Confirm",
                      onTap: model.formKey.currentState?.validate() != true
                          ? null
                          : model.submit,
                    ),
                    30.0.sbH,
                  ],
                ),
              ),
              model.isLoading ? const SmallLoader() : 0.0.sbH,
            ],
          ),
        ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: 184,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          color: Colors.white,
          child: Column(
            children: [
              20.0.sbH,
              AppButton(
                text: "Confirm",
                onTap: model.formKey.currentState?.validate() != true
                    ? null
                    : model.submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
