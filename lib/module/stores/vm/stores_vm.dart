import 'dart:convert';
import 'package:etegram_business/base/base_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app_widget/celebration_widget.dart';
import '../../../constants/reuseable.dart';
import '../../../core/model/store_model.dart';
import '../../../utils/snack_message.dart';

class StoresViewModel extends BaseViewModel {
  // Store Details
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

  // Dropdown Lists
  List<Map<String, dynamic>> statesAndLGAs = [];
  List<String> statesList = [];
  List<String> lgaList = [];
  List<String> wardList = [];
  List<String> currencyChoice = ["Naira", "Us Dollars", "EUROS", "YEN", "Others"];
  List<String> storesListOptions = ["Store", "Warehouse"];
  List<String> storeTypeOption = ["Koisk", "Pharmacy", "Others", "Restaurant", "Recharge Card", "Whole sales", "Supermarket"];
  List<String> classificationOptions = ["Main", 'Branch'];
  List<String> countrySelectionOptions = ["Nigeria", "Gambia"];

  // Form Validation and Editing State
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
  bool isEditing = false;
  Store? selectedStore;

  void onInit() {
    storeNameController.addListener(validateForm);
    loadStatesAndLGAs();
    fetchStores();
  }

  @override
  void dispose() {
    storeNameController.removeListener(validateForm);
    storeNameController.dispose();
    super.dispose();
  }

  // Validation
  void validateForm() {
    isFormValid.value = storeNameController.text.isNotEmpty &&
        stateValue != "Select State" &&
        lgaValue != "Select Local Government" &&
        wardValue != "Select Ward" &&
        selectedStoreCategory.isNotEmpty &&
        selectedCurrency.isNotEmpty;
  }

  // Dropdown Change Handlers
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
    notifyListeners();
  }

  void onStateChanged(String value) {
    stateValue = value;
    lgaValue = 'Select Local Government';
    wardValue = 'Select Ward';

    var selectedState = statesAndLGAs.firstWhere(
          (state) => state['state'] == value,
      orElse: () => {},
    );

    lgaList = ['Select Local Government'];
    lgaList.addAll(selectedState.isNotEmpty
        ? selectedState['lgas'].map<String>((lga) => lga['lga'].toString()).toList()
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
        ? selectedState['lgas'].firstWhere((lga) => lga['lga'] == value, orElse: () => {})
        : {};

    wardList = ['Select Ward'];
    wardList.addAll(selectedLGA.isNotEmpty ? selectedLGA['wards'].cast<String>() : []);
    validateForm();
    notifyListeners();
  }

  void onWardChanged(String value) {
    wardValue = value;
    validateForm();
    notifyListeners();
  }

  // Load States and LGAs
  Future<void> loadStatesAndLGAs() async {
    try {
      String jsonString = await rootBundle.loadString('assets/wards.json');
      List<dynamic> jsonData = json.decode(jsonString);
      statesAndLGAs = jsonData.cast<Map<String, dynamic>>();

      statesList = ["Select State"];
      statesList.addAll(statesAndLGAs.map((state) => state['state'].toString()).toList());
      notifyListeners();
    } catch (e) {
      print("Error loading JSON: $e");
      showCustomToast("Error loading state and LGA data.", success: false);
    }
  }

  // Editing State Management
  void setEditing(Store? store) {
    isEditing = store != null;
    selectedStore = store;

    if (isEditing && selectedStore != null) {
      storeNameController.text = selectedStore!.name ?? "";
      selectedStoreType = selectedStore?.type ?? "";
      selectedStoreClassification = selectedStore?.classification ?? "";
      selectedCountry = selectedStore?.country ?? "";
      stateValue = selectedStore?.state ?? "";
      lgaValue = selectedStore?.lga ?? "";
      selectedCurrency = selectedStore?.currency ?? '';
      wardValue = selectedStore?.area ?? "";
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
    notifyListeners();
  }

  // Save Store (Create or Update)
  Future<void> saveStore(BuildContext context) async {
    startLoader();
    try {
      String ownerId = userService.customer.id ?? '';
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
        // Call the updateStore method with the store ID and store data
        savedStore = await storeRepository.updateStore(store, selectedStore!.id!);
      } else {
        // Call the createStore method with the store data
        savedStore = await storeRepository.createStore(store);
      }

      if (savedStore != null) {
        showCustomToast(
            isEditing ? "Store updated successfully!" : "Store created successfully!",
            success: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CelebrationWidget(
              title: isEditing ? "Store Updated Successfully!" : "Store Created Successfully!",
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ),
        );
      } else {
        showCustomToast(
            isEditing ? "Failed to update store." : "Failed to create store.",
            success: false);
      }
    } catch (e) {
      showCustomToast("An error occurred: $e", success: false);
      print("Error saving store: $e");
    } finally {
      stopLoader();
      notifyListeners();
    }
  }


  // Fetch Stores
  Future<List<Store>> fetchStores() async {
    startLoader();
    try {
      String ownerId = userService.customer.id ?? '';
      List<Store> stores = await storeRepository.getStoresByOwner(ownerId);
      stopLoader();
      notifyListeners();
      return stores;
    } catch (e) {
      print("Error fetching stores: $e");
      stopLoader();
      notifyListeners();
      return [];
    }
  }

  // Getters for Dropdown Lists
  List<String> getStoresListOptions() => storesListOptions;
  List<String> getStoreTypeOption() => storeTypeOption;
  List<String> getClassificationOptions() => classificationOptions;
  List<String> getCountrySelectionOptions() => countrySelectionOptions;
  List<String> getCurrencyChoiceOptions() => currencyChoice;
}