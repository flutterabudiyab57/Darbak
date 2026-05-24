import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../language/locale.dart';

class NewOffers extends StatefulWidget {
  const NewOffers({super.key});

  @override
  State<NewOffers> createState() => _NewOffersState();
}

class _NewOffersState extends State<NewOffers> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Directionality(
      textDirection: locale!.isDirectionRTL(context)
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100.hs(context),
          backgroundColor: Colors.transparent,
          leadingWidth: double.infinity,
          leading: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        locale.ourOffers,
                        style: GoogleFonts.almarai(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        locale.exploreBestExclusiveOffers,
                        style: GoogleFonts.almarai(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Back button
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    children: [
                      if (locale.isDirectionRTL(context))
                        Text(
                          locale.back!,
                          style: GoogleFonts.almarai(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      SizedBox(width: 4.w),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 18.sp),
                      SizedBox(width: 4.w),

                      if (!locale.isDirectionRTL(context))
                        Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 18.sp),
                    ],
                  ),
                ),
              ],
            ),
          ),
          flexibleSpace: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/main99.png',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              /// Title row
              Row(
                children: [
                  Image.asset(
                    'assets/icons/offersIcon.png',
                    width: 18.w,
                    height: 18.h,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'استكشف العروض الحصرية',
                    style: GoogleFonts.almarai(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              /// Offers list
              Expanded(
                child: ListView.separated(
                  itemCount: 3, // change this to actual offer count
                  separatorBuilder: (_, __) => SizedBox(height: 14.h),
                  itemBuilder: (_, index) => _offerItem(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Offer Card Widget
  Widget _offerItem() {
    return Column(
      children: [
        // Offer image
        ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r)),
          child: Image.asset(
            'assets/images/main999.png',
            height: 120.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        // Offer description
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r)),
            gradient: LinearGradient(
              colors: [Color(0xFF2ABF82), Color(0xFF05658F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'احصل على خصم 15% عند الدفع بالفيزا',
                style: GoogleFonts.almarai(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'يمكنك الحصول على خصم مميز 15% عند الدفع بالبطاقة الائتمانية من خلال التطبيق أو الموقع الإلكتروني.',
                style: GoogleFonts.almarai(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
