class CartItem {
  final String code;
  int quantity;
  double price;
  int? size; // Add size property

  CartItem(
      {required this.code, this.quantity = 1, this.price = 0.0, this.size});
}
