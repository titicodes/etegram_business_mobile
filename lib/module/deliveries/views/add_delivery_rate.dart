import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/deliveries/vm/delivery_vm.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:etegram_business/utils/widget_extension.dart';

import '../../../app_widget/app_text.dart';

class AddDeliveryRate extends StatelessWidget {
  const AddDeliveryRate({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<DeliveryViewModel>(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) => Stack(
        children: [
          Scaffold(
            backgroundColor: ColorValues.backgroundColor,
            appBar: CustomAppBar(
              title: 'Add Delivery Agent',
              onBackPressed: () => navigationService.goBack(),
              showMenuIcon: false,
            ),
            body: SingleChildScrollView(
              child: Form(
                key: model.formKey,
                child: Padding(
                  padding: 16.0.padA,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      30.0.sbH,
                      Center(
                        child: SvgPicture.asset(SvgAssets.appLogo),
                      ),
                      16.0.sbH,
                      AppText(
                        'Create Delivery Agent',
                        style: titleSmall,
                        align: TextAlign.center,
                      ),
                      30.0.sbH,
                      AppTextField(
                        controller: model.emailController,
                        hint: 'Email',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      12.0.sbH,
                      AppTextField(
                        controller: model.firstNameController,
                        hint: 'First Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),
                      12.0.sbH,
                      AppTextField(
                        controller: model.lastNameController,
                        hint: 'Last Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),
                      16.0.sbH,
                      AppTextField(
                        hint: 'Phone Number',
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
                              AppText('  +234', style: normalTextStyle12),
                            ],
                          ),
                        ),
                        controller: model.phoneController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          if (!RegExp(r'^0\d{10}$').hasMatch(value)) {
                            return 'Enter a valid 11-digit phone number starting with 0';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      16.0.sbH,
                      AppTextField(
                        hint: 'Extra Phone Number',
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
                              AppText('  +234', style: normalTextStyle12),
                            ],
                          ),
                        ),
                        controller: model.extraPhoneController,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !RegExp(r'^0\d{10}$').hasMatch(value)) {
                            return 'Enter a valid 11-digit phone number starting with 0';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      16.0.sbH,
                      _buildDropdown(
                        context,
                        value: model.country,
                        items: model.countryList,
                        onChanged: model.onCountryChanged,
                        hintText: 'Country',
                      ),
                      16.0.sbH,
                      _buildDropdown(
                        context,
                        value: model.state,
                        items: model.statesList,
                        onChanged: model.onStateChanged,
                        hintText: 'State',
                      ),
                      16.0.sbH,
                      _buildDropdown(
                        context,
                        value: model.city,
                        items: model.lgaList,
                        onChanged: model.onCityChanged,
                        hintText: 'City',
                      ),
                      16.0.sbH,
                      _buildDropdown(
                        context,
                        value: model.area,
                        items: model.wardList,
                        onChanged: model.onAreaChanged,
                        hintText: 'Area',
                      ),
                      16.0.sbH,
                      _buildDropdown(
                        context,
                        value: model.supplierType,
                        items: model.supplierTypeList,
                        onChanged: model.onSupplierTypeChanged,
                        hintText: 'Supplier Type',
                      ),
                      16.0.sbH,
                      AppTextField(
                        controller: model.estateController,
                        hint: 'Estate',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Estate is required';
                          }
                          return null;
                        },
                      ),
                      16.0.sbH,
                      AppTextField(
                        controller: model.extraDetailsController,
                        hint: 'Extra Details (Optional)',
                        maxLength: 3,
                      ),
                      40.0.sbH,
                      ValueListenableBuilder<bool>(
                        valueListenable: model.isFormValid,
                        builder: (context, isValid, child) => AppButton(
                          text: 'Add Delivery Agent',
                          onTap: isValid ? () => model.submit(context) : null,
                          enabled: isValid,
                        ),
                      ),
                      40.0.sbH,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (model.isLoading.value)
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
                  fontFamily: 'Poppins',
                  fontSize: 12,
                ),
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
            onChanged: onChanged,
            icon: Icon(Icons.arrow_drop_down),
            elevation: 0,
            selectedItemBuilder: (BuildContext context) {
              return items.map((String value) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.sp),
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