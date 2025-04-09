import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/module/account/views/feed_back.dart';
import 'package:etegram_business/module/account/views/live_chat_view.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app_widget/app_text.dart';
import '../../../app_widget/custom_listtile.dart';
import '../../../constants/assets.dart';
import '../../../constants/style.dart';

class Support extends StatelessWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: StringValues.support,
        onBackPressed: () {
          navigationService.goBack();
        },
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
              onTap: () {
                navigationService.navigateToWidget(LiveChatView());
              },
              showBorder: false,
              leading: SvgPicture.asset(SvgAssets.chat),
              title: AppText(
                StringValues.liveChat,
                style: normalTextStyle,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: ColorValues.greyColor,
              ),
            ),
            NxListTile(
              onTap: () {
                navigationService.navigateToWidget(FeedBack());
              },
              showBorder: false,
              leading: SvgPicture.asset(SvgAssets.chat),
              title: AppText(
                StringValues.feedbacks,
                style: normalTextStyle,
              ),
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
