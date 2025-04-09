import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/colors.dart';
import '../constants/reuseable.dart';
import '../constants/style.dart';
import 'app_button.dart';


class SuccessfulPopUpWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String? buttonText;
  final Color? titleColor;
  final bool? removeButton;
  final VoidCallback? onTap;
  const SuccessfulPopUpWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.onTap,
    this.buttonText,
    this.removeButton,
    this.titleColor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: navigationService.goBack,
              child: Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: ColorValues.backgroundColor
                ),
                child: const Icon(Icons.clear, size: 18, color: Colors.black,),
              ),
            )
          ],
        ),
        Padding(
          padding: 16.0.padH,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 109,
                height: 109,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 109,
                      height: 109,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFE8F9F1),
                        shape: OvalBorder(),
                      ),
                    ),
                    Container(
                      width: 91.35,
                      height: 91.35,
                      alignment: Alignment.center,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF1CBF73),
                        shape: OvalBorder(),
                      ),
                      child: Icon(Icons.check, size: 48, color: ColorValues.whiteColor,),
                    )
                  ],
                ),
              ),
              24.0.sbH,
              AppText(title.toTitleCase(), size: 16.sp, weight: FontWeight.w700, color: titleColor?? ColorValues.primaryColor,),
              5.0.sbH,
              Padding(
                padding: 22.0.padH,
                child: AppText(
                  subTitle,
                  style: subStyle.copyWith(color: ColorValues.appTextColor),
                  align: TextAlign.center,
                ),
              ),
              60.0.sbH,
              removeButton== true? 0.0.sbH: AppButton(
                text: buttonText?? "back home".toTitleCase(),
                backGroundColor: ColorValues.primaryColor,
                onTap:  onTap,
              ),
              30.0.sbH,
            ],
          ),
        )
      ],
    );
  }
}
