import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nigerian_states_and_lga/nigerian_states_and_lga.dart';

import '../../../app_widget/bottom_sheet.dart';
import '../../../app_widget/celebration_widget.dart';
import '../../../app_widget/success_pupup_widget.dart';
import '../../../core/model/supplier.dart';
import '../../../utils/snack_message.dart';

class SupplierViewModel extends BaseViewModel {
  final businessNameController = TextEditingController();
  final contactNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final accountDetailsController = TextEditingController();
  final addressController = TextEditingController();
  final countryController = TextEditingController();

  String supplyType = "";
  String selectedStoreCategory = "Retail";
  String selectedStoreType = "";
  String selectedStoreClassification = "";
  String selectedStoreFrom = ""; // Clarified what this is for.
  String selectedCountry = "Nigeria";
  String stateValue = "Select State";
  String lgaValue = "Select Local Government";
  String wardValue = "Select Ward";
  String selectedCurrency = "Naira";
  var storeNameController = TextEditingController();
  List<Map<String, dynamic>> statesAndLGAs = [];
  List<String> statesList = [];
  List<String> lgaList = [];
  List<String> wardList = [];
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
  Supplier? supplier;
  String? supplierId;
  bool isEditing = false;
  final formKey = GlobalKey<FormState>();

  void setEditing(Supplier? supplier) {
    isEditing = supplier != null;
    supplierId = supplier?.id;

    if (isEditing && supplier != null) {
      businessNameController.text = supplier.businessName;
      contactNameController.text = supplier.contactName;
      emailController.text = supplier.email;
      phoneNumberController.text = supplier.phoneNumber;
      selectedCurrency = supplier.currency;
      accountDetailsController.text = supplier.accountDetails.toString();
      addressController.text = supplier.address;
      selectedCountry = supplier.country;
      stateValue = supplier.state;
      lgaValue = supplier.lga;
      wardValue = supplier.area;
      notifyListeners();
      return;
    }
    businessNameController.clear();
    contactNameController.clear();
    emailController.clear();
    phoneNumberController.clear();
    selectedCurrency = 'Naira';
    accountDetailsController.clear();
    addressController.clear();
    selectedCountry = 'Nigeria';
    stateValue = 'Select State';
    lgaValue = 'Select Local Government';
    wardValue = 'Select Ward';
    notifyListeners();
  }

  @override
  void dispose() {
    businessNameController.dispose();
    contactNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    accountDetailsController.dispose();
    addressController.dispose();
    countryController.dispose();
    super.dispose();
  }

  void onInit() {
    storeNameController.addListener(validateForm);
    phoneNumberController.addListener(validateForm);
    emailController.addListener(validateForm);
    accountDetailsController.addListener(validateForm);
    addressController.addListener(validateForm);
    businessNameController.addListener(validateForm);
    loadStatesAndLGAs();
    setEditing(supplier);
  }

  void validateForm() {
    isFormValid.value = storeNameController.text.isNotEmpty &&
        stateValue != "Select State" &&
        lgaValue != "Select Local Government" &&
        wardValue != "Select Ward" &&
        selectedStoreCategory.isNotEmpty &&
        selectedCurrency.isNotEmpty;
  }

  void onCurrencyChanged(String currency) {
    selectedCurrency = currency;
    validateForm();
    notifyListeners();
  }

  void onCountryChanged(String country) {
    selectedCountry = country;
    notifyListeners();
  }

  Future<void> loadStatesAndLGAs() async {
    try {
      String jsonString = await rootBundle.loadString('assets/wards.json');
      List<dynamic> jsonData = json.decode(jsonString);
      statesAndLGAs = jsonData.cast<Map<String, dynamic>>();

      statesList = ["Select State"];
      statesList.addAll(
          statesAndLGAs.map((state) => state['state'].toString()).toList());
      notifyListeners();
    } catch (e) {
      print("Error loading JSON: $e");
      showCustomToast("Error loading state and LGA data.", success: false);
    }
  }

  void onStateChanged(String value) {
    stateValue = value;
    lgaValue = 'Select Local Government';
    wardValue = 'Select Area';

    var selectedState = statesAndLGAs.firstWhere(
      (state) => state['state'] == value,
      orElse: () => {},
    );

    lgaList = ['Select Local Government'];
    lgaList.addAll(selectedState.isNotEmpty
        ? selectedState['lgas']
            .map<String>((lga) => lga['lga'].toString())
            .toList()
        : []);

    wardList = [];
    validateForm();
    notifyListeners();
  }

