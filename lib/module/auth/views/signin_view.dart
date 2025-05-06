import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/module/auth/viewmodel/signin_vm.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../constants/assets.dart';
import '../../../constants/style.dart';
import '../../../utils/string_extension.dart';

class SigninView extends StatelessWidget {
  const SigninView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SignInViewModel>(
      onModelReady: (model) => model.init(), // Initialize the ViewModel
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: InkWell(
            onTap: navigationService.goBack,
            child: SvgPicture.asset(SvgAssets.arrowBack),
          ),
        ),
        backgroundColor: ColorValues.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: model.formKey, // Attach the form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: SvgPicture.asset(SvgAssets.appLogo),
                  ),
                  20.0.sbH,
                  AppText(
                    StringValues.enterPaswordLogin,
                    align: TextAlign.center,
                  ),
                  20.0.sbH,
                  AppTextField(
                    hint: StringValues.enterEmail,
                    controller: model.emailNameController,
                    validator: emailValidator,
                    onChanged: (value) => model.onChange(), // Trigger onChange
                  ),
                  30.0.sbH,
                  AppTextField(
                    hint: StringValues.enterPassword,
                    controller: model.passwordNameController,
                    isPassword: true,
                    //validator: passwordValidator,
                    onChanged: (value) => model.onChange(), // Trigger onChange
                  ),
                  60.0.sbH,
                  model.isLoading.value
                      ? const SpinKitCircle(
                          color: Colors.white,
                          size: 50.0,
                        )
                      : AppButton(
                          text: StringValues.signIn,
                          onTap: model.formKey.currentState?.validate() == true
                              ? model.submit
                              : null,
                        ),
                  16.0.sbH,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          navigationService.navigateTo(forgetPasswordRoute);
                        },
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
                            // TextSpan(
                            //   text: StringValues.signUp,
                            //   style: subUnderlineGreenStyle.copyWith(
                            //       fontSize: 15.sp,
                            //       color: ColorValues.primaryColor),
                            //   recognizer: TapGestureRecognizer()
                            //     ..onTap = model.goToSignUpView(),
                            // ),
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
    );
  }
}
