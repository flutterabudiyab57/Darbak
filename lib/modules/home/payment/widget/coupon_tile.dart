import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/constants/assets/assets.dart';
import '../../../../core/style/style.dart';
import '../../../../language/locale.dart';
import '../../../home/blocs/booking_cubit/booking_cubit.dart';
import '../../../widgets/components/ad_gradient_btn.dart';
import '../../../widgets/components/ad_prim_text_form/ad_prim_text_form.dart';

class CouponTile extends StatefulWidget {
  const CouponTile({Key? key}) : super(key: key);

  @override
  _CouponTileState createState() => _CouponTileState();
}

class _CouponTileState extends State<CouponTile> {
  final TextEditingController controller = TextEditingController();
  String? couponMessage;
  bool couponApplied = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final isRTL = locale!.isDirectionRTL(context);

    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is CouponInvalid) {
          setState(() {
            couponMessage = isRTL ? "كوبون غير صالح" : "Invalid Coupon";
            couponApplied = false;
          });
        } else if (state is CouponValid) {
          final cubitCode = context.read<BookingCubit>().couponCode;
          if (controller.text.isEmpty && cubitCode.isNotEmpty) {
            controller.text = cubitCode;
          }
          setState(() {
            couponMessage = isRTL ? 'تم تطبيق الخصم' : 'Discount Applied';
            couponApplied = true;
            FocusManager.instance.primaryFocus?.unfocus();

          });
        } else if (state is DeleteCoupon) {
          setState(() {
            couponMessage = isRTL ? 'تم حذف الكوبون' : 'Coupon Removed';
            couponApplied = false;
            controller.clear();
          });
          clearMessageAfterDelay();
        }
      },
      builder: (context, state) {
        final isLoading = state is CouponLoading;

        return Container(
          decoration: BoxDecoration(
            color: buttonWhiteColor(context),
            borderRadius: BorderRadius.circular(15.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Stack(
                      alignment: isRTL
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      children: [
                        ADPrimTextForm(
                          controller: controller,
                          type: TextInputType.text,
                          label: locale.addCoupon.toString(),
                          pAssetIcon: Assets.icon_coupon,
                        ),
                        if (couponApplied)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: buttonGreenColor(context),
                              size: 22.sp,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(width: 10.w),

                  if (couponApplied)

        Expanded(
                      flex: 3,
                      child: Bounce(
                        onTap: isLoading
                            ? null
                            : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          deleteCouponTrigger();
                        },
                        child: ADGradientButton(

                          locale.cancel.toString(),
                          height: 50.h,
                          backgroundColor: buttonRedColor(context),
                          textColor: buttonWhiteColor(context),
                          textStyle: AppTypography.buttonRed14(context),
                          iconColor: buttonRedColor(context),
                          border: Border.all(
                            color: buttonRedColor(context).withOpacity(.5),
                            width: 1.5.w,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      flex: 3,
                      child: Bounce(
                        onTap: isLoading
                            ? null
                            : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (controller.text.isNotEmpty) {
                            couponTrigger();
                          }
                        },
                        child: ADGradientButton(
                          isLoading
                              ? (isRTL ? "جاري." : "Loading.")
                              : locale.apply,
                          backgroundColor: isLoading
                              ? buttonSecondaryColor(context)
                              : (controller.text.isNotEmpty
                              ? mainTypographyColor(context)
                              : buttonSecondaryColor(context)),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 10.h),

              if (couponMessage != null)
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        couponApplied
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                        size: 18.sp,
                        color: couponApplied
                            ? buttonGreenColor(context)
                            : buttonRedColor(context),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        couponMessage!,
                        style: couponApplied
                            ? AppTypography.buttonGreen16(context)
                            : AppTypography.buttonRed16(context),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> couponTrigger() async {
    if (controller.text.trim().isNotEmpty) {
      BlocProvider.of<BookingCubit>(context).couponCode = controller.text;
      await BlocProvider.of<BookingCubit>(context).checkCouponCode();
    } else {
      BlocProvider.of<BookingCubit>(context).couponCode = "";
    }
  }

  Future<void> deleteCouponTrigger() async {
    final cubit = BlocProvider.of<BookingCubit>(context);
    if (cubit.couponCode.isNotEmpty || controller.text.isNotEmpty) {
      cubit.couponCode =
      cubit.couponCode.isNotEmpty ? cubit.couponCode : controller.text;
      await cubit.deleteCouponCode();
    }
  }

  void clearMessageAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => couponMessage = null);
    });
  }
}