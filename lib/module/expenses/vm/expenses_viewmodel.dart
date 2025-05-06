import 'package:etegram_business/base/base_vm.dart';
import 'package:flutter/material.dart';

import '../../../app_widget/bottom_sheet.dart';
import '../../../app_widget/success_pupup_widget.dart';
import '../../../core/model/expense_response.dart';

class ExpensesViewModel extends BaseViewModel {
  // Add the form key that was missing


  ExpensesViewModel() {
    // Set up listeners but with less frequent validation
    amountController.addListener(_validateFormDebounced);
    descriptionController.addListener(_validateFormDebounced);
  }

  /// 📝 State variables
  List<ExpenseData> _expenses = [];
  List<ExpenseData> get expenses => _expenses;

  ExpenseData? _expense;
  ExpenseData? get expense => _expense;

  bool _isLoading = false;

  String _userId = "";
  String category = "";
  String paymentMethod = "";
  String currency = "";

  DateTime? selectedExpiryDate;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Use ValueNotifier instead of calling notifyListeners for form validation
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

  // Debounce timer to prevent excessive validations
  DateTime? _lastValidationTime;

  /// 🛑 Dispose controllers
  @override
  void dispose() {
    amountController.removeListener(_validateFormDebounced);
    descriptionController.removeListener(_validateFormDebounced);
    amountController.dispose();
    descriptionController.dispose();
    isFormValid.dispose();
    super.dispose();
  }

  void init() {
    // Set initial userId if needed
    // This can come from a service or provider
    fetchExpenses();
  }

  /// 🛠 Validate form fields with debouncing
  void _validateFormDebounced() {
    // Only validate at most once every 500ms
    final now = DateTime.now();
    if (_lastValidationTime == null ||
        now.difference(_lastValidationTime!).inMilliseconds > 500) {
      _lastValidationTime = now;
      _validateForm();
    }
  }

  void _validateForm() {
    // Check all required fields
    bool valid = amountController.text.isNotEmpty &&
        category.isNotEmpty &&
        currency.isNotEmpty &&
        paymentMethod.isNotEmpty;

    // Only update if changed to prevent unnecessary rebuilds
    if (isFormValid.value != valid) {
      isFormValid.value = valid;
    }
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
      _validateForm(); // Validate after date selection
    }
  }

  /// 🏷️ Dropdown options
  List<String> categoryList = [
    "Health",
    "School",
    "Manufacture",
    "Food",
    "Agriculture",
    "Budget"
  ];

  List<String> paymentMethodList = ["Cash", "Card", "Online"];
  List<String> currencyOption = ["Naira", "USD", "Euro"];

  /// 🔄 Handle dropdown changes
  void onChangedPaymentMethod(String val) {
    if (paymentMethod != val) {
      paymentMethod = val;
      _validateForm();
      notifyListeners();
    }
  }

  void onChangedCategory(String val) {
    if (category != val) {
      category = val;
      _validateForm();
      notifyListeners();
    }
  }

  void onChangedCurrency(String val) {
    if (currency != val) {
      currency = val;
      _validateForm();
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
      // Use current date if no date was selected
      final expenseDate = selectedExpiryDate ?? DateTime.now();

      var expense = ExpenseData(
        description: descriptionController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        category: category,
        userId: _userId,
        currency: currency,
        paymentMethod: paymentMethod,
        date: expenseDate,
      );

      final createdExpense = await expenseRepository.createExpense(expense);
      if (createdExpense != null) {
        _expenses.add(createdExpense);
        // Clear form after successful creation
        _resetForm();
      }

      // Show success message if needed
      await showSuccessPopup();

    } catch (err) {
      print("Error creating expense: $err");
      // Show error message if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset form after successful submission
  void _resetForm() {
    amountController.clear();
    descriptionController.clear();
    category = "";
    currency = "";
    paymentMethod = "";
    selectedExpiryDate = null;
    _validateForm();
  }

  /// 📊 Fetch all expenses
  Future<void> fetchExpenses() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await expenseRepository.getAllExpenses() ?? [];
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

  showSuccessPopup() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: navigationService.navigatorKey.currentState!.context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
        child: SuccessfulPopUpWidget(
          title: "Expenses Created successfully!",
          subTitle: "Your new expenses had been created successfully.",
          onTap: navigationService.goBack,
        ),
      ),
    ).whenComplete(navigationService.goBack);
  }
}