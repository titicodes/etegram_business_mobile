import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/module/auth/viewmodel/forget_password_vm.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_widget/app_button.dart';
import '../../../constants/strings.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ForgetPasswordViewModel>(
      builder: (_, vm, child) => Scaffold(
        appBar: CustomAppBar(
          title: "Forget Password",
          onBackPressed: () {
            navigationService.goBack();
          },
          showMenuIcon: false,
          showNotificationIcon: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: vm.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Enter your registered email to receive an OTP."),
                SizedBox(height: 16),

                // ✅ Updated to Email Field
                AppTextField(
                  controller: vm.emailController,
                  keyboardType: TextInputType.emailAddress,
                  hint: "Email",
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.isValidEmail()) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24),

              ],
            ),
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
                text: StringValues.save,
                onTap: vm.submit,
              )
            ],
          ),
        ),
      ),
    );
  }
}
