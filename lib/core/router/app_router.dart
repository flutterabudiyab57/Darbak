import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/Maps/map_select_location.dart';
import '../../modules/auth/blocs/auth_bloc/onboarding_cubt_cubit.dart';
import '../../modules/auth/forgotPassword/presentaion/page/change_password.dart';
import '../../modules/auth/forgotPassword/presentaion/page/enter_code.dart';
import '../../modules/auth/forgotPassword/presentaion/page/errorPage.dart';
import '../../modules/auth/forgotPassword/presentaion/widgets/forgotPassword.dart';
import '../../modules/auth/on_boarding/on_boarding.dart';
import '../../modules/auth/register/presentaion/pages/otp_register.dart';
import '../../modules/auth/register/presentaion/pages/register_page.dart';
import '../../modules/auth/signin/presentation/pages/signin_screen.dart';
import '../../modules/auth/splash_screen.dart';
import '../../modules/home/additions/presentaion/pages/additions_screen.dart';
import '../../modules/home/all_bookings/data/model/booking_model.dart';
import '../../modules/home/all_bookings/data/model/check_order_step_model.dart';
import '../../modules/home/all_bookings/presentaion/page/all_booking_screen.dart';
import '../../modules/home/all_bookings/presentaion/page/bookDetailes.dart';
import '../../modules/home/all_branching/page/branches_screen.dart';
import '../../modules/home/all_branching/page/view_location.dart';
import '../../modules/home/booking_confirmed/bookingConfirmed.dart';
import '../../modules/home/booking_from_cars/presentaion/view/branchs_with_car_screan.dart';
import '../../modules/home/booking_packages/ui/airboart_package_screen.dart';
import '../../modules/home/booking_packages/ui/daily_package_screen.dart';
import '../../modules/home/booking_packages/ui/delivery_package_screen.dart';
import '../../modules/home/booking_packages/ui/monthly_package_screen.dart';
import '../../modules/home/cars/data/models/cars_model.dart';
import '../../modules/home/cars/presentaion/all_cars_screen.dart';
import '../../modules/home/cars/presentaion/page/cars_info.dart';
import '../../modules/home/cars/presentaion/page/filter_cars.dart';
import '../../modules/home/cars/presentaion/page/image_car_page.dart';
import '../../modules/home/cars/presentaion/search_cars/search_about_car.dart';
import '../../modules/home/cash_back/screen/CashBackScreen.dart';
import '../../modules/home/complaints/screen/complaint_screen.dart';
import '../../modules/home/home_screen/clasic.dart';
import '../../modules/home/offers/offer_details_screen.dart';
import '../../modules/home/offers/offers_tap_screen.dart';
import '../../modules/notifications/presentaion/page/notifications_screen.dart';
import '../../modules/home/payment/data/models/credit_card_model.dart';
import '../../modules/home/payment/data/models/invoice_model.dart' hide Icon;
import '../../modules/home/payment/invoice.dart';
import '../../modules/home/payment/invouce_notCompleted.dart';
import '../../modules/home/payment/paymentMethods.dart';
import '../../modules/home/payment/widget/web_payment.dart';
import '../../modules/home/profile/data/models/profile_model.dart';
import '../../modules/home/profile/page/edit_profile/presentaion/page/edit_profile.dart';
import '../../modules/home/profile/page/privacy_policy/privacy_policy.dart';
import '../../modules/home/profile/page/profile.dart';
import '../../modules/home/profile/page/reset_password/presentaion/page/reset_password.dart';
import '../../modules/home/search_screen/data/models/filter_model.dart';
import '../../modules/home/search_screen/presentaion/search_Screen.dart';
import '../../modules/home/selectLanguage/selectLanguage.dart';
import '../../modules/home/additions/data/models/step_one_order_model.dart' hide Icon, Photo;
import '../../modules/shell/app_shell.dart';

