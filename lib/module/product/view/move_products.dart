import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/delivery_response.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart' as toggle_tab;

import '../../deliveries/vm/moved_product_vm.dart';

class MoveProducts extends StatelessWidget {
  const MoveProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<MoveProductViewModel>(
      onModelReady: (model) => model.init(),
      builder: (context, controller, child) => Stack(
        children: [
          Scaffold(
            appBar: CustomAppBar(
              title: 'Move Products',
              onBackPressed: () => navigationService.goBack(),
              showMenuIcon: true,
              onMenuPressed: () => controller.openDrawer(),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                30.0.sbH,

                AppButton(
                  text: 'Scan Barcode',
                  onTap: () => controller.scanBarcode(context),
                ),
                20.0.sbH,
                ValueListenableBuilder<int>(
                  valueListenable: controller.tabIndex,
                  builder: (context, selectedIndex, child) {
                    return FlutterToggleTab(
                      width: 90,
                      borderRadius: 30,
                      height: 50,
                      selectedIndex: selectedIndex,
                      selectedBackgroundColors: const [
                        ColorValues.primaryColor,
                        Colors.blueAccent,
                      ],
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      unSelectedTextStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      dataTabs: controller.tabOptions
                          .map((title) => toggle_tab.DataTab(title: title))
                          .toList(),
                      selectedLabelIndex: (index) {
                        controller.tabIndex.value = index;
                      },
                      isScroll: false,
                    );
                  },
                ),
                20.0.sbH,
                Padding(
                  padding: 16.0.padH,
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: controller.orderIdController,
                          hint: 'Order ID',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Order ID is required';
                            }
                            return null;
                          },
                        ),
                        16.0.sbH,
                        AppTextField(
                          controller: controller.quantityController,
                          hint: 'Quantity',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Quantity is required';
                            }
                            if (int.tryParse(value) == null ||
                                int.parse(value) <= 0) {
                              return 'Enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                        16.0.sbH,
                        DropdownButtonFormField<String>(
                          value: controller.suppliedTo.isNotEmpty
                              ? controller.suppliedTo
                              : null,
                          items: controller.suppliedToSelection
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null)
                              controller.onSuppliedToChanged(value);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Supplied To',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a destination';
                            }
                            return null;
                          },
                        ),
                        16.0.sbH,
                        DropdownButtonFormField<String>(
                          value: controller.selectedAgentId,
                          items: controller.deliveryAgents
                              .map((agent) => DropdownMenuItem(
                                    value: agent.id,
                                    child: Text(
                                        '${agent.firstName} ${agent.lastName}'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) controller.onAgentChanged(value);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Delivery Agent',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                20.0.sbH,
                AppButton(
                  text: 'Submit Transaction',
                  onTap: () => controller.submitDeliveryTransaction(context),
                ),
                20.0.sbH,
                Expanded(
                  child: ValueListenableBuilder<List<DeliveryTransactionData>>(
                    valueListenable: controller.deliveryTransactions,
                    builder: (context, transactions, child) {
                      final filteredTransactions =
                          controller.tabIndex.value == 0
                              ? transactions
                                  .where((t) => t.status == 'DELIVERED')
                                  .toList()
                              : transactions
                                  .where((t) => t.status == 'RECEIVED')
                                  .toList();
                      return ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return ListTile(
                            title: Text('Order #${transaction.orderId}'),
                            subtitle:
                                Text('Items: ${transaction.items.length}'),
                            trailing: Text(
                              transaction.status ?? '',
                              style: const TextStyle(color: Colors.blue),
                            ),
                            onTap: () {
                              showCustomToast(
                                  'Transaction ID: ${transaction.id}');
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black54,
              child: const Center(
                child: SpinKitFadingCircle(
                  color: ColorValues.primaryColor,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
