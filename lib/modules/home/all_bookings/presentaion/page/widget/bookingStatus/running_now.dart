import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/modules/home/all_bookings/presentaion/bloc/allbooking_state.dart';
import 'package:darbak/modules/home/all_bookings/presentaion/page/widget/texttile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../../../../language/locale.dart';
import '../../../../../../../shared/commponents.dart';
import '../../../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../../search_screen/presentaion/widget/shimmer_list.dart';
import '../../../bloc/allbooking_cubit.dart';
import '../../bookDetailes.dart';

class RunningNow extends StatefulWidget {
  const RunningNow({super.key});

  @override
  State<RunningNow> createState() => _RunningNowState();
}

class _RunningNowState extends State<RunningNow> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AllBookingCubit>(context).getAllBooking(state: 'running');
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    Widget cancelBottomSheet(BuildContext context, booking) {
      final locale = AppLocalizations.of(context)!;

      return Container(
        decoration: BoxDecoration(
          color: backgroundColor(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5.h,
              width: 48.w,
              decoration: BoxDecoration(
                color: strokeGrayColor(context),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            SizedBox(height: 24.h),

            Text(
              locale.wantToCancel.toString(),
              textAlign: TextAlign.center,
              style: AppTypography.headingColor20(context)
            ),

            SizedBox(height: 28.h),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: ADGradientButton(
                      locale.goBack,
                      backgroundColor: Colors.transparent,
                      border: Border.all(
                        color: strokeGrayColor(context),
                        width: 2.w,
                      ),
                        textColor:  paragraphColor(context)
                      ),
                    ),
                  ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      BlocProvider.of<AllBookingCubit>(context)
                          .cancelBooking(orderId: booking.id);
                    },
                    child: ADGradientButton(
                      locale.isDirectionRTL(context) ? "إلغاء الحجز" : "Cancel",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return BlocConsumer<AllBookingCubit, AllBookingState>(
      listener: (context, state) {
        if (state is CancelError) {
          Fluttertoast.showToast(
            msg: locale.isDirectionRTL(context)
                ? "حدث خطأ فى الغاء الحجز."
                : "There was an error canceling the booking.",
            backgroundColor: const Color(0xffF6A9A9),
            textColor: const Color(0xffD62E2E),
          );
        }

        if (state is CancelSuccess) {
          BlocProvider.of<AllBookingCubit>(context).getAllBooking(state: 'running');
          Fluttertoast.showToast(
            msg: locale.isDirectionRTL(context)
                ? 'تم الغاء الطلب بنجاح'
                : 'Order has been cancelled Successfully',
            backgroundColor: const Color(0xffDCEFE3),
            textColor: const Color(0xff327B5B),
          );
        }
      },
      builder: (context, state) {
        if (state is AllBookingLoading) {
          return ShimmerLoadingList();
        }

        if (state is AllBookingLoaded) {
          final bookingData =
          BlocProvider.of<AllBookingCubit>(context).booking!.data!;

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: bookingData.length,
            itemBuilder: (context, index) {
              final booking = bookingData[index]!;
              return Padding(
                padding: EdgeInsets.all(12.w),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: strokeGrayColor(context),
                      width: 2.w,
                    ),
                    color: backgroundColor(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                booking.createdAt.toString(),
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: booking.status == 'pending'
                                    ? const Color(0XFF8304B0)
                                    : booking.status == 'notcompleted'
                                    ? const Color(0XFFDD5406)
                                    : const Color(0XFF4B48D4),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                booking.statusText.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10.h),

                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextTileWidget(
                                    contant: booking.id.toString(),
                                    title: locale.bookingnumber.toString(),
                                    size: 22.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  TextTileWidget(
                                    contant: booking.car.name.toString(),
                                    title: "${locale.carName} :",
                                    size: 22.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  TextTileWidget(
                                    contant:
                                    "${booking.price} ${locale.sar}",
                                    title: locale.isDirectionRTL(context)
                                        ? "تكلفة الحجز: "
                                        : "Total amount: ",
                                    size: 22.sp,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 10.w),

                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: backgroundColor(context),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.network(
                                    booking.car.photo,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 6.h),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  navigateTo(
                                    context,
                                    BookDetails(bookingData: booking),
                                  );
                                },
                                child:ADGradientButton(
                                  locale.bookingDetails
                                      .toString(),
                                  backgroundColor: buttonPrimaryBgColor(context),
                                  textStyle: AppTypography.mainTypographyColor18(context).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 12.w),

                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    constraints: const BoxConstraints(maxWidth: double.infinity,),
                                    builder: (_) =>
                                        cancelBottomSheet(context, booking),
                                  );
                                },
                                child: ADGradientButton(
                                  locale.cancel.toString(),
                                  backgroundColor: Colors.transparent,
                                  border: Border.all(
                                    width: 2.w,
                                    color: strokeMainColor(context),
                                  ),
                                   textColor:strokeMainColor(context)
                                ),

                              ),
                            ),
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

        // Empty State
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/emptystate.png", width: 220.w),
            SizedBox(height: 6.h),
            Text(
              locale.noCarsBooking1.toString(),
              style: AppTypography.mainTypographyColor20(context),
            ),
          ],
        );
      },
    );
  }
}
