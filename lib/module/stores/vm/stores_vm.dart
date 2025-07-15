

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/core/model/store_model.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/utils/snack_message.dart';

import '../../../core/model/auth_response.dart';
import '../../../locator.dart';
import '../../../repository/auth_repository.dart';

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

  // void onInit() async {
  //   storeNameController.addListener(validateForm);
  //   await loadStatesAndLGAs();
  //   await fetchStores();
  //   final authResponse = await locator<AuthRepository>().getUser();
  //   customer = authResponse?.data?.user ??
  //       await locator<AuthRepository>().getLocalServiceDetail();
  //   if (customer != null) {
  //     updateBusinessName();
  //   }
  //   notifyListeners();
  // }

  Future<void> onInit() async {
    storeNameController.addListener(validateForm);
    await loadStatesAndLGAs();
    await fetchStores();
    final authResponse = await locator<AuthRepository>().getUser();
    customer = authResponse?.data?.user ??
        await locator<AuthRepository>().getLocalServiceDetail();
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

      statesList = ["Select State"];
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

      Store? savedStore;
      if (isEditing) {
        savedStore =
            await storeRepository.updateStore(store, selectedStore!.id!);
        print("Updated Store Result: $savedStore");
      } else {
        savedStore = await storeRepository.createStore(store);
        print("Created Store Result: $savedStore");
      }

      if (savedStore != null) {
        print("savedStore is NOT null. Proceeding to navigation.");
        showCustomToast(
            isEditing
                ? "Store updated successfully!"
                : "Store created successfully!",
            success: true);
        navigationService.navigateToAndRemoveUntil(addPaymentMethodRoute);
        print("Navigation attempted for route: $addPaymentMethodRoute");
      } else {
        print("savedStore IS null. Navigation skipped.");
        showCustomToast(
            isEditing ? "Failed to update store." : "Failed to create store.",
            success: false);
      }
    } catch (e) {
      print("Error in saveStore: $e");
      showCustomToast("An error occurred: $e", success: false);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<List<Store>> fetchStores() async {
    isLoading.value = true;
    try {
      allStores = await storeRepository.getStoresByOwner();
      print("Fetched ${allStores?.length} stores");
      notifyListeners();
      return allStores ?? [];
    } catch (e) {
      showCustomToast("Error fetching stores: $e", success: false);
      return [];
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<void> deleteStore(String storeId) async {
    isLoading.value = true;
    try {
      await storeRepository.deleteStore(storeId); // Add to StoreRepository
      allStores = allStores?.where((store) => store.id != storeId).toList();
      showCustomToast("Store deleted successfully", success: true);
    } catch (e) {
      showCustomToast("Error deleting store: $e", success: false);
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  void updateBusinessName() {
    businessName = customer?.businessName ?? '';
    notifyListeners();
  }
}
