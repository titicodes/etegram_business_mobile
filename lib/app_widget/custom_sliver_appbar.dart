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
  final bool showLogo; // Flag to show/hide logo
  final String? logoAsset; // Make logo asset optional
  final double expandedHeight;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    required this.onBackPressed,
    this.onNotificationPressed,
    this.onMenuPressed,
    this.showNotificationIcon = false,
    this.showMenuIcon = true,
    this.expandedHeight = 150,
    this.logoAsset, // Now optional
    this.showLogo = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Display logo only if showLogo is true and logoAsset is provided
            if (showLogo && logoAsset != null)
              SvgPicture.asset(
                logoAsset!,
                height: 40, // Set your desired height
              ),
            if (showLogo && logoAsset != null) const SizedBox(height: 8), // Spacing if logo is shown
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        background: Container(
          color: Colors.white,
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
}