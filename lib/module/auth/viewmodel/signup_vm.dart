//
//
// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
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
//   var referralNameController = TextEditingController();
//   var passwordNameController = TextEditingController();
//   var phoneController = TextEditingController();
//   var otherBusinessTypeController = TextEditingController();
//   var otherCurrencyController = TextEditingController();
//
//   final ValueNotifier<String?> passwordError = ValueNotifier<String?>(null);
//   final ValueNotifier<String?> businessNameError = ValueNotifier<String?>(null);
//
//   DateTime? dateOfBirth;
//   DateTime dob = DateTime.now();
//   String? countryCode;
//   String? country;
//   String? phoneNumber;
//   final formatter = DateFormat('yyyy-MM-dd');
//   String? selectedCountry;
//   String businessType = "";
//   String selectedCurrency = "";
//   String businessname = "";
//
//   List<Map<String, dynamic>> statesAndLGAs = [];
//   List<String> statesList = [];
//   List<String> lgaList = [];
//   List<String> wardList = [];
//
//   String stateValue = "Select State";
//   String lgaValue = "Select Local Government";
//   String wardValue = "Select Ward";
//
//   bool isChecked = false;
//   bool _showPassword = true;
//
//   bool get showPassword => _showPassword;
//   final ValueNotifier<bool> isLoading = ValueNotifier(false);
//
//   List<String> businessTypeSelections = [
//     "Sole Proprietorship",
//     "Student",
//     "Civil servant",
//     "Business",
//     "Content creator",
//     "Other",
//   ];
//   List<String> currency = ["Naira", "Dollars", "Other"];
//   List<String> countryList = ["Nigeria"];
//
//   final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
//
//   void goToSignInView() {
//     print("Navigating to loginScreenRoute");
//     navigationService.navigateTo(loginScreenRoute);
//   }
//
//   void onInit({Map<String, dynamic>? arguments}) {
//     if (arguments != null && arguments['isWrongEmail'] == true) {
//       restoreFormData();
//     }
//     firstNameController.addListener(() {
//       validateForm();
//     });
//     lastNameController.addListener(validateForm);
//     emailNameController.addListener(validateForm);
//     phoneController.addListener(validateForm);
//     passwordNameController.addListener(() {
//       validatePassword();
//       validateForm();
//     });
//     userNameController.addListener(() {
//       validateBusinessName(userNameController.text);
//       validateForm();
//     });
//     otherBusinessTypeController.addListener(validateForm);
//     otherCurrencyController.addListener(validateForm);
//   }
//
//   void restoreFormData() {
//     final userData = appCache.userData;
//     if (userData != null) {
//       firstNameController.text = userData.firstName ?? "";
//       lastNameController.text = userData.lastName ?? "";
//       userNameController.text = userData.businessName ?? "";
//       emailNameController.text = userData.email ?? "";
//       phoneController.text = userData.phoneNumber ?? "";
//       passwordNameController.text = userData.password ?? "";
//       country = userData.country ?? "Nigeria";
//       stateValue = userData.state ?? "Select State";
//       lgaValue = userData.city ?? "Select Local Government";
//       wardValue = userData.area ?? "Select Ward";
//       businessType = userData.businessType ?? "";
//       selectedCurrency = userData.currency ?? "";
//       otherBusinessTypeController.text =
//           businessType == "Other" ? userData.businessType ?? "" : "";
//       otherCurrencyController.text =
//           selectedCurrency == "Other" ? userData.currency ?? "" : "";
//       isChecked = true; // Assume user agreed to terms
//       validateForm();
//       notifyListeners();
//       print("Restored form data for email: ${userData.email}");
//     }
//   }
//
//   void validatePassword() {
//     final password = passwordNameController.text;
//     if (password.isEmpty) {
//       passwordError.value = null;
//       return;
//     }
//     if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*])')
//         .hasMatch(password)) {
//       passwordError.value =
//           'Password must contain at least one uppercase letter, one lowercase letter, and one special character';
//     } else if (password.length < 8) {
//       passwordError.value = 'Password must be at least 8 characters';
//     } else {
//       passwordError.value = null;
//     }
//     notifyListeners();
//   }
//
//   void validateBusinessName(String value) {
//     if (value.isEmpty) {
//       businessNameError.value = 'Please enter your business name';
//     } else {
//       businessNameError.value = null;
//     }
//     notifyListeners();
//   }
//
//   void validateForm() {
//     isFormValid.value = firstNameController.text.isNotEmpty &&
//         lastNameController.text.isNotEmpty &&
//         emailNameController.text.isNotEmpty &&
//         phoneController.text.isNotEmpty &&
//         passwordNameController.text.isNotEmpty &&
//         userNameController.text.isNotEmpty &&
//         stateValue != "Select State" &&
//         lgaValue != "Select Local Government" &&
//         wardValue != "Select Ward" &&
//         businessType.isNotEmpty &&
//         selectedCurrency.isNotEmpty &&
//         (businessType != "Other" ||
//             otherBusinessTypeController.text.isNotEmpty) &&
//         (selectedCurrency != "Other" ||
//             otherCurrencyController.text.isNotEmpty) &&
//         isChecked &&
//         passwordError.value == null &&
//         businessNameError.value == null;
//     notifyListeners();
//   }
//
//   void onChangedBusiness(String val) {
//     businessType = val;
//     if (val != "Other") {
//       otherBusinessTypeController.clear();
//     }
//     validateForm();
//     notifyListeners();
//   }
//
//   void onChangedCurrency(String val) {
//     selectedCurrency = val;
//     if (val != "Other") {
//       otherCurrencyController.clear();
//     }
//     validateForm();
//     notifyListeners();
//   }
//
//   void onCountryChanged(String val) {
//     country = val;
//     validateForm();
//     notifyListeners();
//   }
//
//   Future<void> loadStatesAndLGAs() async {
//     try {
//       String jsonString = await rootBundle.loadString('assets/wards.json');
//       List<dynamic> jsonData = json.decode(jsonString);
//       statesAndLGAs = jsonData.cast<Map<String, dynamic>>();
//
//       statesList = ["Select State"];
//       statesList.addAll(
//           statesAndLGAs.map((state) => state['state'].toString()).toList());
//       notifyListeners();
//     } catch (e) {
//       print("Error loading JSON: $e");
//       showCustomToast("Failed to load location data");
//     }
//   }
//
//   void onChange(String? val) {
//     formKey.currentState?.validate();
//     validatePassword();
//     validateForm();
//     notifyListeners();
//   }
//
//   void onStateChanged(String value) {
//     stateValue = value;
//     lgaValue = 'Select Local Government';
//     wardValue = 'Select Area';
//
//     var selectedState = statesAndLGAs.firstWhere(
//       (state) => state['state'] == value,
//       orElse: () => {},
//     );
//
//     lgaList = ['Select Local Government'];
//     lgaList.addAll(selectedState.isNotEmpty
//         ? selectedState['lgas']
//             .map<String>((lga) => lga['lga'].toString())
//             .toList()
//         : []);
//
//     wardList = [];
//     validateForm();
//     notifyListeners();
//   }
//
//   void onLGAChanged(String value) {
//     lgaValue = value;
//     wardValue = 'Select Area';
//
//     var selectedState = statesAndLGAs.firstWhere(
//       (state) => state['state'] == stateValue,
//       orElse: () => {},
//     );
//
//     var selectedLGA = selectedState.isNotEmpty
//         ? selectedState['lgas']
//             .firstWhere((lga) => lga['lga'] == value, orElse: () => {})
//         : {};
//
//     wardList = ['Select Ward'];
//     wardList.addAll(
//         selectedLGA.isNotEmpty ? selectedLGA['wards'].cast<String>() : []);
//     validateForm();
//     notifyListeners();
//   }
//
//   void onWardChanged(String value) {
//     wardValue = value;
//     validateForm();
//     notifyListeners();
//   }
//
//   Future<bool> checkEmailVerificationStatus(String email) async {
//     try {
//       final user = await authRepository.getUser();
//       if (user?.data?.user?.email == email &&
//           user?.data?.user?.emailVerified == false) {
//         return false; // User exists but is unverified
//       }
//       return user?.data?.user?.emailVerified ?? true;
//     } catch (e) {
//       print("Error checking email verification status: $e");
//       return true; // Assume verified if check fails
//     }
//   }
//
//   Future<void> submit() async {
//     FocusManager.instance.primaryFocus?.unfocus();
//     isLoading.value = true;
//     notifyListeners();
//
//     try {
//       if (!formKey.currentState!.validate()) {
//         print("Form validation failed");
//         showCustomToast("Please fill in all required fields");
//         isLoading.value = false;
//         notifyListeners();
//         return;
//       }
//
//       String selectedState = stateValue;
//       String selectedLGA = lgaValue;
//       String selectedWard = wardValue;
//       String selectedCountry = country ?? "Nigeria";
//
//       String formattedPhoneNumber = trimPhone(phoneController.text);
//
//       if (!RegExp(r'^0\d{10}$').hasMatch(formattedPhoneNumber)) {
//         print("Invalid phone number: $formattedPhoneNumber");
//         showCustomToast(
//             "Enter a valid 11-digit Nigerian phone number starting with 0");
//         isLoading.value = false;
//         notifyListeners();
//         return;
//       }
//
//       var userData = Customer(
//         firstName: firstNameController.text.trim(),
//         lastName: lastNameController.text.trim(),
//         email: emailNameController.text.trim(),
//         country: selectedCountry,
//         state: selectedState,
//         city: selectedLGA,
//         area: selectedWard,
//         phoneNumber: formattedPhoneNumber,
//         password: passwordNameController.text.trim(),
//         currency: selectedCurrency == "Other"
//             ? otherCurrencyController.text.trim()
//             : selectedCurrency,
//         businessName: userNameController.text.trim(),
//         businessType: businessType == "Other"
//             ? otherBusinessTypeController.text.trim()
//             : businessType,
//       );
//
//       print("Attempting registration with: ${userData.email}");
//       try {
//         var response = await authRepository.register(customer: userData);
//         print("Register response: ${response.toJson()}");
//         if (response.success == true) {
//           appCache.phoneNumber = formattedPhoneNumber;
//           appCache.userData = userData;
//           appCache.registerResponse = response;
//           print("Registration successful, navigating to verifyEmailView");
//           showCustomToast("Registration successful, kindly verify account",
//               success: true);
//           navigationService.navigateTo(verifyEmailView);
//         } else {
//           print("Registration failed: Response success is false");
//           showCustomToast("Registration failed: Invalid response");
//         }
//       } on DioException catch (e) {
//         if (e.response?.statusCode == 409) {
// // Check if the user is unverified
//           bool isVerified =
//               await checkEmailVerificationStatus(userData.email ?? '');
//           if (!isVerified) {
//             appCache.userData = userData;
//             appCache.phoneNumber = formattedPhoneNumber;
//             print(
//                 "User exists but is unverified, navigating to verifyEmailView");
//             showCustomToast("Email already exists, please verify your account",
//                 success: true);
//             await authRepository.resendOTP(email: userData.email ?? '');
//             navigationService.navigateTo(verifyEmailView);
//           } else {
//             showCustomToast(
//                 "User with email ${userData.email} already exists and is verified");
//           }
//         } else {
//           throw e;
//         }
//       }
//     } on DioException catch (e) {
//       print("Caught DioException in SignUpViewModel: ${e.message}");
//       String errorMessage = "An error occurred during registration";
//       if (e.response != null && e.response!.data is Map) {
//         final statusCode = e.response!.statusCode;
//         final data = e.response!.data as Map;
//         print("Register Dio Error: $data");
//         errorMessage = data['message'] ?? "Server error: $statusCode";
//         if (statusCode == 400) {
//           errorMessage = data['message'] ?? "Invalid registration details";
//         } else if (statusCode == 404) {
//           errorMessage = "Unexpected error: Server endpoint not found";
//         }
//       } else {
//         errorMessage = "Network error, please check your connection";
//       }
//       print("Calling showCustomToast with: $errorMessage");
//       showCustomToast(errorMessage);
//     } catch (e) {
//       print("Unexpected error in SignUpViewModel: $e");
//       showCustomToast("Unexpected error during registration");
//     } finally {
//       isLoading.value = false;
//       notifyListeners();
//     }
//   }
//
//   String trimPhone(String phone) {
//     return phone.replaceAll(RegExp(r'\s+'), '');
//   }
//
//   @override
//   void dispose() {
//     firstNameController.dispose();
//     lastNameController.dispose();
//     userNameController.dispose();
//     emailNameController.dispose();
//     referralNameController.dispose();
//     passwordNameController.dispose();
//     otherBusinessTypeController.dispose();
//     otherCurrencyController.dispose();
//     passwordError.dispose();
//     businessNameError.dispose();
//     super.dispose();
//   }
// }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../../base/base_vm.dart';
import '../../../constants/reuseable.dart';
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
  var otherBusinessTypeController = TextEditingController();
  var otherCurrencyController = TextEditingController();

  final ValueNotifier<String?> passwordError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> businessNameError = ValueNotifier<String?>(null);

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
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  List<String> businessTypeSelections = [
    "Sole Proprietorship",
    "Student",
    "Civil servant",
    "Business",
    "Content creator",
    "Other",
  ];
  List<String> currency = ["Naira", "Dollars", "Other"];
  List<String> countryList = ["Nigeria"];

  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

  void goToSignInView() {
    print("Navigating to loginScreenRoute");
    navigationService.navigateTo(loginScreenRoute);
  }

  void onInit({Map<String, dynamic>? arguments}) {
// Load persisted data if available
    restoreFormData();
    if (arguments != null && arguments['isWrongEmail'] == true) {
      print("Returning from VerifyEmailView with isWrongEmail: true");
      restoreFormData();
    }
    firstNameController.addListener(() {
      validateForm();
      persistFormData();
    });
    lastNameController.addListener(() {
      validateForm();
      persistFormData();
    });
    emailNameController.addListener(() {
      validateForm();
      persistFormData();
    });
    phoneController.addListener(() {
      validateForm();
      persistFormData();
    });
    passwordNameController.addListener(() {
      validatePassword();
      validateForm();
      persistFormData();
    });
    userNameController.addListener(() {
      validateBusinessName(userNameController.text);
      validateForm();
      persistFormData();
    });
    otherBusinessTypeController.addListener(() {
      validateForm();
      persistFormData();
    });
    otherCurrencyController.addListener(() {
      validateForm();
      persistFormData();
    });
  }

  void persistFormData() {
    final userData = Customer(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailNameController.text.trim(),
      country: country ?? "Nigeria",
      state: stateValue != "Select State" ? stateValue : null,
      city: lgaValue != "Select Local Government" ? lgaValue : null,
      area: wardValue != "Select Ward" ? wardValue : null,
      phoneNumber: phoneController.text.trim(),
      password: passwordNameController.text.trim(),
      currency: selectedCurrency == "Other"
          ? otherCurrencyController.text.trim()
          : selectedCurrency,
      businessName: userNameController.text.trim(),
      businessType: businessType == "Other"
          ? otherBusinessTypeController.text.trim()
          : businessType,
    );
    appCache.userData = userData;
    final box = GetStorage();
    box.write(DbTable.customerTableName, jsonEncode(userData.toJson()));
    print("Persisted form data for email: ${userData.email}");
  }

  void restoreFormData() {
    final box = GetStorage();
    final storedData = box.read(DbTable.customerTableName);
    if (storedData != null) {
      try {
        final userData = Customer.fromJson(jsonDecode(storedData));
        appCache.userData = userData;
        firstNameController.text = userData.firstName ?? "";
        lastNameController.text = userData.lastName ?? "";
        userNameController.text = userData.businessName ?? "";
        emailNameController.text = userData.email ?? "";
        phoneController.text = userData.phoneNumber ?? "";
        passwordNameController.text = userData.password ?? "";
        country = userData.country ?? "Nigeria";
        stateValue = userData.state ?? "Select State";
        lgaValue = userData.city ?? "Select Local Government";
        wardValue = userData.area ?? "Select Ward";
        businessType = userData.businessType ?? "";
        selectedCurrency = userData.currency ?? "";
        otherBusinessTypeController.text =
            businessType == "Other" ? userData.businessType ?? "" : "";
        otherCurrencyController.text =
            selectedCurrency == "Other" ? userData.currency ?? "" : "";
        isChecked = true;
        validateForm();
        notifyListeners();
        print("Restored form data for email: ${userData.email}");
      } catch (e) {
        print("Error restoring form data: $e");
      }
    }
  }

  void validatePassword() {
    final password = passwordNameController.text;
    if (password.isEmpty) {
      passwordError.value = null;
      return;
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*])')
        .hasMatch(password)) {
      passwordError.value =
          'Password must contain at least one uppercase letter, one lowercase letter, and one special character';
    } else if (password.length < 8) {
      passwordError.value = 'Password must be at least 8 characters';
    } else {
      passwordError.value = null;
    }
    notifyListeners();
  }

  void validateBusinessName(String value) {
    if (value.isEmpty) {
      businessNameError.value = 'Please enter your business name';
    } else {
      businessNameError.value = null;
    }
    notifyListeners();
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
        (businessType != "Other" ||
            otherBusinessTypeController.text.isNotEmpty) &&
        (selectedCurrency != "Other" ||
            otherCurrencyController.text.isNotEmpty) &&
        isChecked &&
        passwordError.value == null &&
        businessNameError.value == null;
    notifyListeners();
  }

  void onChangedBusiness(String val) {
    businessType = val;
    if (val != "Other") {
      otherBusinessTypeController.clear();
    }
    validateForm();
    persistFormData();
    notifyListeners();
  }

  void onChangedCurrency(String val) {
    selectedCurrency = val;
    if (val != "Other") {
      otherCurrencyController.clear();
    }
    validateForm();
    persistFormData();
    notifyListeners();
  }

  void onCountryChanged(String val) {
    country = val;
    validateForm();
    persistFormData();
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
      showCustomToast("Failed to load location data");
    }
  }

  void onChange(String? val) {
    formKey.currentState?.validate();
    validatePassword();
    validateForm();
    persistFormData();
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
    persistFormData();
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
    persistFormData();
    notifyListeners();
  }

  void onWardChanged(String value) {
    wardValue = value;
    validateForm();
    persistFormData();
    notifyListeners();
  }

  Future<bool> checkEmailVerificationStatus(String email) async {
    try {
      return await authRepository.checkEmailVerificationStatus(email);
    } catch (e) {
      print("Error checking email verification status: $e");
      return true; // Assume verified if check fails
    }
  }

  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    notifyListeners();

    try {
      if (!formKey.currentState!.validate()) {
        print("Form validation failed");
        showCustomToast("Please fill in all required fields");
        isLoading.value = false;
        notifyListeners();
        return;
      }

      String selectedState = stateValue;
      String selectedLGA = lgaValue;
      String selectedWard = wardValue;
      String selectedCountry = country ?? "Nigeria";

      String formattedPhoneNumber = trimPhone(phoneController.text);

      if (!RegExp(r'^0\d{10}$').hasMatch(formattedPhoneNumber)) {
        print("Invalid phone number: $formattedPhoneNumber");
        showCustomToast(
            "Enter a valid 11-digit Nigerian phone number starting with 0");
        isLoading.value = false;
        notifyListeners();
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
        phoneNumber: formattedPhoneNumber,
        password: passwordNameController.text.trim(),
        currency: selectedCurrency == "Other"
            ? otherCurrencyController.text.trim()
            : selectedCurrency,
        businessName: userNameController.text.trim(),
        businessType: businessType == "Other"
            ? otherBusinessTypeController.text.trim()
            : businessType,
      );

      print("Attempting registration with: ${userData.email}");
      try {
        var response = await authRepository.register(customer: userData);
        print("Register response: ${response.toJson()}");
        if (response.success == true) {
          appCache.phoneNumber = formattedPhoneNumber;
          appCache.userData = userData;
          persistFormData();
          print("Registration successful, navigating to verifyEmailView");
          showCustomToast("Registration successful, kindly verify account",
              success: true);
          navigationService.navigateTo(verifyEmailView);
        } else {
          print("Registration failed: Response success is false");
          showCustomToast("Registration failed: Invalid response");
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 409) {
          // bool isVerified = await checkEmailVerificationStatus(userData.email??'');
          if (userData.email == null || userData.email!.isEmpty) {
            showCustomToast("Email address is missing.");
            return;
          }

          bool isVerified = await checkEmailVerificationStatus(userData.email!);

          if (!isVerified) {
            appCache.userData = userData;
            persistFormData();
            print(
                "User exists but is unverified, navigating to verifyEmailView");
            showCustomToast("Email already exists, please verify your account",
                success: true);
            await authRepository.resendOTP(email: userData.email!);
            navigationService.navigateTo(verifyEmailView);
          } else {
            showCustomToast(
                "User with email ${userData.email} already exists and is verified");
          }
        } else {
          throw e;
        }
      }
    } on DioException catch (e) {
      print("Caught DioException in SignUpViewModel: ${e.message}");
      String errorMessage = "An error occurred during registration";
      if (e.response != null && e.response!.data is Map) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data as Map;
        print("Register Dio Error: $data");
        errorMessage = data['message'] ?? "Server error: $statusCode";
        if (statusCode == 400) {
          errorMessage = data['message'] ?? "Invalid registration details";
        } else if (statusCode == 404) {
          errorMessage = "Unexpected error: Server endpoint not found";
        }
      } else {
        errorMessage = "Network error, please check your connection";
      }
      print("Calling showCustomToast with: $errorMessage");
      showCustomToast(errorMessage);
    } catch (e) {
      print("Unexpected error in SignUpViewModel: $e");
      showCustomToast("Unexpected error during registration");
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  String trimPhone(String phone) {
    return phone.replaceAll(RegExp(r'\s+'), '');
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    emailNameController.dispose();
    referralNameController.dispose();
    passwordNameController.dispose();
    otherBusinessTypeController.dispose();
    otherCurrencyController.dispose();
    passwordError.dispose();
    businessNameError.dispose();
    super.dispose();
  }
}
