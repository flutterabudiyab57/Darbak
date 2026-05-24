import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widget_zoom/widget_zoom.dart';

import '../../../core/constants/assets/app_colors.dart';
import '../../../core/helpers/interceptors/loading_indicator.dart';

class CarImageCarousel extends StatefulWidget {
  final String mainPhoto;
  final List<Photo> photos;
  final VoidCallback? onImageTap;

  const CarImageCarousel({
    Key? key,
    required this.mainPhoto,
    required this.photos,
    this.onImageTap,
  }) : super(key: key);

  @override
  State<CarImageCarousel> createState() => _CarImageCarouselState();
}

class _CarImageCarouselState extends State<CarImageCarousel> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final List<String> allImages = [
      widget.mainPhoto,
      ...widget.photos
          .map((photo) => photo.url ?? '')
          .where((url) => url.isNotEmpty),
    ];
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: allImages.length,
              options: CarouselOptions(
                height: 145.h,
                viewportFraction: 1.0,
                enableInfiniteScroll: allImages.length > 1,
                autoPlay: false,
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {},
              ),
              itemBuilder: (context, index, realIndex) {
                return GestureDetector(
                  onTap: widget.onImageTap,
                  child: Center(
                    child: WidgetZoom(
                      heroAnimationTag: 'car_image_$index',
                      zoomWidget: CachedNetworkImage(
                        imageUrl: allImages[index],
                        width: 370.w,
                        height: 145.h,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          width: 370.w,
                          height: 145.h,
                          child: Center(
                            child: LoadingIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 370.w,
                          height: 145.h,
                          color: Colors.grey[300],
                          child: Icon(Icons.error, size: 40.sp),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (allImages.length > 1)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavigationButton(
                        icon: Icons.arrow_back_ios,
                        onTap: () {
                          _carouselController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      _buildNavigationButton(
                        icon: Icons.arrow_forward_ios,
                        onTap: () {
                          _carouselController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: 8.h),

        // if (allImages.length > 1)
        //   SizedBox(
        //     height: 20.h,  // ارتفاع ثابت
        //     child: SingleChildScrollView(
        //       scrollDirection: Axis.horizontal,  // أضف هذا
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: allImages.asMap().entries.map((entry) {
        //           return Container(
        //             width: _currentIndex == entry.key ? 24.w : 8.w,
        //             height: 8.h,
        //             margin: EdgeInsets.symmetric(horizontal: 4.w),
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(4.r),
        //               color: _currentIndex == entry.key
        //                   ? iconDefaultColor(context)
        //                   : strokeGrayColor(context),
        //             ),
        //           );
        //         }).toList(),
        //       ),
        //     ),
        //   ),

        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: buttonWhiteColor(context),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconDefaultColor(context),
            size: 25.sp,
          ),
        ),
      ),
    );
  }
}