  void onLGAChanged(String value) {
    lgaValue = value;
    wardValue = 'Select Ward';

    var selectedState = statesAndLGAs.firstWhere(
      (state) => state['state'] == stateValue,
      orElse: () => {},
    );

    var selectedLGA = selectedState.isNotEmpty
        ? selectedState['lgas']
            .firstWhere((lga) => lga['lga'] == value, orElse: () => {})
        : {};

    wardList = ['Select Ward'];
    wardList.addAll(
        selectedLGA.isNotEmpty ? selectedLGA['wards'].cast<String>() : []);
    validateForm();
    notifyListeners();
  }

  void onWardChanged(String value) {
    wardValue = value;
    validateForm();
    notifyListeners();
  }

  List<String> supplierType = [
    'Bussiness Type',
    'Sole Proprietorship',
    'Coorperate Business',
    'Self Employed',
    'Student',
    'Online',
    'YouTube',
    'WhatsApp',
    'Other',
  ];

  List<String> currency = ["Naira", "Us Dollars", "EUROS", "YEN", "Others"];

  List<String> countryList = ["Nigeria", "Others"];

  onChangeSupplyType(String supply) {
    supplyType = supply;
    notifyListeners();
  }

  onChange(String? val) {
    formKey.currentState?.validate();
    notifyListeners();
  }

  Future<void> addSupplier(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    startLoader();
    try {
      // Convert accountDetails to a string
      String accountDetails = accountDetailsController.text;

      Supplier newSupplier = Supplier(
        businessName: businessNameController.text,
        contactName: contactNameController.text,
        email: emailController.text,
        phoneNumber: phoneNumberController.text,
        currency: selectedCurrency,
        accountDetails: accountDetails, // Keep it as String
        address: addressController.text,
        country: selectedCountry,
        state: stateValue,
        lga: lgaValue,
        area: wardValue,
      );

      Supplier? createdSupplier =
          await supplyRepository.createSupplier(newSupplier);

      if (createdSupplier != null) {
        showCustomToast("Supplier added successfully!", success: true);
        navigationService.goBack();
        await showSuccessPopup();
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => CelebrationWidget(
        //       title: "Supplier Added Successfully!",
        //       onTap: () {
        //         Navigator.pop(context);
        //         Navigator.pop(context);
        //       },
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         children: [AppText("text")],
        //       ),
        //     ),
        //   ),
        // );
      } else {
        showCustomToast("Failed to add supplier.", success: false);
      }
    } catch (e) {
      print("Error adding supplier: $e");
      showCustomToast("An error occurred: $e", success: false);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> updateSupplier(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    startLoader();
    try {
      // Ensure accountDetails is converted to an integer
      int accountDetails = int.tryParse(accountDetailsController.text) ?? 0;

      Supplier updatedSupplier = Supplier(
        id: supplierId,
        businessName: businessNameController.text,
        contactName: contactNameController.text,
        email: emailController.text,
        phoneNumber: phoneNumberController.text,
        currency: selectedCurrency,
        accountDetails:
            accountDetails.toString(), // Pass the integer value here
        address: addressController.text,
        country: selectedCountry,
        state: stateValue,
        lga: lgaValue,
        area: wardValue,
      );

      Supplier? result = await supplyRepository.updateSupplier(updatedSupplier);

      if (result != null) {
        showCustomToast("Supplier updated successfully!", success: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CelebrationWidget(
              title: "Supplier Updated Successfully!",
              onTap: () {
                navigationService.goBack();
                navigationService.goBack();
              },
            ),
          ),
        );
      } else {
        showCustomToast("Failed to update supplier.", success: false);
      }
    } catch (e) {
      print("Error updating supplier: $e");
      showCustomToast("An error occurred: $e", success: false);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> saveSupplier(BuildContext context) async {
    if (isEditing) {
      await updateSupplier(context);
    } else {
      await addSupplier(context);
    }
  }

  showSuccessPopup() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: navigationService.navigatorKey.currentState!.context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
        child: SuccessfulPopUpWidget(
          title: "Pin changed successfully!",
          subTitle: "Your pin has been changed successfully.",
          onTap: navigationService.goBack,
        ),
      ),
    ).whenComplete(navigationService.goBack);
  }

  getAllSuppliers()async{
    try{

    }on DioException catch(e){

    }
  }
}
