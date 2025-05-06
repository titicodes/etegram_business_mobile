import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../app_widget/bottom_sheet.dart';
import '../../../app_widget/success_pupup_widget.dart';
import '../../../core/model/auth_response.dart';
import '../../../core/model/product_model.dart';
import '../../../routes/routes.dart';
import '../../../utils/snack_message.dart';

class CustomerViewModel extends BaseViewModel {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late BuildContext context;
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var addressController = TextEditingController();
  var emailNameController = TextEditingController();
  var referralNameController = TextEditingController();
  var passwordNameController = TextEditingController();
  var phoneController = TextEditingController();
  var confirmPasswordNameController = TextEditingController();
  var extraDetailsController = TextEditingController();

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

  DateTime? selectedExpiryDate;
  final _formKey = GlobalKey<FormState>();

  Product? product;

  void initState() {
    getAllCustomers();
    getACustomer();
  }

  /// 📅 Show date picker
  Future<void> selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedExpiryDate ?? currentDate,
      firstDate: DateTime(1930), // Should be a past date
      lastDate: currentDate, // Ensure users can only pick past dates
    );

    if (picked != null) {
      selectedExpiryDate = picked;
      notifyListeners();
    }
  }


  onChange(String? val) {
    formKey.currentState?.validate();
    validateForm();
    notifyListeners();
  }
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

  void onInit() {
    firstNameController.addListener(validateForm);
    lastNameController.addListener(validateForm);
    emailNameController.addListener(validateForm);
    phoneController.addListener(validateForm);
    passwordNameController.addListener(validateForm);

    loadStatesAndLGAs(); // Load states and LGAs here
  }
  void validateForm() {
    isFormValid.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordNameController.text.isNotEmpty &&
        stateValue != "Select State" &&
        lgaValue != "Select Local Government" &&
        wardValue != "Select Ward" &&
        businessType.isNotEmpty &&
        selectedCurrency.isNotEmpty &&
        isChecked;
    notifyListeners();
  }
  List<String> businessTypeSelections = [
    "Sole Proprietorship",
    "Student",
    "Civil servant",
    "Business",
    "Content creator"
  ];
  List<String> currency = ["Naira", "Dollars"];
  List<String> countryList = ["Nigeria"];


  List<CustomerData>? allCustomer;

  Future<List<CustomerData>?> getAllCustomers() async {
    startLoader();
    notifyListeners();
    try {
      var response = await customerRepository.getAllCustomer();
      if (response != null && response.isNotEmpty) {
        allCustomer = response;
      } else {
        allCustomer = [];
      }
      stopLoader();
      notifyListeners();
      return allCustomer;
    } on DioException catch (e) {
      print(e.response);
      stopLoader();
      notifyListeners();
      return null;
    }
  }

  String customerId = "";
  CustomerData? customer;

  Future<CustomerData?> getACustomer() async {
    startLoader();
    notifyListeners();
    try {
      var response = await customerRepository.getACustomer(customerId);
      if (response != null) {
        customer = response;
        showCustomToast("Customer Details successfully Fetched", success: true);
        stopLoader();
        notifyListeners();
        return response;
      } else {
        showCustomToast("Customer Details failed to fetch", success: false);
        stopLoader();
        notifyListeners();
        return null;
      }

    } on DioException catch (e) {
      print(e.response);
      showCustomToast("API error occured", success: false);
      stopLoader();
      notifyListeners();
      return null;
    } catch (e) {
      print("General error: $e");
      showCustomToast("An unexpected error occurred", success: false);
      stopLoader();
      notifyListeners();
      return null;
    }
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
  void onStateChanged(String value) {
    stateValue = value;
    lgaValue = 'Select Local Government';
    wardValue = 'Select Area';

    var selectedState = statesAndLGAs.firstWhere(
          (state) => state['state'] == value,
      orElse: () => {},
    );

    lgaList = ['Select Local Government'];
    if (selectedState.isNotEmpty && selectedState.containsKey('lgas')) {
      lgaList.addAll(List<String>.from(selectedState['lgas']));
    }
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
    country = val;
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

        var userData = CustomerData(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailNameController.text.trim(),
          country: selectedCountry,
          state: selectedState,
          lga: selectedLGA,
          area: selectedWard,
          phoneNumber: formattedPhoneNumber, // Send only 11 digits
          currency: selectedCurrency,
          address: addressController.text.trim(),
          extraDetails: extraDetailsController.text.trim(),
        );

        print(
            "Sending phone number: '${formattedPhoneNumber}' Length: ${formattedPhoneNumber.length}");

        var response = await customerRepository.createCustomer(data: userData);
        if (response?.success == true) {
          appCache.phoneNumber = formattedPhoneNumber;
          appCache.customerData = userData;
          appCache.customerResponse = response!;
          showCustomToast("Registration successful, kindly verify account",
              success: true);
          stopLoader();
          notifyListeners();
          await showSuccessPopup();
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

  showSuccessPopup() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: navigationService.navigatorKey.currentState!.context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
        child: SuccessfulPopUpWidget(
          title: "Customer Created successfully!",
          subTitle:
          "You are successfully created as a customer on Etegram Business.",
          onTap: navigationService.goBack,
        ),
      ),
    ).whenComplete(navigationService.goBack);
  }

}




