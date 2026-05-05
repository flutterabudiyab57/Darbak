import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:darbak/modules/home/cars/presentaion/widget/car_icon_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/assets/assets.dart';
import '../../../../../core/style/style.dart';

class About extends StatelessWidget {
  final DataCars? datum;

  const About({Key? key, required this.datum}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 30.h),
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(locale.category!,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.paragraphColor15(context)),
                      ),
                      Text("${datum?.category}",
                          style: AppTypography.paragraphColor15(context)),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(locale.type.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.paragraphColor15(context)),
                      ),
                      Text("${datum?.manufactory}",
                          style: AppTypography.paragraphColor15(context)),
                    ],
                  ),
                  // SizedBox(height: 20),
                  // Text(locale.about!,
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .bodyLarge!
                  //         .copyWith(fontSize: 15)),
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Text(
                      datum?.description ?? "",
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // CarIconInfo(
                      //     image: "assets/images/car-door.png",
                      //     text: "${datum?.doors ?? "1"}"),
                      // CarIconInfo(
                      //     image: "assets/images/seat.png", text: "${datum?.luggage ?? "1"}"),
                      CarIconInfo(
                          image: Assets.icon_automaticTransmission,
                          text: "${datum?.transmission ?? "1"}"),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
