import 'package:darbak/modules/home/additions/presentaion/pages/additions_screen.dart';
import 'package:darbak/modules/home/all_bookings/data/model/booking_model.dart';
import 'package:darbak/modules/home/all_bookings/presentaion/bloc/allbooking_state.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:darbak/modules/widgets/components/appbar.dart';
import 'package:darbak/shared/commponents.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/constants/assets/assets.dart';
import '../../../../../core/helpers/helper_fun.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../widgets/Dashed_divider.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../additions/presentaion/blocs/addition_cubit/additions_cubit.dart';

import '../../../cars/presentaion/widget/car_tile.dart';
import '../../../payment/data/models/credit_card_model.dart';
import '../../../payment/invouce_notCompleted.dart';
import '../bloc/allbooking_cubit.dart';

class BookDetails extends StatelessWidget  {
  const BookDetails(
      {Key? key,
      required this.bookingData,
      this.dataCars,
      this.checkOrderStepModel,
      this.isNotCompleted})
      : super(key: key);
  final Datum bookingData;
  final DataCars? dataCars;
  final DataCars? checkOrderStepModel;
  final bool? isNotCompleted;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var locale = AppLocalizations.of(context)!;

    String getPaymentImage(String paymentType) {
      switch (paymentType.toLowerCase()) {
        case 'madfou':
          return 'assets/icons/madfu_ar_logo.svg';
        case 'visa':
          return 'assets/icons/visa.svg';
        case 'cash':
          return 'assets/icons/riyal_cash.svg';
        case 'points':
          return 'assets/icons/points_pay.svg';
        case 'tamara':
          return 'assets/icons/riyal_cash.svg';
        default:
          return 'assets/icons/riyal_cash.svg';
      }
    }

