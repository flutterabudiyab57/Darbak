import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'core/helpers/SharedPreference/pereferences.dart';
import 'core/helpers/helper/date_helper.dart';
import 'core/helpers/interceptors/app_interceptor.dart';
import 'core/helpers/notifications/push_notification_service.dart';
import 'modules/notifications/data/datasources/notifications_remote_datasource.dart';
import 'modules/notifications/presentaion/bloc/notifications_cubit.dart';
import 'modules/auth/forgotPassword/data/datasources/forget_password_data_sourse.dart';
import 'modules/auth/forgotPassword/presentaion/bloc/forget_password_cubit.dart';
import 'modules/auth/register/presentaion/bloc/register_cubit.dart';
import 'modules/auth/signin/presentation/bloc/signin_bloc.dart';
import 'modules/home/all_bookings/data/datasources/booking_data_sources.dart';
import 'modules/home/all_bookings/data/datasources/cancel_booking_data_sources.dart';
import 'modules/home/all_branching/bloc/all_branching_cubit.dart';
import 'modules/home/all_branching/data/BranchRepository.dart';
import 'modules/home/all_branching/data/all_branching_remote_datasource.dart';
import 'modules/home/all_branching/data/local/branch_local_datasource.dart';
import 'modules/home/booking_from_cars/datasources/booking_cars_remote_datasource.dart';
import 'modules/home/booking_from_cars/presentaion/bloc/booking_cars_cubit.dart';
import 'modules/home/selectLanguage/languageCubit.dart';
import 'modules/auth/blocs/auth_bloc/onboarding_cubt_cubit.dart';
import 'modules/auth/blocs/auth_status_cubit.dart';
import 'modules/auth/register/data/datasources/local/register_local_datasources.dart';
import 'modules/auth/register/data/datasources/remote/register_remote_datasource.dart';
import 'modules/auth/signin/data/datasources/loacal/sigin_local_datasource.dart';
import 'modules/auth/signin/data/datasources/remote/signin_remote_datasource.dart';
import 'modules/auth/signin/data/repositories/signin_repository_impl.dart';
import 'modules/home/additions/data/datasource/remote/order_addition_remote_datasource.dart';
import 'modules/home/additions/data/repositories/addition_repository.dart';
import 'modules/home/additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import 'modules/home/all_bookings/presentaion/bloc/allbooking_cubit.dart';
import 'modules/home/blocs/booking_cubit/booking_cubit.dart';
import 'modules/home/cars/data/datasources/remote/cars_remote_datasource.dart';
import 'modules/home/cars/data/datasources/remote/favourite_remote_datasource.dart';
import 'modules/home/cars/data/datasources/remote/manufactories_remote_datasource.dart';
import 'modules/home/cars/presentaion/bloc/all_cars_cubit/all_cars_cubit.dart';
import 'modules/home/cars/presentaion/bloc/cubit/cars_cubit.dart';
import 'modules/home/cars/presentaion/bloc/filter_cubit/filter_cubit.dart';
import 'modules/home/category/data/datasources/remote/category_remote_datasource.dart';
import 'modules/home/payment/blocs/invoice_cubit.dart';
import 'modules/home/payment/data/datasources/remote/coupon_remote_datasource.dart';
import 'modules/home/payment/data/datasources/remote/invoice_remote_datasource.dart';
import 'modules/home/payment/data/datasources/remote/payment_remote_datasource.dart';
import 'modules/home/payment/data/repositories/coupon_repository.dart';
import 'modules/home/payment/data/repositories/invoice_repository.dart';
import 'modules/home/payment/data/repositories/payment_repository.dart';
import 'modules/home/profile/blocs/profile_cubit/profile_cubit.dart';
import 'modules/home/profile/page/edit_profile/datasources/remote/edit_remote_dataSource.dart';
import 'modules/home/profile/page/edit_profile/presentaion/bloc/edit_profile_cubit.dart';
import 'modules/home/profile/page/reset_password/datasources/remote/reset_password_datasources.dart';
import 'modules/home/profile/page/reset_password/presentaion/bloc/rsete_password_cubit.dart';
import 'modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'modules/home/search_screen/data/datasources/remote/areas_remote_datasource.dart';
import 'modules/home/search_screen/data/datasources/remote/check_date_remote.dart';
import 'modules/home/search_screen/data/datasources/remote/regions_remote_datasource.dart';

GetIt sl = GetIt.instance;

