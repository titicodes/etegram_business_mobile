import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_listtile.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/account/views/change_password_view.dart';
import 'package:etegram_business/module/account/views/change_pin_view.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/strings.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: StringValues.security,
        onBackPressed: () {
          navigationService.goBack();
        },
        showMenuIcon: true,
        showNotificationIcon: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.0.sbH,
            NxListTile(
              showBorder: false,
              onTap: () {
                navigationService.navigateToWidget(ChangePasswordView());
              },
              title: AppText(
                StringValues.changePassword,
                style: normalTextStyle12,
              ),
              leading: SvgPicture.asset(SvgAssets.security),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: ColorValues.greyColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