import 'bottom_sheet_page.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ───── auth ─────
    GoRoute(
      path: '/',
      name: Routes.splash,
      builder: (_, __) => SplashScreenOld(),
    ),
    GoRoute(
      path: '/language',
      name: Routes.language,
      pageBuilder: (_, s) => CustomTransitionPage(
        key: s.pageKey,
        child: SelectLanguage((s.extra as bool?) ?? true),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      name: Routes.onBoarding,
      pageBuilder: (_, s) => CustomTransitionPage(
        key: s.pageKey,
        child: OnBoarding(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    ),
    GoRoute(
      path: '/signin',
      name: Routes.signin,
      builder: (_, s) {
        final a = s.extra as AuthScreenArgs?;
        return SignInScreen(
          isLogin: a?.isLogin,
          cubit: a?.cubit,
          pushAddition: a?.pushAddition ?? false,
        );
      },
    ),
    GoRoute(
      path: '/register',
      name: Routes.register,
      builder: (_, s) {
        final a = s.extra as AuthScreenArgs?;
        return RegisterPage(
          isLogin: a?.isLogin,
          onBoardingCubit: a?.cubit,
          pushAddition: a?.pushAddition ?? false,
        );
      },
    ),
    GoRoute(
      path: '/otp',
      name: Routes.otp,
      builder: (_, s) {
        final a = s.extra as OtpArgs;
        return OtpVerifyScreen(userId: a.userId, phone: a.phone);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      name: Routes.forgotPassword,
      builder: (_, __) => ForgotPasswordScreen.entry(),
    ),
    GoRoute(
      path: '/enter-code',
      name: Routes.enterCode,
      builder: (_, __) => EnterCodeScrean(),
    ),
    GoRoute(
      path: '/change-password',
      name: Routes.changePassword,
      builder: (_, __) => ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/error',
      name: Routes.errorPage,
      builder: (_, __) => const ErrorPage(),
    ),

    // ───── shell ─────
    // The 4-tab shell is a StatefulShellRoute: each tab is its own branch with
    // its own navigator and preserved state. `ShellScaffold` wraps the branches
    // with the bottom-nav chrome. The bottom nav appears ONLY here — every
    // detail route below is top-level (root navigator), so pushing one covers
    // this scaffold and hides the nav for free.
    //
    // Branch order MUST match the bottom-nav index and Routes.shellBranchPaths:
    //   0 → /home (Search)  1 → /fleet (Cars)  2 → /bookings  3 → /profile
    StatefulShellRoute.indexedStack(
      builder: (_, __, navigationShell) =>
          ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: Routes.home,
              builder: (_, __) => SearchScreen.entry(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/fleet',
              name: Routes.fleet,
              builder: (_, __) =>
                  AllCarsScreen.entry(fromFilter: false, filterModel: null),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bookings',
              name: Routes.bookings,
              builder: (_, __) => AllBookingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: Routes.profile,
              builder: (_, __) => const MyProfile(),
            ),
          ],
        ),
      ],
    ),

    // ───── cars / search ─────
    GoRoute(
      path: '/cars',
      name: Routes.allCars,
      builder: (_, s) {
        final a = s.extra as AllCarsArgs?;
        return AllCarsScreen.entry(
          filterModel: a?.filterModel,
          fromFilter: a?.fromFilter ?? false,
          model: a?.model,
        );
      },
    ),
    GoRoute(
      path: '/car',
      name: Routes.carsInformation,
      builder: (_, s) {
        final a = s.extra as CarsInformationArgs;
        return CarsInformation(
          datum: a.datum,
          filterModel: a.filterModel,
          stockStatus: a.stockStatus,
        );
      },
    ),
    GoRoute(
      path: '/filter-cars',
      name: Routes.filterCars,
      builder: (_, __) => FiltersCars.entry(),
    ),
    GoRoute(
      path: '/search-cars',
      name: Routes.searchAboutCar,
      pageBuilder: (_, s) => CustomTransitionPage(
        key: s.pageKey,
        child: const SearchCarScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    ),
    GoRoute(
      path: '/car-images',
      name: Routes.imageCarPage,
      builder: (_, s) => ImageCarPage(photo: s.extra as List<Photo>),
    ),
    GoRoute(
      path: '/classic',
      name: Routes.classic,
      builder: (_, __) => Clasic.entry(),
    ),

    // ───── booking ─────
    GoRoute(
      path: '/branch-with-car',
      name: Routes.branchWithCar,
      builder: (_, s) => BranchWithCarScreen(carModel: s.extra as DataCars),
    ),
    GoRoute(
      path: '/daily-package',
      name: Routes.dailyPackage,
      builder: (_, __) => const DailyPackages(),
    ),
    GoRoute(
      path: '/monthly-package',
      name: Routes.monthlyPackage,
      builder: (_, __) => MonthlyPackageScreen.entry(),
    ),
    GoRoute(
      path: '/airport-package',
      name: Routes.airportPackage,
      builder: (_, __) => AirportPackageScreen.entry(),
    ),
    GoRoute(
      path: '/delivery-package',
      name: Routes.deliveryPackage,
      builder: (_, __) => DeliveryPackageScreen.entry(),
    ),
    GoRoute(
      path: '/additions',
      name: Routes.additions,
      builder: (_, s) {
        final a = s.extra as AdditionsArgs?;
        return AdditionsScreen(
          datum: a?.datum,
          checkOrderStepModel: a?.checkOrderStepModel,
          bookDetails: a?.bookDetails,
          fromNotCompleted: a?.fromNotCompleted,
          fromAddAdditions: a?.fromAddAdditions,
        );
      },
    ),
    GoRoute(
      path: '/book-details',
      name: Routes.bookDetails,
      builder: (_, s) {
        final a = s.extra as BookDetailsArgs;
        return BookDetails(
          bookingData: a.bookingData,
          dataCars: a.dataCars,
          checkOrderStepModel: a.checkOrderStepModel,
          isNotCompleted: a.isNotCompleted,
        );
      },
    ),
    GoRoute(
      path: '/booking-confirmed',
      name: Routes.bookingConfirmed,
      pageBuilder: (_, s) {
        final a = s.extra as BookingConfirmedArgs? ?? const BookingConfirmedArgs();
        return BottomSheetPage(
          key: s.pageKey,
          child: BookingConfirmedBottomSheet(
            orderId: a.orderId,
            carName: a.carName,
            total: a.total,
          ),
        );
      },
    ),

    // ───── payment ─────
    GoRoute(
      path: '/payment-methods',
      name: Routes.paymentMethods,
      builder: (_, s) {
        final a = s.extra as PaymentMethodsArgs;
        return PaymentMethodsScreen(
          a.newBooking,
          stepOneOrderModel: a.stepOneOrderModel,
          carModel: a.carModel,
          isAutomated: a.isAutomated,
          datum: a.datum,
          isNotCompleted: a.isNotCompleted,
          orderId: a.orderId,
          cardModel: a.cardModel,
        );
      },
    ),
    GoRoute(
      path: '/invoice',
      name: Routes.invoice,
      builder: (_, s) {
        final a = s.extra as InvoiceArgs? ?? const InvoiceArgs();
        return InvoiceUI(
          checkOrderStepModel: a.checkOrderStepModel,
          allBookingData: a.allBookingData,
          carModel: a.carModel,
          invoiceModel: a.invoiceModel,
          isApplePay: a.isApplePay,
          isNotCompletedOrder: a.isNotCompletedOrder,
          totalApplePay: a.totalApplePay,
          orderID: a.orderID,
          hideAddition: a.hideAddition,
          paymentType: a.paymentType,
        );
      },
    ),
    GoRoute(
      path: '/web-payment',
      name: Routes.webPayment,
      builder: (_, s) => WebPayment(url: s.extra as String?),
    ),
    GoRoute(
      path: '/invoice-not-completed',
      name: Routes.invoiceNotCompleted,
      builder: (_, s) {
        final a = s.extra as InvoiceArgs? ?? const InvoiceArgs();
        return InvoiceNotCompletedUI(
          checkOrderStepModel: a.checkOrderStepModel,
          allBookingData: a.allBookingData,
          carModel: a.carModel,
          isApplePay: a.isApplePay,
          isNotCompletedOrder: a.isNotCompletedOrder,
          totalApplePay: a.totalApplePay,
          orderID: a.orderID,
          hideAddition: a.hideAddition,
          paymentType: a.paymentType,
        );
      },
    ),

    // ───── location ─────
    // returns Map<String, dynamic> via Navigator.pop (still works under GoRouter)
    GoRoute(
      path: '/location-picker',
      name: Routes.locationPicker,
      builder: (_, s) {
        final a = s.extra as LocationPickerArgs? ?? const LocationPickerArgs();
        return LocationPickerFull(
          initialLocation: a.initialLocation,
          searchRadius: a.searchRadius,
          bounds: a.bounds,
          centerOverride: a.centerOverride,
        );
      },
    ),
    GoRoute(
      path: '/view-location',
      name: Routes.viewLocation,
      pageBuilder: (_, s) {
        final a = s.extra as ViewLocationArgs;
        return CupertinoPage(
          key: s.pageKey,
          child: ViewLocation(
            url: a.url,
            title: a.title,
            lat: a.lat,
            long: a.long,
          ),
        );
      },
    ),

    // ───── profile / misc ─────
    GoRoute(
      path: '/edit-profile',
      name: Routes.editProfile,
      builder: (_, __) => const EditProfile(),
    ),
    GoRoute(
      path: '/reset-password',
      name: Routes.resetPassword,
      builder: (_, __) => const ResetPasswordScrean(),
    ),
    GoRoute(
      path: '/branches',
      name: Routes.branches,
      pageBuilder: (_, s) => CupertinoPage(
        key: s.pageKey,
        child: BranchesScreen.entry(),
      ),
    ),
    GoRoute(
      path: '/cashback',
      name: Routes.cashback,
      builder: (_, __) => const CashbackScreen(),
    ),
    GoRoute(
      path: '/complaints',
      name: Routes.complaints,
      builder: (_, __) => const ComplaintScreen(),
    ),
    GoRoute(
      path: '/offers',
      name: Routes.offers,
      builder: (_, s) {
        final fromNotification = (s.extra as bool?) ?? false;
        return OffersScreen(fromNotification: fromNotification);
      },
    ),
    GoRoute(
      path: '/offer-details',
      name: Routes.offerDetails,
      builder: (_, s) => OfferDetailsScreen(offerId: s.extra as int),
    ),
    GoRoute(
      path: '/privacy-policy',
      name: Routes.privacyPolicy,
      builder: (_, __) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: Routes.notifications,
      builder: (_, __) => NotificationsScreen.entry(),
    ),
    GoRoute(
      path: '/select-language',
      name: Routes.selectLanguage,
      builder: (_, s) => SelectLanguage((s.extra as bool?) ?? false),
    ),
  ],
);

