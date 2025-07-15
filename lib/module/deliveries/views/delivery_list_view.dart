import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/delivery_response.dart';
import 'package:etegram_business/module/deliveries/vm/delivery_vm.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';

import 'add_delivery_rate.dart';

class DeliveryListView extends StatelessWidget {
  const DeliveryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<DeliveryViewModel>(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: 'Delivery Management',
          onBackPressed: () => navigationService.goBack(),
          showMenuIcon: false,
        ),
        body: model.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: 16.0.padA,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppButton(
                      text: 'Add Delivery Agent',
                      onTap: () => navigationService.navigateToWidget(
                        const AddDeliveryRate(),
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    ),
                    20.0.sbH,
                    _buildSectionTitle('Delivery Agents'),
                    if (model.deliveryAgents.isEmpty)
                      const Center(child: Text('No delivery agents found.'))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: model.deliveryAgents.length,
                        itemBuilder: (context, index) {
                          final agent = model.deliveryAgents[index];
                          return _buildAgentCard(context, model, agent);
                        },
                      ),
                    20.0.sbH,
                    _buildSectionTitle('Delivery Transactions'),
                    if (model.deliveryTransactions.isEmpty)
                      const Center(
                          child: Text('No delivery transactions found.'))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: model.deliveryTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = model.deliveryTransactions[index];
                          return _buildTransactionCard(context, transaction);
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: 8.0.padV,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorValues.primaryColor,
        ),
      ),
    );
  }

  Widget _buildAgentCard(
      BuildContext context, DeliveryViewModel model, DeliveryData agent) {
    return Card(
      margin: 8.0.padV,
      child: ListTile(
        title: Text('${agent.firstName} ${agent.lastName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${agent.email}'),
            Text('Phone: ${agent.phoneNumber}'),
            Text('Location: ${agent.city}, ${agent.state}, ${agent.country}'),
            Text('Status: ${agent.status ?? 'ACTIVE'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: ColorValues.primaryColor),
              onPressed: () {
                // TODO: Navigate to edit screen (e.g., AddDeliveryRate with pre-filled data)
                showCustomToast('Edit functionality to be implemented.');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Delivery Agent?'),
                    content: Text(
                        'Are you sure you want to delete ${agent.firstName} ${agent.lastName}?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          model.deleteDeliveryAgent(agent.id!, context);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, DeliveryTransactionData transaction) {
    return Card(
      margin: 8.0.padV,
      child: ListTile(
        title: Text('Order ID: ${transaction.orderId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${transaction.status}'),
            Text('Items: ${transaction.items?.length ?? 0}'),
            Text('Created: ${transaction.createdAt?.toString() ?? 'Unknown'}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info, color: ColorValues.primaryColor),
          onPressed: () {
            // TODO: Navigate to transaction details screen
            showCustomToast('Transaction details to be implemented.');
          },
        ),
      ),
    );
  }
}
