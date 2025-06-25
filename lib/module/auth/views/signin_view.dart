import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app_widget/app_button.dart';
import '../../../app_widget/app_text.dart';
import '../../../app_widget/input_fields.dart';
import '../../../base/base_ui.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';
import '../../../routes/routes.dart';
import '../../../utils/string_extension.dart';
import '../../../utils/widget_extension.dart';
import '../viewmodel/signin_vm.dart';

class SigninView extends StatelessWidget {
  const SigninView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<LoginViewModel>(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) => SafeArea(
        child: Scaffold(
          backgroundColor: ColorValues.backgroundColor,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: model.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    30.0.sbH,
                    Center(
                      child: SvgPicture.asset(SvgAssets.appLogo),
                    ),
                    20.0.sbH,
                    AppText(
                      StringValues.signIn,
                      align: TextAlign.center,
                      style: subHeaderTextStyle,
                    ),
                    20.0.sbH,
                    AppText(
                      StringValues.enterPaswordLogin,
                      align: TextAlign.center,
                    ),
                    20.0.sbH,
                    AppTextField(
                      hint: StringValues.enterEmail,
                      controller: model.emailController,
                      validator: emailValidator,
                      onChanged: (value) => model.validateForm(),
                    ),
                    30.0.sbH,
                    AppTextField(
                      hint: StringValues.enterPassword,
                      controller: model.passwordController,
                      isPassword: true,

                      suffixIcon: IconButton(
                        icon: Icon(
                          model.showPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: model.togglePasswordVisibility,
                      ),
                      validator: passwordValidator,
                      onChanged: (value) => model.validateForm(),
                    ),
                    60.0.sbH,
                    model.isLoading.value
                        ? const SpinKitCircle(
                      color: Colors.white,
                      size: 50.0,
                    )
                        : ValueListenableBuilder<bool>(
                      valueListenable: model.isFormValid,
                      builder: (context, isValid, _) => AppButton(
                        text: StringValues.signIn,
                        onTap: isValid
                            ? () {
                          if (model.formKey.currentState!.validate()) {
                            model.submit();
                          }
                        }
                            : null,
                      ),
                    ),
                    16.0.sbH,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => model.goToForgotPasswordView(),
                          child: AppText(
                            "Forgot Password?",
                            style: subUnderlineGreenStyle.copyWith(fontSize: 15),
                          ),
                        )
                      ],
                    ),
                    16.0.sbH,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: StringValues.dontHaveAccount,
                                style: subStyle.copyWith(fontSize: 15.sp),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        InkWell(
                          onTap: () => model.goToSignUpView(),
                          child: AppText(
                            StringValues.signUp,
                            style: subUnderlineGreenStyle.copyWith(
                                fontSize: 15.sp, color: ColorValues.primaryColor),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}