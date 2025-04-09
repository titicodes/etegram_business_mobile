import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/celebration_widget.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/stores/vm/stores_vm.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../app_widget/custom_dropdown.dart';

class NewStores extends StatelessWidget {
  const NewStores({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<StoresViewModel>(
      builder: (_, logic, child) => Scaffold(
        appBar: CustomAppBar(
          title: "New Store/Warehouse",
          onBackPressed: () {
            navigationService.goBack();
          },
          showNotificationIcon: false,
          showMenuIcon: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(
                StringValues.storeWarehouse,
                style: headerTextStyle,
              ),
              20.0.sbH,
              RichText(
                text: TextSpan(
                  text: StringValues.branchOf,
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: ' Company name',
                        style: normalTextStyle12.copyWith(
                            color: ColorValues.primaryColor)),
                  ],
                ),
              ),
              20.0.sbH,
              CustomDropDown(
                width: double.infinity,
                hintText: "I am creating a...",
                items: logic.getStoresListOptions(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                prefix: Icon(Icons.category, color: Colors.grey),
                onChanged: (value) {
                  logic.onStoreCategoryChanged(value);
                },
              ),
              10.0.sbH,
              AppTextField(
                hintText: StringValues.typStoreName,
                controller: logic.storeNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your store name';
                  }
                  return null;
                },
              ),
              10.0.sbH,
              CustomDropDown(
                width: double.infinity,
                hintText: "Store type",
                items: logic.getStoreTypeOption(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                prefix: Icon(Icons.category, color: Colors.grey),
                onChanged: (value) {
                  logic.onStoreTypeChanged(value);
                },
              ),
              10.0.sbH,
              CustomDropDown(
                width: double.infinity,
                hintText: "Store Classification",
                items: logic.getClassificationOptions(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                prefix: Icon(Icons.category, color: Colors.grey),
                onChanged: (value) {
                  logic.onStoreClassificationChanged(value);
                },
              ),
              10.0.sbH,
              CustomDropDown(
                width: double.infinity,
                hintText: "Country",
                items: logic.getCountrySelectionOptions(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                prefix: Icon(Icons.category, color: Colors.grey),
                onChanged: (value) {
                  logic.onCountryChanged(value);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: ColorValues.whiteColor,
                  border: Border.all(color: Colors.grey, width: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: DropdownButton<String>(
                  onChanged: (val) => logic.onStateChanged(val?? ""),
                  key: const ValueKey('States'),
                  value: logic.stateValue,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint:
                      Text('What state are you located in?', style: titleLarge),
                  items: logic.statesList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: AppText(
                        value,
                        style: TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontFamily: "Poppins",
                            fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ),
              10.0.sbH,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                decoration: BoxDecoration(
                  color: ColorValues.whiteColor,
                  border: Border.all(color: Colors.grey, width: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  onChanged: (value) => logic.onLGAChanged(value!),
                  key: const ValueKey('Local governments'),
                  value: logic.lgaValue,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: Text('What LGA are you located in?',
                      style: normalTextStyle12),
                  items: logic.lgaList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: AppText(
                        value,
                        style: TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontFamily: "Poppins",
                            fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ),
              10.0.sbH,
              CustomDropDown(
                width: double.infinity,
                hintText: "Currency",
                items: logic.getCurrencyChoiceOptions(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                prefix: Icon(Icons.category, color: Colors.grey),
                onChanged: (value) {
                  logic.onCurrencyChanged(value);
                },
              ),
              10.0.sbH,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                decoration: BoxDecoration(
                  color: ColorValues.whiteColor,
                  border: Border.all(color: Colors.grey, width: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  onChanged: (value) => logic.onWardChanged(value!),
                  key: const ValueKey('Local governments'),
                  value: logic.wardValue,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: Text('What Area is your store located in?',
                      style: normalTextStyle12),
                  items: logic.wardList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: AppText(
                        value,
                        style: TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontFamily: "Poppins",
                            fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ),
              40.0.sbH,
              ValueListenableBuilder<bool>(
                valueListenable: logic.isFormValid,
                builder: (context, isValid, child) {
                  return AppButton(
                    text: logic.isEditing ? StringValues.updateStore : StringValues.addStore, // Change button text
                    onTap: isValid
                        ? () {
                      logic.saveStore(context); // Use saveStore method
                    }
                        : () {
                      showCustomToast("Please fill all required fields", success: false);
                    },
                  );
                },
              ),
              30.0.sbH
            ],
          ),
        ),
      ),
    );
  }
}

void _showSucces(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => CelebrationWidget(
      title: "Store Created Successfully!",
      onTap: () {
        navigationService.goBack();
      },
    ),
  );
}
