import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:etegram_business/module/profile/vm/profle_vm.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:etegram_business/locator.dart';
import '../../../service/local/drawer_service.dart';
import '../../../service/local/user_service.dart';
import '../../auth/views/widgets/payment_method_view.dart';
import '../../home/drawer/nav_drawer.dart';
import '../../profile/view/profile_view.dart';
import '../../subscription/view/subscription_view.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  void _showLogoutDialog(BuildContext context) {
    print('AccountView: Attempting to show logout dialog');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        print('AccountView: Building logout dialog');
        return AlertDialog(
          backgroundColor: ColorValues.whiteColor,
          title: Text(
            "Confirm Logout",
            style: subHeaderTextStyle,
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: normalTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('AccountView: Cancel logout pressed');
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                "Cancel",
                style: normalTextStyle.copyWith(color: ColorValues.greyColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                print('AccountView: Logout confirmed');
                try {
                  await locator<CustomerService>().logout();
                  // No need to navigate or show toast here; handled in CustomerService.logout()
                } catch (e) {
                  print('AccountView: Logout error: $e');
                  Navigator.of(dialogContext).pop();
                  if (dialogContext.mounted) {
                    showCustomToast(
                      "Logout failed: $e",
                      success: false,
                      context: dialogContext,
                    );
                  }
                }
              },
              child: Text(
                "Log Out",
                style: normalTextStyle.copyWith(color: ColorValues.primaryColor),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      print('AccountView: Logout dialog closed');
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final drawerService = locator<DrawerService>();
    final customerService = locator<CustomerService>();
    final profileViewModel = locator<ProfileViewModel>();
    bool isLogoutTapped = false; // Debounce flag

    // Set the scaffold key in DrawerService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      drawerService.setScaffoldKey(scaffoldKey);
      print(
          'AccountView: Scaffold key set in DrawerService: ${scaffoldKey.hashCode}');
    });

    // Check for payment methods on load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return; // Prevent actions if widget is disposed
      try {
        bool hasPayments = await customerService.hasPaymentMethods();
        if (!hasPayments) {
          showCustomToast(
            "No payment methods found. Please add a payment method.",
            success: false,
            context: context,
          );
          await navigationService
              .navigateToWidget(const AddPaymentMethodView());
        }
      } catch (e) {
        print('AccountView: Error checking payment methods: $e');
        if (context.mounted) {
          showCustomToast(
            "Error checking payment methods: $e",
            success: false,
            context: context,
          );
        }
      }
    });

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: ColorValues.backgroundColor,
      drawer: const NavDrawer(),
      appBar: CustomAppBar(
        backgroundColor: ColorValues.whiteColor,
        title: "Account",
        onBackPressed: () {
          print('AccountView: Navigating to dashboardRoute');
          navigationService.navigateTo(dashboardRoute);
        },
        showNotificationIcon: false,
        showBackButton: false,
        showMenuIcon: true,
        onMenuPressed: () {
          print('AccountView: Opening drawer');
          drawerService.openDrawer();
        },
      ),
      body: Builder(
        builder: (BuildContext bodyContext) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),
                NxListTile(
                  onTap: () =>
                      navigationService.navigateToWidget(const ProfileView()),
                  showBorder: false,
                  leading: ValueListenableBuilder<String?>(
                    valueListenable: profileViewModel.profileImageUrl,
                    builder: (context, imageUrl, _) => CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  SvgPicture.asset(
                                SvgAssets.avatar,
                                height: 24,
                                width: 24,
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : SvgPicture.asset(
                              SvgAssets.avatar,
                              height: 24,
                              width: 24,
                            ),
                    ),
                  ),
                  title: Text(
                    customerService.customer?.firstName ?? "User",
                    style: subHeaderTextStyle,
                  ),
                  subtitle: AppText(
                    customerService.customer?.email ?? "No email",
                    style: normalTextStyle,
                  ),
                  trailing: TextButton(
                    onPressed: () =>
                        navigationService.navigateToWidget(const ProfileView()),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          color: ColorValues.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 5.0),
                        AppText(
                          StringValues.edit,
                          style: normalTextStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                NxListTile(
                  onTap: () => navigationService
                      .navigateToWidget(const NotificationView()),
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.notification),
                  title: Text(
                    "Notification",
                    style: normalTextStyle,
                  ),
                ),
                NxListTile(
                  onTap: () => navigationService
                      .navigateToWidget(const SubscriptionView()),
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.security),
                  title: Text(
                    "Subscription",
                    style: normalTextStyle,
                  ),
                ),
                NxListTile(
                  onTap: () =>
                      navigationService.navigateToWidget(const SecurityView()),
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.security),
                  title: Text(
                    "Security",
                    style: normalTextStyle,
                  ),
                ),
                NxListTile(
                  onTap: () =>
                      navigationService.navigateToWidget(const GeneralView()),
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.settings),
                  title: Text(
                    "General",
                    style: normalTextStyle,
                  ),
                ),
                NxListTile(
                  onTap: () => navigationService
                      .navigateToWidget(const AddPaymentMethodView()),
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.settings),
                  title: Text(
                    "Payment Methods",
                    style: normalTextStyle,
                  ),
                ),
                NxListTile(
                  onTap: () =>
                      navigationService.navigateToWidget(const Support()),
                  showBorder: false,
                  leading: SvgPicture.asset(SvgAssets.support),
                  title: Text(
                    "Support",
                    style: normalTextStyle,
                  ),
                ),
                NxListTile(
                  onTap: () {
                    if (!isLogoutTapped) {
                      isLogoutTapped = true;
                      _showLogoutDialog(bodyContext); // Use bodyContext
                      Future.delayed(const Duration(seconds: 1), () {
                        isLogoutTapped = false; // Reset after 1 second
                      });
                    }
                  },
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
