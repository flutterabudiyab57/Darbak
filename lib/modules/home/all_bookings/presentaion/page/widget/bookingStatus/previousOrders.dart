import 'package:bounce/bounce.dart';
import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:widget_zoom/widget_zoom.dart';
import '../../../../../../../core/constants/assets/assets.dart';
import '../../../../../../../language/locale.dart';
import '../../../../../../../shared/commponents.dart';
import '../../../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../../search_screen/presentaion/widget/shimmer_list.dart';
import '../../../bloc/allbooking_cubit.dart';
import '../../../bloc/allbooking_state.dart';
import '../../bookDetailes.dart';

class PreviousOrders extends StatefulWidget {
  const PreviousOrders({super.key});

  @override
  State<PreviousOrders> createState() => _PreviousOrdersState();
}

class _PreviousOrdersState extends State<PreviousOrders> {
  @override
  void initState() {
    BlocProvider.of<AllBookingCubit>(context).getAllBooking(state: 'ended');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var locale = AppLocalizations.of(context)!;
    return BlocConsumer<AllBookingCubit, AllBookingState>(
      listener: (context, state) {
        if (state is AllBookingError) {
          print("Previous order booking:${state.error}");
        }

        if (state is CancelError) {
          Fluttertoast.showToast(
            msg: locale.isDirectionRTL(context)
                ? "حدث خطأ فى الغاء الحجز."
                : "There was an error canceling the booking.",
            backgroundColor: Color(0xffF6A9A9),
            textColor: Color(0xffD62E2E),
            toastLength: Toast.LENGTH_SHORT,
          );

          print("Cancel booking error: " + state.error);
        }

        if (state is CancelSuccess) {
          BlocProvider.of<AllBookingCubit>(context)
              .getAllBooking(state: 'ended');
          Fluttertoast.showToast(
            msg: locale.isDirectionRTL(context)
                ? 'تم الغاء الطلب بنجاح'
                : 'Order has been cancelled Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Color(0xffDCEFE3),
            textColor: Color(0xff327B5B),
          );
        }

        if (state is DeleteOrderError) {
          Fluttertoast.showToast(
            msg: locale.isDirectionRTL(context)
                ? "حدث خطأ فى حذف الحجز."
                : "There was an error deleting the booking.",
            backgroundColor: Color(0xffF6A9A9),
            textColor: Color(0xffD62E2E),
            toastLength: Toast.LENGTH_SHORT,
          );

          print("Deleting booking error: " + state.error);
        }

        if (state is DeleteOrderSuccess) {
          BlocProvider.of<AllBookingCubit>(context)
              .getAllBooking(state: 'ended');
          Fluttertoast.showToast(
            msg: locale.isDirectionRTL(context)
                ? 'تم حذف الطلب بنجاح'
                : 'Order has been Deleted Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Color(0xffDCEFE3),
            textColor: Color(0xff327B5B),
          );
        }
      },
      builder: (context, state) {
        if (state is AllBookingLoading) {
          return Center(
            child: ShimmerLoadingList(height:258,
            ),
          );
        } else if (BlocProvider.of<AllBookingCubit>(context).booking != null &&
            BlocProvider.of<AllBookingCubit>(context).filteredBookings !=
                null &&
            state is AllBookingLoaded) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: ListView.builder(
              itemCount: BlocProvider.of<AllBookingCubit>(context)
                  .filteredBookings
                  .length,
              itemBuilder: (BuildContext context, int index) {
                var bookingData = BlocProvider.of<AllBookingCubit>(context)
                    .filteredBookings[index];
                var carData = bookingData.car;

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Bounce(
                    onTap: () {
                      navigateTo(context, BookDetails(bookingData: bookingData));
                    },
                    child: Container(
                      width: size.width,
                      decoration: ShapeDecoration(
                        color: backgroundColor(context),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1.5.w,
                            color: strokeGrayColor(context),
                          ),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(6.w),
                            decoration: ShapeDecoration(
                              color: buttonWhiteColor(context),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Center(
                              child: WidgetZoom(
                                heroAnimationTag: 'hero-${bookingData.id}',
                                zoomWidget: Image.network(
                                  carData.photo,
                                  height: 126.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 7.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 7.w),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    textDirection:
                                    locale.isDirectionRTL(context) ? TextDirection.rtl : TextDirection.ltr,
                                    children: [
                                      Text(
                                        locale.carName.toString(),
                                        style: AppTypography.paragraphColor12(context),
                                      ),
                                      Text(
                                        carData.name.toString(),
                                        style: AppTypography.headingColor14(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.w,
                                        color: strokeGrayColor(context),
                                      ),
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16.w,
                                        height: 16.h,
                                        child: Image.asset(
                                          "assets/images/ftes.png",
                                          color: mainTypographyColor(context),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        carData.transmission.toString(),
                                        style: AppTypography.paragraphColor12(context),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Container(
                                  height: 24.h,
                                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.w,
                                        color: strokeGrayColor(context),
                                      ),
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16.w,
                                        height: 16.h,
                                        child: Image.asset(
                                          "assets/images/seat.png",
                                          color: mainTypographyColor(context),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        carData.luggage.toString(),
                                        style: AppTypography.paragraphColor14(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 8.h),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 7.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Padding(
                                   padding:   EdgeInsets.symmetric(horizontal:  8.w),
                                   child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          textDirection: locale.isDirectionRTL(context)
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                          children: [
                                            Text(
                                              locale.bookingnumber.toString(),
                                              style: AppTypography.paragraphColor12(context),
                                            ),
                                            Flexible(
                                              child: Text(
                                                bookingData.id.toString(),
                                                style: AppTypography.mainTypographyColor14(context),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              locale.isDirectionRTL(context)
                                                  ? 'تكلفة الحجز : '
                                                  : 'Booking Cost : ',
                                              style: AppTypography.paragraphColor12(context),
                                            ),
                                            Text(
                                              bookingData.price.truncate().toString(),
                                              style: AppTypography.mainTypographyColor14(context),
                                            ),
                                            SvgPicture.asset(
                                              Assets.icon_riyal,
                                              height: 15.h,
                                              width: 14.w,
                                              color: paragraphColor(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                                                   ),
                                 ),

                                SizedBox(height: 6.h),

                                 Center(
                                   child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    textDirection: locale.isDirectionRTL(context)
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    children: [
                                      Text(
                                        locale.isDirectionRTL(context)
                                            ? 'تاريخ الحجز : '
                                            : 'Booking Date : ',
                                        style: AppTypography.paragraphColor12(context),
                                      ),
                                      Flexible(
                                        child: Text(
                                          bookingData.createdAt.toString(),
                                          style: AppTypography.mainTypographyColor12(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                                                   ),
                                 ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: ADGradientButton(
                              locale.moredetails.toString(),
                            ),
                          ),

                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            color: backgroundColor(context),
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/emptystate.png", width: 220.w),
                SizedBox(height: 16.h),
                Text(
                  locale.noCarsBooking1.toString(),
                  style: TextStyle(
                    color: mainTypographyColor(context),
                    fontSize: 20.sp,
                    fontFamily: 'IBMPlexSansArabic',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}