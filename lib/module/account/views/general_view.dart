import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_listtile.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GeneralView extends StatelessWidget {
  const GeneralView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: StringValues.general,
        onBackPressed: () {navigationService.goBack();},
        showMenuIcon: true,
        showNotificationIcon: false,
        onMenuPressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.0.sbH,
            NxListTile(
              showBorder: false,
              leading: SvgPicture.asset(SvgAssets.settings),
              trailing: Icon(Icons.arrow_forward_ios,
                size: 18,
                color: ColorValues.greyColor,),
              title: AppText(
                StringValues.privacyPolicy,
                style: normalTextStyle,
              ),
              onTap: () {},
            ),
            NxListTile(
              showBorder: false,
              leading: SvgPicture.asset(SvgAssets.settings),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: ColorValues.greyColor,
              ),
              title: AppText(
                StringValues.termOfUse,
                style: normalTextStyle,
              ),
              onTap: () {},
            ),
            NxListTile(
              showBorder: false,
              leading: SvgPicture.asset(SvgAssets.settings),
              trailing: Icon(Icons.arrow_forward_ios,
                size: 18,
                color: ColorValues.greyColor,),
              title: AppText(
                StringValues.aboutUs,
                style: normalTextStyle,
              ),
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }
}
