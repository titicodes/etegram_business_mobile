import 'package:country_code_picker/country_code_picker.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/deliveries/vm/delivery_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app_widget/custom_dropdown.dart';
import '../../../app_widget/input_fields.dart';
import '../../../constants/assets.dart';

class DeliveryAgent extends StatelessWidget {
  DeliveryAgent({super.key});
  String pNumber = 'null';
  CountryCode countryCode = CountryCode(dialCode: '+234');

  @override
  Widget build(BuildContext context) {
    return BaseView<DeliveryViewModel>(
      builder: (_, logic, child) => Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            30.0.sbH,
            AppText(
              StringValues.addDeliveryAgent,
              style: headerTextStyle,
            ),
            10.0.sbH,
            AppTextField(
              hint: "*Business Name",
              controller: logic.businessNameController,
            ),
            10.0.sbH,
            AppTextField(
              hint: "*First Name",
              controller: logic.firstNameController,
            ),
            10.0.sbH,
            AppTextField(
              hint: "*Last Name",
              controller: logic.lastNameController,
            ),
            10.0.sbH,
            AppTextField(
              hint: StringValues.businesContact,
              prefix: Container(
                width: 150.sp, // Adjust this if needed
                child: Row(
                  children: [
                    10.0.sbW,
                    SvgPicture.asset(
                      SvgAssets.flag,
                      height: 16.sp,
                      width: 16.sw,
                    ),
                    AppText('  +234', style: normalTextStyle12),
                  ],
                ),
              ),
              controller: logic.businessController,
              onChanged: (value) {
                if (value.length > 10) {
                  pNumber =
                      '$countryCode${logic.phoneController.text.substring(1)}';
                  if (kDebugMode) {
                    print(pNumber);
                  }
                } else {
                  pNumber = '$countryCode${logic.phoneController.text}';
                }
              },
            ),
            AppTextField(
              hint: StringValues.businesPhone,
              prefix: Container(
                width: 150.sp, // Adjust this if needed
                child: Row(
                  children: [
                    10.0.sbW,
                    SvgPicture.asset(
                      SvgAssets.flag,
                      height: 16.sp,
                      width: 16.sw,
                    ),
                    AppText('  +234', style: normalTextStyle12),
                  ],
                ),
              ),
              controller: logic.phoneController,
              onChanged: (value) {
                if (value.length > 10) {
                  pNumber =
                      '$countryCode${logic.phoneController.text.substring(1)}';
                  print(pNumber);
                } else {
                  pNumber = '$countryCode${logic.phoneController.text}';
                }
              },
            ),
            20.0.sbH,
            CustomDropDown(
              width: double.infinity,
              hintText: "Currency",
              items: logic.businessTypeSelection,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
              prefix: Icon(Icons.person_2_outlined,
                  color: Colors.grey), // Optional prefix icon
              onChanged: (value) {
                logic.onChangedBusinessType(value);
              },
            ),
            10.0.sbH,
            AppTextField(
              hint: StringValues.emailBusiness,
            ),
            30.0.sbH,
            AppButton(
              text: StringValues.addDeliveryAgent,
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }
}
