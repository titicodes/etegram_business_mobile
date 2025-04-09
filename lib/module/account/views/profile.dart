import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../../../app_widget/app_text.dart';
import '../../../constants/colors.dart';
import '../../../constants/style.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Profile",
        onBackPressed: () {
          navigationService.goBack();
        },
        showNotificationIcon: false,
        showMenuIcon: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                    // borderRadius: BorderRadius.circular(100), child: const Image(image: AssetImage(tProfileImage))),
                    borderRadius: BorderRadius.circular(100),
                    child: SvgPicture.asset(SvgAssets.avatar)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: ColorValues.greyColor),
                  child: Icon(
                    LineAwesomeIcons.camera_retro_solid,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          20.0.sbH,
          AppTextField(
            hintText: StringValues.firstName,
          ),
          20.0.sbH,
          AppTextField(
            hintText: StringValues.lastName,
          ),
          20.0.sbH,
          AppTextField(
            hint: StringValues.phoneNumber,
            prefix: Container(
              width: 150.sp,
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
          30.0.sbH,
        ],
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
