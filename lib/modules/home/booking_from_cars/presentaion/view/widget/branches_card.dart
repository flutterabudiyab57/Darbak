import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../language/locale.dart';
import '../../../../../../core/router/routes.dart';
import '../../../../search_screen/blocs/search_bloc/search_cubit.dart';

class Branches_Card extends StatelessWidget {
  const Branches_Card({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        BlocProvider.of<SearchCubit>(context).clearAllDataSearched();
        BlocProvider.of<SearchCubit>(context).getAirPortBranches();
        context.pushNamed(Routes.deliveryPackage);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: ShapeDecoration(
          color: bg2Color(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    locale!.deliveryTitle.toString(),
                    textAlign: TextAlign.end,
                    style: AppTypography.headingColor20(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: ShapeDecoration(
                    color: buttonColor(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    locale!.New.toString(),
                    style: AppTypography.buttonText12(context),
                    maxLines: 1,
                  ),
                ),
                // Title
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Text(
                        locale.deliverySubtitle.toString(),
                        textAlign: TextAlign.start,
                        style: AppTypography.paragraphColor12(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 12.h),

                      // CTA button — white with blue border
                      Container(
                        width: double.infinity,
                        height: 42.h,
                        decoration: ShapeDecoration(
                          color: buttonWhiteColor(context),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: buttonColor(context),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            locale.deliveryCta.toString(),
                            textAlign: TextAlign.center,
                            style: AppTypography.secondaryTypographyColor16(
                                context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Car image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    'assets/images/Delivery_Car.png',
                    width: 133.w,
                    height: 65.h,
                    fit: BoxFit.fill,
                  ),
                ),

                // Subtitle + CTA button
              ],
            ),

            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }
}
