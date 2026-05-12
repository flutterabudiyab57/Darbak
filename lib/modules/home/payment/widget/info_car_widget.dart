import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/assets/assets.dart';
import '../../../../core/style/style.dart';
import '../../../widgets/strike_through_text.dart';

class InfoCarWidget extends StatelessWidget {
  final DataCars? carModel;

  const InfoCarWidget({Key? key, required this.see, required this.carModel})
      : super(key: key);
  final bool see;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: FittedBox(
              child: Padding(
                padding: EdgeInsets.only(top: see ? 0 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carModel!.name.toString(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Text(
                          carModel!.manufactory,
                          style: AppTypography.paragraphColor14(context),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Text(
                              carModel!.priceAfter.toString() + "  ",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            StrikethroughText(
                              text: carModel!.priceBefore.toString(),
                              style: AppTypography.paragraphColor16(context),
                            ),
                            SizedBox(width: 4.w),
                            SvgPicture.asset(Assets.icon_riyal, height: 20.h, width: 20.w),
                          ],
                        )                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Container(
            height: 100.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(carModel!.photo),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
