import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_listtile.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/style.dart';

class Faq extends StatelessWidget {
  const Faq({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: StringValues.faq,
        onBackPressed: () {},
        showNotificationIcon: false,
        showMenuIcon: true,
        onMenuPressed: () {},
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.0.sbH,
          NxListTile(
            onTap: () {},
            showBorder: false,
            leading: SvgPicture.asset(SvgAssets.faqs),
            title: AppText(
              StringValues.faq,
              style: normalTextStyle12,
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          )
        ],
      ),
    );
  }
}
