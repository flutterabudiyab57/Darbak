// Route-arg classes for multi-parameter destinations. Imported by call sites
// (`context.pushNamed(Routes.x, extra: XxxArgs(...))`) AND by app_router.dart.
// Kept separate from app_router so feature files don't transitively depend on
// every screen import in the router.

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/Maps/map_select_location.dart' show LocationBounds;
import '../../modules/auth/blocs/auth_bloc/onboarding_cubt_cubit.dart';
import '../../modules/home/additions/data/models/step_one_order_model.dart'
    hide Icon, Photo;
import '../../modules/home/all_bookings/data/model/booking_model.dart';
import '../../modules/home/all_bookings/data/model/check_order_step_model.dart';
import '../../modules/home/cars/data/models/cars_model.dart';
import '../../modules/home/payment/data/models/credit_card_model.dart';
import '../../modules/home/payment/data/models/invoice_model.dart' hide Icon;
import '../../modules/home/profile/data/models/profile_model.dart';
import '../../modules/home/search_screen/data/models/filter_model.dart';

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
