import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../language/locale.dart';
import '../../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../booking_packages/ui/delivery_package_screen.dart';
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DeliveryPackageScreen.entry()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient:LinearGradient(
            begin: _figmaToFlutter(0.00, 0.00),
            end: _figmaToFlutter(1.00, 1.00),
        colors:  [
          buttonPrimaryBgColor(context),
          Color(0xFF009966),

        ],
        stops: const [0.0, 1.0],
      ),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              textDirection: Directionality.of(context),
              children: [
                Flexible(
                  child: Text(
                    locale!.deliveryTitle.toString(),
                    textAlign: TextAlign.start,
                    style: AppTypography.buttonText20(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF2BC181),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    locale.New.toString(),
                    style: AppTypography.buttonText12(context),
                    maxLines: 1,
                  ),
                ),

              ],
            ),

            SizedBox(height: 8.h),

            Row(
              children: [
                Expanded(
                  child: Text(
                    locale.deliverySubtitle.toString(),
                    textAlign: TextAlign.start,
                    style: AppTypography.buttonText12(context).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            ADGradientButton(
              locale.deliveryCta,
              backgroundColor: buttonWhiteColor(context),
              textStyle: AppTypography.secondaryTypographyColor16(context),
              height: 42.h,
            ),

            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }
}
Alignment _figmaToFlutter(double x, double y) {
  return Alignment((x * 2) - 1, (y * 2) - 1);
}