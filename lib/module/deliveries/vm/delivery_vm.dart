import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/delivery_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nigerian_states_and_lga/nigerian_states_and_lga.dart';

import '../../../app_widget/bottom_sheet.dart';
import '../../../app_widget/success_pupup_widget.dart';
import '../../../utils/snack_message.dart';

class DeliveryViewModel extends BaseViewModel {
  String businessTypes = "";
  var phoneController = TextEditingController();
  var businessController = TextEditingController();
  var emailNameController = TextEditingController();
  var firstNameController = TextEditingController();
  var businessNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var estateController = TextEditingController();
  String countries = "";
  String area = "";
  String estate = '';
  String? phoneNumber;
  String? businessPhone;
  // State variables
  List<Map<String, dynamic>> statesAndLGAs = [];
  List<String> statesList = [];
  List<String> lgaList = [];
  List<String> wardList = [];

  String stateValue = "Select State";
  String lgaValue = "Select Local Government";
  String wardValue = "Select Ward";
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

  void onInit() {
    phoneController.addListener(validateForm);
    businessController.addListener(validateForm);
    emailNameController.addListener(validateForm);
    phoneController.addListener(validateForm);
    firstNameController.addListener(validateForm);
    lastNameController.addListener(validateForm);
  }

  void validateForm() {
    isFormValid.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        stateValue != "Select State" &&
        lgaValue != "Select Local Government" &&
        wardValue != "Select Ward";

    notifyListeners();
  }

  onChangedBusinessType(String val) {
    businessTypes = val;
    notifyListeners();
  }

  onAreaChanged(String val) {
    area = val;
    notifyListeners();
  }

  onEsatateChanged(String val) {
    estate = val;
    notifyListeners();
  }

  onChangedCountry(String val) {
    countries = val;
    notifyListeners();
  }

  Future<void> loadStatesAndLGAs() async {
    try {
      String jsonString = await rootBundle.loadString('assets/wards.json');
      List<dynamic> jsonData = json.decode(jsonString);
      statesAndLGAs = jsonData.cast<Map<String, dynamic>>();

      statesList = ["Select State"]; // Ensure default option is included
      statesList.addAll(
          statesAndLGAs.map((state) => state['state'].toString()).toList());
      notifyListeners();
    } catch (e) {
      print("Error loading JSON: $e");
    }
  }

  onChange(String? val) {
    formKey.currentState?.validate();
    validateForm();
    notifyListeners();
  }

  // Method to handle LGA selection
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
    wardValue = 'Select Area';

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

  onCountryChanged(String val) {
    countries = val;
    validateForm();
    notifyListeners();
  }

  List<String> businessTypeSelection = ["", "Individual", "Business"];
  List<String> countriesList = ["Nigeia", "Gambia"];
  List<String> areaChoice = ["Uyo 1", "Uyo Urban", "Itu Road"];
  List<String> estateChoie = ["Confi Estate", "Real Eatate"];

  submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    startLoader();
    if (formKey.currentState!.validate()) {
      startLoader();
      try {
        String selectedState = stateValue;
        String selectedLGA = lgaValue;
        String selectedWard = wardValue;
        String selectedCountry = countries ?? "Nigeria";

        // Get and validate the phone number
        String formattedPhoneNumber = phoneController.text.trim();

        if (!RegExp(r'^0\d{10}$').hasMatch(formattedPhoneNumber)) {
          showCustomToast(
              "Enter a valid 11-digit Nigerian phone number starting with 0");
          stopLoader();
          return;
        }

        var delivery = DeliveryData(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailNameController.text.trim(),
          country: selectedCountry,
          state: selectedState,
          city: selectedLGA,
          area: selectedWard,
          phoneNumber: formattedPhoneNumber, // Send only 11 digits
          estate: estateController.text.trim(),
        );

        print(
            "Sending phone number: '${formattedPhoneNumber}' Length: ${formattedPhoneNumber.length}");

        var response = await deliveryRepository.createDelivery(delivery);
        if (response != null) {
          appCache.phoneNumber = formattedPhoneNumber;
          appCache.businessPhone = formattedPhoneNumber;
          appCache.deliveryData = delivery;
          appCache.deliveryData = response;
          showCustomToast("Operation successful, Start Delivering",
              success: true);
          stopLoader();
          notifyListeners();
          await showSuccessPopup();
        } else {
          stopLoader();
          notifyListeners();
          showCustomToast("Operation failed");
        }
      } on DioException {
        stopLoader();
        notifyListeners();
      }
    } else {
      showCustomToast("Input all fields");
    }
  }

  String trimPhone(String phone) {
    return phone.replaceAll(RegExp(r'\s+'), '');
  }

  showSuccessPopup() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: navigationService.navigatorKey.currentState!.context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
        child: SuccessfulPopUpWidget(
          title: "Delivery Agent Created successfully!",
          subTitle: "You are now registered as a delivery agent.",
          onTap: navigationService.goBack,
        ),
      ),
    ).whenComplete(navigationService.goBack);
  }
}
