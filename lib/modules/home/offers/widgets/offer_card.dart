import 'package:bounce/bounce.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';

class OfferCard extends StatelessWidget {
  final int id;
  final String name;
  final String from;
  final String to;
  final String description;
  final String coupon;
  final int discountValue;
  final String imageUrl;
  final int coupon_is_work;

  const OfferCard({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    required this.coupon,
    required this.discountValue,
    required this.imageUrl,
    required this.description,
    required this.coupon_is_work,
  });

  @override
  Widget build(BuildContext context) {
    // onTap: () {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => OfferDetailsScreen(offerId: id),
    //     ),
    //   );
    // },
    return Bounce(
      onTap: () async {
        final facebookAppEvents = FacebookAppEvents();
        await facebookAppEvents.logViewContent();
        await facebookAppEvents.flush();
        print('logViewContent');
        context.pushNamed(Routes.offerDetails, extra: id);
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.r),
                        topRight: Radius.circular(25.r),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
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
                    ),
                  )
                : Container(
                    color: backgroundColor(context),
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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: AppTypography.buttonText14(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$description',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.buttonText12(context),
                    ),
                    SizedBox(height: 6.h),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
