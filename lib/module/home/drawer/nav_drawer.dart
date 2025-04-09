import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/deliveries/views/add_delivery_rate.dart';
import 'package:etegram_business/module/deliveries/views/deliveries_agent.dart';
import 'package:etegram_business/module/expenses/view/new_expenses.dart';
import 'package:etegram_business/module/sales/view/sales_view.dart';
import 'package:etegram_business/module/supply/view/new_supplier.dart';
import 'package:etegram_business/module/supply/view/new_supply_view.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../expenses/view/all_expenses.dart';
import '../../supply/view/list_of_suppliers.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  // State variables to track the expansion of each category
  bool _isSupplyExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.7, // ✅ Set max width (75% of screen)
      child: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // UserAccountsDrawerHeader(
              //   accountName: AppText("Anietimfon Effiong"),
              //   accountEmail: AppText("anietimfoneeffiong@gmail.com"),
              //   decoration: BoxDecoration(
              //     image: DecorationImage(
              //       image: AssetImage(AssetValues.noRecord),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              //   currentAccountPicture: CircleAvatar(
              //     backgroundImage: NetworkImage(
              //       "https://your-profile-image-url.com",
              //     ),
              //   ),
              // ),
              // New Supply category with ExpansionTile
              ListTile(
                leading: Icon(Icons.home),
                title: AppText("Home", style: normalTextStyle12),
                onTap: () {
                  // Handle Return subcategory tap
                  navigationService.goBack();
                  // Navigate to the return screen
                  navigationService.navigateTo(homeViewRoute);
                },
              ),
              ListTile(
                leading: Icon(Icons.arrow_back),
                title: AppText("Insight", style: normalTextStyle12),
                onTap: () {
                  // Handle Return subcategory tap
                  navigationService.goBack();
                  // Navigate to the return screen
                  navigationService.navigateToWidget(SAles());
                },
              ),
              ExpansionTile(
                leading: Icon(Icons.insights),
                title: AppText("Customer", style: normalTextStyle12),
                // Control the expansion state
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    _isSupplyExpanded = expanded;
                  });
                },
                children: [
                  // Subcategory ListTile for Return
                  ListTile(
                    leading: Icon(Icons.dashboard_customize),
                    title: AppText("New Customer", style: normalTextStyle12),
                    onTap: () {
                      // Handle Return subcategory tap
                      navigationService.goBack();
                      // Navigate to the return screen
                      navigationService.navigateTo(newCustomerRoute);
                    },
                  ),
                  // Subcategory ListTile for Renewed Supply
                  ListTile(
                    leading: Icon(Icons.refresh),
                    title:
                        AppText("List of Customers", style: normalTextStyle12),
                    onTap: () {
                      // Handle Renewed Supply subcategory tap
                      navigationService.goBack();
                      navigationService.navigateTo(listOfCustomersRoute);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.refresh),
                    title: AppText("Birthdays", style: normalTextStyle12),
                    onTap: () {
                      // Handle Renewed Supply subcategory tap
                      navigationService.goBack();

                      navigationService.navigateTo(birthDayRoute);
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: Icon(Icons.money_off_csred_rounded),
                title: AppText("Expenses", style: normalTextStyle12),
                // Control the expansion state
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    _isSupplyExpanded = expanded;
                  });
                },
                children: [
                  // Subcategory ListTile for Return
                  ListTile(
                    leading: Icon(Icons.mobile_friendly),
                    title: AppText("New Expenses", style: normalTextStyle12),
                    onTap: () {
                      // Handle Return subcategory tap
                      navigationService.goBack();
                      // Navigate to the return screen
                      navigationService.navigateToWidget(NewExpenses());
                    },
                  ),
                  // Subcategory ListTile for Renewed Supply
                  ListTile(
                    leading: Icon(Icons.money_off_csred),
                    title: AppText("All Expenses", style: normalTextStyle12),
                    onTap: () {
                      // Handle Renewed Supply subcategory tap
                      navigationService.goBack();
                      // Navigate to the renewed supply screen
                      navigationService.navigateToWidget(AllExpenses());
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: Icon(Icons.join_full),
                title: AppText("Warehouse/Stores", style: normalTextStyle12),
                // Control the expansion state
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    _isSupplyExpanded = expanded;
                  });
                },
                children: [
                  // Subcategory ListTile for Return
                  ListTile(
                    leading: Icon(Icons.arrow_back),
                    title: AppText("New stores/warehouses",
                        style: normalTextStyle12),
                    onTap: () {
                      // Handle Return subcategory tap
                      navigationService.goBack();
                      // Navigate to the return screen
                      navigationService.navigateToWidget(SAles());
                    },
                  ),
                  // Subcategory ListTile for Renewed Supply
                  ListTile(
                    leading: Icon(Icons.refresh),
                    title: AppText("List of Stores/Warehouses",
                        style: normalTextStyle12),
                    onTap: () {
                      // Handle Renewed Supply subcategory tap
                      navigationService.goBack();
                      // Navigate to the renewed supply screen
                      // navigationService.navigateTo(renewedSupplyScreen);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.refresh),
                    title: AppText("My Staffs", style: normalTextStyle12),
                    onTap: () {
                      // Handle Renewed Supply subcategory tap
                      navigationService.goBack();
                      // Navigate to the renewed supply screen
                      // navigationService.navigateTo(renewedSupplyScreen);
                    },
                  ),
                ],
              ),

              ExpansionTile(
                leading: Icon(Icons.join_full),
                title: AppText("Delivery", style: normalTextStyle12),
                // Control the expansion state
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    _isSupplyExpanded = expanded;
                  });
                },
                children: [
                  // Subcategory ListTile for Return
                  ListTile(
                    leading: Icon(Icons.arrow_back),
                    title: AppText("Delivery Rate", style: normalTextStyle12),
                    onTap: () {
                      // Handle Return subcategory tap
                      navigationService.goBack();
                      // Navigate to the return screen
                      navigationService.navigateToWidget(DeliveryAgent());
                    },
                  ),
                  // Subcategory ListTile for Renewed Supply
                  ListTile(
                    leading: Icon(Icons.refresh),
                    title: AppText("Delivery Agents", style: normalTextStyle12),
                    onTap: () {
                      // Handle Renewed Supply subcategory tap
                      navigationService.goBack();
                      // Navigate to the renewed supply screen
                      navigationService.navigateToWidget(AddDeliveryRate());
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.refresh),
                    title:
                        AppText("List of Suppliers", style: normalTextStyle12),
                    onTap: () {
                      // Handle Renewed Supply subcategory tap
                      navigationService.goBack();
                      // Navigate to the renewed supply screen
                      navigationService.navigateToWidget(ListOfSuppliers());
                    },
                  ),
                ],
              ),
              // Add more categories with ExpansionTile as needed
              ListTile(
                leading: Icon(Icons.logout),
                title: AppText("Logout", style: normalTextStyle12),
                onTap: () {
                  // Handle Return subcategory tap
                  userService.logout();
                  // Navigate to the return screen
                  //navigationService.navigateTo(returnScreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
