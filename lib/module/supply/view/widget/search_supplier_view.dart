import 'package:flutter/material.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app_widget/input_fields.dart';
import '../../../../base/base_ui.dart';
import '../../view_model/supplier_list_vm.dart';
import '../new_supplier.dart';

class SearchSupplierScreen extends StatelessWidget {
  const SearchSupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SupplierListViewModel>(
      onModelReady: (model) => model.loadSuppliers(),
      builder: (context, logic, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text("Search Suppliers"),
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 1,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AppTextField(
                  hint: "Search by name, phone, or email...",
                  onChanged: logic.searchSuppliers,
                ),
              ),
              Expanded(
                child: logic.isLoading.value
                    ? const Center(child:
                SpinKitChasingDots(
                  color: Colors.white,
                  size: 50.0,
                ))
                    : logic.filteredSuppliers.isEmpty
                        ? Center(child: SvgPicture.asset(SvgAssets.noRecord))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: logic.filteredSuppliers.length,
                            itemBuilder: (context, index) {
                              final supplier = logic.filteredSuppliers[index];
                              final data = supplier.data;

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    data?.businessName ?? "No Business Name",
                                    style: normalTextStyle.copyWith(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      if (data?.email != null)
                                        Text(
                                          "Email: ${data!.email}",
                                          style: normalTextStyle12,
                                        ),
                                      if (data?.phoneNumber != null)
                                        Text(
                                          "Phone: ${data?.phoneNumber}",
                                          style: normalTextStyle12,
                                        ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NewSupplierView(),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
