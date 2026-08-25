import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/search_screen/data/models/filter_model.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/router/routes.dart';
import '../../../../../service_locator.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../widgets/strike_through_text.dart';
import '../../../blocs/favourite_cubit/favourite_cubit.dart';
import '../../data/models/cars_model.dart';

class CarTile extends StatefulWidget {
  final int index;
  final cubit;
  final FilterModel? filterModel;
  final state;
  final DataCars? datum;
  final bool isFavouritePage;

  const CarTile({
    Key? key,
    required this.index,
    this.cubit,
    this.filterModel,
    this.state,
    this.datum,
    this.isFavouritePage = false,
  }) : super(key: key);

  @override
  State<CarTile> createState() => _CarTileState();
}

class _CarTileState extends State<CarTile> {
  late bool isFavorite = false;

  DataCars get _carData {
    if (widget.datum != null) return widget.datum!;
    return widget.cubit.data[widget.index];
  }

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavouritePage ? true : _carData.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final carData = _carData;

    return BlocProvider<FavouriteCubit>(
      create: (_) => FavouriteCubit(sl(), sl()),
      child: Container(
        margin: EdgeInsets.all(4.h),
        decoration: BoxDecoration(
          color: backgroundColor(context),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: strokeGrayColor(context),
            width: 0.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x28000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // [A] TOP SECTION
            Container(
              height: 122.h,
              width: double.infinity,
              color: bg2Color(context),
              child: Stack(
                children: [
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: carData.photo,
                      fit: BoxFit.contain,
                      height: 103.h,
                      errorWidget: (context, url, error) =>
                          Lottie.asset("assets/anim/empty.json"),
                    ),
                  ),
                  // Price badge
                  PositionedDirectional(
                    end: 0,
                    top: 0,
                    child: carData.availableBranches.isEmpty
                        ? Container(
                            height: 36.h,
                            padding: EdgeInsets.symmetric(horizontal: 11.w),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadiusDirectional.only(
                                topStart: Radius.circular(15.r),
                                bottomEnd: Radius.circular(15.r),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              locale!.outOfStock,
                              style: AppTypography.buttonText14(context)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          )
                        : Container(
                            height: 36.h,
                            padding: EdgeInsets.symmetric(horizontal: 11.w),
                            decoration: BoxDecoration(
                              color: iconBlueColor(context),
                              borderRadius: BorderRadiusDirectional.only(
                                bottomStart: Radius.circular(15.r),
                                topEnd: Radius.circular(15.r),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  locale!.pricewithtax.toString(),
                                  style: AppTypography.buttonText12(context),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Favorite heart
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    child: Builder(
                      builder: (context) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            BlocProvider.of<FavouriteCubit>(context)
                                .addToFavourites(carData.id.toString());
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                          icon: Icon(
                            Icons.favorite,
                            color:
                                isFavorite ? Colors.red : const Color(0xff999999),
                            size: 36.sp,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // [B] CONTENT SECTION
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Leading side — car info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              carData.name,
                              maxLines: 1,
                              style: AppTypography.headingColor16(context),
                            ),
                            SizedBox(height: 14.h),
                            // Chips row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _chip(
                                  context,
                                  child: ImageWithText(
                                    imagePath: "assets/images/car_seat.png",
                                    text: "${carData.doors} ",
                                    rtlText: "${carData.doors} ",
                                  ),
                                ),
                                _divider(context),
                                _chip(
                                  context,
                                  child: ImageWithText(
                                    imagePath: "assets/images/seat.png",
                                    text: "${carData.luggage} ",
                                    rtlText: "${carData.luggage} ",
                                  ),
                                ),
                                _divider(context),
                                _chip(
                                  context,
                                  child: ImageWithText(
                                    imagePath: "assets/images/ftes.png",
                                    text: "${carData.transmission}",
                                    rtlText: "${carData.transmission}",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Trailing side — price column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StrikethroughText(
                            text: "${carData.priceBefore}",
                            style: AppTypography.mainTypographyColor14(context),
                            children: [
                              SizedBox(width: 3.w),
                              SvgPicture.asset(
                                Assets.icon_riyal,
                                height: 15.sp,
                                width: 14.sp,
                                color: mainTypographyColor(context),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                locale.perDay,
                                style: AppTypography.mainTypographyColor14(context),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${carData.priceAfter}",
                                style:
                                    AppTypography.secondaryTypographyColor16(
                                        context),
                              ),
                              SizedBox(width: 4.w),
                              SvgPicture.asset(
                                Assets.icon_riyal,
                                height: 16.h,
                                width: 16.w,
                                color: SecondaryTypographyColor(context),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                locale!.perDay,
                                style:
                                    AppTypography.secondaryTypographyColor16(
                                        context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Row 2 — book button
                  GestureDetector(
                    onTap: () {
                      if (carData.availableBranches.isEmpty) {
                        context.pushNamed(
                          Routes.carsInformation,
                          extra: CarsInformationArgs(
                            datum: carData,
                            filterModel: widget.filterModel,
                            stockStatus: 'نفذت الكميه',
                          ),
                        );
                      } else {
                        context.pushNamed(
                          Routes.carsInformation,
                          extra: CarsInformationArgs(
                            datum: carData,
                            filterModel: widget.filterModel,
                          ),
                        );
                      }
                    },
                    child: ADGradientButton(
                      locale!.bookNow,
                      width: double.infinity,
                      height: 40.h,
                      textStyle: AppTypography.buttonText16(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, {required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0x3F2676F0),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: child,
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(
        width: 1.w,
        height: 18.h,
        color: strokeGrayColor(context),
      ),
    );
  }
}

class ImageWithText extends StatelessWidget {
  final String imagePath;
  final String text;
  final String rtlText;

  const ImageWithText({
    Key? key,
    required this.imagePath,
    required this.text,
    required this.rtlText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    bool isRTL = locale!.isDirectionRTL(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          color: iconDefaultColor(context),
          width: 16.w,
          height: 16.h,
          fit: BoxFit.contain,
        ),
        SizedBox(width: 2.w),
        Text(
          isRTL ? rtlText : text,
          style: AppTypography.paragraphColor12(context),
        ),
      ],
    );
  }
}
