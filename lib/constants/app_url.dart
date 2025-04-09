abstract class AppUrls {
  static const baseUrl = 'https://6219-197-210-84-210.ngrok-free.app/api/';
  static const registerUrl = 'auth/register';
  static const verifyEmailUrl = "auth/verify-email";
  static const loginUrl = 'auth/login';
  static const String getUserUrl = 'user';
  static const String getUserAfterVerificationUrl =
      "/user/user/after-verification/{email}";
  static const scanAddProductsUrl = "products/scan-and-add";
  static const searchProductUrl = "products/search";
  static const getProductsUrl = "products";
  static const String logoutUrl = 'auth/logout';
  static const barcodeLockUp = 'https://api.barcodelookup.com/v3/products';
  static const createStoreUrl = "stores";
  static const forgotPasswordUrl = "auth/forgot-password";
  static const resetPasswordUrl  = "auth/forgot-password/update";
  static const createPaymentMethod = "payment-methods";
  static const getPaymentMethod = "payment-methods";
  static const createCheckout = "checkout";
  static const createCustomerUrl = 'customer';
  static const getExpenseUrl = "expenses";
  static const createDeliveryUrl = "deliveries";
}
