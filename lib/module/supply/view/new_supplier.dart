import 'package:flutter/material.dart';
import 'package:etegram_business/base/base_ui.dart';
import '../../../app_widget/app_button.dart';
import '../../../app_widget/input_fields.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../app_widget/custom_sliver_appbar.dart';
import '../view_model/supply_vm.dart';

class NewSupplierView extends StatelessWidget {
  const NewSupplierView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SupplierViewModel>(
      notDefaultLoading: true,
      onModelReady: (model) => model.onInit(),
      builder: (_, logic, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        body: CustomScrollView(
          slivers: [
            CustomSliverAppBar(
              title: logic.supplier == null
                  ? StringValues.newSupplier
                  : StringValues.updateSupplier,
              onBackPressed: () {
                navigationService.goBack();
              },
              showMenuIcon: false,
              onMenuPressed: () {},
              showNotificationIcon: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Form(
                  key: logic.formKey, // Use formKey from ViewModel
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        hint: StringValues.businessName,
                        controller: logic.businessNameController,
                      ),
                      SizedBox(height: 12),
                      AppTextField(
                        hint: StringValues.contactName,
                        controller: logic.contactNameController,
                      ),
                      SizedBox(height: 12),
                      AppTextField(
                        hint: StringValues.enterEmail,
                        controller: logic.emailController,
                      ),
                      SizedBox(height: 12),
                      AppTextField(
                        hint: StringValues.phoneNumber,
                        controller: logic.phoneNumberController,
                      ),
                      SizedBox(height: 12),
                      _buildDropdown(context,
                          value: logic.selectedCurrency,
                          items: logic.currency,
                          onChanged: (value) => logic.onCurrencyChanged,
                          hintText: 'Currency'),
                      SizedBox(height: 12),
                      AppTextField(
                        hint: StringValues.accountDetail,
                        controller: logic.accountDetailsController,
                      ),
                      SizedBox(height: 12),
                      AppTextField(
                        hint: StringValues.address,
                        controller: logic.addressController,
                      ),
                      SizedBox(height: 12),
                      _buildDropdown(context,
                          value: logic.selectedCountry,
                          items: logic.countryList,
                          onChanged: (value) =>
                              logic.onCountryChanged(value ?? ""),
                          hintText: 'Country'),
                      SizedBox(height: 12),
                      _buildDropdown(context,
                          value: logic.stateValue,
                          items: logic.statesList,
                          onChanged: (value) =>
                              logic.onStateChanged(value ?? ""),
                          hintText: 'State'),
                      SizedBox(height: 12),
                      _buildDropdown(context,
                          value: logic.lgaValue,
                          items: logic.lgaList,
                          onChanged: (value) => logic.onLGAChanged(value ?? ""),
                          hintText: 'City'),
                      SizedBox(height: 12),
                      _buildDropdown(context,
                          value: logic.wardValue,
                          items: logic.wardList,
                          onChanged: (value) =>
                              logic.onWardChanged(value ?? ""),
                          hintText: 'Area'),
                      SizedBox(height: 12),
                      AppButton(
                        text: StringValues.save,
                        onTap: () => logic.addSupplier(context), // Pass context
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context,
      {required String? value,
      required List<String> items,
      required ValueChanged<String?> onChanged,
      required String hintText}) {
    return Container(
      height: 55,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hintText,
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
