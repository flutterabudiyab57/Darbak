import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/widgets/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/style/style.dart';

class Reviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      // physics: ScrollPhysics(),
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(15.r)),
                        child: Row(
                          children: [
                            Text(
                              locale.dummyRating!,
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(Icons.star, size: 10.sp, color: Colors.white)
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text("98" + locale.peopleRated!,
                          style: AppTypography.paragraphColor12(context))
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemExtent: 120.h,
                    itemBuilder: (BuildContext context, int index) {
                      List profile = [
                        // Assets.layer_10,
                        // Assets.layer_12,
                        // Assets.layer_13
                      ];
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25.r,
                                      backgroundImage:
                                          AssetImage(profile[index]),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          locale.dummyName1!,
                                          style: AppTypography.paragraphColor14(
                                              context),
                                        ),
                                        Text(
                                          locale.dummyDate1!,
                                          style: AppTypography.headingColor10(
                                              context),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 13.sp,
                                      color: Colors.orange,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 13.sp,
                                      color: Colors.orange,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 13.sp,
                                      color: Colors.orange,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 13.sp,
                                      color: Colors.orange,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 13.sp,
                                      color: Colors.orange,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              locale.lorem!,
                              style: AppTypography.paragraphColor12(context)
                                  .copyWith(
                                color: Colors.grey[300],
                              ),
                            ),
                            Divider()
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
