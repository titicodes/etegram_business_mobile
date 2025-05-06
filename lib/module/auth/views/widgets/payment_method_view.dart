import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app_widget/app_text.dart';
import '../../../../app_widget/custom_appbar.dart';
import '../../../../app_widget/input_fields.dart';
import '../../../../base/base_ui.dart';
import '../../../../constants/strings.dart';
import '../../../../constants/style.dart';
import '../../../../core/model/bank.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/widget_extension.dart';
import '../../viewmodel/add_payment_method_vm.dart';

class AddPaymentMethodView extends StatelessWidget {
  const AddPaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<AddPaymentMethodViwModel>(
      onModelReady: (logic) => logic.init(),
      builder: (_, logic, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: "Add Payment Method",
          onBackPressed: () {},
          showNotificationIcon: false,
          showMenuIcon: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: logic.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (logic.errorMessage != null)
                        Text(
                          logic.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      AppTextField(
                        onChanged: logic.updateNewMethodName,
                        hint: StringValues.paymentMethodName,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 55.sp,
                        width: width(context),
                        padding:
                            EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.sp),
                        decoration: BoxDecoration(
                          color: ColorValues.whiteColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Bank>(
                            isExpanded: true,
                            hint: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: AppText(
                                "Select Bank",
                                style: TextStyle(
                                    color: Color(0xFFD9D9D9),
                                    fontFamily: "Poppins",
                                    fontSize: 12),
                              ),
                            ),
                            value: logic
                                .selectedBank, // Ensure this is the selected Bank object
                            onChanged: (Bank? newBank) {
                              if (newBank != null) {
                                logic.selectBank(newBank); // Handle the change
                              }
                            },
                            items: logic.banks.map((Bank bank) {
                              return DropdownMenuItem<Bank>(
                                value: bank,
                                child: Text(bank.name), // Display the bank's name
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller:
                            TextEditingController(text: logic.newMethodBank),
                        hint: 'Bank (Read-only)',
                        enabled: false,
                      ),
                      20.0.sbH,
                      AppTextField(
                        onChanged: logic.updateAccountNumber,
                        hint: 'Account Number',
                        keyboardType: TextInputType.number,
                      ),
                      20.0.sbH,
                      AppTextField(
                        onChanged: logic.updateAccountName,
                        hint: 'Account Name',
                      ),
                      20.0.sbH,
                      Container(
                        decoration: BoxDecoration(color: ColorValues.whiteColor),
                        alignment: Alignment.center,
                        child: TextField(
                          maxLines: 3,
                          onChanged: logic.updateExtraInfo,
                          decoration:  InputDecoration(
                            hintText: 'Extra Info (Optional)',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10),
                            hintStyle: normalTextStyle
                          ),

                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: "Save Payment Method",
                        onTap: logic.canSave()
                            ? () async {
                                await logic.savePaymentMethod();
                                if (context.mounted) {
                                  Navigator.of(context)
                                      .pushReplacementNamed(dashboardRoute);
                                }
                              }
                            : null,
                      ),
                      const SizedBox(height: 24),
                      if (logic.paymentMethods.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logic.paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = logic.paymentMethods[index];
                            return ListTile(
                              title: AppText(method.name ?? ""),
                              subtitle: AppText(method.bank ?? ""),
                            );
                          },
                        ),
                    ],
                  ),
              ),
        ),
      ),
    );
  }
}
