import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/assets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback? onNotificationPressed; // Nullable
  final VoidCallback? onMenuPressed; // Nullable
  final bool showNotificationIcon; // Flag to show/hide notification icon
  final bool showMenuIcon; // Flag to show/hide menu icon
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onBackPressed,
    this.onNotificationPressed,
    this.onMenuPressed,
    this.showNotificationIcon = true, // Default to true
    this.showMenuIcon = true, this.backgroundColor, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge, // Adjust style as needed
      ),
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: onBackPressed,
          child: SvgPicture.asset(
            SvgAssets.arrowBack,
          ),
        ),
      ),
      actions: [
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
