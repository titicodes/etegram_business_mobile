import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_listtile.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/account/views/general_view.dart';
import 'package:etegram_business/module/account/views/notification_view.dart';
import 'package:etegram_business/module/account/views/security.dart';
import 'package:etegram_business/module/account/views/support.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: ColorValues.whiteColor,
        title: "Account",
        onBackPressed: () {},
        showNotificationIcon: false,
        showMenuIcon: true,
        onMenuPressed: () {},
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.0.sbH,
              NxListTile(
                onTap: () {},
                showBorder: false,
                leading: SvgPicture.asset(SvgAssets.avatar),
                title: Text(
                  "Anietimfon effiong",
                  style: subHeaderTextStyle,
                ),
                subtitle: AppText(
                  "anietimfoneeffiong@gmail.com",
                  style: normalTextStyle,
                ),
                trailing: TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: ColorValues.primaryColor,
                          size: 18,
                        ),
                        5.0.sbW,
                        AppText(
                          StringValues.edit,
                          style: normalTextStyle,
                        )
                      ],
                    )),
              ),
              NxListTile(
                  onTap: () {
                    navigationService.navigateToWidget(NotificationView());
                  },
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.notification),
                  title: Text(
                    "Notification",
                    style: normalTextStyle,
                  ),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: ColorValues.greyColor,
                      ))),
              NxListTile(
                  onTap: () {},
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.security),
                  title: Text(
                    "Security",
                    style: normalTextStyle,
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        navigationService.navigateToWidget(SecurityView());
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: ColorValues.greyColor,
                      ))),
              NxListTile(
                  onTap: () {},
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.settings),
                  title: Text(
                    "General",
                    style: normalTextStyle,
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        navigationService.navigateToWidget(GeneralView());
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: ColorValues.greyColor,
                      ))),
              NxListTile(
                  onTap: () {},
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.faqs),
                  title: Text(
                    "Help Center",
                    style: normalTextStyle,
                  ),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: ColorValues.greyColor,
                      ))),
              NxListTile(
                  onTap: () {
                    navigationService.navigateToWidget(Support());
                  },
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.support),
                  title: Text(
                    "Support",
                    style: normalTextStyle,
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        navigationService.navigateToWidget(Support());
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: ColorValues.greyColor,
                      ))),
              NxListTile(
                  onTap: () {},
                  showBorder: false,
                  leading: SvgPicture.asset(
                    SvgAssets.logout,
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    "Logout",
                    style: normalTextStyle,
                  ),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: ColorValues.greyColor,
                      ))),
            ],
          ),
        ),
      ),
    );
  }
}
