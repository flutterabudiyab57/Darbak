import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import 'package:darbak/modules/home/additions/presentaion/widgets/services.dart';
import 'package:darbak/modules/home/additions/presentaion/widgets/services_notCompleted.dart';
import 'package:darbak/modules/home/all_bookings/presentaion/bloc/allbooking_cubit.dart';
import 'package:darbak/modules/home/blocs/booking_cubit/booking_cubit.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/helpers/SharedPreference/pereferences.dart';
import '../../../../../core/helpers/helper_fun.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import 'package:darbak/modules/home/all_bookings/data/model/booking_model.dart';
import '../../../../widgets/components/appbar.dart';
import '../../../all_bookings/data/model/check_order_step_model.dart';
import '../../../cash_back/bloc/cashback__cubit.dart';
import '../../../cash_back/repository/applycashback.dart';
import '../../../cash_back/repository/cashback_balance.dart';
import '../../../payment/paymentMethods.dart';
import '../../../search_screen/presentaion/widget/shimmer_list.dart';

// ignore: must_be_immutable
class AdditionsScreen extends StatefulWidget {
  final DataCars? datum;
  final CheckOrderStepModel? checkOrderStepModel;
  Datum? bookDetails;
  bool? fromNotCompleted;
  bool? fromAddAdditions;

  AdditionsScreen(
      {this.datum,
      this.checkOrderStepModel,
      this.fromNotCompleted,
      this.fromAddAdditions,
      this.bookDetails});

  @override
  _AdditionsScreenState createState() => _AdditionsScreenState();
}

class _AdditionsScreenState extends State<AdditionsScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  //var _scrollController, _tabController;
  @override
  void initState() {
    // _scrollController = ScrollController();
    // _tabController = TabController(length: 2, vsync: this);
    // BlocProvider.of<AdditionsCubit>(context).getCarFeatures(context, widget.datum!.id.toString());
    if (widget.fromNotCompleted == true) {
      widget.fromAddAdditions == true ? checkOrderStep() : false;
    } else {
      // BlocProvider.of<AdditionsCubit>(context).getCarFeatures(context, widget.datum!.id.toString());
    }

    super.initState();
  }

  checkOrderStep() async {
    await BlocProvider.of<AdditionsCubit>(context).checkOrderStep(
        orderId: BlocProvider.of<AdditionsCubit>(context)
            .stepModel!
            .order!
            .id
            .toString());
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    return BlocConsumer<AdditionsCubit, AdditionsState>(
      listener: (context, state) {
        if (state is CheckOrderStateLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const LoadingIndicator();
            },
          );
        }
        if (state is AdditionsFailed) {
          HelperFunctions.showFlashBar(
            context: context,
            title: state.error.contains("not Authanticated")
                ? locale!.loginToContinue.toString()
                : state.error.toString().replaceAll(
                    "message: Error During Communication. -> Details: Exception:",
                    ''),
            message: '',
            icon: Icons.info,
            iconColor: Colors.red,
          );

          print("AdditionsFailed111");
        }
        if (state is AdditionsFailed) {
          HelperFunctions.showFlashBar(
            context: context,
            title: state.error.contains("Error Please LOGIN To Continue")
                ? locale!.loginToContinue.toString()
                : state.error.toString().replaceAll(
                    "message: Error During Communication. -> Details: Exception:",
                    ''),
            message: '',
            icon: Icons.info,
            iconColor: Colors.red,
          );

          print("AdditionsFailed");
        }
      },
      builder: (context, state) {
        return Scaffold(
            backgroundColor: backgroundColor(context),
            appBar: CustomAppBar(
              title: locale!.checkOut.toString(),
              showBackButton: true,
              // showThemeToggle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  state is AdditionsFailed
                      ? Container(
                          padding: EdgeInsets.all(10.sp),
                          margin: EdgeInsets.all(8.sp),
                          decoration: BoxDecoration(
                              color: buttonWhiteColor(context)),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: size.height / 7,
                                ),
                                Image.asset(Assets.img_empty),
                                SizedBox(height: 20.sp),
                                Text(
                                  locale.bookingNotAvailable,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                SizedBox(height: 20.sp),
                                GestureDetector(
                                  onTap: () async {
                                    print('BTN_TAP_FIRED');   // <-- ضيف السطر ده بس
                                    BlocProvider.of<BookingCubit>(context)
                                        .reset();
                                    await BlocProvider.of<AllBookingCubit>(
                                        context)
                                        .getAllBooking(state: 'running');

                                    context.go('/shell?tab=2');
                                  },
                                  child: ADGradientButton(
                                    locale.goToBookings,
                                    textColor: buttonTextColor(context),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      : state is AdditionsLoading
                          ? Center(
                              child:ShimmerLoadingList(),
                            )
                          : Column(
                              children: [
                                widget.fromNotCompleted == true
                                    ? ServicesNotCompeted(
                                        checkOrderStepModel:
                                            BlocProvider.of<AdditionsCubit>(
                                                    context)
                                                .stepModel,
                                        featuresNotCompleted:
                                            BlocProvider.of<AdditionsCubit>(
                                                    context)
                                                .features2,
                                      )
                                    : Services(
                                        datum: widget.datum,
                                        features: state is AdditionsSuccess
                                            ? state.features
                                            : []),
                                SizedBox(
                                  height: 12.h,
                                ),
                                Container(
                                  child: widget.fromNotCompleted == true
                                      ? BlocProvider(
                                          create: (context) => CashbackCubit(
                                                CashbackRemoteDataSource(Dio(), SharedPreferencesHelper()),
                                                ApplyCashbackRemoteDataSource(Dio(),SharedPreferencesHelper()),)
                                            ..getCashbackBalance(),
                                          child: PaymentMethodsScreen(
                                            true,
                                            isNotCompleted: true,
                                            carModel: widget.datum,
                                            stepOneOrderModel:
                                                BlocProvider.of<AdditionsCubit>(
                                                        context)
                                                    .stepOneOrderModel,
                                            orderId: widget
                                                .checkOrderStepModel!.order!.id
                                                .toString(),
                                          ))
                                      : BlocProvider(create: (context) => CashbackCubit(
                                            CashbackRemoteDataSource(Dio(), SharedPreferencesHelper()),
                                            ApplyCashbackRemoteDataSource(Dio(), SharedPreferencesHelper()),)
                                            ..getCashbackBalance(),
                                          child: PaymentMethodsScreen(
                                            true,
                                            isNotCompleted: false,
                                            carModel: widget.datum,
                                            stepOneOrderModel:
                                                BlocProvider.of<AdditionsCubit>(
                                                        context)
                                                    .stepOneOrderModel,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                ],
              ),
            ));
      },
    );
  }

  String extractDetails(String inputString) {
    final detailsKeyword = "not Authanticated";
    final startIndex = inputString.indexOf(detailsKeyword);

    if (startIndex != -1) {
      final extractedString = inputString.substring(startIndex);
      return extractedString.trim();
    }

    return '';
  }
}
