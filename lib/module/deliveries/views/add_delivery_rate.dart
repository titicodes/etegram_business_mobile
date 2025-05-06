import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/module/deliveries/vm/delivery_vm.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nigerian_states_and_lga/nigerian_states_and_lga.dart';

import '../../../app_widget/app_text.dart';
import '../../../app_widget/custom_dropdown.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';

class AddDeliveryRate extends StatelessWidget {
  const AddDeliveryRate({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<DeliveryViewModel>(
      notDefaultLoading: true,
      onModelReady: (model) {
        model.loadStatesAndLGAs();
      },
      builder: (_, logic, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: "Add Delivery Agents",
          onBackPressed: () {
            navigationService.goBack();
          },
          showMenuIcon: false,
          showNotificationIcon: false,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: logic.formKey,
            child: Padding(
              padding: 16.0.padA,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  10.0.sbH,
                  Center(
                    child: SvgPicture.asset(SvgAssets.appLogo),
                  ),
                  16.0.sbH,
                  AppText(
                    StringValues.createDeliverAgent,
                    style: titleSmall,
                    align: TextAlign.center,
                  ),
                  30.0.sbH,
                  AppTextField(
                    controller: logic.emailNameController,
                    hint: "Email",
                  ),
                  12.0.sbH,
                  AppTextField(
                    controller: logic.lastNameController,
                    hint: "First name",
                  ),
                  12.0.sbH,
                  AppTextField(
                    controller: logic.firstNameController,
                    hint: "last name",
                  ),
                  16.0.sbH,
                  AppTextField(
                    hint: StringValues.phoneNumber,
                    prefix: Container(
                      width: 150.sp,
                      child: Row(
                        children: [
                          10.0.sbW,
                          SvgPicture.asset(
                            SvgAssets.flag,
                            height: 16.sp,
                            width: 16.sw,
                          ),
                          AppText('  +234',
                              style:
                                  normalTextStyle12), // +234 is only for display
                        ],
                      ),
                    ),
                    controller: logic.phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      }
                      if (!RegExp(r'^0\d{10}$').hasMatch(value)) {
                        return 'Enter a valid 11-digit phone number starting with 0';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      logic.phoneNumber = value;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  16.0.sbH,
                  AppTextField(
                    hint: StringValues.businesContact,
                    prefix: Container(
                      width: 150.sp,
                      child: Row(
                        children: [
                          10.0.sbW,
                          SvgPicture.asset(
                            SvgAssets.flag,
                            height: 16.sp,
                            width: 16.sw,
                          ),
                          AppText('  +234',
                              style:
                              normalTextStyle12), // +234 is only for display
                        ],
                      ),
                    ),
                    controller: logic.businessController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      }
                      if (!RegExp(r'^0\d{10}$').hasMatch(value)) {
                        return 'Enter a valid 11-digit phone number starting with 0';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      logic.businessPhone = value;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  16.0.sbH,
                  _buildDropdown(context,
                      value: logic.countries,
                      items: logic.countriesList, onChanged: (value) {
                    logic.onCountryChanged(value ?? "");
                  }, hintText: 'Country'),
                  16.0.sbH,
                  _buildDropdown(context,
                      value: logic.stateValue,
                      items: logic.statesList, onChanged: (value) {
                    logic.onStateChanged(value ?? "");
                  }, hintText: 'State'),
                  16.0.sbH,
                  _buildDropdown(context,
                      value: logic.lgaValue,
                      items: logic.lgaList, onChanged: (value) {
                    logic.onLGAChanged(value ?? "");
                  }, hintText: 'City'),
                  16.0.sbH,
                  _buildDropdown(context,
                      value: logic.wardValue,
                      items: logic.wardList, onChanged: (value) {
                    logic.onWardChanged(value ?? "");
                  }, hintText: 'Area'),
                  16.0.sbH,
                  _buildDropdown(context,
                      value: logic.businessTypes,
                      items: logic.businessTypeSelection, onChanged: (value) {
                    logic.onChangedBusinessType(value ?? "");
                  }, hintText: 'Business Type'),
                  16.0.sbH,
                  Container(
                    width: width(context),
                    decoration: BoxDecoration(color: ColorValues.whiteColor),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "Where is your estate",
                          border: InputBorder.none,
                          contentPadding: 10.0.padA,
                          hintStyle: normalTextStyle),
                      controller: logic.estateController,
                    ),
                  ),
                  40.0.sbH,
                  ValueListenableBuilder<bool>(
                    valueListenable: logic.isFormValid,
                    builder: (context, isValid, child) {
                      return AppButton(
                        text: StringValues.addDeliveryAgent,
                        onTap: isValid
                            ? () {
                                logic.submit();
                              }
                            : null,
                        enabled: isValid,
                      );
                    },
                  ),
                  40.0.sbH,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hintText,
  }) {
    String? selectedValue = items.contains(value) ? value : null;

    return Padding(
      padding: EdgeInsets.all(0.sp),
      child: Container(
        height: 55.sp,
        width: width(context),
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.sp),
        decoration: BoxDecoration(
          color: ColorValues.whiteColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: AppText(
                hintText,
                style: TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontFamily: "Poppins",
                    fontSize: 12),
              ),
            ),
            value: selectedValue,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: AppText(item.toCapitalized()),
                      ),
                    ))
                .toList(),
            onChanged: (newValue) {
              onChanged(newValue);
            },
            icon: Icon(Icons.arrow_drop_down),
            elevation: 0,
            selectedItemBuilder: (BuildContext context) {
              return items.map((String value) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.sp),
                  child: AppText(
                    value.toCapitalized(),
                    style: normalTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
