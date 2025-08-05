import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            100.0.sbH,
            AppText(StringValues.letGetScanning, style: subHeaderTextStyle,),
            10.0.sbH,
            AppText(StringValues.letGetScanSub, style: normalTextStyle12, align: TextAlign.center,),
            40.0.sbH,
            SvgPicture.asset(SvgAssets.onboarding4),
            100.0.sbH,
            AppButton(
              text: StringValues.signUp,
              onTap: (){
                navigationService.navigateTo(signUpScreenRoute);
              },
            ),
            30.0.sbH,
            AppButton(
              isTransparent: true,
              onTap: (){
                navigationService.navigateTo(loginScreenRoute);
              },
              text: "Log In",
            ),
            32.0.sbH
          ],
        ),
      ),
    );
  }
}
