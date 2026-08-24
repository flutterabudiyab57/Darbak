import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/additions/data/models/step_one_order_model.dart' hide Icon;
import 'package:darbak/modules/home/additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/constants/assets/assets.dart';
import '../../../../widgets/Dashed_divider.dart';

class Services extends StatefulWidget {
  final List<Feature?>? features;
  final DataCars? datum;
  final bool isAutomated;

  const Services({
    Key? key,
    this.datum,
    this.isAutomated = false,
    this.features,
  }) : super(key: key);

  @override
  _ServicesState createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  int? selectedInsuranceIndex;
  Set<int> selectedAdditionsIndexes = {};

  @override
  void initState() {
    super.initState();
    for (int index = 0; index < widget.features!.length; index++) {
      BlocProvider.of<AdditionsCubit>(context)
          .removeAddition(context, widget.features![index]);
    }

    final insurance = insuranceFeatures;
    if (insurance.isNotEmpty) {
      selectedInsuranceIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BlocProvider.of<AdditionsCubit>(context)
            .addAddition(context, insurance[0]);
      });
    }
  }
  List<Feature?> get insuranceFeatures {
    return widget.features!.where((feature) {
      final title = feature?.title?.toLowerCase() ?? "";
      return title.contains("تأمين") ||
          title.contains("insurance") ||
          title.contains("درع") ||
          title.contains("shield") ||
          title.contains("أساسي") ||
          title.contains("basic") ||
          title.contains("شامل") ||
          title.contains("full");
    }).toList();
  }

  List<Feature?> get additionsFeatures {
    return widget.features!.where((feature) {
      final title = feature?.title?.toLowerCase() ?? "";
      return !(title.contains("تأمين") ||
          title.contains("insurance") ||
          title.contains("درع") ||
          title.contains("shield") ||
          title.contains("أساسي") ||
          title.contains("basic") ||
          title.contains("شامل") ||
          title.contains("full"));
    }).toList();
  }
  Widget buildInsuranceList(List<Feature?> insuranceList) {
    final locale = AppLocalizations.of(context)!;
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: insuranceList.length,
      itemBuilder: (BuildContext context, int index) {
        final feature = insuranceList[index];
        final title = feature?.title ?? "";
        final price = "${feature?.price}";
        final daily = feature?.daily == false
            ? ""
            : "/ ${locale.day.toString()} ";

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: InkWell(
            onTap: () async {
              final messages = {
                "Shield": {
                  "ar": "درع دربك:\n"
                      "تأمين شامل بدون دفع قسط التحمل.\n"
                      "دفع رسوم إضافية عن كل يوم.\n"
                      "يشمل تغطية الأضرار: الإطارات، الزجاج، الواجهة الأمامية (السافي).\n"
                      "تطبق الشروط والأحكام.",
                  "en": "Darbak Shield Insurance:\n"
                      "Full coverage with no deductible.\n"
                      "Extra daily charges apply.\n"
                      "Covers damages: tires, glass, and front body (safi).\n"
                      "Terms and conditions apply."
                },
                "full": {
                  "ar": "التأمين الشامل:\n"
                      "تأمين شامل بدون دفع قسط التحمل.\n"
                      "دفع رسوم إضافية عن كل يوم.\n"
                      "تطبق الشروط والأحكام.",
                  "en": "Full Insurance:\n"
                      "Full coverage with no deductible.\n"
                      "Extra daily charges apply.\n"
                      "Terms and conditions apply."
                },
                "Basic": {
                  "ar": "التأمين الأساسي:\n"
                      "تأمين شامل مع قسط تحمل.\n"
                      "تطبق الشروط والأحكام.",
                  "en": "Basic Insurance:\n"
                      "Full coverage with a deductible.\n"
                      "Terms and conditions apply."
                },
              };

              final String lang = Localizations.localeOf(context).languageCode;
              String? message = "";
              final currentTitle = title;

              if (currentTitle.contains("درع") || currentTitle.contains("Shield")) {
                message = messages["Shield"]?[lang];
              } else if (currentTitle.contains("شامل") || currentTitle.contains("full")) {
                message = messages["full"]?[lang];
              } else if (currentTitle.contains("أساسي") || currentTitle.contains("Basic")) {
                message = messages["Basic"]?[lang];
              } else {
                message = lang == "ar"
                    ? "هل تريد اختيار $currentTitle؟\nالسعر: $price ريال $daily"
                    : "Do you want to choose $currentTitle?\nPrice: $price SAR $daily";
              }

              final result = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    lang == "ar" ? "تأكيد الاختيار" : "Confirm Selection",
                    style: AppTypography.headingColor22(context),
                  ),
                  content: Text(
                    message ?? "",
                    style: AppTypography.mainTypographyColor18(context),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        lang == "ar" ? "إلغاء" : "Cancel",
                        style: AppTypography.headingColor18(context),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconDefaultColor(context),
                      ),
                      child: Text(
                        lang == "ar" ? "موافق" : "Confirm",
                        style: AppTypography.buttonText18(context),
                      ),
                    ),
                  ],
                ),
              );

              if (result == true) {
                setState(() {

                  if (selectedInsuranceIndex != index) {
                    if (selectedInsuranceIndex != null) {
                      BlocProvider.of<AdditionsCubit>(context)
                          .removeAddition(context, insuranceList[selectedInsuranceIndex!]);
                    }
                    selectedInsuranceIndex = index;
                    BlocProvider.of<AdditionsCubit>(context)
                        .addAddition(context, feature);
                  }
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: buttonWhiteColor(context),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: strokeGrayColor(context),
                  width: 2.w,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: Color(0xffE6EBEC),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        Assets.icon_insurance,
                        height: 25.h,
                        width: 25.w,
                        color: strokeMainColor(context),


                      ),
                    ),
                  ) ,
                  SizedBox(width: 8.w,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.mainTypographyColor14(context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            price,
                            style: AppTypography.paragraphColor14(context),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(width: 4.w),
                          SvgPicture.asset(
                            Assets.icon_riyal,
                            height: 10.h,
                            width: 9.w,
                            color: mainTypographyColor(context),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            daily,
                            style: AppTypography.paragraphColor14(context),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    width: 26.w,
                    height: 26.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.r),
                      border: Border.all(
                        width: 1.5.w,
                        color: selectedInsuranceIndex == index
                            ? iconDefaultColor(context)
                            : strokeGrayColor(context),
                      ),
                      color: selectedInsuranceIndex == index
                          ? iconDefaultColor(context)
                          : Colors.transparent,
                    ),
                    child: selectedInsuranceIndex == index
                        ? Icon(
                      Icons.check,
                      size: 18.sp,
                      color: Colors.white,
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildAdditionsList(List<Feature?> additionsList) {
    final locale = AppLocalizations.of(context)!;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: additionsList.length,
      itemBuilder: (BuildContext context, int index) {
        final feature = additionsList[index];
        final title = feature?.title ?? "";

        final price = "${feature?.price}";
        final daily = feature?.daily == false
            ? ""
            : "/${locale.day.toString()} ";

        return InkWell(
          onTap: () {
            setState(() {
              if (selectedAdditionsIndexes.contains(index)) {
                selectedAdditionsIndexes.remove(index);
                BlocProvider.of<AdditionsCubit>(context)
                    .removeAddition(context, feature);
              } else {
                selectedAdditionsIndexes.add(index);
                BlocProvider.of<AdditionsCubit>(context)
                    .addAddition(context, feature);
              }
            });
          },
          child:Container(
            decoration: BoxDecoration(
              color: buttonWhiteColor(context),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: strokeGrayColor(context),
                width: 2.w,
              ),
            ),
            margin: EdgeInsets.symmetric(vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                SvgPicture.asset(
                  Assets.icon_additions,
                  height: 35.h,
                  width: 35.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headingColor14(context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      SizedBox(height: 4.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            price,
                            style: AppTypography.paragraphColor12(context),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(width: 4.w),
                          SvgPicture.asset(
                            Assets.icon_riyal,
                            height: 10.h,
                            width: 9.w,
                            color: mainTypographyColor(context),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            daily,
                            style: AppTypography.paragraphColor12(context),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 26.w,
                  height: 26.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(
                      width: 1.5.w,
                      color: selectedAdditionsIndexes.contains(index)
                          ? iconDefaultColor(context)
                          : strokeGrayColor(context),
                    ),
                    color: selectedAdditionsIndexes.contains(index)
                        ? iconDefaultColor(context)
                        : Colors.transparent,
                  ),
                  child: selectedAdditionsIndexes.contains(index)
                      ? Icon(
                    Icons.check,
                    size: 18.sp,
                    color: Colors.white,
                  )
                      : null,
                )                ],
            ),
          )
          ,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    final insurance = insuranceFeatures;
    final additions = additionsFeatures;

    return SingleChildScrollView(
      padding: EdgeInsets.all(10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Insurance Section
          if (insurance.isNotEmpty)
            Container(
              decoration: ShapeDecoration(
                color: buttonWhiteColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    width: 1.5.w,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: strokeGrayColor(context),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          locale.insurance,
                          style:AppTypography.mainTypographyColor20(context)
                        ),
                      ),
                    ],
                  ),
                  buildInsuranceList(insurance),
                ],
              ),
            ),

          if (insurance.isNotEmpty && additions.isNotEmpty)
            SizedBox(height: 12.h),
          dashedDivider(context),
          SizedBox(height: 8.h),

          if (additions.isNotEmpty)
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
    color: buttonWhiteColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    width: 1.5.w,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: strokeGrayColor(context),
                  ),

                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0),
                          child: Text(
                            locale.additions!,
                            style: TextStyle(
                              fontFamily: "ThmanyahSans",
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: mainTypographyColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    buildAdditionsList(additions),

                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),

          if (widget.features!.isEmpty)
            Container(
              color: Theme.of(context).colorScheme.onSecondary,
              alignment: Alignment.center,
              child: Text(
                "No Features",
                style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 34.sp,
                    fontFamily: "ThmanyahSans",
                    letterSpacing: 1.5),
              ),
            ),
        ],
      ),
    );
  }
}