import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_life_cycle_manager.dart';
import 'core/style/style.dart';
import 'core/theme.dart';
import 'modules/home/selectLanguage/languageCubit.dart';
import 'language/locale.dart';
import 'modules/auth/splash_screen.dart';
import 'service_locator.dart';
import 'modules/auth/blocs/auth_bloc/auth_bloc.dart';
import 'modules/auth/forgotPassword/presentaion/bloc/forget_password_cubit.dart';
import 'modules/home/additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import 'modules/home/all_bookings/presentaion/bloc/allbooking_cubit.dart';
import 'modules/home/all_branching/bloc/all_branching_cubit.dart';
import 'modules/home/blocs/booking_cubit/booking_cubit.dart';
import 'modules/home/cars/presentaion/bloc/all_cars_cubit/all_cars_cubit.dart';
import 'modules/home/cars/presentaion/bloc/cubit/cars_cubit.dart';
import 'modules/home/cars/presentaion/bloc/filter_cubit/filter_cubit.dart';
import 'modules/home/payment/blocs/invoice_cubit.dart';
import 'modules/home/profile/blocs/profile_cubit/profile_cubit.dart';
import 'modules/home/search_screen/blocs/search_bloc/search_cubit.dart';

MultiBlocProvider CreateBlocProviders(BuildContext context) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
      BlocProvider<CarsCubit>(create: (context) => sl<CarsCubit>()),
      BlocProvider<BookingCubit>(create: (context) => sl<BookingCubit>()),
      BlocProvider<LanguageCubit>(create: (context) => sl<LanguageCubit>()),
      BlocProvider<ForgetPasswordCubit>(create: (context) => sl<ForgetPasswordCubit>()),
      BlocProvider<ProfileCubit>(create: (context) => sl<ProfileCubit>()),
      BlocProvider<AdditionsCubit>(create: (context) => sl<AdditionsCubit>()),
      BlocProvider<InvoiceCubit>(create: (context) => sl<InvoiceCubit>()),
      BlocProvider<SearchCubit>(create: (context) => sl<SearchCubit>()),
      BlocProvider<FilterCubit>(create: (context) => sl<FilterCubit>()),
      BlocProvider<AllBookingCubit>(create: (context) => sl<AllBookingCubit>()),
      BlocProvider<AllBranchCubit>(create: (context) => sl<AllBranchCubit>()),
      BlocProvider<AllCarsCubit>(create: (context) => sl<AllCarsCubit>()),
      BlocProvider<AdditionsCubit>(create: (context) => sl<AdditionsCubit>()),
      BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
    ],
    child: BlocBuilder<LanguageCubit, Locale>(
      builder: (_, locale) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return AppLifeCycleManager(
              child: MaterialApp(
                useInheritedMediaQuery: true,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [
                  const AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en'), Locale('ar')],
                locale: locale,
                theme: lightTheme(),
                darkTheme: darkTheme(),
                themeMode: themeMode,
                home: SplashScreenOld(),
              ),
            );
          },
        );
      },
    ),
  );
}
