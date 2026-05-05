import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../core/constants/assets/assets.dart';
import '../../../../../widgets/strike_through_text.dart';

class InfoCar extends StatelessWidget {
  const InfoCar({Key? key, required this.carModel}) : super(key: key);
  final DataCars carModel;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Container(
      width: MediaQuery.of(context).size.width * .9,
      height: MediaQuery.of(context).size.height * .16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        color: buttonWhiteColor(context),
        border: Border.all(
          color: strokeGrayColor(context),
          width: 2.w,
        ),
        //   color: Colors.red,
      ),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * .40,
            height: MediaQuery.of(context).size.height * .16,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(carModel.photo),
                fit: BoxFit.contain,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * .04,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        carModel.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.mainTypographyColor18(context),
                      ),
                    ),
                  ],
                ),

                Text(
                  locale!.pricewithtax.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.mainTypographyColor16(context),
                ),

                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${carModel.priceAfter} ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.mainTypographyColor16(context),
                      ),
                    ),

                    SizedBox(width: 6.w),

                    Flexible(
                      child: StrikethroughText(
                        text: '${carModel.priceBefore}',
                        style: TextStyle(
                          fontFamily: "IBMPlexSansArabic",
                          fontSize: 14.sp,
                          color: paragraphColor(context),
                        ),
                      ),
                    ),

                    SizedBox(width: 4.w),

                    SvgPicture.asset(
                      Assets.icon_riyal,
                      height: 20.h,
                      width: 20.w,
                      color: mainTypographyColor(context),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );

    //     Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       /// Car Image Section
    //       Container(
    //         width: 120.w,
    //         height: 100.h,
    //         decoration: BoxDecoration(
    //           image: DecorationImage(
    //             image: NetworkImage(carModel.photo),
    //             fit: BoxFit.contain,
    //           ),
    //           borderRadius: BorderRadius.circular(8.r),
    //         ),
    //       ),
    //
    //       SizedBox(width: 12.w),
    //
    //       /// Info Section
    //       Expanded(
    //         child: Padding(
    //           padding: EdgeInsets.symmetric(vertical: 8.h),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               /// Car Name
    //               Text(
    //                 carModel.name,
    //                 style: GoogleFonts.almarai(
    //                   fontSize: 13.sp,
    //                   fontWeight: FontWeight.bold,
    //                   color: Color(0xFF05658F),
    //                 ),
    //               ),
    //
    //               SizedBox(height: 4.h),
    //
    //               /// Manufacturer
    //               Text(
    //                 carModel.manufactory,
    //                 style: GoogleFonts.almarai(
    //                   fontSize: 12.sp,
    //                   fontWeight: FontWeight.w500,
    //                   color: Color(0xFF05658F),
    //                 ),
    //               ),
    //
    //               SizedBox(height: 8.h),
    //
    //               /// Price Section
    //               Row(
    //                 children: [
    //                   Text(
    //                     '${carModel.priceAfter} ',
    //                     style: GoogleFonts.almarai(
    //                       fontSize: 20.sp,
    //                       fontWeight: FontWeight.bold,
    //                       color: Theme.of(context).colorScheme.onPrimary,
    //                     ),
    //                   ),
    //                   SizedBox(width: 6.w),
    //                   Text(
    //                     '${carModel.priceBefore}',
    //                     style: GoogleFonts.almarai(
    //                       fontSize: 14.sp,
    //                       color: Colors.grey,
    //                       decoration: TextDecoration.lineThrough,
    //                     ),
    //                   ),
    //                   SizedBox(width: 4.w),
    //                   SvgPicture.asset(
    //                      Assets.icon_riyal,
    //                     height: 20.h,
    //                     width: 20.w,
    //                   ),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   );
    // }
  }
}
