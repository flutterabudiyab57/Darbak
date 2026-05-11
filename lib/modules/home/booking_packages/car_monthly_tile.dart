// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:darbak/core/constants/assets/assets.dart';
// import 'package:darbak/core/style/style.dart';
// import 'package:darbak/language/locale.dart';
// import 'package:darbak/modules/home/search_screen/data/models/filter_model.dart';
// import 'package:bounce/bounce.dart';
// import 'package:cached_network_image_ce/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:lottie/lottie.dart';
// import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
// import 'package:shimmer/shimmer.dart';
// import '../../../core/constants/assets/app_colors.dart';
//  import '../../widgets/components/ad_gradient_btn.dart';
// import '../additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
// import '../blocs/favourite_cubit/favourite_cubit.dart';
// import '../search_screen/blocs/search_bloc/search_cubit.dart';
// import '../cars/data/models/cars_model.dart';
// import '../cars/presentaion/page/cars_monthly_info.dart';
//
// class CarMonthlyTile extends StatefulWidget {
//   final int index;
//   final cubit;
//   final FilterModel? filterModel;
//   final state;
//   final DataCars? datum;
//
//   const CarMonthlyTile({
//     Key? key,
//     required this.index,
//     this.cubit,
//     this.filterModel,
//     this.state,
//     this.datum,
//   }) : super(key: key);
//
//   @override
//   State<CarMonthlyTile> createState() => _CarMonthlyTileState();
// }
//
// class _CarMonthlyTileState extends State<CarMonthlyTile> {
//   bool? lookLike = true;
//   late bool isFavorite = false;
//
//   @override
//   void initState() {
//     print('object');
//     if (widget.filterModel == null && lookLike == true) {
//     } else {
//       // BlocProvider.of<AdditionsCubit>(context).getCarFeatures(context, widget.cubit.data[widget.index].id.toString());
//     }
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final locale = AppLocalizations.of(context);
//     Size size = MediaQuery.of(context).size;
//
//     final differenceInDays = context.read<SearchCubit>().differenceInDays;
//
//     num priceCarAfter;
//     final num priceCarBefore;
//     num finalPriceAfter = 0.0;
//     num finalPriceBefore = 0.0;
//
//     if (differenceInDays > 359) {
//       priceCarAfter = widget.cubit.data[widget.index].priceAfter12Month / 360;
//       priceCarBefore = widget.cubit.data[widget.index].price12Month / 360;
//       finalPriceBefore = priceCarBefore * differenceInDays;
//       finalPriceAfter = priceCarAfter * differenceInDays;
//     } else if (differenceInDays > 269) {
//       priceCarAfter = widget.cubit.data[widget.index].priceAfter9Month / 270;
//       finalPriceAfter = priceCarAfter * differenceInDays;
//       priceCarBefore = widget.cubit.data[widget.index].price9Month / 270;
//       finalPriceBefore = priceCarBefore * differenceInDays;
//     } else if (differenceInDays > 179) {
//       priceCarAfter = widget.cubit.data[widget.index].priceAfter6Month / 180;
//       finalPriceAfter = priceCarAfter * differenceInDays;
//       priceCarBefore = widget.cubit.data[widget.index].price6Month / 180;
//       finalPriceBefore = priceCarBefore * differenceInDays;
//     } else if (differenceInDays > 89) {
//       priceCarAfter = widget.cubit.data[widget.index].priceAfter3Month / 90;
//       finalPriceAfter = priceCarAfter * differenceInDays;
//       priceCarBefore = widget.cubit.data[widget.index].price3Month / 90;
//       finalPriceBefore = priceCarBefore * differenceInDays;
//     } else if (differenceInDays > 25) {
//       priceCarAfter = widget.cubit.data[widget.index].priceAfter1Month / 30;
//       finalPriceAfter = priceCarAfter * differenceInDays;
//       priceCarBefore = widget.cubit.data[widget.index].price1Month / 30;
//       finalPriceBefore = priceCarBefore * differenceInDays;
//     } else {
//       priceCarAfter = widget.cubit.data[widget.index].priceBefore;
//       finalPriceAfter = priceCarAfter * differenceInDays;
//     }
//
//     if (priceCarAfter == 0.0) {
//       finalPriceAfter =
//           widget.cubit.data[widget.index].priceBefore * differenceInDays;
//       priceCarAfter = widget.cubit.data[widget.index].priceBefore;
//     }
//
//     final carData = widget.cubit.data[widget.index];
//
//     return BlocConsumer<AdditionsCubit, AdditionsState>(
//       listener: (context, state) {
//         if (state is AdditionsLoading) {
//           Center(
//             child: Shimmer.fromColors(
//               baseColor: Colors.grey[300]!,
//               highlightColor: Colors.grey[100]!,
//               child: Container(
//                 width: 100.w,
//                 height: 100.h,
//                 color: Colors.white,
//               ),
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         return Bounce(
//           onTap: () {
//             PersistentNavBarNavigator.pushNewScreen(context,
//                 screen: CarsMonthlyInfo(
//                   datum: carData,
//                   filterModel: widget.filterModel,
//                 ));
//           },
//           child: Container(
//             margin: EdgeInsets.all(6.h),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15.r),
//               color: backgroundColor(context),
//               border: Border.all(color: strokeGrayColor(context), width: 2.w),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       padding: EdgeInsets.zero,
//                       constraints: BoxConstraints(),
//                       onPressed: () {
//                         BlocProvider.of<FavouriteCubit>(context)
//                             .addToFavourites(
//                           carData.id.toString(),
//                         );
//                         setState(() {
//                           isFavorite = !isFavorite;
//                         });
//                       },
//                       icon: Icon(
//                         Icons.favorite,
//                         color: isFavorite ? Colors.red : Color(0xff999999),
//                         size: 36.sp,
//                       ),
//                     ),
//                     carData.availableBranches.isEmpty
//                         ? Align(
//                       alignment: Alignment.topRight,
//                       child: Container(
//                         width: 100.w,
//                         height: 50.h,
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(12.r),
//                             bottomRight: Radius.circular(18.r),
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             locale!.isDirectionRTL(context)
//                                 ? "نفذت الكميه"
//                                 : "Out of Stock",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                         : Container(
//                       padding: EdgeInsets.all(8.w),
//                       height: size.height * 0.064,
//                       decoration: BoxDecoration(
//                         color: buttonPrimaryBgColor(context),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(12.r),
//                           bottomRight: Radius.circular(18.r),
//                         ),
//                       ),
//                       child: Center(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "${carData.priceAfter}",
//                               style: AppTypography.buttonText15(context),
//                             ),
//                             SizedBox(width: 4.w),
//                             SvgPicture.asset(
//                               Assets.icon_riyal,
//                               height: 15.sp,
//                               width: 14.sp,
//                               color: Colors.white,
//                             ),
//                             Text(
//                               locale!.isDirectionRTL(context) ? "/ يوم" : "/ Daily",
//                               style: AppTypography.buttonText15(context),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Center(
//                       child: CachedNetworkImage(
//                         imageUrl: carData.photo,
//                         fit: BoxFit.contain,
//                         width: 300.w,
//                         height: 180.h,
//                         errorWidget: (context, url, error) =>
//                             Lottie.asset("assets/anim/empty.json"),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(4.sp),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         flex: 7,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             AutoSizeText(
//                               _trimText(carData.name ?? ''),
//                               style: AppTypography.mainTypographyColor16(context),
//                             ),
//                             SizedBox(height: 5.h),
//                             AutoSizeText(
//                               locale.pricewithtax.toString(),
//                               style: AppTypography.mainTypographyColor16(context),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   "${carData.priceAfter} ",
//                                   style: AppTypography.mainTypographyColor16(context),
//                                 ),
//                                 Text(
//                                   "${carData.priceBefore} ",
//                                   style: TextStyle(
//                                     fontFamily: 'IBMPlexSansArabic',
//                                     color: mainTypographyColor(context),
//                                     fontSize: 14.sp,
//                                     decoration: TextDecoration.lineThrough,
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//                                 SvgPicture.asset(
//                                   Assets.icon_riyal,
//                                   height: 20.h,
//                                   width: 20.w,
//                                   color: mainTypographyColor(context),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(width: 8.w),
//                       Expanded(
//                         flex: 11,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: strokeGrayColor(context),
//                                       width: 1.5.w,
//                                     ),
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                   padding: EdgeInsets.all(3.sp),
//                                   child: ImageWithText(
//                                     imagePath: "assets/images/ftes.png",
//                                     text: "${carData.transmission}",
//                                     rtlText: "${carData.transmission}",
//                                   ),
//                                 ),
//                                 SizedBox(width: 6.w),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: strokeGrayColor(context),
//                                       width: 1.5.w,
//                                     ),
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                   padding: EdgeInsets.all(3.sp),
//                                   child: ImageWithText(
//                                     imagePath: "assets/images/seat.png",
//                                     text: "${carData.luggage} ",
//                                     rtlText: "${carData.luggage} ",
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 12.h),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 ADGradientButton(
//                                   locale.bookNow,
//                                   width: 90.w,
//                                   backgroundColor: iconDefaultColor(context),
//                                   textStyle: AppTypography.buttonText15(context),
//                                   height: 40.h,
//                                 ),
//                                 SizedBox(width: 8.w),
//                                 ADGradientButton(
//                                   locale.moredetails,
//                                   width: 90.w,
//                                   height: 40.h,
//                                   backgroundColor: Colors.transparent,
//                                   textStyle: AppTypography.headingColor12(context),
//                                   border: Border.all(
//                                     width: 2.w,
//                                     color: iconDefaultColor(context),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget verticalDivider(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 1.w),
//       child: Container(
//         height: 14.h,
//         width: 0.5.w,
//         color: Theme.of(context).brightness == Brightness.light
//             ? Colors.white
//             : Colors.black,
//       ),
//     );
//   }
// }
//
// class ImageWithText extends StatelessWidget {
//   final String imagePath;
//   final String text;
//   final String rtlText;
//
//   const ImageWithText({
//     Key? key,
//     required this.imagePath,
//     required this.text,
//     required this.rtlText,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final locale = AppLocalizations.of(context);
//
//     bool isRTL = locale!.isDirectionRTL(context);
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 6.h),
//       child: Row(
//         children: [
//           Image.asset(
//             imagePath,
//             color: mainTypographyColor(context),
//             width: 20.w,
//             height: 24.h,
//             fit: BoxFit.contain,
//           ),
//           SizedBox(width: 2.w),
//           Text(
//             isRTL ? rtlText : text,
//             style: AppTypography.paragraphColor12(context),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// String _trimText(String text) {
//   if (text.length <= 25) return text.toUpperCase();
//   return "${text.substring(0, 10).toUpperCase()}...";
// }
