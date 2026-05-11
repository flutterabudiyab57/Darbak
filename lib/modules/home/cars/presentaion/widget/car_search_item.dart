import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/constants/assets/assets.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../search_screen/data/models/filter_model.dart';
import '../../data/models/cars_model.dart';
import '../page/cars_info.dart';
import 'car_icon_info.dart';

class CarSearchItem extends StatelessWidget {
  final DataCars car;
  final FilterModel? filterModel;
  final VoidCallback? onTap;

  const CarSearchItem({
    Key? key,
    required this.car,
    this.filterModel,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final isRTL = locale.isDirectionRTL(context);

    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 125.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: buttonWhiteColor(context),
              border: Border.all(color: strokeGrayColor(context), width: 1.5.w),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Center(
                      child: Image.network(
                        car.photo,
                        width: 159.w,
                        height: 117.h,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (_, __, ___) => Container(
                          width: 159.w,
                          height: 117.h,
                          color: strokeGrayColor(context),
                          child: Icon(Icons.directions_car,
                              color: iconGrayColor(context)),
                        ),
                      ),
                    ),
                    // if (car.availableBranches.isEmpty)
                    //   Positioned(
                    //     top: 0,
                    //     left: 0,
                    //     child: Container(
                    //       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    //       decoration: BoxDecoration(
                    //         color: buttonRedColor(context),
                    //         borderRadius: BorderRadius.only(
                    //           bottomRight: Radius.circular(10.r),
                    //         ),
                    //       ),
                    //       child: Text(
                    //         isRTL ? 'نفذت الكميه' : 'Out of Stock',
                    //         style: AppTypography.buttonText14(context)
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(vertical:12.h),
                  child: SizedBox(
                    child: verticalDashedDivider(context),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(car.name,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.mainTypographyColor15(context)),
                        Row(
                          children: [
                            Text('${car.priceAfter}',
                                style: AppTypography.paragraphColor14(context)),
                            SizedBox(width: 3.w),
                            SvgPicture.asset(
                              Assets.icon_riyal,
                              height: 14.h,
                              width: 14.w,
                              color: paragraphColor(context),
                            ),
                            Text(
                              isRTL ? '/يوم' : '/day',
                              style: AppTypography.mainTypographyColor14(context)
                                  .copyWith(
                                letterSpacing: -0.20,
                              ),
                            ),
                             SizedBox(width: 10.w),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${car.priceBefore}',
                                      style: AppTypography.mainTypographyColor14(context),
                                    ),
                                    SizedBox(width: 6.w),
                                    SvgPicture.asset(
                                      Assets.icon_riyal,
                                      height: 14.h,
                                      width: 14.w,
                                      color: mainTypographyColor(context),
                                    ),
                                    Text(isRTL ? '/يوم' : '/day',
                                        style: AppTypography.mainTypographyColor14(context)),
                                  ],
                                ),
                                Positioned.fill(
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: -0.12,
                                      child: Container(
                                        height: 2.h,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 4.w),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF0004),
                                          borderRadius: BorderRadius.circular(2.r),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: isRTL,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: strokeGrayColor(context),
                                    width: 1.5.w,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 3.h,horizontal: 2.w),
                                child: ImageWithText(
                                  imagePath: "assets/images/ftes.png",
                                  text: "${car.transmission}",
                                  rtlText: "${car.transmission}",
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: strokeGrayColor(context),
                                    width: 1.5.w,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 3.h,horizontal: 2.w),
                                child: ImageWithText(
                                  imagePath: "assets/images/seat.png",
                                  text: "${car.luggage} ",
                                  rtlText: "${car.luggage} ",
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: strokeGrayColor(context),
                                    width: 1.5.w,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 3.h,horizontal: 2.w),
                                child: ImageWithText(
                                  imagePath: "assets/images/car_seat.png",
                                  text: "${car.doors} ",
                                  rtlText: "${car.doors} ",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h,)
        ],
      ),
    );
  }
}

class ImageWithText extends StatelessWidget {
  final String imagePath;
  final String text;
  final String rtlText;

  const ImageWithText({
    Key? key,
    required this.imagePath,
    required this.text,
    required this.rtlText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    bool isRTL = locale!.isDirectionRTL(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.h),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            color: iconDefaultColor(context),
            width: 18.w,
            height: 18.h,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 2.w),
          Text(
            isRTL ? rtlText : text,
            style: AppTypography.paragraphColor12(context),
          ),
        ],
      ),
    );
  }
}
Widget verticalDashedDivider(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final dashHeight = 6.h;
      final dashSpace = 4.h;
      final dashCount =
      (constraints.maxHeight / (dashHeight + dashSpace)).floor();

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          dashCount,
              (_) => SizedBox(
            width: 2.w,
            height: dashHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: strokeGrayColor(context),
              ),
            ),
          ),
        ),
      );
    },
  );
}