    return BlocConsumer<AllBookingCubit, AllBookingState>(
      listener: (context, state) {
        if (state is CancelError) {
          // HelperFunctions.showFlashBar(
          //     context: context,
          //     title: "locale.error.toString() 1",
          //     message: state.error,
          //     color: Color(0xffF6A9A9),
          //     titlcolor: Color(0xffD62E2E),
          //     icon: Icons.warning_amber,
          //     iconColor: Color(0xffD62E2E));

          print("Cancel Error BookDetails: " + state.error);
        }
        if (state is CheckOrderStateLoading) {
          LoadingIndicator();
        }
        if (state is CancelSuccess) {
          // BlocProvider.of<AllBookingCubit>(context).getAllBooking(state: 'running');
          HelperFunctions.showFlashBar(
              context: context,
              title: '',
              message: locale.orderCancelledSuccessfully,
              icon: Icons.check,
              iconColor: Color(0xff327B5B));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor:backgroundColor(context),
          bottomNavigationBar: bookingData.status == 'confirmed' ||
              bookingData.status == 'pending'
              ? Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.025,
            ),
            child: InkWell(
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  constraints: const BoxConstraints(maxWidth: double.infinity,),
                  builder: (BuildContext context) {
                    return Container(
                      height: size.height * 0.20,
                      color: backgroundColor(context),
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Container(
                            width: 40.w,
                            height: size.height * 0.007,
                            decoration: BoxDecoration(
                                color: strokeGrayColor(context),
                                borderRadius: BorderRadius.circular(20.r)),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Center(
                            child: Text(
                              locale.wantToCancel.toString(),
                              style: AppTypography.headingColor18(context),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: ADGradientButton(
                                  locale.dontCancel,
                                  width: size.width * 0.35,
                                  height: size.height * 0.050,
                                  backgroundColor: backgroundColor(context),
                                  textColor: mainTypographyColor(context),
                                  textStyle: AppTypography.buttonText18(context).copyWith(
                                    color: mainTypographyColor(context),
                                  ),
                                  border: Border.all(
                                    color: strokeMainColor(context),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await BlocProvider.of<AllBookingCubit>(
                                      context)
                                      .cancelBooking(
                                    orderId: bookingData.id,
                                  )
                                      .then((value) =>
                                      Navigator.pop(context));
                                  Navigator.pop(context);
                                },
                                child: ADGradientButton(
                                  locale.cancelOrderAction,
                                  width: size.width * 0.35,
                                  height: size.height * 0.050,
                                  backgroundColor: buttonRedColor(context),
                                  textColor: Colors.white,
                                  textStyle: AppTypography.buttonText18(context).copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: size.width * 0.01,horizontal: size.width * 0.05),

                child: state is CancelLoading
                    ? Center(
                    child: LoadingIndicator()
                )
                    : ADGradientButton(
                  locale.cancel.toString(),
                  backgroundColor: backgroundColor(context),
                  textColor: buttonRedColor(context),
                  textStyle: AppTypography.buttonText18(context).copyWith(
                    color: buttonRedColor(context),
                  ),
                  border: Border.all(
                    color: buttonRedColor(context),
                    width: 1.5.w,
                  ),
                ),
              ),
            ),
          )
              : bookingData.status == 'notcompleted'
                  ? Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.00,
                          bottom: MediaQuery.of(context).size.height * 0.09,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            await BlocProvider.of<AdditionsCubit>(context)
                                .checkOrderStep(
                                    orderId: bookingData.id.toString());
                            if (bookingData.step == 2) {
                              BlocProvider.of<AdditionsCubit>(context)
                                          .stepModel !=
                                      null
                                  ? navigateTo(
                                      context,
                                      AdditionsScreen(
                                        datum: bookingData.car,
                                        fromNotCompleted: true,
                                        bookDetails: bookingData,
                                        checkOrderStepModel:
                                            BlocProvider.of<AdditionsCubit>(
                                                    context)
                                                .stepModel,
                                      ))
                                  : null;
                            } else if (bookingData.step == 3) {
                              BlocProvider.of<AdditionsCubit>(context)
                                          .stepModel !=
                                      null
                                  ? PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: InvoiceNotCompletedUI(
                                        carModel: dataCars,
                                        isNotCompletedOrder: true,
                                        orderID: bookingData.id.toString(),
                                        paymentType: PaymentMethod.fromWire(
                                            bookingData.paymentType),
                                        checkOrderStepModel:
                                            BlocProvider.of<AdditionsCubit>(
                                                    context)
                                                .stepModel,
                                      ),
                                      withNavBar: false)
                                  : false;
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.05),
                            child: Card(
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.5)),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Container(
                                height: size.height * 0.053,
                                width: size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Theme.of(context).colorScheme.primary,
                                  border: Border.all(
                                      color: strokeGrayColor(context),
                                      width: 1.3),
                                ),
                                child: Center(
                                    child: state is CancelLoading
                                        ?LoadingIndicator()
                                        : BlocConsumer<AdditionsCubit,
                                            AdditionsState>(
                                            listener: (context, state) {},
                                            builder: (context, state) {
                                              return state
                                                      is CheckOrderStateLoading
                                                  ? LoadingIndicator()

                                              : AutoSizeText(
                                                      locale.continueOrder,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                              color:
                                                                  Colors.white),
                                                    );
                                            },
                                          )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 2.w,
                      height: 2.h,
                    ),
          appBar:CustomAppBar(title: locale.bookingDetails.toString(),
                 showBackButton : true,
                  // showThemeToggle :true
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                spacing: 12.h,
                children: [
                  Container(
                    height: Device.get().isTablet
                        ? MediaQuery.of(context).size.height * 0.09
                        : MediaQuery.of(context).size.height * 0.07,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                AutoSizeText(locale.bookingnumber.toString(),
                                  style: AppTypography.headingColor14(context),
                                ),
                                Text(
                                  bookingData.id.toString(),
                                  style:AppTypography.mainTypographyColor16(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  "${locale.paymentTypeLabel} ",
                                  style: AppTypography.headingColor14(context),
                                ),
                                Text(
                                  bookingData.paymentType.toString(),
                                  style:AppTypography.mainTypographyColor16(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(width: 6.w,),
                        ],
                    ),
                  ),
                  dashedDivider(context),
                  Column(
                    spacing: MediaQuery.of(context).size.height * 0.02,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.carSelected.toString(),
                        style: AppTypography.headingColor16(context)
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: strokeGrayColor(context),
                                width: 1.2.w),
                            borderRadius: BorderRadius.circular(6.r)),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Image.network(
                                bookingData.car.photo.toString(),
                              ),
                            ),
                            Text(
                              bookingData.car.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.mainTypographyColor12(context),
                            ),
                            Spacer(),
                            Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 4.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        bookingData.price.toString(),
                                        style: AppTypography.mainTypographyColor16(context),
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      SvgPicture.asset(
                                        Assets.icon_riyal,
                                        height: 20.h,
                                        width: 20.w,
                                        color: mainTypographyColor(context),
                                      ),
                                    ],
                                  ),
                                  ImageWithText(
                                    imagePath: "assets/images/speedometer.png",
                                    text: "${bookingData.car.kilo} KM /day",
                                    rtlText: "${bookingData.car.kilo} كم/ يوم",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        locale.bookingDetails.toString(),
                          style: AppTypography.headingColor16(context)
                      ),
                      Container(
                        width: double.infinity,
                        padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: strokeGrayColor(context),
                                width: 1.2.w),
                            borderRadius: BorderRadius.circular(6.r)),
                        child:Column(
                        spacing: 8.h,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  locale.bookingDays,
                                  style: AppTypography.mainTypographyColor16(context),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  "${bookingData.diff.toString()} ${locale.daySuffix}",
                                  textAlign: TextAlign.end,
                                  style: AppTypography.mainTypographyColor16(context),
                                ),
                              ),
                            ],
                          ),
                          dashedDivider(context),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: mainTypographyColor(context),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  locale.reservation.toString(),
                                  style: AppTypography.paragraphColor14(context),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 20.sp,
                                color: mainTypographyColor(context),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  bookingData.recivingBranch.name.toString(),
                                  style: AppTypography.mainTypographyColor14(context),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: mainTypographyColor(context),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  locale.delivery.toString(),
                                  style: AppTypography.paragraphColor14(context),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.gps_fixed,
                                size: 18.sp,
                                color: mainTypographyColor(context),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  bookingData.deliveryBranch.name.toString(),
                                  style: AppTypography.mainTypographyColor16(context),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.watch_later_outlined,
                                      size: 16.sp,
                                      color: mainTypographyColor(context),
                                    ),
                                    Expanded(
                                      child: Text(
                                        bookingData.receive_time.toString(),
                                        style: AppTypography.mainTypographyColor14(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer (),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.watch_later_outlined,
                                      size: 16.sp,
                                      color: mainTypographyColor(context),
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        bookingData.deliver_time.toString(),
                                        style: AppTypography.mainTypographyColor14(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: 18.sp,
                                      color: mainTypographyColor(context),
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        bookingData.receive_date.toString(),
                                        style: AppTypography.mainTypographyColor14(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer (),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: 18.sp,
                                      color: mainTypographyColor(context),
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        bookingData.deliver_date.toString(),
                                        style: AppTypography.mainTypographyColor14(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ),
                       Text(
                        locale.paymentDetails,
                          style: AppTypography.headingColor16(context)
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.03),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: strokeGrayColor(context),
                                width: 1.2.w),
                            borderRadius: BorderRadius.circular(6.r)),
                        child: Column(
                          spacing: 8.h,
                          children: [
                            RowRentDetails(
                                title: locale.rent.toString(),
                                resultTitle: bookingData.rent_price.toString()),
                            RowRentDetails(
                                title: locale.additions.toString(),
                                resultTitle: bookingData.additions.toString()),
                            RowRentDetails(
                                title: locale.tam.toString(),
                                resultTitle: bookingData.tamm_price.toString()),
                            RowRentDetails(
                                title: locale.memberDiscount.toString(),
                                resultTitle:
                                bookingData.membership_discount.toString()),
                            RowRentDetails(
                                title: locale.promotionalDiscount.toString(),
                                resultTitle: bookingData.promotional_discount
                                    .toString()),
                            RowRentDetails(
                              title: locale.couponDiscount,
                              resultTitle:
                              bookingData.coupon_discount.toString(),
                            ),
                            RowRentDetails(
                              title: locale.pointsPayment,
                              resultTitle:
                              bookingData.points_discount.toString(),
                            ),
                            RowRentDetails(
                                title: locale.visaDiscount.toString(),
                                resultTitle: bookingData.visaAmout.toString()),
                            RowRentDetails(
                                title: locale.total3.toString(),
                                resultTitle: bookingData.net_price.toString()),
                            RowRentDetails(
                                title: locale.taxValue.toString(),
                                resultTitle: bookingData.vat_value.toString()),
                            RowRentDetails(
                                title: locale.total.toString(),
                                resultTitle:
                                bookingData.price.toString()),
                          ],
                        ),
                      ),
                      bookingData.status != "completed" ||
                          bookingData.status != "pinging"
                          ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                      )
                          : SizedBox(height: 0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RowRentDetails extends StatelessWidget {
  const RowRentDetails({
    Key? key,
    required this.title,
    required this.resultTitle,
    this.titleStyle,
    this.resultStyle,
  }) : super(key: key);

  final String title;
  final String resultTitle;
  final TextStyle? titleStyle;
  final TextStyle? resultStyle;

  @override
  Widget build(BuildContext context) {
    if (resultTitle.isEmpty ||
        resultTitle == 'null' ||
        double.tryParse(resultTitle) == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: titleStyle ?? AppTypography.headingColor16(context),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          resultTitle,
          style: resultStyle ?? AppTypography.mainTypographyColor16(context),
        ),
        SizedBox(width: 5.w),
        SvgPicture.asset(
          Assets.icon_riyal,
          height: 18.h,
          width: 18.w,
          color: mainTypographyColor(context),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }
}
