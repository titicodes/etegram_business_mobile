import 'package:etegram_business/module/customer/view/widgets/customer_card.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../app_widget/app_text.dart';
import '../../../app_widget/custom_sliver_appbar.dart';
import '../../../base/base_ui.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';
import '../vm/customer_vm.dart';

class CustomersListView extends StatelessWidget {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomerViewModel>(
      onModelReady: (model) => model.initState(),
      builder: (_, logic, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        body: CustomScrollView(
          // Handles overall scrolling
          slivers: [
            CustomSliverAppBar(
              title: StringValues.customer,
              onBackPressed: () {
                navigationService.goBack();
              },
              showMenuIcon: false,
              onMenuPressed: () {},
              showNotificationIcon: false,
            ),
            // Static content wrapped in SliverToBoxAdapter
            SliverToBoxAdapter(
              child: Padding(
                // Add padding here if needed around this section
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Example padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    10.0.sbH,
                    AppText(
                      StringValues.totalCustomers,
                      style: subHeaderTextStyle,
                    ),
                    20.0.sbH,
                  ],
                ),
              ),
            ),
            // The list itself as a SliverList
            SliverPadding(
              // Add padding around the list
              padding: const EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Handle potential null list or null items gracefully
                    final customer = logic.allCustomer?[index];
                    if (customer == null) {
                      // Return a placeholder or an empty container if an item is unexpectedly null
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      // Add padding between cards if needed
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomerCard(customer: customer),
                    );
                  },
                  childCount: logic.allCustomer?.length ??
                      0, // Handle null list for count
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
