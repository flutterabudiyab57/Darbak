import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/all_bookings/presentaion/bloc/allbooking_cubit.dart';
import 'package:darbak/modules/home/blocs/booking_cubit/booking_cubit.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constants/assets/assets.dart';

class BookingConfirmedBottomSheet extends StatelessWidget {
  final String? orderId;
  final String? carName;
  final String? total;

  const BookingConfirmedBottomSheet({
    Key? key,
    this.orderId,
    this.carName,
    this.total,
  }) : super(key: key);

  static void show(BuildContext context,
      {String? orderId, String? carName, String? total}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: BookingConfirmedBottomSheet(
            orderId: orderId, carName: carName, total: total),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 27.h),
      decoration: ShapeDecoration(
        color: buttonWhiteColor(context),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.5.w,
            color: strokeMainColor(context).withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(22.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: Text(
              locale.bookingConfirmed.toString(),
              textAlign: TextAlign.center,
              style: AppTypography.mainTypographyColor24(context).copyWith(
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
                height: 1.44.h,
                letterSpacing: -0.10,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
            ),
            margin: EdgeInsets.only(bottom: 30.h),
            child: SvgPicture.asset(
              Assets.icon_Confirm,
              height: 182.h,
              width: 182.w,

            ),
          ),
          SizedBox(
            width: 305.w,
            child: Text(
              locale.bookingSuccessMessage,
              textAlign: TextAlign.center,
              style: AppTypography.headingColor16(context).copyWith(
                fontWeight: FontWeight.w600,
                height: 1.44.h,
                letterSpacing: -0.10,
              ),
            ),
          ),
          SizedBox(height: 23.h),
          Column(
            spacing: 10.h,
            children: [
              GestureDetector(
                onTap: () async {
                  BlocProvider.of<BookingCubit>(context).reset();
                  await BlocProvider.of<AllBookingCubit>(context)
                      .getAllBooking(state: 'running');

                  context.go('/shell?tab=2');
                },
                child: ADGradientButton(
                  locale.goToBookings,
                  // backgroundColor: buttonPrimaryBgColor(context),
                  textColor: buttonTextColor(context),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  BlocProvider.of<BookingCubit>(context).reset();
                  await BlocProvider.of<AllBookingCubit>(context)
                      .getAllBooking(state: 'running');

                  context.go('/shell?tab=0');
                },
                child: ADGradientButton(
                  locale.goToHome,
                  backgroundColor: buttonWhiteColor(context),
                  border: Border.all(
                    width: 2.w,
                    color: strokeGrayColor(context),
                  ),
                  textStyle:
                      AppTypography.mainTypographyColor18(context).copyWith(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
