import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/assets.dart';
import '../constants/style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onMenuPressed;
  final bool showNotificationIcon;
  final bool showMenuIcon;
  final Color? backgroundColor;
  final List<Widget>? actions; // <-- NEW

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onBackPressed,
    this.onNotificationPressed,
    this.onMenuPressed,
    this.showNotificationIcon = true,
    this.showMenuIcon = true,
    this.backgroundColor,
    this.actions, // <-- NEW
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: headerTextStyle,
      ),
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: onBackPressed,
          child: SvgPicture.asset(SvgAssets.arrowBack),
        ),
      ),
      actions: [
        ...?actions, // <-- Add custom actions first
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              if (showNotificationIcon && onNotificationPressed != null)
                InkWell(
                  onTap: onNotificationPressed,
                  child: SvgPicture.asset(
                    SvgAssets.notification,
                    height: 30,
                    width: 30,
                  ),
                ),
              if (showNotificationIcon && onNotificationPressed != null)
                SizedBox(width: 16.0),
              if (showMenuIcon && onMenuPressed != null)
                InkWell(
                  onTap: onMenuPressed,
                  child: SvgPicture.asset(
                    SvgAssets.menu,
                    height: 40,
                    width: 40,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
