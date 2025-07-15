// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:etegram_business/base/base_vm.dart';
// import 'package:etegram_business/core/model/delivery_response.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/repository/delivery_repository.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'package:etegram_business/service/local/user_service.dart';
// import 'package:etegram_business/utils/snack_message.dart';
//
// import '../../../app_widget/celebration_widget.dart';
//
// class DeliveryViewModel extends BaseViewModel {
//   final formKey = GlobalKey<FormState>();
//   final firstNameController = TextEditingController();
//   final lastNameController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//   final extraPhoneController = TextEditingController();
//   final estateController = TextEditingController();
//   final extraDetailsController = TextEditingController();
//   final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
//   final CustomerService _customerService = locator<CustomerService>();
//   final DeliveryRepository _deliveryRepository = locator<DeliveryRepository>();
//
//   String _storeId = '';
//   String country = 'Nigeria';
//   String? state;
//   String? city;
//   String? area;
//   String supplierType = '';
//   List<Map<String, dynamic>> statesAndLGAs = [];
//   List<String> statesList = [];
//   List<String> lgaList = [];
//   List<String> wardList = [];
//   List<String> countryList = ['Nigeria', 'Gambia'];
//   List<String> supplierTypeList = ['Individual', 'Business'];
//
//   DeliveryViewModel() {
//     firstNameController.addListener(_validateForm);
//     lastNameController.addListener(_validateForm);
//     emailController.addListener(_validateForm);
//     phoneController.addListener(_validateForm);
//     extraPhoneController.addListener(_validateForm);
//     estateController.addListener(_validateForm);
//     extraDetailsController.addListener(_validateForm);
//   }
//
//   Future<void> init() async {
//     final storeId = await _customerService.getActiveStoreId();
//     if (storeId == null) {
//       showCustomToast('Store information missing.');
//       return;
//     }
//     _storeId = storeId;
//     await loadStatesAndLGAs();
//     notifyListeners();
//   }
//
//   Future<void> loadStatesAndLGAs() async {
//     try {
//       String jsonString = await rootBundle.loadString('assets/wards.json');
//       List<dynamic> jsonData = json.decode(jsonString);
//       statesAndLGAs = jsonData.cast<Map<String, dynamic>>();
//       statesList = ['Select State']..addAll(
//           statesAndLGAs.map((state) => state['state'].toString()).toList());
//       notifyListeners();
//     } catch (e) {
//       print('Error loading JSON: $e');
//       showCustomToast('Error loading location data.');
//     }
//   }
//
//   void _validateForm() {
//     isFormValid.value = firstNameController.text.isNotEmpty &&
//         lastNameController.text.isNotEmpty &&
//         emailController.text.isNotEmpty &&
//         RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//             .hasMatch(emailController.text) &&
//         phoneController.text.isNotEmpty &&
//         RegExp(r'^0\d{10}$').hasMatch(phoneController.text) &&
//         (extraPhoneController.text.isEmpty ||
//             RegExp(r'^0\d{10}$').hasMatch(extraPhoneController.text)) &&
//         estateController.text.isNotEmpty &&
//         country.isNotEmpty &&
//         state != null &&
//         state != 'Select State' &&
//         city != null &&
//         city != 'Select City' &&
//         area != null &&
//         area != 'Select Area' &&
//         supplierType.isNotEmpty;
//   }
//
//   void onCountryChanged(String? value) {
//     if (value != null) {
//       country = value;
//       state = null;
//       city = null;
//       area = null;
//       lgaList = [];
//       wardList = [];
//       _validateForm();
//       notifyListeners();
//     }
//   }
//
//   void onStateChanged(String? value) {
//     if (value != null && value != state) {
//       state = value;
//       city = null;
//       area = null;
//       lgaList = ['Select City'];
//       wardList = [];
//       if (value != 'Select State') {
//         var selectedState = statesAndLGAs.firstWhere(
//           (s) => s['state'] == value,
//           orElse: () => {},
//         );
//         lgaList.addAll(selectedState['lgas']
//                 ?.map<String>((lga) => lga['lga'].toString()) ??
//             []);
//       }
//       _validateForm();
//       notifyListeners();
//     }
//   }
//
//   void onCityChanged(String? value) {
//     if (value != null && value != city) {
//       city = value;
//       area = null;
//       wardList = ['Select Area'];
//       if (value != 'Select City') {
//         var selectedState = statesAndLGAs.firstWhere(
//           (s) => s['state'] == state,
//           orElse: () => {},
//         );
//         var selectedLGA = selectedState['lgas']?.firstWhere(
//           (lga) => lga['lga'] == value,
//           orElse: () => {},
//         );
//         wardList.addAll(selectedLGA['wards']?.cast<String>() ?? []);
//       }
//       _validateForm();
//       notifyListeners();
//     }
//   }
//
//   void onAreaChanged(String? value) {
//     if (value != null && value != area) {
//       area = value;
//       _validateForm();
//       notifyListeners();
//     }
//   }
//
//   void onSupplierTypeChanged(String? value) {
//     if (value != null) {
//       supplierType = value;
//       _validateForm();
//       notifyListeners();
//     }
//   }
//
//   Future<void> submit(BuildContext context) async {
//     if (!formKey.currentState!.validate() || isLoading.value) return;
//
//     isLoading.value = true;
//     notifyListeners();
//
//     try {
//       final delivery = DeliveryData(
//         firstName: firstNameController.text.trim(),
//         lastName: lastNameController.text.trim(),
//         email: emailController.text.trim(),
//         phoneNumber: phoneController.text.trim(),
//         extraPhone: extraPhoneController.text.trim().isNotEmpty
//             ? extraPhoneController.text.trim()
//             : null,
//         estate: estateController.text.trim(),
//         country: country,
//         state: state!,
//         city: city!,
//         area: area!,
//         supplierType: supplierType,
//         extraDetails: extraDetailsController.text.trim().isNotEmpty
//             ? extraDetailsController.text.trim()
//             : null,
//         storeId: _storeId,
//       );
//
//       final createdDelivery =
//           await _deliveryRepository.createDeliveryAgent(delivery);
//       if (createdDelivery != null) {
//         showCustomToast('Delivery agent created successfully!');
//         _resetForm();
//         navigationService.navigateToWidget(
//           CelebrationWidget(
//             title: 'Back to Dashboard',
//             onTap: () {
//               navigationService.navigateTo(dashboardRoute);
//             },
//             child: const Text(
//               'Delivery Agent Created Successfully!',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           transitionBuilder: (context, animation, secondaryAnimation, child) {
//             return SlideTransition(
//               position: Tween<Offset>(
//                 begin: const Offset(1, 0),
//                 end: Offset.zero,
//               ).animate(animation),
//               child: child,
//             );
//           },
//         );
//       } else {
//         showCustomToast('Failed to create delivery agent.');
//       }
//     } catch (e) {
//       print('Error creating delivery agent: $e');
//       showCustomToast('Error creating delivery agent: $e');
//     } finally {
//       isLoading.value = false;
//       notifyListeners();
//     }
//   }
//
//   void _resetForm() {
//     firstNameController.clear();
//     lastNameController.clear();
//     emailController.clear();
//     phoneController.clear();
//     extraPhoneController.clear();
//     estateController.clear();
//     extraDetailsController.clear();
//     country = 'Nigeria';
//     state = null;
//     city = null;
//     area = null;
//     supplierType = '';
//     lgaList = [];
//     wardList = [];
//     isFormValid.value = false;
//   }
//
//   @override
//   void dispose() {
//     firstNameController.removeListener(_validateForm);
//     lastNameController.removeListener(_validateForm);
//     emailController.removeListener(_validateForm);
//     phoneController.removeListener(_validateForm);
//     extraPhoneController.removeListener(_validateForm);
//     estateController.removeListener(_validateForm);
//     extraDetailsController.removeListener(_validateForm);
//     firstNameController.dispose();
//     lastNameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     extraPhoneController.dispose();
//     estateController.dispose();
//     extraDetailsController.dispose();
//     isFormValid.dispose();
//     super.dispose();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/delivery_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/repository/delivery_repository.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import '../../../app_widget/celebration_widget.dart';

class DeliveryViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final extraPhoneController = TextEditingController();
  final estateController = TextEditingController();
  final extraDetailsController = TextEditingController();
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
  final CustomerService _customerService = locator<CustomerService>();
  final DeliveryRepository _deliveryRepository = locator<DeliveryRepository>();

  String _storeId = '';
  String country = 'Nigeria';
  String? state;
  String? city;
  String? area;
  String? supplierType = '';
  List<Map<String, dynamic>> statesAndLGAs = [];
  List<String> statesList = [];
  List<String> lgaList = [];
  List<String> wardList = [];
  List<String> countryList = ['Nigeria', 'Gambia'];
  List<String> supplierTypeList = ['Individual', 'Business'];
  List<DeliveryData> deliveryAgents = [];
  List<DeliveryTransactionData> deliveryTransactions = [];

  DeliveryViewModel() {
    firstNameController.addListener(_validateForm);
    lastNameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
    extraPhoneController.addListener(_validateForm);
    estateController.addListener(_validateForm);
    extraDetailsController.addListener(_validateForm);
  }

  Future<void> init() async {
    final storeId = await _customerService.getActiveStoreId();
    if (storeId == null) {
      showCustomToast('Store information missing.');
      return;
    }
    _storeId = storeId;
    print('Initialized _storeId: $_storeId');
    await loadStatesAndLGAs();
    await fetchDeliveryAgents();
    await fetchDeliveryTransactions();
    notifyListeners();
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
      showCustomToast('Error loading location data.');
    }
  }

  Future<void> fetchDeliveryAgents() async {
    try {
      startLoader();
      final agents =
          await _deliveryRepository.getAllDeliveryAgents(storeId: _storeId);
      if (agents != null) {
        deliveryAgents = agents;
        print('Fetched ${deliveryAgents.length} delivery agents');
      } else {
        showCustomToast('Failed to fetch delivery agents.');
      }
    } catch (e) {
      print('Error fetching delivery agents: $e');
      showCustomToast('Error fetching delivery agents: $e');
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> fetchDeliveryTransactions() async {
    try {
      startLoader();
      final transactions = await _deliveryRepository.getAllDeliveryTransactions(
          storeId: _storeId);
      if (transactions != null) {
        deliveryTransactions = transactions;
        print('Fetched ${deliveryTransactions.length} delivery transactions');
      } else {
        showCustomToast('Failed to fetch delivery transactions.');
      }
    } catch (e) {
      print('Error fetching delivery transactions: $e');
      showCustomToast('Error fetching delivery transactions: $e');
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> deleteDeliveryAgent(String id, BuildContext context) async {
    try {
      startLoader();
      final success = await _deliveryRepository.deleteDeliveryAgent(id);
      if (success == true) {
        deliveryAgents.removeWhere((agent) => agent.id == id);
        showCustomToast('Delivery agent deleted successfully.');
      } else {
        showCustomToast('Failed to delete delivery agent.');
      }
    } catch (e) {
      print('Error deleting delivery agent: $e');
      showCustomToast('Error deleting delivery agent: $e');
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  void _validateForm() {
    isFormValid.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(emailController.text) &&
        phoneController.text.isNotEmpty &&
        RegExp(r'^0\d{10}$').hasMatch(phoneController.text) &&
        (extraPhoneController.text.isEmpty ||
            RegExp(r'^0\d{10}$').hasMatch(extraPhoneController.text)) &&
        estateController.text.isNotEmpty &&
        country.isNotEmpty &&
        state != null &&
        state != 'Select State' &&
        city != null &&
        city != 'Select City' &&
        area != null &&
        area != 'Select Area' &&
        supplierType != null &&
        supplierType!.isNotEmpty;
  }

  void onCountryChanged(String? value) {
    if (value != null) {
      country = value;
      state = null;
      city = null;
      area = null;
      lgaList = [];
      wardList = [];
      _validateForm();
      notifyListeners();
    }
  }

  void onStateChanged(String? value) {
    if (value != null && value != state) {
      state = value;
      city = null;
      area = null;
      lgaList = ['Select City'];
      wardList = [];
      if (value != 'Select State') {
        var selectedState = statesAndLGAs.firstWhere(
          (s) => s['state'] == value,
          orElse: () => {},
        );
        lgaList.addAll(selectedState['lgas']
                ?.map<String>((lga) => lga['lga'].toString()) ??
            []);
      }
      _validateForm();
      notifyListeners();
    }
  }

  void onCityChanged(String? value) {
    if (value != null && value != city) {
      city = value;
      area = null;
      wardList = ['Select Area'];
      if (value != 'Select City') {
        var selectedState = statesAndLGAs.firstWhere(
          (s) => s['state'] == state,
          orElse: () => {},
        );
        var selectedLGA = selectedState['lgas']?.firstWhere(
          (lga) => lga['lga'] == value,
          orElse: () => {},
        );
        wardList.addAll(selectedLGA['wards']?.cast<String>() ?? []);
      }
      _validateForm();
      notifyListeners();
    }
  }

  void onAreaChanged(String? value) {
    if (value != null && value != area) {
      area = value;
      _validateForm();
      notifyListeners();
    }
  }

  void onSupplierTypeChanged(String? value) {
    if (value != null) {
      supplierType = value;
      _validateForm();
      notifyListeners();
    }
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate() || isLoading.value) return;

    try {
      startLoader();
      final delivery = DeliveryData(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        extraPhone: extraPhoneController.text.trim().isNotEmpty
            ? extraPhoneController.text.trim()
            : null,
        estate: estateController.text.trim(),
        country: country,
        state: state!,
        city: city!,
        area: area!,
        supplierType: supplierType!,
        extraDetails: extraDetailsController.text.trim().isNotEmpty
            ? extraDetailsController.text.trim()
            : null,
        storeId: _storeId,
      );

      final createdDelivery =
          await _deliveryRepository.createDeliveryAgent(delivery);
      if (createdDelivery != null) {
        deliveryAgents.add(createdDelivery);
        showCustomToast('Delivery agent created successfully!');
        _resetForm();
        navigationService.navigateToWidget(
          CelebrationWidget(
            title: 'Back to Dashboard',
            onTap: () {
              navigationService.navigateTo(dashboardRoute);
            },
            child: const Text(
              'Delivery Agent Created Successfully!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
      } else {
        showCustomToast('Failed to create delivery agent.');
      }
    } catch (e) {
      print('Error creating delivery agent: $e');
      showCustomToast('Error creating delivery agent: $e');
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  void _resetForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    extraPhoneController.clear();
    estateController.clear();
    extraDetailsController.clear();
    country = 'Nigeria';
    state = null;
    city = null;
    area = null;
    supplierType = null;
    lgaList = [];
    wardList = [];
    isFormValid.value = false;
  }

  @override
  void dispose() {
    firstNameController.removeListener(_validateForm);
    lastNameController.removeListener(_validateForm);
    emailController.removeListener(_validateForm);
    phoneController.removeListener(_validateForm);
    extraPhoneController.removeListener(_validateForm);
    estateController.removeListener(_validateForm);
    extraDetailsController.removeListener(_validateForm);
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    extraPhoneController.dispose();
    estateController.dispose();
    extraDetailsController.dispose();
    isFormValid.dispose();
    super.dispose();
  }
}
