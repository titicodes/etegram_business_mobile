import 'package:etegram_business/service/local/drawer_service.dart';
import 'package:etegram_business/service/web/store_api_service.dart';
import 'package:get_it/get_it.dart';
import 'package:etegram_business/module/account/viewmodel/change_password_vm.dart';
import 'package:etegram_business/module/account/viewmodel/change_pin_vm.dart';
import 'package:etegram_business/module/account/viewmodel/notification_vm.dart';
import 'package:etegram_business/module/auth/viewmodel/signin_vm.dart';
import 'package:etegram_business/module/auth/viewmodel/signup_vm.dart';
import 'package:etegram_business/module/auth/viewmodel/verify_email.dart';
import 'package:etegram_business/module/deliveries/vm/delivery_vm.dart';
import 'package:etegram_business/module/expenses/vm/expenses_viewmodel.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/product/vm/product_viewmodel.dart';
import 'package:etegram_business/module/splash/splash_view_model.dart';
import 'package:etegram_business/repository/auth_repository.dart';
import 'package:etegram_business/repository/customer_repository.dart';
import 'package:etegram_business/repository/delivery_repository.dart';
import 'package:etegram_business/repository/expenses_repository.dart';
import 'package:etegram_business/repository/payment_method_repository.dart';
import 'package:etegram_business/repository/product_repository.dart';
import 'package:etegram_business/repository/sales_repository.dart';
import 'package:etegram_business/repository/store_repostory.dart';
import 'package:etegram_business/repository/supply_repository.dart';
import 'package:etegram_business/service/local/cache.dart';
import 'package:etegram_business/service/local/navigation_service.dart';
import 'package:etegram_business/service/local/storage_service.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/service/web/auth_api.dart';
import 'package:etegram_business/service/web/customer_api_service.dart';
import 'package:etegram_business/service/web/delivery_api_service.dart';
import 'package:etegram_business/service/web/expenses_api_service.dart';
import 'package:etegram_business/service/web/notification_api_service.dart';
import 'package:etegram_business/service/web/payment_method_api_service.dart';
import 'package:etegram_business/service/web/product_api.dart';
import 'package:etegram_business/service/web/sales_api_service.dart';
import 'package:etegram_business/service/web/supply_api.dart';
import 'package:etegram_business/module/auth/viewmodel/add_payment_method_vm.dart';
import 'package:etegram_business/module/auth/viewmodel/forget_password_vm.dart';
import 'package:etegram_business/module/customer/vm/customer_vm.dart';
import 'package:etegram_business/module/deliveries/vm/moved_product_vm.dart';
import 'package:etegram_business/module/home/vm/main_nav_vm.dart';
import 'package:etegram_business/module/onboarding/onboarding_vm.dart';
import 'package:etegram_business/module/profile/vm/profle_vm.dart';
import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
import 'package:etegram_business/module/sales/vm/sales_record_vm.dart';
import 'package:etegram_business/module/stores/vm/stores_vm.dart';
import 'package:etegram_business/module/supply/view_model/supplier_list_vm.dart';
import 'package:etegram_business/module/supply/view_model/supply_vm.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  registerViewModels();
  registerServices();
}

void registerServices() {
  locator.registerLazySingleton(() => CustomerService());
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
  locator.registerLazySingleton<StorageService>(() => StorageService());
  locator.registerLazySingleton(() => AppCache());
  locator.registerLazySingleton<AuthRepository>(() => AuthRepository());
  locator.registerLazySingleton<AuthenticationApiService>(() => AuthenticationApiService());
  locator.registerLazySingleton<ProductRepository>(() => ProductRepository());
  locator.registerLazySingleton<ProductApiService>(() => ProductApiService());
  locator.registerLazySingleton<StoreApiService>(() => StoreApiService());
  locator.registerLazySingleton<SupplyApiService>(() => SupplyApiService());
  locator.registerLazySingleton<StoreRepository>(() => StoreRepository());
  locator.registerLazySingleton<SupplyRepository>(() => SupplyRepository());
  locator.registerLazySingleton<PaymentMethodRepository>(() => PaymentMethodRepository());
  locator.registerLazySingleton<PaymentMethodApiService>(() => PaymentMethodApiService());
  locator.registerLazySingleton<SalesRepository>(() => SalesRepository());
  locator.registerLazySingleton<SalesApiService>(() => SalesApiService());
  locator.registerLazySingleton<CustomerApiService>(() => CustomerApiService());
  locator.registerLazySingleton<CustomerRepository>(() => CustomerRepository());
  locator.registerLazySingleton<ExpensesApiService>(() => ExpensesApiService());
  locator.registerLazySingleton<ExpensesRepository>(() => ExpensesRepository());
  locator.registerLazySingleton<DeliveryRepository>(() => DeliveryRepository());
  locator.registerLazySingleton<DeliveryApiService>(() => DeliveryApiService());
  locator.registerLazySingleton<NotificationService>(() => NotificationService());
  locator.registerLazySingleton<SaleViewModel>(() => SaleViewModel());
  locator.registerLazySingleton<MainNavViewModel>(() => MainNavViewModel());
  locator.registerLazySingleton<HomeViewModel>(() => HomeViewModel());
  locator.registerLazySingleton<ChangePasswordViewModel>(() => ChangePasswordViewModel());
  locator.registerLazySingleton<DrawerService>(() => DrawerService());
}

void registerViewModels() {
  locator.registerFactory<OnBoardingViewModel>(() => OnBoardingViewModel());
  locator.registerFactory<SignUpViewModel>(() => SignUpViewModel());
  locator.registerFactory<LoginViewModel>(() => LoginViewModel());
  locator.registerFactory<MoveProductViewModel>(() => MoveProductViewModel());
  locator.registerFactory<SupplierViewModel>(() => SupplierViewModel());
  locator.registerFactory<SalesRecordViewModel>(() => SalesRecordViewModel());
  locator.registerFactory<VerifyEmailViewModel>(() => VerifyEmailViewModel());
  locator.registerFactory<StoresViewModel>(() => StoresViewModel());
  locator.registerFactory<ProductViewModel>(() => ProductViewModel());
  locator.registerFactory<ProfileViewModel>(() => ProfileViewModel());
  locator.registerFactory<ChangePinViewModel>(() => ChangePinViewModel());
  locator.registerFactory<SupplierListViewModel>(() => SupplierListViewModel());
  locator.registerFactory<CustomerViewModel>(() => CustomerViewModel());
  locator.registerFactory<ExpensesViewModel>(() => ExpensesViewModel());
  locator.registerFactory<AddPaymentMethodViewModel>(() => AddPaymentMethodViewModel());
  locator.registerFactory<DeliveryViewModel>(() => DeliveryViewModel());
  locator.registerFactory<ForgetPasswordViewModel>(() => ForgetPasswordViewModel());
  locator.registerFactory<SplashScreenViewModel>(() => SplashScreenViewModel());
  locator.registerFactory<NotificationViewModel>(() => NotificationViewModel());
}