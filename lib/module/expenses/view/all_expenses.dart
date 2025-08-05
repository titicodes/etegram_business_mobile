import 'package:flutter/material.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/expenses/vm/expenses_viewmodel.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../service/local/drawer_service.dart';
import 'edit_expenses.dart';

class AllExpenses extends StatelessWidget {
  const AllExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final drawerService = locator<DrawerService>();
    return BaseView<ExpensesViewModel>(
      onModelReady: (model) {
        model.init();
        drawerService.setScaffoldKey(scaffoldKey);
      },
      builder: (context, model, child) => Stack(
        children: [
          Scaffold(
            key: scaffoldKey,
            backgroundColor: ColorValues.backgroundColor,
            drawer: const NavDrawer(),
            appBar: CustomAppBar(
              title: 'All Expenses',
              onBackPressed: () => navigationService.goBack(),
              showMenuIcon: true,
              onMenuPressed: () => drawerService.openDrawer(),
            ),
            body: model.expenses.isEmpty
                ? Center(
                    child: Text('No expenses found.', style: normalTextStyle))
                : ListView.builder(
                    itemCount: model.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = model.expenses[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Dismissible(
                          key: Key(expense.id ?? index.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            model.deleteExpense(expense.id!, context);
                          },
                          child: Card(
                            elevation: 0,
                            child: ListTile(
                              title: Text(
                                expense.description ?? 'No Description',
                                style: normalTextStyle12,
                              ),
                              subtitle: Text(
                                'Amount: ${expense.currency} ${expense.amount?.toStringAsFixed(2) ?? '0.0'}\nCategory: ${expense.category ?? 'N/A'}',
                                style: normalTextStyle12.copyWith(
                                    color: Colors.grey),
                              ),
                              trailing: Text(
                                expense.date != null
                                    ? '${expense.date!.day}/${expense.date!.month}/${expense.date!.year}'
                                    : 'N/A',
                                style: normalTextStyle12,
                              ),
                              onTap: () {
                                navigationService.navigateToWidget(
                                  EditExpense(expense: expense),
                                  transitionBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (model.isLoading.value)
            Container(
              color: Colors.black54,
              child: const Center(
                child: SpinKitFadingCircle(
                  color: ColorValues.primaryColor,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
