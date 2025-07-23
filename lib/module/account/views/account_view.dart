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
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/profile/vm/profle_vm.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:etegram_business/locator.dart';
import '../../../service/local/user_service.dart';
import '../../auth/views/widgets/payment_method_view.dart';
import '../../home/drawer/nav_drawer.dart';
import '../../profile/view/profile_view.dart';
import '../../subscription/view/subscription_view.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
              onPressed: () => Navigator.of(dialogContext).pop(), // Cancel
              child: Text(
                "Cancel",
                style: normalTextStyle.copyWith(color: ColorValues.greyColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await locator<CustomerService>().logout();
              },
              child: Text(
                "Log Out",
                style:
                    normalTextStyle.copyWith(color: ColorValues.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerService = locator<CustomerService>();
    var model = locator<HomeViewModel>();
    var logic = locator<ProfileViewModel>();
    // Check for payment methods on load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool hasPayments = await customerService.hasPaymentMethods();
      if (!hasPayments) {
        showCustomToast(
            "No payment methods found. Please add a payment method.",
            success: false);
        navigationService.navigateToWidget(const AddPaymentMethodView());
      }
    });

    return Scaffold(
      key: model.scaffoldKey,
      backgroundColor: ColorValues.backgroundColor,
      drawer: const NavDrawer(),
      appBar: CustomAppBar(
        backgroundColor: ColorValues.whiteColor,
        title: "Account",
        onBackPressed: () => navigationService.navigateTo(dashboardRoute),
        showNotificationIcon: false,
        showMenuIcon: true,
        onMenuPressed: () => model.openDrawer(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: 16.0.padA,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.0.sbH,
              NxListTile(
                onTap: () =>
                    navigationService.navigateToWidget(const ProfileView()),
                showBorder: false,
                //leading: SvgPicture.asset(SvgAssets.avatar),
                leading: ValueListenableBuilder<String?>(
                  valueListenable: logic.profileImageUrl,
                  builder: (context, imageUrl, _) => CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    child: imageUrl != null
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
                            imageBuilder: (context, imageProvider) => Container(
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
                trailing: IconButton(
                  onPressed: () => navigationService
                      .navigateToWidget(const NotificationView()),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: ColorValues.greyColor,
                  ),
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
                trailing: IconButton(
                  onPressed: () => navigationService
                      .navigateToWidget(const SubscriptionView()),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: ColorValues.greyColor,
                  ),
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
                trailing: IconButton(
                  onPressed: () =>
                      navigationService.navigateToWidget(const SecurityView()),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: ColorValues.greyColor,
                  ),
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
                trailing: IconButton(
                  onPressed: () =>
                      navigationService.navigateToWidget(const GeneralView()),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: ColorValues.greyColor,
                  ),
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
                trailing: IconButton(
                  onPressed: () => navigationService
                      .navigateToWidget(const AddPaymentMethodView()),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: ColorValues.greyColor,
                  ),
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
                trailing: IconButton(
                  onPressed: () =>
                      navigationService.navigateToWidget(const Support()),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: ColorValues.greyColor,
                  ),
                ),
              ),
              NxListTile(
                onTap: () => _showLogoutDialog(context),
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
                  onPressed: () => _showLogoutDialog(context),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: ColorValues.greyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
