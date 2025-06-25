// customer_card.dart
import 'package:flutter/material.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CustomerCard extends StatelessWidget {
  final CustomerData customer;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final birthday = customer.birthday != null
        ? DateFormat('MMMM d').format(DateTime.parse(customer.birthday!))
        : 'Unknown';
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListTile(
        onTap: onTap,
        title: AppText(
          '${customer.firstName} ${customer.lastName}',
          style: bodyLarge,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Email: ${customer.email}', style: normalTextStyle12),
            AppText('Phone: ${customer.phoneNumber}', style: normalTextStyle12),
            AppText('Birthday: $birthday', style: normalTextStyle12),
            if (customer.address!.isNotEmpty)
              AppText('Address: ${customer.address}', style: normalTextStyle12),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
