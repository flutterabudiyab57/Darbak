import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:darbak/modules/home/cars/presentaion/widget/car_icon_info.dart';
import 'package:darbak/modules/home/search_screen/data/models/filter_model.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/constants/assets/assets.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../widgets/Dashed_divider.dart';
import '../../../../widgets/components/appbar.dart';
import '../../../../widgets/components/car_photos_slider.dart';
 import '../../../../widgets/strike_through_text.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/router/routes.dart';
import '../../../search_screen/blocs/search_bloc/search_cubit.dart';
import '../../../search_screen/presentaion/widget/monthly_package_widget.dart';

class CarsInformation extends StatefulWidget {
  CarsInformation(
      {Key? key, required this.datum, this.filterModel, this.stockStatus})
      : super(key: key);

  final DataCars? datum;
  final FilterModel? filterModel;
  final String? stockStatus;

  @override
  State<CarsInformation> createState() => _CarsInformationState();
}

class _CarsInformationState extends State<CarsInformation> {
  late bool isFavorite;
  bool isPackagesVisible = false;

  bool? lookLike = true;

  @override
  void initState() {
    isFavorite = widget.datum!.isFavorite;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    // Prices mapping
    final List<Map<String, dynamic>> prices = [
      {
        "priceAfter": widget.datum!.priceAfter1Month,
        "priceOriginal": widget.datum!.price1Month,
        "label": locale!.k1Month,
      },
      {
        "priceAfter": widget.datum!.priceAfter3Month,
        "priceOriginal": widget.datum!.price3Month,
        "label": locale.k3Months,
      },
      {
        "priceAfter": widget.datum!.priceAfter6Month,
        "priceOriginal": widget.datum!.price6Month,
        "label": locale.k6Months,
      },
      {
        "priceAfter": widget.datum!.priceAfter9Month,
        "priceOriginal": widget.datum!.price9Month,
        "label": locale.k9Months,
      },
      {
        "priceAfter": widget.datum!.priceAfter12Month,
        "priceOriginal": widget.datum!.price12Month,
        "label": locale.k12Months,
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: CustomAppBar(
        title:locale.carDetails,
        showBackButton: true,
        // showThemeToggle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    if (widget.stockStatus != null)
                      SizedBox(height: 30.h,),
                    CarImageCarousel(
                      mainPhoto: widget.datum!.photo,
                      photos: widget.datum!.photos,
                      onImageTap: () {
                        context.pushNamed(
                          Routes.imageCarPage,
                          extra: widget.datum!.photos,
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                "${widget.datum!.name} ",
                                style:AppTypography.headingColor20(context),
                              ),  SizedBox(width: 10.w,),
                              // Container(
                              //   height: 35.h,
                              //   decoration: BoxDecoration(
                              //       color: Color(0xffA70003).withValues(alpha: 0.15),
                              //       borderRadius: BorderRadius.circular(10.sp),
                              //     border: Border.all(
                              //       color: Color(0xffA70003).withValues(alpha: 0.5),
                              //       width:1.w,
                              //     ),                        ),
                              //   child: Padding(
                              //     padding:   EdgeInsets.symmetric(horizontal:  4.sp),
                              //     child: Row(
                              //       mainAxisSize: MainAxisSize.min,
                              //
                              //       children: [
                              //         Flexible(
                              //           child: Text(
                              //             "${locale.lookLike1.toString() }",
                              //             style:AppTypography.headingColor12(context),
                              //           ),
                              //         ),
                              //         Flexible(
                              //           child: IconButton(
                              //             icon: Icon(
                              //               Icons.priority_high,
                              //               color: Color(0xffA70003),
                              //               size: 21.sp,
                              //             ),
                              //             onPressed: () {
                              //               showModalBottomSheet(
                              //                 context: context,
                              //                 isScrollControlled: true,
                              //                 backgroundColor: Colors.white,
                              //                 constraints: const BoxConstraints(maxWidth: double.infinity,),
                              //                 barrierColor: Colors.black.withValues(alpha: 0.5),
                              //                 shape: RoundedRectangleBorder(
                              //                   borderRadius: BorderRadius.vertical(
                              //                     top: Radius.circular(20.r),
                              //                   ),
                              //                 ),
                              //                 builder: (context) {
                              //                   List<TextSpan> spans = [];
                              //                   String description =
                              //                       widget.datum!.description ?? "";
                              //                   List<String> lines = description.split('\n');
                              //
                              //                   for (var line in lines) {
                              //                     if (line.trim().isEmpty) continue;
                              //                     List<String> parts = line.split(':');
                              //
                              //                     if (parts.length > 1) {
                              //                       spans.add(
                              //                         TextSpan(
                              //                           text: "${parts[0].trim()}: ",
                              //                           style: GoogleFonts.almarai(
                              //                             color: Colors.blue,
                              //                             fontWeight: FontWeight.bold,
                              //                             fontSize: 14.sp,
                              //                           ),
                              //                         ),
                              //                       );
                              //                       spans.add(
                              //                         TextSpan(
                              //                           text:
                              //                           "${parts.sublist(1).join(':').trim()}\n",
                              //                           style: AppTypography.headingColor14(context),
                              //                         ),
                              //                       );
                              //                     } else {
                              //                       spans.add(
                              //                         TextSpan(
                              //                           text: "$line\n",
                              //                           style: AppTypography.headingColor14(context),
                              //                         ),
                              //                       );
                              //                     }
                              //                   }
                              //
                              //                   return Padding(
                              //                     padding: EdgeInsets.only(
                              //                       bottom:
                              //                       MediaQuery.of(context).viewInsets.bottom,
                              //                       left: 20.w,
                              //                       right: 20.w,
                              //                       top: 20.h,
                              //                     ),
                              //                     child: Wrap(
                              //                       children: [
                              //                         Center(
                              //                           child: Container(
                              //                             width: 40.w,
                              //                             height: 5.h,
                              //                             margin: EdgeInsets.only(bottom: 10.h),
                              //                             decoration: BoxDecoration(
                              //                               color: Colors.grey[300],
                              //                               borderRadius:
                              //                               BorderRadius.circular(10.r),
                              //                             ),
                              //                           ),
                              //                         ),
                              //                         RichText(
                              //                           text: TextSpan(children: spans),
                              //                         ),
                              //                         SizedBox(height: 20.h),
                              //                         Align(
                              //                           alignment: Alignment.centerRight,
                              //                           child: TextButton(
                              //                             onPressed: () =>
                              //                                 Navigator.pop(context),
                              //                             child: Text(
                              //                               "إغلاق",
                              //                               style: GoogleFonts.almarai(
                              //                                 color: Colors.blue,
                              //                                 fontWeight: FontWeight.w600,
                              //                                 fontSize: 16.sp,
                              //                               ),
                              //                             ),
                              //                           ),
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   );
                              //                 },
                              //               );
                              //             },
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),

                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                locale.pricewithtax.toString(),
                                style: AppTypography.headingColor20(context),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                "${widget.datum!.priceAfter} ",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                  color: mainTypographyColor(context),
                                  fontFamily: 'ThmanyahSans',
                                ),
                              ),
                              SizedBox(width: 4.w),
                              StrikethroughText(
                                text: "${widget.datum!.priceBefore}",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                  fontFamily: 'ThmanyahSans',
                                ),
                              ),                      SizedBox(width: 6.w),
                              SvgPicture.asset(
                                Assets.icon_riyal,
                                color: mainTypographyColor(context),
                                height: 20.h,
                                width: 20.w,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h,),
                          // CashbackReward(cashbackAmount: 25),
                          SizedBox(height: 10.h,),
                          dashedDivider(context),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.stockStatus != null)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 100.w,
                      height: 55.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                          bottomStart: Radius.circular(18.r),
                          topEnd: Radius.circular(12.r),
                        ),
                        color: Colors.red,
                      ),
                      child: Center(
                        child: Text(
                          locale.outOfStock,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: 12.h,
            ),
            SizedBox(
              height: 150.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                children: [
                  CarIconInfo(
                    image:Assets.icon_carSeat,
                    description: locale.numberOfSeats,
                    text:
                    "${widget.datum!.doors} ",
                    text2: "${locale.seats}",
                    backgroundColor:seatsContainer(context),
                    foregroundColor: const Color(0xFFD58F11),

                  ),
                  // CarIconInfo(
                  //   image: "assets/images/seat.png",
                  //   text:
                  //       "${widget.datum!.luggage} ${locale.bags}",
                  // ),
                  CarIconInfo(
                    image:Assets.icon_maximumSpeed,

                    description: locale.maximumSpeed,
                    text:
                    "${widget.datum!.kilo} ",
                    text2: "${locale.kmDay}",
                    backgroundColor: speedContainer(context),
                    foregroundColor: const Color(0xFF42813B),

                  ),
                  CarIconInfo(
                    image:Assets.icon_fuelPump,
                    description: locale.fuel,
                    text:
                    "${widget.datum!.fuel} ",
                    backgroundColor: fuelContainer(context),
                    foregroundColor: const Color(0xFF3B3B3B),

                  ),

                  CarIconInfo(
                    image:Assets.icon_automaticTransmission,
                    description: locale.transmission,

                    text: widget.datum!.transmission == "ناقل حركة أوتوماتيكي"
                        ? locale.automatic
                        : widget.datum!.transmission == "ناقل حركة يدوى"
                        ? locale.manual
                        : "${widget.datum!.transmission}",
                    backgroundColor: TransmissionContainer(context),
                    foregroundColor: const Color(0xFFA10012),
                    )
                ],
              ),
            ),
            SizedBox(
              height: 8.h,
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal:  14.sp),
              child: dashedDivider(context),
            ),
            SizedBox(height: 8.h,),
            Padding(
                padding:  EdgeInsets.all(8.sp),
                child: Column(
                  children: [
                    MonthlyPackageWidget(
                      onTap: () {
                        setState(() {
                          isPackagesVisible = !isPackagesVisible;
                        });
                      },
                    ),
                    if (isPackagesVisible) ...[
                      Divider(
                        thickness: 0.6.w,
                        color: Colors.grey,
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: prices.length,
                        itemBuilder: (context, index) {
                          final price = prices[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: backgroundColor(context),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: strokeGrayColor(context),
                                width: 1.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 8.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${price['priceAfter']} ",
                                  style:AppTypography.mainTypographyColor16(context),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    StrikethroughText(
                                      text: "${price['priceOriginal']}",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w400,
                                        color: paragraphColor(context),
                                      ),
                                    ),                                    SvgPicture.asset(
                                      Assets.icon_riyal,
                                      color:
                                      Theme.of(context).colorScheme.primary,
                                      height: 16.h,
                                      width: 16.w,
                                    ),
                                    Text(
                                      "/${price['label']}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                          color:
                                          headingColor(context)
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                )
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                children: [
                  SizedBox(height: 10.h,),
                  Bounce(
                    onTap: () {
                      if (widget.filterModel == null) {
                        context.pushNamed(Routes.branchWithCar,
                            extra: widget.datum!);
                      } else {
                        context.pushNamed(Routes.additions,
                            extra: AdditionsArgs(datum: widget.datum));
                      }
                    },
                    child: Bounce(
                      onTap: () {
                        if (widget.stockStatus != null) {
                          Fluttertoast.showToast(
                            msg: locale.stockStatusIsNotAvailableEnjoy,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.redAccent.shade400,
                            textColor: Colors.white,
                            fontSize: 14.sp,
                          );
                          return;
                        }
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  widget.datum!.name.toString().toUpperCase() +
                                      ' ' +
                                      locale.lookLike1.toString(),
                                  style:AppTypography.headingColor16(context),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.r))),
                                backgroundColor: backgroundColor(context),
                                content: Container(
                                  child: Text(
                                      locale.lookLike.toString(),
                                      style:AppTypography.paragraphColor15(context)
                                  ),
                                ),
                                actions: [
                                  BlocConsumer<AdditionsCubit, AdditionsState>(
                                    listener: (context, state) {
                                      if (state is AdditionsFailed) {
                                        print("AdditionsFailed 11 11 ... ....");
                                        print("error:  ${state.error}");
                                        if (state.error.contains(
                                            "Error Please LOGIN To Continue")) {
                                          context.go('/signin');
                                        }
                                      }
                                    },
                                    builder: (context, state) {
                                      return Bounce(
                                        onTap: () async {
                                          await BlocProvider.of<AdditionsCubit>(context)
                                              .getCarFeatures(context, widget.datum!.id.toString(), widget.filterModel);
                                          if (widget.filterModel == null && lookLike == true) {
                                            BlocProvider.of<SearchCubit>(context).resetBranches();
                                            context.pushNamed(Routes.branchWithCar,
                                                extra: widget.datum!);} else {
                                            Navigator.pop(context);
                                            if (state is AdditionsSuccess ||
                                                state is AdditionsInitial) {
                                              context.pushNamed(Routes.additions,
                                                  extra: AdditionsArgs(datum: widget.datum));
                                            }
                                            if (state is AdditionsFailed) {
                                              print("AdditionsFailed 00 00 00");
                                              if (state.error.contains(
                                                  "Error Please LOGIN To Continue")) {
                                                context.go('/signin');
                                              }
                                            }
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            state is AdditionsLoading
                                                ? LoadingIndicator()
                                                : ADGradientButton(
                                              locale.ok.toString(),
                                              width: MediaQuery.of(context).size.width * 0.4,
                                              textStyle: AppTypography.buttonText18(context),
                                            )

                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: ADGradientButton(locale.bookNow),
                    ),
                  ),
                  SizedBox(
                    height: 36.h,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
