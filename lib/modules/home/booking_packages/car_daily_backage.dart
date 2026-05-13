import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/cars/presentaion/bloc/cubit/cars_cubit.dart';
import 'package:darbak/modules/home/cars/presentaion/page/cars_info.dart';
import 'package:darbak/modules/home/search_screen/data/models/filter_model.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../service_locator.dart';

import '../../../core/constants/assets/app_colors.dart';
import '../../../core/style/style.dart';
import '../../widgets/components/ad_gradient_btn.dart';
import '../../widgets/strike_through_text.dart';
import '../additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import '../blocs/favourite_cubit/favourite_cubit.dart';
import '../cars/data/models/cars_model.dart';

class CarDailyPackage extends StatefulWidget {
  final int index;
  final cubit;
  final FilterModel? filterModel;
  final state;
  final DataCars? datum;

  const CarDailyPackage({
    Key? key,
    required this.index,
    this.cubit,
    this.filterModel,
    this.state,
    this.datum,
  }) : super(key: key);

  @override
  State<CarDailyPackage> createState() => _CarDailyPackageState();
}

class _CarDailyPackageState extends State<CarDailyPackage> {
  bool? lookLike = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return BlocProvider<FavouriteCubit>(
      create: (_) => FavouriteCubit(sl(), sl()),
      child: BlocConsumer<AdditionsCubit, AdditionsState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Bounce(
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: CarsInformation(
                  datum: widget.cubit.data[widget.index],
                  filterModel: widget.filterModel,
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: backgroundColor(context),
                border: Border.all(
                  color: strokeGrayColor(context),
                  width: 2.w,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        iconSize: 24.sp,
                        onPressed: () {
                          BlocProvider.of<FavouriteCubit>(context)
                              .addToFavourites(
                            widget.cubit.data[widget.index].id.toString(),
                          );
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
                      Container(
                        padding: EdgeInsets.all(8.w),
                        height: size.height * 0.066,
                        decoration: BoxDecoration(
                          color: iconDefaultColor(context),
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
                                "${widget.cubit.data[widget.index].priceAfter}",
                                style: AppTypography.buttonText15(context),
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
                                style: AppTypography.buttonText15(context),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: Builder(
                          builder: (context) {
                            if (widget.state is CarsImageLoadError) {
                              return Lottie.asset(Assets.anim_loading_car);
                            }
                            if (widget.cubit.data != null &&
                                widget.cubit.data.isNotEmpty &&
                                widget.index < widget.cubit.data.length) {
                              return Image.network(
                                widget.cubit.data[widget.index].photo,
                                width: 300.w,
                                height: 180.h,
                                fit: BoxFit.contain,
                              );
                            }
                            return Lottie.asset("assets/anim/empty.json");
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                widget.cubit.data[widget.index].name ?? '',
                                style: AppTypography.mainTypographyColor16(
                                    context),
                              ),
                              Text(
                                locale.pricewithtax.toString(),
                                style: AppTypography.mainTypographyColor14(
                                    context),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${widget.cubit.data[widget.index].priceAfter} ",
                                    style: AppTypography.mainTypographyColor14(
                                        context),
                                  ),
                                  StrikethroughText(
                                    text: "${widget.cubit.data[widget.index].priceBefore}",
                                    style: TextStyle(
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
                                    padding: EdgeInsets.all(3.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.5.w,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: ImageWithText(
                                      imagePath: "assets/images/ftes.png",
                                      text: widget.cubit.data[widget.index]
                                          .transmission,
                                      rtlText: widget.cubit.data[widget.index]
                                          .transmission,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Container(
                                    padding: EdgeInsets.all(3.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.5.w,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: ImageWithText(
                                      imagePath: "assets/images/seat.png",
                                      text:
                                          "${widget.cubit.data[widget.index].luggage} ",
                                      rtlText:
                                          "${widget.cubit.data[widget.index].luggage} ",
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ADGradientButton(
                                    locale.bookNow,
                                    width: 90.w,
                                    backgroundColor: iconDefaultColor(context),
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
                                        AppTypography.headingColor12(context),
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
                  ),
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
