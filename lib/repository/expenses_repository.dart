import 'package:etegram_business/service/web/expenses_api_service.dart';

import '../core/model/expense_response.dart';
import '../locator.dart';
import '../service/local/cache.dart';
import '../service/local/storage_service.dart';
import '../service/local/user_service.dart';
import '../service/web/auth_api.dart';

class ExpensesRepository {
  AppCache appCache = locator<AppCache>();
  ExpensesApiService expensesApiService = locator<ExpensesApiService>();
  CustomerService customerService = locator<CustomerService>();
  StorageService storageService = locator<StorageService>();

  Future<ExpenseData?> createExpense(ExpenseData expense) async {
    final response = await expensesApiService.createExpense(expense);
    return response;
  }

  Future<List<ExpenseData>?> getAllExpenses(String? storeId) async {
    return expensesApiService.getAllExpenses(storeId: storeId);
  }

  Future<ExpenseData?> getExpenseById(String id, String userId) async {
    return expensesApiService.getExpenseById(id);
  }

  Future<ExpenseData?> updateExpense(ExpenseData expense) async {
    final response = await expensesApiService.updateExpense(expense);
    return response;
  }

  Future<bool> deleteExpense(String id, String userId) async {
    return expensesApiService.deleteExpense(id,);
  }
}
