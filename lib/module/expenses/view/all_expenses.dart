import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/expenses/vm/expenses_viewmodel.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AllExpenses extends StatelessWidget {
  const AllExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    var homeViewModel = locator<HomeViewModel>();
    return BaseView<ExpensesViewModel>(
      onModelReady: (model) => model.init(),
      builder: (_, logic, child) => Scaffold(
        key: homeViewModel.scaffoldKey,
        drawer: NavDrawer(),
        appBar: CustomAppBar(
          title: "All Expenses",
          onBackPressed: () {
            navigationService.goBack();
          },
          showMenuIcon: true,
          onMenuPressed: () => homeViewModel.openDrawer(),
        ),
        body: logic.isLoading.value
            ? Center(
                child: SpinKitFadingCircle(
                  itemBuilder: (BuildContext context, int index) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: index.isEven ? Colors.red : Colors.green,
                      ),
                    );
                  },
                ),
              )
            : logic.expenses.isEmpty
                ? Center(child: Text("No expenses found."))
                : ListView.builder(
                    itemCount: logic.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = logic.expenses[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(expense.description ?? "No Description", style: normalTextStyle12,),
                          subtitle: Text(
                              "Amount: ${expense.amount ?? 0.0}, Category: ${expense.category ?? 'N/A'}"),
                          trailing: Text(expense.date?.toString() ?? "N/A"),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