// ════════════════════════════════════════════════════════════════════════════
// Route-arg classes for multi-parameter destinations. Kept colocated with the
// router so the shape of `extra:` is discoverable in one place.
// ════════════════════════════════════════════════════════════════════════════

class AuthScreenArgs {
  final Function()? isLogin;
  final OnBoardingCubit? cubit;
  final bool pushAddition;
  const AuthScreenArgs({this.isLogin, this.cubit, this.pushAddition = false});
}

class OtpArgs {
  final String userId;
  final String phone;
  const OtpArgs({required this.userId, required this.phone});
}

class AllCarsArgs {
  final FilterModel? filterModel;
  final bool fromFilter;
  final ProfileModel? model;
  const AllCarsArgs({this.filterModel, this.fromFilter = false, this.model});
}

class CarsInformationArgs {
  final DataCars? datum;
  final FilterModel? filterModel;
  final String? stockStatus;
  const CarsInformationArgs({this.datum, this.filterModel, this.stockStatus});
}

class AdditionsArgs {
  final DataCars? datum;
  final CheckOrderStepModel? checkOrderStepModel;
  final Datum? bookDetails;
  final bool? fromNotCompleted;
  final bool? fromAddAdditions;
  const AdditionsArgs({
    this.datum,
    this.checkOrderStepModel,
    this.bookDetails,
    this.fromNotCompleted,
    this.fromAddAdditions,
  });
}

