import 'package:etegram_business/base/base_vm.dart';
import 'package:flutter/material.dart';

import '../../../core/model/expense_response.dart';


class ExpensesViewModel extends BaseViewModel {


  ExpensesViewModel() {
    amountController.addListener(validateForm);
  }

  /// 📝 State variables
  List<ExpenseData> _expenses = [];
  List<ExpenseData> get expenses => _expenses;

  ExpenseData? _expense;
  ExpenseData? get expense => _expense;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _userId = "";
  String category = "";
  String paymentMethod = "";
  String currency = "";

  DateTime? selectedExpiryDate;
  DateTime dob = DateTime.now();

  var amountController = TextEditingController();
  var descriptionController = TextEditingController();

  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

  /// 🛑 Dispose controllers
  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void init(){
    fetchExpenses();

  }
  /// 🛠 Validate form fields
  void validateForm() {
    isFormValid.value = amountController.text.isNotEmpty &&
        category.isNotEmpty &&
        currency.isNotEmpty;
  }

  /// 📅 Show date picker
  Future<void> selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedExpiryDate ?? currentDate,
      firstDate: DateTime(1930), // Minimum date
      lastDate: currentDate, // Prevent future dates
    );

    if (picked != null && picked != selectedExpiryDate) {
      selectedExpiryDate = picked;
      notifyListeners();
    }
  }

  /// 🏷️ Dropdown options
  List<String> categoryList = [
    "Health", "School", "Manufacture", "Food", "Agriculture", "Budget"
  ];

  List<String> paymentMethodList = ["Cash", "Card", "Online"];
  List<String> currencyOption = ["Naira", "USD", "Euro"];

  /// 🔄 Handle dropdown changes
  void onChangedPaymentMethod(String val) {
    if (paymentMethod != val) {
      paymentMethod = val;
      validateForm();
      notifyListeners();
    }
  }

  void onChangedCategory(String val) {
    if (category != val) {
      category = val;
      validateForm();
      notifyListeners();
    }
  }

  void onChangedCurrency(String val) {
    if (currency != val) {
      currency = val;
      validateForm();
      notifyListeners();
    }
  }

  /// 👤 Set user ID
  void setUserId(String id) {
    _userId = id;
  }

  /// 💰 Create new expense
  Future<void> createExpense() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      var expense = ExpenseData(
        description: descriptionController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        category: category,
        userId: _userId,
        currency: currency,
        date: selectedExpiryDate,
      );

      final createdExpense = await expenseRepository.createExpense(expense);
      if (createdExpense != null) {
        _expenses.add(createdExpense);
      }
    } catch (err) {
      print("Error creating expense: $err");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 📊 Fetch all expenses
  Future<void> fetchExpenses() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await expenseRepository.getAllExpenses(_userId) ?? [];
    } catch (err) {
      print("Error fetching expenses: $err");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔍 Fetch single expense
  Future<void> fetchExpenseById(String id) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _expense = await expenseRepository.getExpenseById(id, _userId);
    } catch (err) {
      print("Error fetching expense: $err");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✏️ Update expense
  Future<void> updateExpense(ExpenseData expense) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedExpense = await expenseRepository.updateExpense(expense);
      if (updatedExpense != null) {
        final index = _expenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          _expenses[index] = updatedExpense;
        }
      }
    } catch (err) {
      print("Error updating expense: $err");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ❌ Delete expense
  Future<void> deleteExpense(String id) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final deleted = await expenseRepository.deleteExpense(id, _userId);
      if (deleted) {
        _expenses.removeWhere((e) => e.id == id);
      }
    } catch (err) {
      print("Error deleting expense: $err");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 Get dropdown options
  List<String> getCategoryListOptions() => categoryList;
  List<String> getPaymentOption() => paymentMethodList;
  List<String> getCurrencyOption() => currencyOption;
}
