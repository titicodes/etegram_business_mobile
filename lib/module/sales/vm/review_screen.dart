import 'package:flutter/material.dart';

import '../../../core/model/get_scan_response.dart';
import '../../../locator.dart';
import '../../../utils/snack_message.dart';
import '../view/widgets/payment_screen.dart';
import 'new_sales_vm.dart';

class ReviewScreen extends StatefulWidget {
  final List<Cart> cartItems; // Receiving cartItems from ScanToCheckoutView

  const ReviewScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final SaleViewModel _saleViewModel = locator<SaleViewModel>();
  final _promoCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the cart items passed from ScanToCheckoutView
    _saleViewModel.cartItems = widget.cartItems;
  }

  @override
  Widget build(BuildContext context) {
    double total = _saleViewModel.calculateTotalPrice();
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Items'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: () {
              _saleViewModel.clearCart(context);
            },
            tooltip: 'Clear Cart',
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: _saleViewModel,
        builder: (context, child) {
          final items = _saleViewModel.cartItems;

          if (items.isEmpty) {
            return Center(child: Text('Your cart is empty'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(item.name ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₦${(item.price ?? 0).toStringAsFixed(2)}'),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if ((item.quantity ?? 1) > 1) {
                                _saleViewModel.updateItemQuantityInReview(
                                    item, item.quantity! - 1);
                              }
                            },
                          ),
                          Text('Qty: ${item.quantity ?? 1}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              final newQty = (item.quantity ?? 1) + 1;
                              _saleViewModel.updateItemQuantityInReview(
                                  item, newQty);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _saleViewModel.removeItemFromReview(item);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _promoCodeController,
              decoration: InputDecoration(
                labelText: "Promo Code",
                suffixIcon: IconButton(
                  icon: Icon(Icons.check_circle),
                  onPressed: () {
                    final code = _promoCodeController.text.trim().toLowerCase();
                    if (code == 'promo200') {
                      _saleViewModel.updateDiscount(200);
                      showCustomToast("₦200 discount applied");
                    } else {
                      showCustomToast("Invalid promo code");
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _saleViewModel,
              builder: (context, child) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount:'),
                        Text(
                            '- ₦${_saleViewModel.discount.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:'),
                        Text(
                          '₦${_saleViewModel.calculateTotalPrice().toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // review_screen.dart
            ElevatedButton.icon(
              icon: Icon(Icons.payment),
              label: Text('Proceed to Payment'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
              onPressed: () {
                if (_saleViewModel.cartItems.isEmpty) {
                  showCustomToast("Cart is empty");
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      totalAmount: total,
                      cartItems: _saleViewModel.cartItems, // Pass cartItems here
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
