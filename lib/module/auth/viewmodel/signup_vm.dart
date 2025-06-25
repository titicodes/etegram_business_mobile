// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
//
// import '../../../base/base_vm.dart';
// import '../../../core/model/auth_response.dart';
// import '../../../routes/routes.dart';
// import '../../../utils/snack_message.dart';
//
// class SignUpViewModel extends BaseViewModel {
//   var firstNameController = TextEditingController();
//   var lastNameController = TextEditingController();
//   var userNameController = TextEditingController();
//   var emailNameController = TextEditingController();
//   var phoneController = TextEditingController();
//   var passwordNameController = TextEditingController();
//   var confirmPasswordNameController = TextEditingController();
//
//   String? country = "Nigeria";
//   // Store values as they appear in the JSON (lowercase)
//   String stateValue = "";
//   String lgaValue = "";
//   String wardValue = "";
//   String businessType = "";
//   String selectedCurrency = "";
//   String phoneNumber = "";
//   bool isChecked = false;
//   bool _showPassword = true;
//
//   bool get showPassword => _showPassword;
//   ValueNotifier<bool> isLoading = ValueNotifier(false);
//
//   List<Map<String, dynamic>> statesAndLGAs = [];
//   List<String> statesList = []; // Will store lowercase state names
//   List<String> lgaList = []; // Will store lowercase LGA names
//   List<String> wardList = []; // Will store lowercase ward names
//   List<String> businessTypeSelections = [
//     "Sole Proprietorship",
//     "Student",
//     "Civil servant",
//     "Business",
//     "Content creator"
//   ];
//   List<String> currency = ["Naira", "Dollars"];
//   List<String> countryList = ["Nigeria"];
//
//   final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
//
//   @override // Make sure onInit is an override
//   void onInit() {
//     print("SignUpViewModel: onInit called."); // Debugging
//     firstNameController.addListener(validateForm);
//     lastNameController.addListener(validateForm);
//     emailNameController.addListener(validateForm);
//     phoneController.addListener(validateForm);
//     passwordNameController.addListener(validateForm);
//     userNameController.addListener(validateForm);
//     loadStatesAndLGAs();
//   }
//
//   void validateForm() {
//     isFormValid.value = firstNameController.text.isNotEmpty &&
//         lastNameController.text.isNotEmpty &&
//         emailNameController.text.isNotEmpty &&
//         phoneController.text.isNotEmpty &&
//         passwordNameController.text.isNotEmpty &&
//         userNameController.text.isNotEmpty &&
//         stateValue.isNotEmpty && // Check if a state is actually selected
//         lgaValue.isNotEmpty && // Check if an LGA is actually selected
//         wardValue.isNotEmpty && // Check if a ward is actually selected
//         businessType.isNotEmpty &&
//         selectedCurrency.isNotEmpty &&
//         isChecked;
//     // print("isFormValid: ${isFormValid.value}"); // Debugging for button
//     notifyListeners();
//   }
//
//   void onChangedBusiness(String? val) {
//     businessType = val ?? "";
//     print("Selected Business Type: $businessType"); // Debugging
//     validateForm();
//     notifyListeners();
//   }
//
//   void onChangedCurrency(String? val) {
//     selectedCurrency = val ?? "";
//     print("Selected Currency: $selectedCurrency"); // Debugging
//     validateForm();
//     notifyListeners();
//   }
//
//   void onCountryChanged(String? val) {
//     country = val;
//     print("Selected Country: $country"); // Debugging
//     validateForm();
//     notifyListeners();
//   }
//
//   Future<void> loadStatesAndLGAs() async {
//     print("Attempting to load states and LGAs from assets/wards.json"); // Debugging
//     try {
//       String jsonString = await DefaultAssetBundle.of(navigatorKey.currentContext!)
//           .loadString('assets/wards.json');
//       List<dynamic> jsonData = json.decode(jsonString);
//       statesAndLGAs = jsonData.cast<Map<String, dynamic>>();
//
//       statesList = [];
//       // Populate statesList with lowercase names from JSON
//       statesList.addAll(statesAndLGAs.map((state) => state['state'].toString()).toList());
//       print("States loaded successfully. First 3 states: ${statesList.take(3).toList()}"); // Debugging
//       notifyListeners();
//     } catch (e) {
//       print("Error loading JSON: $e");
//       // Consider showing an error message to the user here
//     }
//   }
//
//   void onChange(String? val) {
//     // This is a generic onChange for AppTextField. No specific dropdown logic here.
//     // formKey.currentState?.validate(); // Removed this as validateForm is already called
//     validateForm();
//     notifyListeners();
//   }
//
//   void onStateChanged(String? value) {
//     print("onStateChanged called with raw value: '$value'"); // Debugging
//     final selectedValue = value?.toLowerCase() ?? "";
//
//     if (selectedValue.isEmpty) {
//       stateValue = "";
//       lgaValue = "";
//       wardValue = "";
//       lgaList = [];
//       wardList = [];
//       print("State deselected or empty value received. Resetting LGA/Ward lists."); // Debugging
//       validateForm(); // Re-validate after clearing
//       notifyListeners();
//       return;
//     }
//
//     stateValue = selectedValue; // Store the lowercase value
//     lgaValue = ""; // Reset LGA when state changes
//     wardValue = ""; // Reset Ward when state changes
//     lgaList = []; // Clear previous LGA list
//     wardList = []; // Clear previous Ward list
//
//     print("State selected (internal): '$stateValue'"); // Debugging
//
//     var selectedState = statesAndLGAs.firstWhere(
//           (state) => state['state'].toString() == stateValue, // Direct match with stored lowercase value
//       orElse: () {
//         print("ERROR: State '$stateValue' not found in loaded statesAndLGAs data!"); // Debugging
//         return {}; // Provide an empty map if not found
//       },
//     );
//
//     if (selectedState.isNotEmpty && selectedState['lgas'] != null) {
//       lgaList.addAll(selectedState['lgas'].map<String>((lga) => lga['lga'].toString()).toList());
//       print("LGA list populated for '$stateValue': ${lgaList.take(3).toList()}"); // Debugging
//     } else {
//       print("No LGAs found for state '$stateValue' or state not found."); // Debugging
//     }
//
//     validateForm();
//     notifyListeners(); // Crucial to update the UI
//   }
//
//   void onLGAChanged(String? value) {
//     print("onLGAChanged called with raw value: '$value'"); // Debugging
//     final selectedValue = value?.toLowerCase() ?? "";
//
//     if (selectedValue.isEmpty) {
//       lgaValue = "";
//       wardValue = "";
//       wardList = [];
//       print("LGA deselected or empty value received. Resetting Ward list."); // Debugging
//       validateForm(); // Re-validate after clearing
//       notifyListeners();
//       return;
//     }
//
//     lgaValue = selectedValue; // Store the lowercase value
//     wardValue = ""; // Reset Ward when LGA changes
//     wardList = []; // Clear previous Ward list
//
//     print("LGA selected (internal): '$lgaValue' for state: '$stateValue'"); // Debugging
//
//     var selectedState = statesAndLGAs.firstWhere(
//           (state) => state['state'].toString() == stateValue, // Use stored lowercase stateValue
//       orElse: () {
//         print("ERROR: Parent state '$stateValue' not found for LGA lookup!"); // Debugging
//         return {};
//       },
//     );
//
//     var selectedLGA = selectedState.isNotEmpty && selectedState['lgas'] != null
//         ? selectedState['lgas'].firstWhere(
//           (lga) => lga['lga'].toString() == lgaValue, // Direct match with stored lowercase lgaValue
//       orElse: () {
//         print("ERROR: LGA '$lgaValue' not found within state '$stateValue' LGAs!"); // Debugging
//         return {};
//       },
//     )
//         : {};
//
//     if (selectedLGA.isNotEmpty && selectedLGA['wards'] != null) {
//       wardList.addAll(selectedLGA['wards'].cast<String>());
//       print("Ward list populated for '$lgaValue': ${wardList.take(3).toList()}"); // Debugging
//     } else {
//       print("No Wards found for LGA '$lgaValue' or LGA not found."); // Debugging
//     }
//
//     validateForm();
//     notifyListeners(); // Crucial to update the UI
//   }
//
//   void onWardChanged(String? value) {
//     print("onWardChanged called with raw value: '$value'"); // Debugging
//     wardValue = value?.toLowerCase() ?? ""; // Store lowercase ward value
//     print("Ward selected (internal): '$wardValue'"); // Debugging
//     validateForm();
//     notifyListeners();
//   }
//
//   void goToSignInView() {
//     navigationService.navigateTo(loginScreenRoute);
//   }
//
//   Future<void> submit() async {
//     if (!formKey.currentState!.validate()) {
//       showCustomToast("Please fill all required fields");
//       return;
//     }
//
//     if (stateValue.isEmpty || lgaValue.isEmpty || wardValue.isEmpty) {
//       showCustomToast("Please select your State, City, and Area.");
//       return;
//     }
//
//     FocusManager.instance.primaryFocus?.unfocus();
//     startLoader();
//     try {
//       String formattedPhoneNumber = phoneController.text.trim();
//
//       if (!RegExp(r'^0\d{10}$').hasMatch(formattedPhoneNumber)) {
//         showCustomToast("Enter a valid 11-digit Nigerian phone number starting with 0");
//         stopLoader();
//         return;
//       }
//
//       var userData = Customer(
//         firstName: firstNameController.text.trim(),
//         lastName: lastNameController.text.trim(),
//         email: emailNameController.text.trim(),
//         country: country ?? "Nigeria",
//         state: stateValue, // Send lowercase value
//         city: lgaValue, // Send lowercase value
//         area: wardValue, // Send lowercase value
//         phone: formattedPhoneNumber,
//         password: passwordNameController.text.trim(),
//         currency: selectedCurrency,
//         businessName: userNameController.text.trim(),
//         businessType: businessType,
//       );
//
//       var response = await authRepository.register(data: userData);
//       if (response?.success == true) {
//         appCache.phoneNumber = formattedPhoneNumber;
//         appCache.userData = userData;
//         appCache.registerResponse = response!;
//         showCustomToast("Registration successful, please verify your account", success: true);
//         stopLoader();
//         notifyListeners();
//         navigationService.navigateTo(verifyEmailView);
//       } else {
//         stopLoader();
//         notifyListeners();
//         showCustomToast(response?.message ?? "Registration failed");
//       }
//     } on DioException catch (e) {
//       stopLoader();
//       notifyListeners();
//       showCustomToast("Registration failed: ${e.response?.data['message'] ?? e.message}");
//     } finally {
//       stopLoader();
//     }
//   }
//
//   String trimPhone(String phone) {
//     return phone.replaceAll(RegExp(r'\s+'), '');
//   }
// }

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
          phoneNumber: formattedPhoneNumber, // Send only 11 digits
          password: passwordNameController.text.trim(),
          currency: selectedCurrency,
          businessName: userNameController.text.trim(),
          businessType: businessType,
        );

        print(
            "Sending phone number: '$formattedPhoneNumber' Length: ${formattedPhoneNumber.length}");

        var response = await authRepository.register(customer: userData);
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