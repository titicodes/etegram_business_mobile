// Modified StoresViewModel
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../base/base_vm.dart';
import '../../../constants/reuseable.dart';
import '../../../core/model/auth_response.dart';
import '../../../core/model/store_model.dart';
import '../../../routes/routes.dart';
import '../../../utils/snack_message.dart';

class StoresViewModel extends BaseViewModel {
  String selectedStoreCategory = "";
  String selectedStoreType = "";
  String selectedStoreClassification = "";
  String selectedCountry = "Nigeria";
  String stateValue = "Select State";
  String lgaValue = "Select Local Government";
  String wardValue = "Select Ward";
  String selectedCurrency = "Naira";
  var storeNameController = TextEditingController();
  List<Store>? allStores = [];
  String businessName = "";
  Customer? customer;

  List<Map<String, dynamic>> statesAndLGAs = [];
  List<String> statesList = [];
  List<String> lgaList = [];
  List<String> wardList = [];
  List<String> currencyChoice = [
    "Naira",
    "US Dollars",
    "EUROS",
    "YEN",
    "Others"
  ];
  List<String> storesListOptions = ["Store", "Warehouse"];
  List<String> storeTypeOption = [
    "Kiosk",
    "Pharmacy",
    "Others",
    "Restaurant",
    "Recharge Card",
    "Wholesale",
    "Supermarket"
  ];
  List<String> classificationOptions = ["Main", "Branch"];
  List<String> countrySelectionOptions = ["Nigeria", "Gambia"];

  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
  bool isEditing = false;
  Store? selectedStore;

  void onInit() async {
    storeNameController.addListener(validateForm);
    await loadStatesAndLGAs();
    await fetchStores();
    customer = await authRepository.getUser() ??
        await authRepository.getLocalServiceDetail();
    if (customer != null) {
      updateBusinessName();
    }
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

  void validateForm() {
    isFormValid.value = storeNameController.text.isNotEmpty &&
        stateValue != "Select State" &&
        lgaValue != "Select Local Government" &&
        wardValue != "Select Ward" &&
        selectedStoreCategory.isNotEmpty &&
        selectedStoreType.isNotEmpty &&
        selectedStoreClassification.isNotEmpty &&
        selectedCurrency.isNotEmpty;
    notifyListeners();
  }

  void onStoreCategoryChanged(String category) {
    selectedStoreCategory = category;
    validateForm();
    notifyListeners();
  }

  void onStoreTypeChanged(String type) {
    selectedStoreType = type;
    validateForm();
    notifyListeners();
  }

  void onStoreClassificationChanged(String classification) {
    selectedStoreClassification = classification;
    validateForm();
    notifyListeners();
  }

  void onCurrencyChanged(String currency) {
    selectedCurrency = currency;
    validateForm();
    notifyListeners();
  }

  void onCountryChanged(String country) {
    selectedCountry = country;
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

  void setEditing(Store? store) {
    isEditing = store != null;
    selectedStore = store;
    if (isEditing && selectedStore != null) {
      storeNameController.text = selectedStore!.name ?? "";
      selectedStoreType = selectedStore!.type ?? "";
      selectedStoreClassification = selectedStore!.classification ?? "";
      selectedCountry = selectedStore!.country ?? "";
      stateValue = selectedStore!.state ?? "";
      lgaValue = selectedStore!.lga ?? "";
      selectedCurrency = selectedStore!.currency ?? '';
      wardValue = selectedStore!.area ?? "";
    } else {
      storeNameController.clear();
      selectedStoreType = '';
      selectedStoreClassification = '';
      selectedCountry = '';
      stateValue = '';
      lgaValue = '';
      selectedCurrency = '';
      wardValue = '';
    }
    validateForm();
    notifyListeners();
  }

  Future<void> saveStore() async {
    if (!isFormValid.value) {
      showCustomToast("Please fill all required fields", success: false);
      return;
    }
    startLoader();
    try {
      String ownerId = userService.customer?.id ?? '';
      Store store = Store(
        id: isEditing ? selectedStore!.id : null,
        name: storeNameController.text,
        type: selectedStoreType,
        classification: selectedStoreClassification,
        country: selectedCountry,
        state: stateValue,
        lga: lgaValue,
        currency: selectedCurrency,
        area: wardValue,
        owner: ownerId,
      );

      Store? savedStore; // Declare it here
      if (isEditing) {
        savedStore = await storeRepository.updateStore(store, selectedStore!.id!);
        print("Updated Store Result: $savedStore"); // Add this print
      } else {
        savedStore = await storeRepository.createStore(store);
        print("Created Store Result: $savedStore"); // Add this print
      }

      // Check the value of savedStore immediately
      if (savedStore != null) {
        print("savedStore is NOT null. Proceeding to navigation."); // Crucial print
        showCustomToast(
            isEditing
                ? "Store updated successfully!"
                : "Store created successfully!",
            success: true);
        navigationService.navigateToAndRemoveUntil(addPaymentMethodRoute);
        print("Navigation attempted for route: $addPaymentMethodRoute"); // Your existing print
      } else {
        print("savedStore IS null. Navigation skipped."); // Crucial print
        showCustomToast(
            isEditing ? "Failed to update store." : "Failed to create store.",
            success: false);
      }
    } catch (e) {
      print("Error in saveStore: $e"); // Ensure this catches unexpected errors
      showCustomToast("An error occurred: $e", success: false);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<List<Store>> fetchStores() async {
    startLoader();
    try {
      allStores = await storeRepository.getStoresByOwner();
      return allStores!;
    } catch (e) {
      showCustomToast("Error fetching stores: $e", success: false);
      return [];
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  void updateBusinessName() {
    businessName = customer?.businessName ?? '';
    notifyListeners();
  }
}
