import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/deliveries/views/add_delivery_rate.dart';
import 'package:etegram_business/module/deliveries/views/deliveries_agent.dart';
import 'package:etegram_business/module/expenses/view/all_expenses.dart';
import 'package:etegram_business/module/expenses/view/expense.dart';
import 'package:etegram_business/module/stores/views/new_stores.dart';
import 'package:etegram_business/module/supply/view/list_of_suppliers.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:flutter/material.dart';

import '../../customer/views/birth_day_view.dart';
import '../../customer/views/customer_list_view.dart';
import '../../customer/views/new_customer.dart';
import '../../sales/view/sales_list.dart';
import '../../sales/view/sales_record.dart';
import '../views/home_view.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  bool _isSupplyExpanded = false;
  bool _isCustomerExpanded = false;
  bool _isExpensesExpanded = false;
  bool _isWarehouseExpanded = false;
  bool _isDeliveryExpanded = false;

  Future _navigateWithAnimation(Widget destination) {
    return navigationService.navigateToWidget(
      destination,
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: AppText('Home', style: normalTextStyle12),
                onTap: () {
                  navigationService.goBack();
                  _navigateWithAnimation(const HomeView());
                },
              ),
              ExpansionTile(
                leading: const Icon(Icons.insights),
                title: AppText('Customer', style: normalTextStyle12),
                onExpansionChanged: (expanded) =>
                    setState(() => _isCustomerExpanded = expanded),
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: AppText('New Customer', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const NewCustomers());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: AppText('List of Customers', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const CustomersListView());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.cake),
                    title: AppText('Birthdays', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const BirthdaysView());
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.money_off_csred_rounded),
                title: AppText('Expenses', style: normalTextStyle12),
                onExpansionChanged: (expanded) =>
                    setState(() => _isExpensesExpanded = expanded),
                children: [
                  ListTile(
                    leading: const Icon(Icons.mobile_friendly),
                    title: AppText('New Expense', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const Expense());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.money_off_csred),
                    title: AppText('All Expenses', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const AllExpenses());
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.join_full),
                title: AppText('Warehouse/Stores', style: normalTextStyle12),
                onExpansionChanged: (expanded) =>
                    setState(() => _isWarehouseExpanded = expanded),
                children: [
                  ListTile(
                    leading: const Icon(Icons.arrow_back),
                    title: AppText('New Stores/Warehouses', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const NewStores());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: AppText('List of Stores/Warehouses', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const SizedBox());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: AppText('My Staffs', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const SizedBox());
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.join_full),
                title: AppText('Delivery', style: normalTextStyle12),
                onExpansionChanged: (expanded) =>
                    setState(() => _isDeliveryExpanded = expanded),
                children: [
                  ListTile(
                    leading: const Icon(Icons.arrow_back),
                    title: AppText('Delivery Rate', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const AddDeliveryRate());
                    },
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.refresh),
                  //   title: AppText('Delivery Agents', style: normalTextStyle12),
                  //   onTap: () {
                  //     navigationService.goBack();
                  //     _navigateWithAnimation(const DeliveryAgent());
                  //   },
                  // ),
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: AppText('List of Suppliers', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const ListOfSuppliers());
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.join_full),
                title: AppText('Sales', style: normalTextStyle12),
                onExpansionChanged: (expanded) =>
                    setState(() => _isDeliveryExpanded = expanded),
                children: [
                  ListTile(
                    leading: const Icon(Icons.arrow_back),
                    title: AppText('Sales Records', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const SalesRecordScreen());
                    },
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.refresh),
                  //   title: AppText('Delivery Agents', style: normalTextStyle12),
                  //   onTap: () {
                  //     navigationService.goBack();
                  //     _navigateWithAnimation(const DeliveryAgent());
                  //   },
                  // ),
                  ListTile(
                    leading: const Icon(Icons.baby_changing_station),
                    title: AppText('Sales List', style: normalTextStyle12),
                    onTap: () {
                      navigationService.goBack();
                      _navigateWithAnimation(const SalesList());
                    },
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: AppText('Logout', style: normalTextStyle12),
                onTap: () {
                  userService.logout();
                  navigationService.navigateTo(loginScreenRoute);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

