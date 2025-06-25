// Placeholder for CustomerViewModel. You need to apply these changes to your actual file.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for rootBundle
import 'package:intl/intl.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/core/model/store_model.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:dio/dio.dart'; // Make sure Dio is imported if used in base_vm or repositories
import 'package:etegram_business/locator.dart'; // Assuming locator is used
import 'package:etegram_business/service/local/user_service.dart'; // Assuming customerService is here
import 'package:etegram_business/service/local/storage_service.dart'; // Assuming storageService is here
import 'package:etegram_business/service/web/customer_api_service.dart'; // Import CustomerApiService
import 'dart:convert';

import '../../../app_widget/bottom_sheet.dart';
import '../../../app_widget/success_pupup_widget.dart'; // Import for jsonDecode



class CustomerViewModel extends BaseViewModel {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final extraPhoneController = TextEditingController();
  final extraDetailsController = TextEditingController();
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
  final ValueNotifier<String?> selectedStoreId = ValueNotifier<String?>(null);
  DateTime?
      _selectedBirthday; // Use private for direct modification, public getter/setter
  DateTime? get selectedBirthday => _selectedBirthday;
  set selectedBirthday(DateTime? value) {
    _selectedBirthday = value;
    validateForm(); // Re-validate form when birthday changes
    notifyListeners(); // Notify listeners to update UI
  }

  // The ViewModel will now directly use customerService.stores, no longer maintain its own _stores list
  List<Store> get stores => customerService.stores;

  List<CustomerData>? allCustomers;
  CustomerData? customer;
  String? customerId;

  String country = 'Nigeria';
  String? state;
  String? lga;
  String? area;
  List<Map<String, dynamic>> statesAndLGAs = [];
  List<String> statesList = ['Select State'];
  List<String> lgaList = ['Select LGA'];
  List<String> wardList = ['Select Area'];
  List<String> countryList = [
    'Nigeria'
  ]; // Consider making this dynamic if needed

  final CustomerService customerService = locator<CustomerService>();
  final StorageService storageService = locator<StorageService>();

  CustomerViewModel() {
    // Add listeners in the constructor for immediate setup
    firstNameController.addListener(validateForm);
    lastNameController.addListener(validateForm);
    emailController.addListener(validateForm);
    phoneController.addListener(validateForm);
    addressController.addListener(validateForm);
    extraPhoneController.addListener(validateForm);
    extraDetailsController.addListener(validateForm);
  }

  // --- Initialization ---
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // IMPORTANT: Ensure user data is loaded before proceeding with store or other checks.
      // This mimics the ExpensesViewModel's pattern of awaiting ownerId/storeId.
      print('CustomerViewModel: initState - calling getStoreUser()');
      await customerService.getStoreUser();
      print(
          'CustomerViewModel: initState - isUserLoggedIn: ${customerService.isUserLoggedIn}, customer: ${customerService.customer?.email}');

      // Call fetchStores here to ensure customerService.stores is populated right before this screen's logic
      print('CustomerViewModel: initState - calling fetchStores()');
      await customerService.fetchStores();
      print(
          'CustomerViewModel: initState - fetched ${customerService.stores.length} stores.');

      // Set the initial selected store for the form
      // Rely directly on customerService.activeStoreId and customerService.stores
      if (customerService.activeStoreId != null &&
          customerService.stores
              .any((s) => s.id == customerService.activeStoreId)) {
        onStoreChanged(customerService.activeStoreId);
        print(
            'CustomerViewModel: initState - selectedStoreId set to activeStoreId: ${customerService.activeStoreId}');
      } else if (customerService.stores.isNotEmpty) {
        // If no active store or active store is invalid, default to the first available
        onStoreChanged(customerService.stores.first.id);
        print(
            'CustomerViewModel: initState - selectedStoreId defaulted to first store: ${customerService.stores.first.id}');
      } else {
        // If no stores are available at all, selectedStoreId remains null.
        // The UI (NewCustomers widget) will handle displaying the "No stores available" message.
        selectedStoreId.value = null;
        print(
            'CustomerViewModel: initState - No stores available, selectedStoreId is null.');
      }

