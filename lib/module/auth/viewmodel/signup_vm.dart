import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../base/base_vm.dart';
import '../../../core/model/auth_response.dart';
import '../../../routes/routes.dart';
import '../../../utils/snack_message.dart';

class SignUpViewModel extends BaseViewModel {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var userNameController = TextEditingController();
  var emailNameController = TextEditingController();
  var referralNameController = TextEditingController();
  var passwordNameController = TextEditingController();
  var phoneController = TextEditingController();
  var confirmPasswordNameController = TextEditingController();

  DateTime? dateOfBirth;
  DateTime dob = DateTime.now();
  String? countryCode;
  String? country;
  String? phoneNumber;
  final formatter = DateFormat('yyyy-MM-dd');
  String? selectedCountry;
  String businessType = "";
  String selectedCurrency = "";
  String businessname = "";

  List<Map<String, dynamic>> statesAndLGAs = [];
  List<String> statesList = [];
  List<String> lgaList = [];
  List<String> wardList = [];

  String stateValue = "Select State";
  String lgaValue = "Select Local Government";
  String wardValue = "Select Ward";

  bool isChecked = false;
  bool _showPassword = true;

  bool get showPassword => _showPassword;
  final bool _isLoading = false;
  ValueNotifier<bool> isLoading = ValueNotifier(false);


  // @override
  // bool get isLoading => _isLoading;

  List<String> businessTypeSelections = [
    "Sole Proprietorship",
    "Student",
    "Civil servant",
    "Business",
    "Content creator"
  ];
  List<String> currency = ["Naira", "Dollars"];
  List<String> countryList = ["Nigeria"];

  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

  goToSignInView(){
    navigationService.navigateTo(loginScreenRoute);
  }

  void onInit() {
    firstNameController.addListener(validateForm);
    lastNameController.addListener(validateForm);
    emailNameController.addListener(validateForm);
    phoneController.addListener(validateForm);
    passwordNameController.addListener(validateForm);
    userNameController.addListener(validateForm);
  }

  void validateForm() {
    isFormValid.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordNameController.text.isNotEmpty &&
        userNameController.text.isNotEmpty &&
        stateValue != "Select State" &&
        lgaValue != "Select Local Government" &&
        wardValue != "Select Ward" &&
        businessType.isNotEmpty &&
        selectedCurrency.isNotEmpty &&
        isChecked;
    notifyListeners();
  }

  onChangedBusiness(String val) {
    businessType = val;
    validateForm();
    notifyListeners();
  }

  onChangedCurrency(String val) {
    selectedCurrency = val;
    validateForm();
    notifyListeners();
  }

  onCountryChanged(String val) {
    country = val;
    validateForm();
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

  submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    startLoader();
    if (formKey.currentState!.validate()) {
      startLoader();
      try {
        String selectedState = stateValue;
        String selectedLGA = lgaValue;
        String selectedWard = wardValue;
        String selectedCountry = country ?? "Nigeria";

        // Get and validate the phone number
        String formattedPhoneNumber = phoneController.text.trim();

        if (!RegExp(r'^0\d{10}$').hasMatch(formattedPhoneNumber)) {
          showCustomToast(
              "Enter a valid 11-digit Nigerian phone number starting with 0");
          stopLoader();
          return;
        }

        var userData = Customer(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailNameController.text.trim(),
          country: selectedCountry,
          state: selectedState,
          city: selectedLGA,
          area: selectedWard,
          phone: formattedPhoneNumber, // Send only 11 digits
          password: passwordNameController.text.trim(),
          currency: selectedCurrency,
          businessName: userNameController.text.trim(),
          businessType: businessType,
        );

        print(
            "Sending phone number: '${formattedPhoneNumber}' Length: ${formattedPhoneNumber.length}");

        var response = await authRepository.register(data: userData);
        if (response?.success == true) {
          appCache.phoneNumber = formattedPhoneNumber;
          appCache.userData = userData;
          appCache.registerResponse = response!;
          showCustomToast("Registration successful, kindly verify account",
              success: true);
          stopLoader();
          notifyListeners();
          navigationService.navigateTo(verifyEmailView);
        } else {
          stopLoader();
          notifyListeners();
          showCustomToast("\n${response?.message}\n");
        }
      } on DioException {
        stopLoader();
        notifyListeners();
      }
    } else {
      showCustomToast("Input all fields");
    }
  }

// Add this function to your SignUpViewModel
  String trimPhone(String phone) {
    return phone.replaceAll(RegExp(r'\s+'), '');
  }
}
