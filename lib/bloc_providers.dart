import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_life_cycle_manager.dart';
import 'core/router/app_router.dart';
import 'core/style/style.dart';
import 'core/theme.dart';
import 'modules/home/selectLanguage/languageCubit.dart';
import 'language/locale.dart';
import 'service_locator.dart';
import 'modules/auth/blocs/auth_status_cubit.dart';
import 'modules/home/additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import 'modules/home/all_bookings/presentaion/bloc/allbooking_cubit.dart';
import 'modules/home/blocs/booking_cubit/booking_cubit.dart';
import 'modules/home/payment/blocs/invoice_cubit.dart';
import 'modules/home/profile/blocs/profile_cubit/profile_cubit.dart';
import 'modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'modules/home/all_branching/bloc/all_branching_cubit.dart';

MultiBlocProvider CreateBlocProviders(BuildContext context) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthStatusCubit>.value(value: sl<AuthStatusCubit>()),
      BlocProvider<BookingCubit>(create: (context) => sl<BookingCubit>()),
      BlocProvider<LanguageCubit>(create: (context) => sl<LanguageCubit>()),
      BlocProvider<ProfileCubit>(create: (context) => sl<ProfileCubit>()),
      BlocProvider<AdditionsCubit>(create: (context) => sl<AdditionsCubit>()),
      BlocProvider<InvoiceCubit>(create: (context) => sl<InvoiceCubit>()),
      BlocProvider<SearchCubit>(create: (context) => sl<SearchCubit>()),
      BlocProvider<AllBranchCubit>(create: (context) => sl<AllBranchCubit>()),
      BlocProvider<AllBookingCubit>(create: (context) => sl<AllBookingCubit>()),
      BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
    ],
    child: BlocBuilder<LanguageCubit, Locale>(
      builder: (_, locale) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return AppLifeCycleManager(
              child: MaterialApp.router(
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
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: MediaQuery.textScalerOf(context).clamp(
                        minScaleFactor: 0.8,
                        maxScaleFactor: 1.2,
                      ),
                    ),
                    child: child!,
                  );
                 },
                routerConfig: appRouter,
              ),
            );
          },
        );
      },
    ),
  );
}
