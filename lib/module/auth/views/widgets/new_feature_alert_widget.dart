import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/auth/viewmodel/signin_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

class NewFeatureAlertWidget extends StatelessWidget {
   const NewFeatureAlertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SignInViewModel>(
      builder:(_,model,child) => Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            30.0.sbH,
            AppText(
              StringValues.newFeatureArt,
              style: headerTextStyle,
            ),
            30.0.sbH,
            AppText(StringValues.createAPaymentMethod),
            20.0.sbH,
            RichText(
              text: TextSpan(
                text: StringValues.learnToUse,
                style: normalTextStyle12,
                children: <TextSpan>[
                  TextSpan(
                      text: StringValues.click,
                      style: normalTextStyle12.copyWith(color: Colors.black)),
                  TextSpan(
                      text: StringValues.toWatchTutorials,
                      style: normalTextStyle12),
                ],
              ),
            ),
            20.0.sbH,
            AppButton(
              text: StringValues.addPaymentMethod,
              onTap: () {},
            ),
            20.0.sbH,
            TextButton(onPressed: () {}, child: AppText(StringValues.dismiss)),
            30.0.sbH,
           Row(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               Checkbox(
                 checkColor: Colors.white,
                 value: model.isChecked,
                 onChanged: (bool? value) {
                   model.oncheckedChanged(value!);
                 },
               ),
               20.0.sbW,
               AppText(StringValues.dontShowAgain, style: normalTextStyle,)
             ],
           )
          ],
        ),
      ),
    );
  }
}
