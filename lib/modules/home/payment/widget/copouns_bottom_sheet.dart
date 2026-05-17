import 'package:darbak/modules/home/payment/data/models/all_coupons_model.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/constants/assets/assets.dart';
import '../../../../core/style/style.dart';
import '../../../../language/locale.dart';
import '../../../widgets/components/ad_gradient_btn.dart';
import '../../blocs/booking_cubit/booking_cubit.dart';

class CouponBottomSheet extends StatelessWidget {
  final List<AllCouponsModel> coupons;

  const CouponBottomSheet({Key? key, required this.coupons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    final isRTL = locale.isDirectionRTL(context);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.r),
        topRight: Radius.circular(25.r),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: backgroundColor(context),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.r),
            topRight: Radius.circular(25.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Header(isRTL: isRTL, onBack: () => Navigator.pop(context)),
            SizedBox(height: 15.h),
            if (coupons.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text(
                  isRTL ? "لا توجد كوبونات متاحة" : "No coupons available",
                  style: AppTypography.paragraphColor14(context),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                itemCount: coupons.length,
                separatorBuilder: (_, __) => SizedBox(height: 15.h),
                itemBuilder: (context, index) {
                  return _CouponCard(coupon: coupons[index], isRTL: isRTL);
                },
              ),
          ],
        ),
      ),
    );
  }
}
class _Header extends StatelessWidget {
  final bool isRTL;
  final VoidCallback onBack;

  const _Header({required this.isRTL, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
      decoration: BoxDecoration(
        color: buttonWhiteColor(context),
        border: Border(
          bottom: BorderSide(width: 1.w, color: strokeGrayColor(context)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRTL ? "الكوبونات المتاحة" : "Available Coupons",
                textAlign: TextAlign.right,
                style: AppTypography.mainTypographyColor18(context),
              ),
              SizedBox(height: 4.h),
              Text(
                isRTL ? "اختر الكوبون الأنسب لرحلتك" : "Choose the best coupon for your trip",
                textAlign: TextAlign.right,
                style: AppTypography.paragraphColor16(context),
              ),
            ],
          ),

          Bounce(
            onTap: onBack,
            child: Row(
              children: [ Text(
                isRTL ? "رجــوع" : "Back",
                style: AppTypography.mainTypographyColor20(context),
              ),
                SizedBox(width: 4.w),
                Icon(
                  isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  size: 19.sp,
                  color: mainTypographyColor(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final AllCouponsModel coupon;
  final bool isRTL;

  const _CouponCard({required this.coupon, required this.isRTL});

  String get _badgeLabel => coupon.discountType.toLowerCase() == "percentage"
      ? "خصم فوري"
      : "رصيد";

  String get _badgeLabelEn => coupon.discountType.toLowerCase() == "percentage"
      ? "Instant Discount"
      : "Balance";

  String get _discountText =>
      coupon.discountType.toLowerCase() == "percentage"
          ? "%${coupon.discountValue}"
          : "${coupon.discountValue}";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: buttonWhiteColor(context),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.5.w, color: strokeGrayColor(context)),
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _RightContent(coupon: coupon, isRTL: isRTL),

            _LeftBadge(
              discountText: _discountText,
              badgeLabel: isRTL ? _badgeLabel : _badgeLabelEn,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeftBadge extends StatelessWidget {
  final String discountText;
  final String badgeLabel;

  const _LeftBadge({required this.discountText, required this.badgeLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      decoration: BoxDecoration(
        color: buttonPrimaryBG_Light.withValues(alpha: .1),

      ),
      child:  Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              discountText,
              style: AppTypography.mainTypographyColor24(context),
            ),
            SizedBox(height: 4.h),
            Text(
              badgeLabel,
              textAlign: TextAlign.center,
              style: AppTypography.mainTypographyColor12(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _RightContent extends StatelessWidget {
  final AllCouponsModel coupon;
  final bool isRTL;

  const _RightContent({required this.coupon, required this.isRTL});

  Widget _descriptionWidget(BuildContext context) {
    final isPercentage = coupon.discountType.toLowerCase() == 'percentage';

    return SizedBox(
      width: 240.w,
      child: Text.rich(
        TextSpan(
          children: isRTL
              ? [
            const TextSpan(text: 'خصم '),
            TextSpan(
              text:
              '${coupon.discountValue}${isPercentage ? '٪' : ''} ',
            ),
            if (!isPercentage)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: SvgPicture.asset(
                    Assets.icon_riyal,
                    height: 12.h,
                    width: 10.w,
                    color: mainTypographyColor(context),
                  ),
                ),
              ),
            const TextSpan(text: 'على جميع السيارات'),
          ]
              : [
            TextSpan(
              text:
              '${coupon.discountValue}${isPercentage ? '%' : ''} ',
            ),
            if (!isPercentage)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: SvgPicture.asset(
                    Assets.icon_riyal,
                    height: 12.h,
                    width: 10.w,
                    color: mainTypographyColor(context),
                  ),
                ),
              ),
            const TextSpan(text: ' off on all cars'),
          ],
        ),
        textAlign: TextAlign.center,
        style: AppTypography.mainTypographyColor14(context).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding:  EdgeInsets.all(8.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 30.h,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: ShapeDecoration(
                    color: buttonWhiteColor(context),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1.w, color: strokeGrayColor(context)),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        Assets.icon_coupon,
                        height: 12.h,
                        width: 12.w,color: strokeMainColor(context),
                      ),
                      SizedBox(width:3.w),
                      Text(
                        coupon.name,
                        style: AppTypography.paragraphColor12(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Align(
              child: _descriptionWidget(context),
            ),
            SizedBox(height: 8.h),
            Bounce(
              onTap: () {
                context.read<BookingCubit>().applyCoupon(coupon.name);
                Fluttertoast.showToast(
                  msg: isRTL ? "تم تطبيق الكوبون!" : "Coupon applied!",
                  backgroundColor: buttonGreenColor(context),
                  textColor: Colors.white,
                    fontSize:16.w
                );
                Navigator.pop(context);
              },
              child: ADGradientButton(
                isRTL ? "تطبيق الكوبون" : "Apply Coupon",
              ),
            ),
          ],
        ),
      ),
    );
  }
}