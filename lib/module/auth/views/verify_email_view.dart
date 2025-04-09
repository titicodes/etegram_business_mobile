import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/module/auth/viewmodel/verify_email.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../app_widget/app_button.dart';
import '../../../app_widget/app_text.dart';
import '../../../base/base_ui.dart';
import '../../../constants/style.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<VerifyEmailViewModel>(
      onModelReady: (model) async => await model.verifyOTP(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar(
          title: "verify phone number".toTitleCase(),
          onBackPressed: () {
            navigationService.goBack();
          },
        ),
        body: Padding(
          padding: 16.0.padH,
          child: Form(
            key: model.formKey,
            child: ListView(
              children: [
                20.0.sbH,
                PinCodeTextField(
                  length: 6,
                  textStyle: bodyTextStyle2.copyWith(fontSize: 20), // Reduced font size
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  obscureText: false,
                  autoFocus: true,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 60, // Reduced field height
                    fieldWidth: (width(context) - 60) / 6, // Reduced field width and adjusted calculation
                    inactiveFillColor: Colors.transparent,
                    inactiveColor:
                    Theme.of(context).disabledColor.withOpacity(0.3),
                    selectedFillColor: Colors.transparent,
                    selectedColor: Theme.of(context).primaryColor,
                    activeColor: Colors.transparent,
                    activeFillColor:
                    Theme.of(context).iconTheme.color?.withOpacity(0.1),
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  controller: model.pinCodeController,
                  enableActiveFill: true,
                  validator: (val) {
                    if (model.pinCodeController.text.trim().length != 6) {
                      return "Pin Code must be 6 characters";
                    } else {
                      return null;
                    }
                  },
                  onChanged: model.onChange,
                  beforeTextPaste: (text) {
                    print("Allowing to paste $text");
                    return true;
                  },
                  appContext: context,
                ),
                12.0.sbH,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: StringValues.enterOTP,
                            style: subStyle.copyWith(fontSize: 15),
                          ),
                          TextSpan(
                            text: "${model.appCache.phoneNumber}",
                            style: subStyle.copyWith(
                                fontSize: 15, color: ColorValues.primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                print('Details tapped!');
                              },
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                32.0.sbH,
                AppButton(
                  text: "Verify & Proceed",
                  onTap: model.formKey.currentState?.validate() != true
                      ? null
                      : model.verifyOTP,
                ),
                16.0.sbH,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: StringValues.didntReceive,
                            style: subStyle.copyWith(fontSize: 15),
                          ),
                          model.timer?.isActive == true
                              ? TextSpan(
                            text:
                            "Wait ${model.formatTime(model.secondsRemaining)} mins",
                            style: normalTextStyle.copyWith(fontSize: 15),
                          )
                              : TextSpan(
                            text: "Resend OTP",
                            style: subUnderlineGreenStyle.copyWith(
                                fontSize: 15, color:ColorValues.primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = model.verifyOTP,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                30.0.sbH,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: navigationService.goBack,
                      child: AppText(
                        "Wrong Email?",
                        style: subUnderlineGreenStyle.copyWith(fontSize: 15),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}