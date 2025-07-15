import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_listtile.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:flutter/material.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/user_service.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final customerService = locator<CustomerService>();

    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: 'Subscription',
        onBackPressed: () {
          navigationService.goBack();
        },
        showNotificationIcon: false,
        showMenuIcon: true,
      ),
      body: FutureBuilder(
        future: customerService.fetchSubscriptionStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final subscription = customerService.subscription;

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Subscription',
                  style: subHeaderTextStyle,
                ),
                const SizedBox(height: 10),
                Text(
                  'During the internal testing period, all features are accessible without a subscription.',
                  style: normalTextStyle.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                NxListTile(
                  showBorder: false,
                  title: Text(
                    'Status: ${subscription?.status ?? "No Subscription"}',
                    style: normalTextStyle,
                  ),
                  subtitle: Text(
                    subscription?.status == 'TRIAL'
                        ? 'Trial ends: ${subscription?.trialEndDate?.toString().split('.')[0] ?? "N/A"}'
                        : subscription?.status == 'PREMIUM'
                            ? 'Premium ends: ${subscription?.endDate?.toString().split('.')[0] ?? "N/A"}'
                            : 'No active subscription',
                    style: normalTextStyle,
                  ),
                ),
                if (subscription?.status == 'TRIAL' ||
                    subscription?.status == 'EXPIRED' ||
                    subscription == null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Upgrade to Premium',
                    style: subHeaderTextStyle,
                  ),
                  NxListTile(
                    onTap: () async {
                      await customerService.subscribeToPremium('MONTHLY');
                      (context as Element).markNeedsBuild(); // Force rebuild
                    },
                    showBorder: false,
                    title: Text(
                      'Monthly Plan',
                      style: normalTextStyle,
                    ),
                    subtitle: Text(
                      'Access all premium features for 30 days',
                      style: normalTextStyle,
                    ),
                  ),
                  NxListTile(
                    onTap: () async {
                      await customerService.subscribeToPremium('YEARLY');
                      (context as Element).markNeedsBuild(); // Force rebuild
                    },
                    showBorder: false,
                    title: Text(
                      'Yearly Plan',
                      style: normalTextStyle,
                    ),
                    subtitle: Text(
                      'Access all premium features for 365 days',
                      style: normalTextStyle,
                    ),
                  ),
                ],
                if (subscription?.status == 'PREMIUM' &&
                    subscription?.isActive == true) ...[
                  const SizedBox(height: 20),
                  NxListTile(
                    onTap: () async {
                      await customerService.cancelSubscription();
                      (context as Element).markNeedsBuild(); // Force rebuild
                    },
                    showBorder: false,
                    title: Text(
                      'Cancel Subscription',
                      style: normalTextStyle,
                    ),
                    subtitle: Text(
                      'Cancel your active premium subscription',
                      style: normalTextStyle,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
