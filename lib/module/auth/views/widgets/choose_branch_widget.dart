import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

class ChooseBranchWidget extends StatelessWidget {
  const ChooseBranchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "",
        onBackPressed: () {
          navigationService.goBack();
        },
        showMenuIcon: false,
        showNotificationIcon: false,
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          40.0.sbH,
          AppText(
            StringValues.choseBranch,
            style: headerTextStyle,
          ),
          5.0.sbH,
          AppText(
            StringValues.youCanChangeLater,
            style: normalTextStyle12,
          ),
          30.0.sbH,
          Container(
            height: 150,
            width: width(context) * .8,
            decoration: BoxDecoration(
                border: Border.all(color: ColorValues.greyColor),
                borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Icon(
                Icons.location_on_sharp,
                color: ColorValues.primaryColor,
              ),
              title: AppText(
                'Tifon Systems ltd',
                style: headerTextStyle,
              ),
              subtitle: AppText(
                'active Merchant',
                style: normalTextStyle12,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AppButton(
              text: StringValues.continues,
              onTap:() {

              },
            ),
          )
        ],
      )),
    );
  }
}
