import 'package:etegram_business/app_widget/custom_listtile.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/account/viewmodel/profile_vw.dart';
import 'package:flutter/material.dart';

import '../../../app_widget/custom_appbar.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProfileViewModel>(
      builder: (_, logic, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: StringValues.notifications,
          onBackPressed: () {
            navigationService.goBack();
          },
          showNotificationIcon: false,
          showMenuIcon: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              NxListTile(
                showBorder: false,
                trailing: Switch(
                  value: logic.isEmailSelected,
                  onChanged: logic.toggleEmailSwitch,
                  activeColor: ColorValues.primaryColor,
                ),
                title: Text(
                  StringValues.email,
                  style: normalTextStyle,
                ),
              ),
              NxListTile(
                showBorder: false,
                trailing: Switch(
                  value: logic.isPushNotificationSelected,
                  onChanged: logic.togglePushedNotificationSwitch,
                  activeColor: ColorValues.primaryColor,
                ),
                title: Text(
                  StringValues.pushNotification,
                  style: normalTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
