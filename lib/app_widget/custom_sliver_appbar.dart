import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/assets.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onMenuPressed;
  final bool showNotificationIcon;
  final bool showMenuIcon;
  final double expandedHeight;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    required this.onBackPressed,
    this.onNotificationPressed,
    this.onMenuPressed,
    this.showNotificationIcon = false, // Default to false
    this.showMenuIcon = true, // Default to true
    this.expandedHeight = 150, // Default expanded height
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        background: Container(
          color: Colors.white, // Customize the background color if needed
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: onBackPressed,
          child: SvgPicture.asset(SvgAssets.arrowBack),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              // Show notification icon only if enabled
              if (showNotificationIcon && onNotificationPressed != null)
                InkWell(
                  onTap: onNotificationPressed,
                  child: SvgPicture.asset(
                    SvgAssets.notification,
                    height: 30,
                    width: 30,
                  ),
                ),
              // Add spacing if notification icon is shown
              if (showNotificationIcon && onNotificationPressed != null)
                SizedBox(width: 16.0),
              // Show menu icon only if enabled
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
}
