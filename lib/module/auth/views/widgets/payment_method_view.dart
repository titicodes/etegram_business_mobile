// Modified AddPaymentMethodView

import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app_widget/app_button.dart';
import '../../../../app_widget/app_text.dart';
import '../../../../app_widget/custom_appbar.dart';
import '../../../../app_widget/custom_dropdown.dart';
import '../../../../app_widget/input_fields.dart';
import '../../../../base/base_ui.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/reuseable.dart';
import '../../../../constants/strings.dart';
import '../../../../constants/style.dart';
import '../../../../core/model/payment_method_response.dart';
import '../../viewmodel/add_payment_method_vm.dart';

class AddPaymentMethodView extends StatelessWidget {
  const AddPaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<AddPaymentMethodViewModel>(
      onModelReady: (logic) => logic.init(),
      builder: (_, logic, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: "Add Payment Method",
          onBackPressed: () => navigationService.goBack(),
          showNotificationIcon: false,
          showMenuIcon: false,
        ),
        body: logic.isLoading.value
            ? const Center(
                child: SpinKitDoubleBounce(
                    color: ColorValues.primaryColor, size: 50.0))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: logic.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (logic.errorMessage != null)
                        //   AppText(logic.errorMessage!, style: const TextStyle(color: Colors.red)),
                        10.0.sbH,
                        Center(
                          child: SvgPicture.asset(SvgAssets.appLogo),
                        ),
                        20.0.sbH,
                        // >>> NEW: Payment Method Type Dropdown
                        CustomDropDown(
                          width: double.infinity,
                          hintText: "Select Payment Type",
                          items: PaymentMethodType.values
                              .map((type) => type.toDisplayName())
                              .toList(),
                          value: logic.selectedPaymentType
                              ?.toDisplayName(), // Display selected value
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.grey),
                          prefix:
                              const Icon(Icons.category, color: Colors.grey),
                          onChanged: (value) {
                            logic.selectPaymentType(value);
                          },
                        ),
                        16.0.sbH,
                        AppTextField(
                          onChanged: logic.updateNewMethodName,
                          hint: StringValues.paymentMethodName,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter method name'
                              : null,
                        ),
                        16.0.sbH,
                        CustomDropDown(
                          width: double.infinity,
                          hintText: "Select Bank",
                          items: logic.banks.map((bank) => bank.name).toList(),
                          value: logic
                              .selectedBank?.name, // Display selected bank name
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.grey),
                          prefix: const Icon(Icons.account_balance,
                              color: Colors.grey),
                          onChanged: (value) => logic.selectBank(logic.banks
                              .firstWhere((bank) => bank.name == value)),
                        ),
                        16.0.sbH,
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
                          validator: (value) => value!.length != 10
                              ? 'Enter a valid 10-digit account number'
                              : null,
                        ),
                        20.0.sbH,
                        AppTextField(
                          onChanged: logic.updateAccountName,
                          hint: 'Account Name',
                          validator: (value) => value!.isEmpty
                              ? 'Please enter account name'
                              : null,
                        ),
                        20.0.sbH,
                        Container(
                          decoration:
                              BoxDecoration(color: ColorValues.whiteColor),
                          alignment: Alignment.center,
                          child: TextField(
                            maxLines: 3,
                            onChanged: logic.updateExtraInfo,
                            decoration: InputDecoration(
                              hintText: 'Extra Info (Optional)',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(10),
                              hintStyle: normalTextStyle,
                            ),
                          ),
                        ),
                        40.0.sbH,
                        AppButton(
                          text: "Save Payment Method",
                          onTap: logic.canSave()
                              ? () => logic.savePaymentMethod(context)
                              : null,
                        ),
                        24.0.sbH,
                        if (logic.paymentMethods.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: logic.paymentMethods.length,
                            itemBuilder: (context, index) {
                              final method = logic.paymentMethods[index];
                              return ListTile(
                                title: AppText(method.name ?? ""),
                                subtitle: AppText(
                                    "${method.bank} - ${method.accountNumber}"),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
