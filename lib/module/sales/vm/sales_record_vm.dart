import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/auth_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

class SalesRecordViewModel extends BaseViewModel {
  String? selectTimeOfSales = "";
  String selectPaymentMethod = "";
  String selectedCustomer = "";
  String selectedStaff = "";
  String filterBy = "";
  String searchQuerry = "";
  int _selectedIndex = 0;
  List<String> searchResults = [];

  int get selectedIndex => _selectedIndex;
  final ValueNotifier<int> tebIndex = ValueNotifier(0);

  List<DataTab> get recordTaps =>[DataTab(title: "Owing"), DataTab(title: "Owed")];

  onChange(String? val) {
    formKey.currentState?.validate();
    notifyListeners();
  }

  onchangeSelectTimeOfSales(String val) {
    selectTimeOfSales = val;
    notifyListeners();
  }

  onchangeSelectPaymentMethod(String val) {
    selectPaymentMethod = val;
    notifyListeners();
  }

  onchangeSelectedCustomer(String val) {
    selectedCustomer = val;
    notifyListeners();
  }

  onchangeSelectStaff(String val) {
    selectedStaff = val;
    notifyListeners();
  }

  onchangeSelectFilteredBy(String val) {
    filterBy = val;
    notifyListeners();
  }

  void onQueryChanged(String newQuery) {
    searchResults = data
        .where((item) => item.toLowerCase().contains(newQuery.toLowerCase()))
        .toList();

    notifyListeners();
  }

  List<String> timeOfSale = [
    "Today's Sales",
    "Yesterday's Sales",
    "This Week Sales",
    "Last Seven days Sales",
    "This Month's Sales",
    "Last 30 days Sales",
    "This year's Sales",
    'Other',
  ];

  List<String> paymentMethod = [
    "Cash",
    "Online Payment",
    "Bank Transfer",
    "Others"
  ];

  List<String> customer = ["Tifon Systems", "Anitexy"];
  List<String> staffSelection = ["Udeme Effiong", "Titi", "Others"];

  List<String> filterBySelection = ["Refunded sales", "Discounted Sales"];

  List<String> filterOwingRecode = ["All", "Paid", "Unpaid"];

  List<String> data = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grapes',
    'Honeydew',
    'Kiwi',
    'Lemon',
  ];
}
