import 'package:flutter/material.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import '../../../../constants/colors.dart';
import '../../../../core/model/bank.dart';
import '../../../../routes/routes.dart';
import '../../viewmodel/add_payment_method_vm.dart';

class AddPaymentMethodView extends StatelessWidget {
  const AddPaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<AddPaymentMethodViwModel>(
      onModelReady: (logic) => logic.init(),
      builder: (_, logic, child) => Scaffold(
        appBar: AppBar(title: const Text('Add Payment Method')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: logic.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (logic.errorMessage != null)
                Text(logic.errorMessage!,
                    style: const TextStyle(color: Colors.red)),

              AppTextField(
                onChanged: logic.updateNewMethodName,
                hint: StringValues.paymentMethodName,
              ),

              const SizedBox(height: 16),

              DropdownButton<Bank>(
                isExpanded: true,
                hint: const Text('Select Bank'),
                value: logic.selectedBank,
                onChanged: logic.selectBank,
                items: logic.banks.map((bank) {
                  return DropdownMenuItem<Bank>(
                    value: bank,
                    child: Text(bank.name),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller:
                TextEditingController(text: logic.newMethodBank),
                hint: 'Bank (Read-only)',
                enabled: false,
              ),

              AppTextField(
                onChanged: logic.updateAccountNumber,
                hint: 'Account Number',
              ),

              AppTextField(
                onChanged: logic.updateAccountName,
                hint: 'Account Name',
              ),

              TextField(
                maxLines: 3,
                onChanged: logic.updateExtraInfo,
                decoration: const InputDecoration(
                    labelText: 'Extra Info (Optional)'),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: logic.canSave()
                    ? () async {
                  await logic.savePaymentMethod();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushReplacementNamed(dashboardRoute);
                  }
                }
                    : null,
                child: const Text('Save Payment Method'),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: logic.paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = logic.paymentMethods[index];
                    return ListTile(
                      title: AppText(method.name ?? ""),
                      subtitle: AppText(method.bank ?? ""),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
