abstract class AppUrls {
  static const baseUrl = 'https://storefrontapp.etegramgroup.com/api/';
 //static const baseUrl = 'https://9d325fb0987f.ngrok-free.app/api/';
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
  static const resetPasswordUrl = "auth/forgot-password/update";
  static const createPaymentMethod = "payment-methods";
  static const getPaymentMethod = "payment-methods";
  static const createCheckout = "checkout";
  static const String changePasswordUrl = 'auth/user/change-password';
  static const createCustomerUrl = 'customers';
  static const getExpenseUrl = "expenses";
  static const createDeliveryUrl = "deliveries";
  static const String resendOtpUrl = "otp/resend";
}
