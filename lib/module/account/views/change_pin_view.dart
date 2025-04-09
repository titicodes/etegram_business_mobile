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
import 'package:flutter/services.dart';

import '../viewmodel/change_pin_vm.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ChangePinViewModel>(
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
              // Wrap your Column with a Form Widget.
              key: logic.formKey, // Assign the formKey.
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
                    controller: logic.pinCodeController,
                    maxLength: 4,
                    onChanged: logic.onChange,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(4),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Old Pin cannot be empty";
                      }
                      return null;
                    },
                  ),
                  16.0.sbH,
                  20.0.sbH,
                  AppTextField(
                    prefix: const Icon(Icons.lock_person_rounded),
                    hint: StringValues.newPassword,
                    isPassword: true,
                    controller: logic.newPinController,
                    maxLength: 4,
                    onChanged: logic.onChange,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(4),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "New Pin cannot be empty";
                      }
                      return null;
                    },
                  ),
                  20.0.sbH,
                  AppTextField(
                    prefix: const Icon(Icons.lock_person_rounded),
                    hint: StringValues.confirmPassword,
                    isPassword: true,
                    controller: logic.confirmNewPinController,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(4),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (val) {
                      if (logic.confirmNewPinController.text.trim().isEmpty) {
                        return "Confirm Pin cannot be empty";
                      } else if (logic.confirmNewPinController.text.trim() !=
                          logic.newPinController.text.trim()) {
                        return "Confirm Pin must be the same as Pin";
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              20.0.sbH,
              AppButton(
                text: "Change Pin",
                backGroundColor: logic.isFormValid
                    ? ColorValues.primaryColor
                    : Colors.grey, // Disable color when form is invalid
                onTap: logic.isFormValid ? logic.submit : null, // Disable button if form is invalid
                isLoading: logic.isLoading,
              ),
            ],
          ),
        ),

      ),
    );
  }
}
