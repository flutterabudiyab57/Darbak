import 'package:darbak/modules/home/offers/model/offer_model.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/style/style.dart';
import '../../../../language/locale.dart';
import '../../cars/presentaion/widget/car_tile.dart';

class OfferDetailsContent extends StatelessWidget {
  final OfferModel offer;

  const OfferDetailsContent({Key? key, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                offer.image != null && offer.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.r),
                          topRight: Radius.circular(25.r),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: offer.image,
                          width: double.infinity,
                          height: 200.h,
                          fit: BoxFit.fill,
                          errorWidget: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/offers_empty.png',
                              width: double.infinity,
                              height: 200.h,
                              fit: BoxFit.fill,
                            );
                          },
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.r),
                          topRight: Radius.circular(25.r),
                        ),
                        child: Image.asset(
                          'assets/images/offers_empty.png',
                          width: double.infinity,
                          height: 200.h,
                          fit: BoxFit.fill,
                        ),
                      ),
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: buttonPrimaryBgColor(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.r),
                        bottomRight: Radius.circular(20.r),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              offer.name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBMPlexSansArabic',
                                color: buttonTextColor(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          offer.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.buttonText14(context),
                        ),
                        SizedBox(height: 6.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            locale.isDirectionRTL(context)
                ? "السيارات فى العرض"
                : "Cars in Offers",
            style: AppTypography.headingColor18(context),
          ),
          SizedBox(height: 8.h),
          if (offer.cars.isEmpty)
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/cars_offers.png',
                    height: 200.h,
                  ),
                  Text(
                    locale.isDirectionRTL(context)
                        ? "العرض متاح لجميع السيارات."
                        : "Offer available for all cars.",
                    style: AppTypography.headingColor12(context),
                  ),
                ],
              ),
            )
          else
            ...offer.cars.asMap().entries.map(
                  (entry) => CarTile(
                    index: entry.key,
                    datum: entry.value,
                  ),
                ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
