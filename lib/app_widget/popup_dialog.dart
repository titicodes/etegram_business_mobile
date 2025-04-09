import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/reuseable.dart';
import 'app_button.dart';
import 'app_text.dart';


class PopUpDialog extends StatelessWidget {
  final String title;
  final Widget? body;
  final String? subTitle;
  final String? cancelButtonText;
  final String? doItButtonText;
  final VoidCallback? otherOnTap;
  final Widget? prefixIcon1;
  final Widget? prefixIcon2;
  final Function onTap;
  const PopUpDialog({super.key, required this.title, this.body, this.subTitle, this.cancelButtonText, this.doItButtonText, this.otherOnTap, this.prefixIcon1, this.prefixIcon2, required this.onTap});

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
              AppText(title, size: 20.sp, weight: FontWeight.w600, align: TextAlign.center,),
              16.0.sbH,
              Padding(
                padding: 16.0.padH,
                child: AppText(
                  subTitle??"Are you sure you want to ${title.toLowerCase()}?",
                  color: const Color(0xFF6B6B6B),
                  size: 12.sp,
                  align: TextAlign.center,
                ),
              ),
              50.0.sbH,
              body??Row(
                children: [
                  Expanded(
                      child: AppButton(
                        isTransparent: true,
                        borderColor: Colors.red,
                        text: cancelButtonText?? "No",
                        textColor: Colors.red,
                        onTap: otherOnTap?? navigationService.goBack,
                      )
                  ),
                  29.0.sbW,
                  Expanded(
                      child: AppButton(
                        text: doItButtonText?? "Yes",
                        onTap: ()async{
                          navigationService.goBack();
                          onTap();
                        },
                        textColor: Colors.white,
                        borderWidth: 2,
                        backGroundColor: ColorValues.primaryColor,
                      )
                  ),
                ],
              ),
              40.0.sbH,
            ],
          ),
        )
      ],
    );
  }
}
