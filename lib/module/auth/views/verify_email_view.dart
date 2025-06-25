// Modified VerifyEmailView
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../app_widget/app_button.dart';
import '../../../app_widget/app_text.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../base/base_ui.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';
import '../viewmodel/verify_email.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<VerifyEmailViewModel>(
      onModelReady: (model) => model.onModelReady(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar(
          title: "Verify Email",
          onBackPressed: navigationService.goBack,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: model.formKey,
            child: ListView(
              children: [
                20.0.sbH,
                PinCodeTextField(
                  length: 6,
                  textStyle: bodyTextStyle2.copyWith(fontSize: 20),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  obscureText: false,
                  autoFocus: true,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 60,
                    fieldWidth: (width(context) - 60) / 7,
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
                  validator: (val) =>
                      model.pinCodeController.text.trim().length != 6
                          ? "Pin Code must be 6 characters"
                          : null,
                  onChanged: model.onChange,
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
                              style: subStyle.copyWith(fontSize: 12)),
                          TextSpan(
                            text: model.email,
                            style: subStyle.copyWith(
                                fontSize: 12, color: ColorValues.primaryColor),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                32.0.sbH,
                model.isLoading.value
                    ? const SpinKitDoubleBounce(
                        color: ColorValues.primaryColor, size: 50.0)
                    : AppButton(
                        text: "Verify & Proceed",
                        onTap: model.formKey.currentState?.validate() == true
                            ? model.verifyOTP
                            : null,
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
                              style: subStyle.copyWith(fontSize: 15)),
                          model.timer?.isActive == true
                              ? TextSpan(
                                  text:
                                      "Wait ${model.formatTime(model.secondsRemaining)}",
                                  style: normalTextStyle.copyWith(fontSize: 15),
                                )
                              : TextSpan(
                                  text: "Resend OTP",
                                  style: subUnderlineGreenStyle.copyWith(
                                      fontSize: 15,
                                      color: ColorValues.primaryColor),
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
                Center(
                  child: InkWell(
                    onTap: model.goToUserLogin,
                    child: AppText("Wrong Email?",
                        style: subUnderlineGreenStyle.copyWith(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
