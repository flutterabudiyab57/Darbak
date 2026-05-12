import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/cars/presentaion/bloc/filter_cubit/filter_cubit.dart';
import 'package:darbak/modules/widgets/components/ad_colored_text_button.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../../core/constants/assets/assets.dart';
import '../../../../../service_locator.dart';
import '../../../../widgets/Dashed_divider.dart';
import '../../../../widgets/components/appbar.dart';
import '../all_cars_screen.dart';

class FiltersCars extends StatefulWidget {
  const FiltersCars({Key? key}) : super(key: key);

  static Widget entry() => BlocProvider<FilterCubit>(
        create: (_) => sl<FilterCubit>(),
        child: const FiltersCars(),
      );

  @override
  State<FiltersCars> createState() => _FiltersCarsState();
}

class _FiltersCarsState extends State<FiltersCars>
    with SingleTickerProviderStateMixin {
  late TabController tabControler;
  RangeValues _currentRangeValues = const RangeValues(40, 80);

  List<String> years = [
    "2026",
    "2025",
    "2024",
    "2023",
    "2022",
    "2021",
  ];

  List<String> colors = [
    "احمر",
    "اصفر",
    "أزرق",
    "أبيض",
    "أسود",
    "رمادي",
  ];

  String? selectedColor;

  @override
  void initState() {
    tabControler = TabController(length: 3, vsync: this);
    geData();
    super.initState();
  }

  geData() async => await sl<FilterCubit>().getData();

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: CustomAppBar(
        title: locale!.filterCars.toString(),
        showBackButton: true,
        // showThemeToggle: true,
      ),
      body: BlocConsumer<FilterCubit, FilterState>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = context.read<FilterCubit>();

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Column(
                spacing: 13.h,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        locale.isDirectionRTL(context)
                            ? "فئة السيارة"
                            : "Vehicle class",
                        style: AppTypography.headingColor20(context),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 42.h,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: Directionality.of(context) == TextDirection.rtl,
                      child: Row(
                        children: (state is FilterSuccess)
                            ? state.categoryModel.data.map((category) {
                                return ADColoredTextButton(
                                  text: category.name ?? "",
                                  isSelected: cubit.categories
                                      .contains(category.id.toString()),
                                  onTap: () {
                                    setState(() {
                                      cubit.categoriesAddingHandler(
                                          category.id.toString());
                                    });
                                  },
                                );
                              }).toList()
                            : [],
                      ),
                    ),
                  ),
                  dashedDivider(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locale.price,
                        style: AppTypography.headingColor20(context),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 10.h,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 12.r,
                      ),
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: 12.r,
                      ),
                      valueIndicatorTextStyle: AppTypography.buttonWhite16(context),
                    ),
                    child: RangeSlider(
                      inactiveColor: Color(0xFF87AEB5),
                      values: _currentRangeValues,
                      max: 10000,
                      activeColor: iconDefaultColor(context),
                      divisions: 200,
                      labels: RangeLabels(
                        '${_currentRangeValues.start.round()}',
                        '${_currentRangeValues.end.round()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _currentRangeValues = values;
                          cubit.minPrice = values.start.toInt();
                          cubit.maxPrice = values.end.toInt();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50.h,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.w),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 2.w,
                                color: strokeGrayColor(context),
                              ),
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5.w),
                              Text(
                                "${cubit.maxPrice}",
                                style: AppTypography.paragraphColor20(context),
                              ),
                              SizedBox(width: 4.w),
                              SvgPicture.asset(
                                Assets.icon_riyal,
                                height: 20.h,
                                width: 20.w,
                                colorFilter: ColorFilter.mode(
                                    paragraphColor(context), BlendMode.srcIn),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Container(
                          height: 50.h,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.w),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 2.w,
                                color: strokeGrayColor(context),
                              ),
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${cubit.minPrice}",
                                style: AppTypography.paragraphColor20(context),
                              ),
                              SizedBox(width: 4.w),
                              SvgPicture.asset(
                                Assets.icon_riyal,
                                height: 20.h,
                                width: 20.w,
                                colorFilter: ColorFilter.mode(
                                    paragraphColor(context), BlendMode.srcIn),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  dashedDivider(context),
                  Row(
                    children: [
                      Text(
                        locale.brand.toString(),
                        style: AppTypography.headingColor20(context),
                      ),
                    ],
                  ),
                  SizedBox(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        children: (state is FilterSuccess)
                            ? state.manufactoriesModel.data!.map((brand) {
                                final isSelected =
                                    cubit.brands.contains(brand.id.toString());

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      cubit.brandsAddingHandler(
                                          brand.id.toString());
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 7.w),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8.h, horizontal: 6.w),
                                        decoration: BoxDecoration(
                                          color: buttonWhiteColor(context),
                                          border: isSelected
                                              ? Border.all(
                                                  color:
                                                      strokeMainColor(context),
                                                  width: 1.5.w,
                                                )
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.network(
                                              brand.icon ?? '',
                                              height: 60.h,
                                              width: 50.w,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(
                                                Icons.directions_car,
                                                size: 30.h,
                                              ),
                                            ),
                                            SizedBox(height: 6.h),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        brand.name ?? '',
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: isSelected
                                            ? AppTypography.mainTypographyColor14(context)
                                            : AppTypography.paragraphColor14(context),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList()
                            : [],
                      ),
                    ),
                  ),
                  dashedDivider(context),
                  Row(
                    children: [
                      Text(
                        locale.selectModel,
                        style: AppTypography.headingColor20(context),
                      ),
                    ],
                  ),
                  SizedBox(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        children: years.map((year) {
                          final isSelected = cubit.modelYear.contains(year);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                cubit.modelAddingHandler(year, context);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 7.w),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.h, horizontal: 12.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? strokeMainColor(context)
                                    : buttonWhiteColor(context),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Text(
                                  year,
                                  style: isSelected
                                      ? AppTypography.buttonText16(context)
                                      : AppTypography.paragraphColor16(context),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  dashedDivider(context),
                  SizedBox(height: 24.h),
                  GestureDetector(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(context,
                        screen: AllCarsScreen.entry(fromFilter: true),
                      );
                    },
                    child: ADGradientButton(locale.search),
                  ),
                  SizedBox(height: size.height * 0.12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// Row(
//   children: [
//     AutoSizeText(
//       locale.isDirectionRTL(context)
//           ? "لون السيارة"
//           : "Car Color",
//       style: AppTypography.headingColor20(context),
//     ),
//   ],
// ),
// SizedBox(
//   child: SingleChildScrollView(
//     scrollDirection: Axis.horizontal,
//     reverse: true,
//     child: Row(
//       children: colors.map((color) {
//         final isSelected = selectedColor == color;
//
//         return GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedColor = isSelected ? null : color;
//             });
//           },
//           child: Container(
//             margin: EdgeInsets.only(left: 7.w),
//             padding: EdgeInsets.symmetric(
//                 vertical: 8.h, horizontal: 12.w),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: isSelected
//                   ? Border.all(
//                       color: strokeMainColor(context),
//                       width: 1.5.w,
//                     )
//                   : null,
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: Center(
//               child: Text(
//                 color,
//                 style: isSelected
//                     ? AppTypography.mainTypographyColor14(
//                         context)
//                     : AppTypography.paragraphColor14(context),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     ),
//   ),
// ),
