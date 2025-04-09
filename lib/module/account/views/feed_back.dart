import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app_widget/app_button.dart';
import '../../../app_widget/input_fields.dart';
import '../../../constants/style.dart';

class FeedBack extends StatelessWidget {
  const FeedBack({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: StringValues.feedbacks,
        onBackPressed: () {
          navigationService.goBack();
        },
        showNotificationIcon: false,
        showMenuIcon: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            20.0.sbH,
            AppText(StringValues.doYouHaveFeedBacks),
            20.0.sbH,
            AppTextField(
              hint: StringValues.email,
              keyboardType: TextInputType.emailAddress,
            ),
            20.0.sbH,
            AppTextField(
              hint: StringValues.lastName,
            ),
            20.0.sbH,
            AppTextField(
              hint: StringValues.phoneNumber,

              prefix: Container(
                width: 150.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50)
                ),
                child: Row(
                  children: [
                    10.0.sbW,
                    SvgPicture.asset(
                      SvgAssets.flag,
                      height: 16.sp,
                      width: 16.sw,
                    ),
                    AppText('+234',
                        style: normalTextStyle12), // +234 is only for display
                  ],
                ),
              ),
              // controller: model.phoneController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                if (!RegExp(r'^0\d{10}$').hasMatch(value)) {
                  return 'Enter a valid 11-digit phone number starting with 0';
                }
                return null;
              },
              // onChanged: (value) {
              //   model.phoneNumber = value;
              // },
              keyboardType: TextInputType.number,
            ),
            20.0.sbH,
            Container(
              width: width(context),
              decoration: BoxDecoration(color: ColorValues.whiteColor),
              child: TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Type something...",
                  hintStyle: normalTextStyle,
                  contentPadding: EdgeInsets.all(8),

                ),
                maxLines: 4,

              ),
            )
          ],
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
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }
}
