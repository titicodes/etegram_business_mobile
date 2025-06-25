// customer_details_view.dart (New)
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../base/base_ui.dart';
import '../../vm/customer_vm.dart';
import '../new_customer.dart';

class CustomerDetailsView extends StatelessWidget {
  final CustomerData customer;

  const CustomerDetailsView({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomerViewModel>(
      builder: (_, model, child) => Scaffold(
        appBar: CustomAppBar(
          title: '${customer.firstName} ${customer.lastName}',
          onBackPressed: navigationService.goBack,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Email: ${customer.email}', style: bodyTextStyle),
              10.0.sbH,
              AppText('Phone: ${customer.phoneNumber}', style: bodyTextStyle),
              10.0.sbH,
              AppText('Address: ${customer.address}', style: bodyTextStyle),
              10.0.sbH,
              // AppText('Store: ${customer.storeName ?? 'Not assigned'}', style: bodyTextStyle),
              // 10.0.sbH,
              AppText(
                'Birthday: ${customer.birthday != null ? DateFormat('MMMM d, yyyy').format(DateTime.parse(customer.birthday!)) : 'Not set'}',
                style: bodyTextStyle,
              ),
              10.0.sbH,
              AppText('Country: ${customer.country}', style: bodyTextStyle),
              10.0.sbH,
              AppText('State: ${customer.state}', style: bodyTextStyle),
              10.0.sbH,
              AppText('City: ${customer.lga}', style: bodyTextStyle),
              10.0.sbH,
              AppText('Extra Details: ${customer.extraDetails ?? 'None'}', style: bodyTextStyle),
              20.0.sbH,
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Edit',
                      onTap: () {
// TODO: Implement edit functionality
                        showCustomToast('Edit feature coming soon');
                      },
                    ),
                  ),
                  10.0.sbW,
                  Expanded(
                    child: AppButton(
                      text: 'Delete',
                      backGroundColor: Colors.red,
                      onTap: () async {
                        final success = await model.deleteCustomer(customer.id!);
                        if ( success) {
                          navigationService.goBack(); // returns void — that's okay
                          showCustomToast('Customer deleted successfully', success: true); // returns void — okay if just called
                        } else {
                          showCustomToast('Failed to delete customer');
                        }
                      },
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}