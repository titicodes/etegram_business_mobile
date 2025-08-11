import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/assets.dart';
import '../constants/colors.dart';
import '../constants/style.dart';
import '../module/account/views/notification_view.dart';
import '../constants/reuseable.dart';
import '../module/account/viewmodel/notification_vm.dart';
import 'package:etegram_business/locator.dart';
import 'app_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed; // Made optional
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onMenuPressed;
  final bool showNotificationIcon;
  final bool showMenuIcon;
  final bool showBackButton; // New parameter to control back button visibility
  final Color? backgroundColor;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed, // Made optional
    this.onNotificationPressed,
    this.onMenuPressed,
    this.showNotificationIcon = true,
    this.showMenuIcon = true,
    this.showBackButton = true, // Default to true for backward compatibility
    this.backgroundColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final notificationViewModel = locator<NotificationViewModel>();
    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: headerTextStyle,
      ),
      leading: showBackButton && onBackPressed != null
          ? Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: onBackPressed,
                child: SvgPicture.asset(SvgAssets.arrowBack),
              ),
            )
          : null, // Set to null if back button should not be shown
      actions: [
        ...?actions,
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showNotificationIcon)
                InkWell(
                  onTap: onNotificationPressed ??
                      () async {
                        await navigationService
                            .navigateToWidget(const NotificationView());
                        await notificationViewModel.fetchNotifications();
                      },
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        SvgAssets.notification,
                        height: 30,
                        width: 30,
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: notificationViewModel.unreadCount,
                        builder: (context, unreadCount, _) {
                          if (unreadCount <= 0) return const SizedBox.shrink();
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: ColorValues.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: AppText(
                                unreadCount.toString(),
                                style: normalTextStyle12.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                align: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              if (showNotificationIcon && showMenuIcon)
                const SizedBox(width: 16.0),
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
