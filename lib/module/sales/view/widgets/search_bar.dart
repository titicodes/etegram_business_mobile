import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/sales/vm/sales_record_vm.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    var model = locator<SalesRecordViewModel>();
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        onChanged: model.onQueryChanged,
        decoration: InputDecoration(
          labelText: 'Search Customers',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