class BookDetailsArgs {
  final Datum bookingData;
  final DataCars? dataCars;
  final DataCars? checkOrderStepModel;
  final bool? isNotCompleted;
  const BookDetailsArgs({
    required this.bookingData,
    this.dataCars,
    this.checkOrderStepModel,
    this.isNotCompleted,
  });
}

class BookingConfirmedArgs {
  final String? orderId;
  final String? carName;
  final String? total;
  const BookingConfirmedArgs({this.orderId, this.carName, this.total});
}

class PaymentMethodsArgs {
  final bool newBooking;
  final StepOneOrderModel? stepOneOrderModel;
  final DataCars? carModel;
  final bool isAutomated;
  final DataCars? datum;
  final bool? isNotCompleted;
  final String? orderId;
  final CreditCardModel? cardModel;
  const PaymentMethodsArgs({
    required this.newBooking,
    required this.stepOneOrderModel,
    required this.carModel,
    this.isAutomated = false,
    this.datum,
    this.isNotCompleted,
    this.orderId,
    this.cardModel,
  });
}

class InvoiceArgs {
  final DataCars? carModel;
  final InvoiceModel? invoiceModel;
  final bool? isApplePay;
  final bool? isNotCompletedOrder;
  final bool? hideAddition;
  final Datum? allBookingData;
  final String? totalApplePay;
  final String? orderID;
  final PaymentMethod? paymentType;
  final CheckOrderStepModel? checkOrderStepModel;
  const InvoiceArgs({
    this.carModel,
    this.invoiceModel,
    this.isApplePay,
    this.isNotCompletedOrder,
    this.hideAddition,
    this.allBookingData,
    this.totalApplePay,
    this.orderID,
    this.paymentType,
    this.checkOrderStepModel,
  });
}

class LocationPickerArgs {
  final LatLng? initialLocation;
  final double? searchRadius;
  final LocationBounds? bounds;
  final LatLng? centerOverride;
  const LocationPickerArgs({
    this.initialLocation,
    this.searchRadius,
    this.bounds,
    this.centerOverride,
  });
}

class ViewLocationArgs {
  final String? url;
  final String title;
  final String? lat;
  final String? long;
  const ViewLocationArgs({
    required this.url,
    required this.title,
    this.lat,
    this.long,
  });
}