Future<void> setup() async {
  if (sl.isRegistered<SignInBloc>()) {
    print('⚠️ Service Locator already initialized, skipping...');
    return;
  }

  // ==================== Blocs/Cubits ====================
  sl.registerLazySingleton(() => AuthStatusCubit(sl()));
  sl.registerFactory(() => SignInBloc(sl(), sl()));
  sl.registerFactory(() => RegisterCubit(sl()));
  sl.registerFactory(() => OnBoardingCubit());
  sl.registerLazySingleton(() => BookingCubit(sl()));
  sl.registerLazySingleton(() => LanguageCubit(sl()));
  sl.registerFactory(() => CarsCubit(sl()));
  sl.registerLazySingleton(() => FilterCubit(sl(), sl()));
  sl.registerLazySingleton(() => SearchCubit(sl(), sl(), sl()));
  sl.registerFactory(
      () => AdditionsCubit(sl(), sl(), AllBookingCubit(sl(), sl()), sl()));
  sl.registerFactory(() => EditProfileCubit(sl()));
  sl.registerFactory(() => RsetePasswordCubit(sl()));
  sl.registerFactory(() => ForgetPasswordCubit(sl()));
  sl.registerFactory(() => AllBookingCubit(sl(), sl()));
  sl.registerFactory(() => ProfileCubit(sl()));
  sl.registerFactory(() => InvoiceCubit(sl(), sl(), sl(), sl()));

  // ✅ UPDATED: Branch Cubit with Repository
  sl.registerFactory(() => AllBranchCubit(sl<BranchRepository>()));

  sl.registerFactory(() => BookingFromCarsCubit(sl()));
  sl.registerFactory(() => AllCarsCubit(sl()));

  // Notifications: factory cubit (per-screen), DI Dio for the datasource.
  sl.registerFactory(() => NotificationsCubit(sl()));

  // ==================== Repositories ====================
  sl.registerLazySingleton(() => SignInRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => AdditionRepository(sl(), sl()));
  sl.registerLazySingleton(() => InvoiceRepository(sl(), sl()));
  sl.registerLazySingleton(() => PaymentRepository(sl(), sl()));
  sl.registerLazySingleton(() => CouponRepository(sl(), sl()));

  sl.registerLazySingleton<BranchRepository>(
    () => BranchRepository(
      remoteDataSource: sl<AllBranchRemoteDataSource>(),
      localDataSource: sl<BranchLocalDataSource>(),
    ),
  );

  // ==================== Remote DataSources ====================
  sl.registerLazySingleton(() => SignInRemoteDataSourceImpl());
  sl.registerLazySingleton(() => SignInLocalDataSourceImpl(sl()));
  sl.registerLazySingleton(() => RegisterRemoteDatasource());
  sl.registerLazySingleton(() => RegisterLocalDataSourceImpl(sl()));
  sl.registerLazySingleton(() => CarsRemoteDataSource(sl(), sl()));
  sl.registerLazySingleton(() => ManufactoriesRemoteDataSource());
  sl.registerLazySingleton(() => CategoryRemotDataSource());
  sl.registerLazySingleton(() => OrderAdditionsRemoteDatasource());
  sl.registerLazySingleton(() => EditProfileDataSource());
  sl.registerLazySingleton<ResetPasswordDataSource>(
    () => ResetPasswordDataSource(
      sl<Dio>(),
      sl<SharedPreferencesHelper>(),
    ),
  );
  sl.registerLazySingleton(() => ForgetPasswordDataSourse());
  sl.registerLazySingleton(() => BookingDataSources());
  sl.registerLazySingleton(() => InvoiceRemoteDatasource());
  sl.registerLazySingleton(() => DateCheckerRemote());
  sl.registerLazySingleton(() => PaymentRemoteDatasource());
  sl.registerLazySingleton(() => FavouriteRemoteDatasource(sl()));
  sl.registerLazySingleton(() => RegionsRemoteDatasource(sl()));
  sl.registerLazySingleton<AllBranchRemoteDataSource>(
    () => AllBranchRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton(() => BookingFromCarsRemoteDataSource());
  sl.registerLazySingleton(() => CancelBookingDataSources(sl(), sl()));
  sl.registerLazySingleton(() => CouponRemoteDatasource(sl()));
  sl.registerLazySingleton(() => AreasRemoteDatasource(sl()));
  sl.registerLazySingleton(() => NotificationsRemoteDataSource(sl<Dio>()));

  // ✅ NEW: Branch Local DataSource
  sl.registerLazySingleton<BranchLocalDataSource>(
    () => BranchLocalDataSource(),
  );

  // ==================== External ====================
  sl.registerLazySingleton(() => SharedPreferencesHelper());
  sl.registerLazySingleton(() => DateHandler());
  sl.registerLazySingleton(() => PushNotificationService());
  sl.registerLazySingleton(() => Dio());
  sl<Dio>().interceptors.add(AppInterceptors(sl<SharedPreferencesHelper>()));

  print('✅ Service Locator setup completed with caching system');
}
