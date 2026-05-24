import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/cars/presentaion/page/cars_info.dart';
import 'package:darbak/modules/home/search_screen/data/models/filter_model.dart';
import 'package:bounce/bounce.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../../service_locator.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../../widgets/strike_through_text.dart';
import '../../../additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
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
  bool? lookLike = true;
  late bool isFavorite = false;

  DataCars get _carData {
    if (widget.datum != null) return widget.datum!;
    return widget.cubit.data[widget.index];
  }

  @override
  void initState() {
    super.initState();

    final carData = _carData;

    if (!widget.isFavouritePage &&
        widget.cubit != null &&
        widget.filterModel != null &&
        lookLike != true) {
      try {
        BlocProvider.of<AdditionsCubit>(context).getCarFeatures(
          context,
          carData.id.toString(),
          widget.filterModel,
        );
      } catch (e) {
        print('Error loading car features: $e');
      }
    }

    isFavorite = widget.isFavouritePage ? true : carData.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;

    final carData = _carData;

    return BlocProvider<FavouriteCubit>(
      create: (_) => FavouriteCubit(sl(), sl()),
      child: BlocConsumer<AdditionsCubit, AdditionsState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Bounce(
            onTap: () {
              if (carData.availableBranches.isEmpty) {
                PersistentNavBarNavigator.pushNewScreen(context,
                    screen: CarsInformation(
                      datum: carData,
                      filterModel: widget.filterModel,
                      stockStatus: 'نفذت الكميه',
                    ));
              } else {
                PersistentNavBarNavigator.pushNewScreen(context,
                    screen: CarsInformation(
                      datum: carData,
                      filterModel: widget.filterModel,
                    ));
              }
            },
            child: Container(
              margin: EdgeInsets.all(6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: backgroundColor(context),
                border: Border.all(color: strokeGrayColor(context), width: 2.w),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () {
                          BlocProvider.of<FavouriteCubit>(context)
                              .addToFavourites(carData.id.toString());
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                        icon: Icon(
                          Icons.favorite,
                          color: isFavorite ? Colors.red : Color(0xff999999),
                          size: 36.sp,
                        ),
                      ),
                      carData.availableBranches.isEmpty
                          ? Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                width: 100.w,
                                height: 55.h,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadiusDirectional.only(
                                    bottomStart: Radius.circular(18.r),
                                    topEnd: Radius.circular(12.r),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    locale!.outOfStock,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.all(8.w),
                              height: size.height * 0.064,
                              decoration: BoxDecoration(
                                gradient: secondary2,
                                borderRadius: BorderRadiusDirectional.only(
                                  bottomStart: Radius.circular(18.r),
                                  topEnd: Radius.circular(12.r),
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${carData.priceAfter}",
                                      style:
                                          AppTypography.buttonText15(context),
                                    ),
                                    SizedBox(width: 4.w),
                                    SvgPicture.asset(
                                      Assets.icon_riyal,
                                      height: 15.sp,
                                      width: 14.sp,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      locale!.perDay,
                                      style:
                                          AppTypography.buttonText15(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: CachedNetworkImage(
                          imageUrl: carData.photo,
                          fit: BoxFit.contain,
                          width: 300.w,
                          height: 180.h,
                          errorWidget: (context, url, error) =>
                              Lottie.asset("assets/anim/empty.json"),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                _trimText(carData.name),
                                style: AppTypography.mainTypographyColor16(
                                    context),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                locale.pricewithtax.toString(),
                                style: AppTypography.mainTypographyColor14(
                                    context),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${carData.priceAfter} ",
                                    style: AppTypography.mainTypographyColor16(
                                        context),
                                  ),
                                  StrikethroughText(
                                    text: "${carData.priceBefore}",
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSansArabic',
                                      color: mainTypographyColor(context),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    Assets.icon_riyal,
                                    height: 20.h,
                                    width: 20.w,
                                    color: mainTypographyColor(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: strokeGrayColor(context),
                                        width: 1.5.w,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    padding: EdgeInsets.all(3.sp),
                                    child: ImageWithText(
                                      imagePath: "assets/images/ftes.png",
                                      text: "${carData.transmission}",
                                      rtlText: "${carData.transmission}",
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: strokeGrayColor(context),
                                        width: 1.5.w,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    padding: EdgeInsets.all(3.sp),
                                    child: ImageWithText(
                                      imagePath: "assets/images/seat.png",
                                      text: "${carData.luggage} ",
                                      rtlText: "${carData.luggage} ",
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ADGradientButton(
                                    locale.bookNow,
                                    width: 90.w,
                                    gradient: secondary,
                                    textStyle:
                                        AppTypography.buttonText15(context),
                                    height: 40.h,
                                  ),
                                  SizedBox(width: 8.w),
                                  ADGradientButton(
                                    locale.moredetails,
                                    width: 110.w,
                                    height: 40.h,
                                    backgroundColor: Colors.transparent,
                                    textStyle:
                                        AppTypography.headingColor16(context),
                                    border: Border.all(
                                      width: 2.w,
                                      color: iconDefaultColor(context),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.h),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            color: iconDefaultColor(context),
            width: 20.w,
            height: 24.h,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 2.w),
          Text(
            isRTL ? rtlText : text,
            style: AppTypography.paragraphColor12(context),
          ),
        ],
      ),
    );
  }
}

String _trimText(String text) {
  if (text.length <= 25) return text.toUpperCase();
  return "${text.substring(0, 10).toUpperCase()}...";
}
