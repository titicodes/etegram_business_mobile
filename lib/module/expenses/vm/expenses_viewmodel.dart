import 'package:flutter/material.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/expense_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/routes/routes.dart';

import '../../../app_widget/celebration_widget.dart';

class ExpensesViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
  final CustomerService _customerService = locator<CustomerService>();

  List<ExpenseData> _expenses = [];
  List<ExpenseData> get expenses => _expenses;

  ExpenseData? _expense;
  ExpenseData? get expense => _expense;

  String _userId = '';
  String _storeId = '';
  String category = '';
  String paymentMethod = '';
  String currency = '';
  DateTime? selectedDate;

  List<String> categoryList = ['UTILITIES', 'SUPPLIES', 'SALARIES', 'OTHER'];
  List<String> paymentMethodList = ['Cash', 'Card', 'Online'];
  List<String> currencyOption = ['Naira', 'USD', 'Euro'];

  DateTime? _lastValidationTime;

  ExpensesViewModel() {
    amountController.addListener(_validateFormDebounced);
    descriptionController.addListener(_validateFormDebounced);
    notesController.addListener(_validateFormDebounced);
  }

  Future<void> init() async {
    final userId = await _customerService.getOwnerId();
    final storeId = await _customerService.getActiveStoreId();
    if (userId == null || storeId == null) {
      showCustomToast('User or store information missing.');
      return;
    }
    _userId = userId;
    _storeId = storeId;
    fetchExpenses();
  }

  void _validateFormDebounced() {
    final now = DateTime.now();
    if (_lastValidationTime == null ||
        now.difference(_lastValidationTime!).inMilliseconds > 500) {
      _lastValidationTime = now;
      _validateForm();
    }
  }

  void _validateForm() {
    bool valid = amountController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        category.isNotEmpty &&
        currency.isNotEmpty &&
        paymentMethod.isNotEmpty &&
        selectedDate != null;
    if (isFormValid.value != valid) {
      isFormValid.value = valid;
    }
  }

  get validateForm => _validateForm();

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      _validateForm();
      notifyListeners();
    }
  }

  void onChangedCategory(String? value) {
    if (value != null && category != value) {
      category = value;
      _validateForm();
      notifyListeners();
    }
  }

  void onChangedPaymentMethod(String? value) {
    if (value != null && paymentMethod != value) {
      paymentMethod = value;
      _validateForm();
      notifyListeners();
    }
  }

  void onChangedCurrency(String? value) {
    if (value != null && currency != value) {
      currency = value;
      _validateForm();
      notifyListeners();
    }
  }

  Future<void> createExpense(BuildContext context) async {
    if (!formKey.currentState!.validate() || isLoading.value) return;

    isLoading.value = true;
    notifyListeners();

    try {
      final expense = ExpenseData(
        description: descriptionController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        category: category,
        storeId: _storeId,
        currency: currency,
        paymentMethod: paymentMethod,
        notes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
        date: selectedDate,
      );

      final createdExpense = await expenseRepository.createExpense(expense);
      if (createdExpense != null) {
        _expenses.add(createdExpense);
        _resetForm();
        showCustomToast('Expense created successfully!');
        // Navigate to CelebrationWidget with slide transition
        navigationService.navigateToWidget(
          CelebrationWidget(
            title: 'Back to Dashboard',
            onTap: () {
              navigationService
                  .navigateTo(dashboardRoute); // Navigate to dashboard
            },
            child: const Text(
              'Expense Created Successfully!',
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
        showCustomToast('Failed to create expense.');
      }
    } catch (e) {
      print('Error creating expense: $e');
      showCustomToast('Error creating expense: $e');
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<void> fetchExpenses() async {
    if (isLoading.value) return;

    isLoading.value = true;
    notifyListeners();

    try {
      final expenses = await expenseRepository.getAllExpenses(_storeId);
      _expenses = expenses ?? [];
    } catch (e) {
      print('Error fetching expenses: $e');
      showCustomToast('Error fetching expenses.');
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<void> fetchExpenseById(String id) async {
    if (isLoading.value) return;

    isLoading.value = true;
    notifyListeners();

    try {
      _expense = await expenseRepository.getExpenseById(id, _userId);
      if (_expense == null) {
        showCustomToast('Expense not found.');
      }
    } catch (e) {
      print('Error fetching expense: $e');
      showCustomToast('Error fetching expense.');
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<void> updateExpense(ExpenseData expense, BuildContext context) async {
    if (isLoading.value) return;

    isLoading.value = true;
    notifyListeners();

    try {
      final updatedExpense =
          await expenseRepository.updateExpense(expense.copyWith(
        storeId: _storeId,
      ));
      if (updatedExpense != null) {
        final index = _expenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          _expenses[index] = updatedExpense;
        }
        showCustomToast('Expense updated successfully!');
        Navigator.of(context).pop();
      } else {
        showCustomToast('Failed to update expense.');
      }
    } catch (e) {
      print('Error updating expense: $e');
      showCustomToast('Error updating expense.');
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id, BuildContext context) async {
    if (isLoading.value) return;

    isLoading.value = true;
    notifyListeners();

    try {
      final deleted = await expenseRepository.deleteExpense(id, _userId);
      if (deleted) {
        _expenses.removeWhere((e) => e.id == id);
        showCustomToast('Expense deleted successfully!');
        Navigator.of(context).pop();
      } else {
        showCustomToast('Failed to delete expense.');
      }
    } catch (e) {
      print('Error deleting expense: $e');
      showCustomToast('Error deleting expense.');
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  void _resetForm() {
    amountController.clear();
    descriptionController.clear();
    notesController.clear();
    category = '';
    currency = '';
    paymentMethod = '';
    selectedDate = null;
    isFormValid.value = false;
  }

  List<String> getCategoryListOptions() => categoryList;
  List<String> getPaymentOption() => paymentMethodList;
  List<String> getCurrencyOption() => currencyOption;

  @override
  void dispose() {
    amountController.removeListener(_validateFormDebounced);
    descriptionController.removeListener(_validateFormDebounced);
    notesController.removeListener(_validateFormDebounced);
    amountController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    isFormValid.dispose();
    super.dispose();
  }
}
