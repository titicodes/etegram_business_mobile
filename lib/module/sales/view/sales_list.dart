import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/sales_records.dart';
import 'package:etegram_business/module/sales/vm/sales_record_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../routes/routes.dart';
import '../../../utils/string_extension.dart';

class SalesList extends StatelessWidget {
  const SalesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SalesRecordViewModel>(
      onModelReady: (model) => model.init(),
      builder: (_, model, child) => Scaffold(
        appBar: CustomAppBar(
          title: StringValues.review,
          onBackPressed: () => navigationService.goBack(),
          showMenuIcon: true,
          showNotificationIcon: false,
        ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              2.0.sbH,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(StringValues.total, style: subHeaderTextStyle),
                  ValueListenableBuilder<List<SalesRecord>>(
                    valueListenable: model.salesHistory,
                    builder: (context, records, _) {
                      final total = records.fold(
                          0.0, (sum, record) => sum + record.totalPriceWithTax);
                      return AppText('NGN ${total.toStringAsFixed(2)}', // Fallback to NGN
                          style: subHeaderTextStyle);
                    },
                  ),
                ],
              ),
              10.0.sbH,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(context, "Owed",
                          () => navigationService.navigateTo(owningRecordsRoute)),
                  _buildButton(context, StringValues.customer, () {}),
                  _buildButton(context, StringValues.discount, () {}),
                ],
              ),
            ],
          ),
        ),
        body: ValueListenableBuilder<List<SalesRecord>>(
          valueListenable: model.salesHistory,
          builder: (context, records, _) => records.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText('No sales records found.',
                    style: normalTextStyle),
                AppButton(
                  text: 'Retry',
                  onTap: () => model.init(),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: AppText(
                    'Order #${record.id}',
                    style: normalTextStyle.copyWith(
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                          'Total: ${formatPrice(record.totalPriceWithTax.toStringAsFixed(2))}'),
                      AppText('Status: ${record.status}'),
                      AppText('Payment: ${record.paymentMethod}'),
                      AppText(
                          'Date: ${record.createdAt.toString().substring(0, 10)}'),
                      if (record.isCredit)
                        AppText(
                            'Customer: ${record.customerId ?? 'Unknown'}'),
                      if (record.supplierId != null)
                        AppText('Supplier: ${record.supplierId}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
          color: ColorValues.whiteColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AppText(
          title,
          style: normalTextStyle12,
        ),
      ),
    );
  }
}