      // Load other necessary data
      await loadStatesAndLGAs();
      // It's no longer necessary to call getAllCustomers here as it could lead to
      // unwanted backend calls/errors if the user isn't logged in or no store is active.
      // This data should be fetched when explicitly needed (e.g., in a separate customer list view).

      validateForm(); // Initial form validation after data is loaded
      notifyListeners(); // Ensure UI elements reflect initial state after all async data is ready.
      print('CustomerViewModel: initState - finished.');
    });
  }

  @override
  void dispose() {
    firstNameController.removeListener(validateForm);
    lastNameController.removeListener(validateForm);
    emailController.removeListener(validateForm);
    phoneController.removeListener(validateForm);
    addressController.removeListener(validateForm);
    extraPhoneController.removeListener(validateForm);
    extraDetailsController.removeListener(validateForm);
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    extraPhoneController.dispose();
    extraDetailsController.dispose();
    isFormValid.dispose();
    selectedStoreId.dispose();
    // If storesNotifier was added previously, ensure it's disposed
    // storesNotifier.dispose(); // Ensure this is only uncommented if storesNotifier is added to VM
    super.dispose();
  }

  // --- Data Loading (No longer specific 'loadStores' method in ViewModel) ---

  String? getStoreName(String? storeId) {
    if (storeId == null) return 'Unknown Store';
    // Use customerService.stores directly
    final store = customerService.stores.firstWhereOrNull(
      // Using firstWhereOrNull extension
      (store) => store.id == storeId,
    );
    return store?.name ?? 'Unknown Store'; // Safely access name
  }

  Future<void> loadStatesAndLGAs() async {
    try {
      String jsonString = await rootBundle.loadString('assets/wards.json');
      List<dynamic> jsonData = json.decode(jsonString);
      statesAndLGAs = jsonData.cast<Map<String, dynamic>>();
      statesList = ['Select State']..addAll(
          statesAndLGAs.map((state) => state['state'].toString()).toList());
      notifyListeners();
    } catch (e) {
      print('Error loading JSON: $e');
      showCustomToast('Error loading location data.', success: false);
    }
  }

  // --- Form Logic ---

  void onCountryChanged(String? value) {
    if (value != null) {
      country = value;
      state = null;
      lga = null;
      area = null;
      lgaList = ['Select LGA'];
      wardList = ['Select Area'];
      validateForm();
      notifyListeners();
    }
  }

  void onStateChanged(String? value) {
    if (value != null && value != state) {
      state = value;
      lga = null;
      area = null;
      lgaList = ['Select LGA'];
      wardList = ['Select Area'];
      if (value != 'Select State') {
        var selectedState = statesAndLGAs.firstWhere(
          (s) => s['state'] == value,
          orElse: () => {},
        );
        lgaList.addAll(selectedState['lgas']
                ?.map<String>((lga) => lga['lga'].toString()) ??
            []);
      }
      validateForm();
      notifyListeners();
    }
  }

  void onLGAChanged(String? value) {
    if (value != null && value != lga) {
      lga = value;
      area = null;
      wardList = ['Select Area'];
      if (value != 'Select LGA') {
        var selectedState = statesAndLGAs.firstWhere(
          (s) => s['state'] == state,
          orElse: () => {},
        );
        var selectedLGA = selectedState['lgas']?.firstWhere(
          (l) => l['lga'] == value,
          orElse: () => {},
        );
        wardList.addAll(selectedLGA['wards']?.cast<String>() ?? []);
      }
      validateForm();
      notifyListeners();
    }
  }

  void onAreaChanged(String? value) {
    if (value != null && value != area) {
      area = value;
      validateForm();
      notifyListeners();
    }
  }

  void onStoreChanged(String? value) {
    selectedStoreId.value = value;
    customerService
        .setActiveStore(value ?? ''); // Update CustomerService's active store
    validateForm();
    // No notifyListeners() needed here as ValueNotifier will update.
    // However, if other parts of the UI depend on `stores` list, then notifyListeners() is needed.
  }

  Future<void> selectBirthday(BuildContext context) async {
    final currentDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthday ?? DateTime(currentDate.year - 18),
      firstDate: DateTime(1900),
      lastDate: currentDate,
    );
    if (picked != null) {
      selectedBirthday = picked;
      validateForm();
      notifyListeners(); // Notify listeners when birthday changes and UI needs update
    }
  }

  void validateForm() {
    isFormValid.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(emailController.text) &&
        phoneController.text.isNotEmpty &&
        RegExp(r'^0\d{10}$').hasMatch(phoneController.text) &&
        (extraPhoneController.text.isEmpty ||
            RegExp(r'^0\d{10}$').hasMatch(extraPhoneController.text)) &&
        addressController.text.isNotEmpty &&
        selectedStoreId.value != null &&
        selectedStoreId.value!.isNotEmpty && // Ensure store ID is selected
        selectedBirthday != null &&
        country.isNotEmpty &&
        state != null &&
        state != 'Select State' &&
        lga != null &&
        lga != 'Select LGA' &&
        area != null &&
        area != 'Select Area';
    // No notifyListeners() here, as ValueListenableBuilder will react to isFormValid.value changes
  }

  Future<void> submit() async {
    print('Submit button tapped.'); // Debugging log
    if (!formKey.currentState!.validate()) {
      print(
          'Form validation failed via formKey.currentState!.validate()'); // Debugging log
      showCustomToast('Please fill all required fields correctly',
          success: false);
      return;
    }

    if (!isFormValid.value) {
      print('isFormValid.value is false.'); // Debugging log
      showCustomToast('Please fill all required fields correctly',
          success: false);
      return;
    }

    // Double-check login and customer status right before submission
    print(
        'Checking customerService.isUserLoggedIn before submit: ${customerService.isUserLoggedIn}');
    print(
        'Checking customerService.customer before submit: ${customerService.customer != null ? customerService.customer!.email : 'null'}');

    // Explicitly check for login and active store BEFORE attempting backend call
    if (!customerService.isUserLoggedIn || customerService.customer == null) {
      print(
          'User not logged in or customer data missing. Showing toast.'); // Debugging log
      showCustomToast('You must be logged in to create a customer.',
          success: false);
      return; // Return, do NOT navigate to login.
    }

    if (selectedStoreId.value == null || selectedStoreId.value!.isEmpty) {
      print('No store selected.'); // Debugging log
      showCustomToast('Please select a store to create a customer.',
          success: false);
      return;
    }

    startLoader(); // This will make isLoading.value true
    print('Starting loader for submission.'); // Debugging log
    try {
      final userData = CustomerData(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        address: addressController.text.trim(),
        storeId:
            selectedStoreId.value!, // This will be the active/selected store ID
        birthday: selectedBirthday != null
            ? DateFormat('yyyy-MM-dd').format(selectedBirthday!)
            : null,
        extraPhone: extraPhoneController.text.trim().isNotEmpty
            ? extraPhoneController.text.trim()
            : null,
        extraDetails: extraDetailsController.text.trim().isNotEmpty
            ? extraDetailsController.text.trim()
            : null,
        country: country,
        state: state!,
        lga: lga!,
        area: area,
      );

      print(
          'Attempting to create customer with data: ${userData.toJson()}'); // Debugging log
      // MODIFIED: Expect CustomerData? directly from createCustomer
      final createdCustomer =
          await customerRepository.createCustomer(data: userData);

      if (createdCustomer != null) {
        // Check if customer was successfully created
        print(
            'Customer created successfully. Created Customer ID: ${createdCustomer.toString()}'); // Debugging log
        showCustomToast('Customer created successfully', success: true);
        await customerService.storeCustomer(
            await createdCustomer); // Store the directly returned CustomerData
        await showSuccessPopup();
        clearForm();
      } else {
        print(
            'Failed to create customer. createdCustomer is null.'); // Debugging log
        showCustomToast('Failed to create customer',
            success: false); // Generic message if createdCustomer is null
      }
    } on DioException catch (e) {
      print(
          'DioException during customer creation: ${e.response?.data ?? e.message}'); // Debugging log
      showCustomToast(
          'Error: ${e.response?.data['message'] ?? 'Failed to create customer'}',
          success: false);
    } catch (e) {
      print('General error during customer creation: $e'); // Debugging log
      showCustomToast('An unexpected error occurred during customer creation.',
          success: false);
    } finally {
      stopLoader(); // This will make isLoading.value false
      print('Stopping loader after submission.'); // Debugging log
      notifyListeners();
    }
  }

  Future<void> updateCustomer(String customerId) async {
    if (!formKey.currentState!.validate() || !isFormValid.value) {
      showCustomToast('Please fill all required fields correctly',
          success: false);
      return;
    }

    // Explicitly check for login and active store BEFORE attempting backend call
    if (!customerService.isUserLoggedIn || customerService.customer == null) {
      showCustomToast('You must be logged in to update a customer.',
          success: false);
      return; // Return, do NOT navigate to login.
    }

    if (selectedStoreId.value == null || selectedStoreId.value!.isEmpty) {
      showCustomToast('Please select a store to update a customer.',
          success: false);
      return;
    }

    startLoader();
    try {
      final userData = CustomerData(
        id: customerId,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        address: addressController.text.trim(),
        storeId:
            selectedStoreId.value!, // This will be the active/selected store ID
        birthday: selectedBirthday != null
            ? DateFormat('yyyy-MM-dd').format(selectedBirthday!)
            : null,
        extraPhone: extraPhoneController.text.trim().isNotEmpty
            ? extraPhoneController.text.trim()
            : null,
        extraDetails: extraDetailsController.text.trim().isNotEmpty
            ? extraDetailsController.text.trim()
            : null,
        country: country,
        state: state!,
        lga: lga!,
        area: area,
      );

      // MODIFIED: Expect CustomerData? directly from updateCustomer
      final updatedCustomer =
          await customerRepository.updateCustomer(customerId, userData);
      if (updatedCustomer != null) {
        // Check if customer was successfully updated
        showCustomToast('Customer updated successfully', success: true);
        await customerService.storeCustomer(
            await updatedCustomer); // Store the directly returned CustomerData
        await showSuccessPopup();
        clearForm();
      } else {
        showCustomToast('Failed to update customer',
            success: false); // Generic message if updatedCustomer is null
      }
    } on DioException catch (e) {
      showCustomToast(
          'Error: ${e.response?.data['message'] ?? 'Failed to update customer'}',
          success: false);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  deleteCustomer(String customerId) async {
    startLoader();
    try {
      final success = await customerRepository
          .deleteCustomer(customerId); // Assuming customerRepository exists
      if (success) {
        showCustomToast('Customer deleted successfully', success: true);
        allCustomers?.removeWhere((c) => c.id == customerId);
      } else {
        showCustomToast('Failed to delete customer', success: false);
      }
    } on DioException catch (e) {
      showCustomToast(
          'Error: ${e.response?.data['message'] ?? 'Failed to delete customer'}',
          success: false);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> getAllCustomers(
      {String? storeId, String? keyword, int page = 1}) async {
    // Check for login here, as this is a data-fetching operation.
    // However, if not logged in, just return with a toast, no navigation.
    if (!customerService.isUserLoggedIn || customerService.customer == null) {
      showCustomToast('User not logged in to fetch customers.', success: false);
      return;
    }

    startLoader();
    try {
      final response = await customerRepository.getAllCustomer(
        storeId: storeId ?? customerService.activeStoreId,
        keyword: keyword,
        page: page,
      );
      if (response != null) {
        allCustomers = response; // This still expects List<CustomerData>
      } else {
        allCustomers = [];
        showCustomToast('Failed to fetch customers', success: false);
      }
    } on DioException catch (e) {
      showCustomToast(
          'Error: ${e.response?.data['message'] ?? 'Failed to fetch customers'}',
          success: false);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> getBirthdays({String? storeId, int? month}) async {
    // Check for login here, as this is a data-fetching operation.
    // However, if not logged in, just return with a toast, no navigation.
    if (!customerService.isUserLoggedIn || customerService.customer == null) {
      showCustomToast('User not logged in to fetch birthdays.', success: false);
      return;
    }

    startLoader();
    try {
      // getUpcomingBirthdays returns CustomerResponse?, so we need to access its data list
      final response = await customerRepository.getUpcomingBirthdays(
        storeId: storeId ?? customerService.activeStoreId,
        month: month ?? DateTime.now().month,
      );
      if (response?.success == true) {
        allCustomers =
            response?.data ?? []; // Access data property from CustomerResponse
      } else {
        allCustomers = [];
        showCustomToast(response?.message ?? 'Failed to fetch birthdays',
            success: false);
      }
    } on DioException catch (e) {
      showCustomToast(
          'Error: ${e.response?.data['message'] ?? 'Failed to fetch birthdays'}',
          success: false);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> getACustomer(String customerId) async {
    if (customerId.isEmpty) return;
    // Check for login here, as this is a data-fetching operation.
    // However, if not logged in, just return with a toast, no navigation.
    if (!customerService.isUserLoggedIn || customerService.customer == null) {
      showCustomToast('User not logged in to fetch customer details.',
          success: false);
      return;
    }

    startLoader();
    try {
      // MODIFIED: getACustomer now returns CustomerData? directly
      final fetchedCustomer = await customerRepository.getACustomer(customerId);
      if (fetchedCustomer != null) {
        customer = fetchedCustomer; // Directly assign the fetched customer
        await customerService.storeCustomer(fetchedCustomer);
        showCustomToast('Customer details fetched successfully', success: true);
      } else {
        showCustomToast('Failed to fetch customer details', success: false);
      }
    } on DioException catch (e) {
      showCustomToast(
          'Error: ${e.response?.data['message'] ?? 'Failed to fetch customer'}',
          success: false);
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    extraPhoneController.clear();
    extraDetailsController.clear();
    selectedStoreId.value =
        customerService.activeStoreId; // Reset to active store
    _selectedBirthday = null; // Clear the private field
    country = 'Nigeria';
    state = null;
    lga = null;
    area = null;
    lgaList = ['Select LGA'];
    wardList = ['Select Area'];
    customerId = null;
    validateForm();
    notifyListeners();
  }

  void populateForm(CustomerData customer) {
    customerId = customer.id;
    firstNameController.text = customer.firstName ?? '';
    lastNameController.text = customer.lastName ?? '';
    emailController.text = customer.email ?? '';
    phoneController.text = customer.phoneNumber ?? '';
    addressController.text = customer.address ?? '';
    extraPhoneController.text = customer.extraPhone ?? '';
    extraDetailsController.text = customer.extraDetails ?? '';
    selectedStoreId.value =
        customer.storeId; // Populate with customer's storeId
    _selectedBirthday =
        customer.birthday != null ? DateTime.parse(customer.birthday!) : null;
    country = customer.country ?? 'Nigeria';
    state = customer.state ?? 'Select State';
    lga = customer.lga ?? 'Select LGA';
    area = customer.area ?? 'Select Area';
    if (state != 'Select State') {
      var selectedState = statesAndLGAs.firstWhere(
        (s) => s['state'] == state,
        orElse: () => {},
      );
      lgaList = ['Select LGA']..addAll(
          selectedState['lgas']?.map<String>((lga) => lga['lga'].toString()) ??
              []);
      if (lga != 'Select LGA') {
        var selectedLGA = selectedState['lgas']?.firstWhere(
          (l) => l['lga'] == lga,
          orElse: () => {},
        );
        wardList.addAll(selectedLGA['wards']?.cast<String>() ?? []);
      }
    }
    validateForm();
    notifyListeners();
  }

  Future<void> showSuccessPopup() async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: navigationService.navigatorKey.currentState!.context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
        child: SuccessfulPopUpWidget(
          title: customerId != null
              ? 'Customer Updated Successfully!'
              : 'Customer Created Successfully!',
          subTitle:
              'The customer has been successfully ${customerId != null ? 'updated' : 'created'} on Etegram Business.',
          onTap: () {
            navigationService.goBack();
            navigationService.navigateTo(customersListRoute);
          },
        ),
      ),
    );
  }
}

// Extension to safely get the first element or null (similar to .firstOrNull in Dart 2.12+)
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
