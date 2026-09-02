import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/core/helpers/enums.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/data/models/regions_model.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/assets/app_colors.dart';

class RegionTile extends StatelessWidget {
  final List<RegionModel>? regions;
  final Function(RegionModel)? onRegionSelected;

  const RegionTile({
    Key? key,
    required this.regions,
    this.onRegionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        customDialog(context,
            regionModel: regions!.toList(), receive: true);
      },
      child: Container(
        height: 55.h,
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          border: Border.all(color: strokeGrayColor(context), width: 2.w),
          borderRadius: BorderRadius.circular(15.r),
          color: backgroundColor(context),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.03,
          ),
          child: Row(
            children: [
              Image.asset(
                Assets.img_map_region,
                color: mainTypographyColor(context),
                width: 35.w,
                height: 35.h,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  BlocProvider.of<SearchCubit>(context).selectedRegion ??
                      locale!.selectRegion.toString(),
                  style: AppTypography.paragraphColor18(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                color: mainTypographyColor(context),
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> customDialog(BuildContext context,
      {required List<RegionModel> regionModel, required bool receive}) {
    final locale = AppLocalizations.of(context);
    int? selectedIndex;

    return showModalBottomSheet(
      useRootNavigator: true,
      backgroundColor: backgroundColor(context),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10.h),
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: strokeGrayColor(sheetContext),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              locale!.selectRegion.toString(),
                              style:
                              AppTypography.headingColor18(sheetContext),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(sheetContext),
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: bg2Color(sheetContext),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Icon(Icons.close,
                                size: 20.sp,
                                color: headingColor(sheetContext)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1.55,
                      ),
                      itemCount: regionModel.length,
                      itemBuilder: (context, index) {
                        final region = regionModel[index];
                        final isSelected = selectedIndex == index;
                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedIndex = index),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 15.h),
                            decoration: BoxDecoration(
                              color: bg2Color(context),
                              borderRadius: BorderRadius.circular(16.r),
                              border: isSelected
                                  ? Border.all(
                                  color: buttonPrimaryBgColor(context),
                                  width: 2.w)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 29.w,
                                  height: 30.h,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: buttonPrimaryBgColor(context),
                                    borderRadius:
                                    BorderRadius.circular(5.r),
                                  ),
                                  child: SvgPicture.asset(
                                    Assets.icon_areaLocation,
                                    width: 18.w,
                                    height: 18.h,
                                    colorFilter: ColorFilter.mode(
                                        backgroundColor(context),
                                        BlendMode.srcIn),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  region.name ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                  AppTypography.headingColor16(context),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: GestureDetector(
                      onTap: selectedIndex == null
                          ? null
                          : () {
                        final selectedRegion =
                        regionModel[selectedIndex!];

                        BlocProvider.of<SearchCubit>(context)
                            .selectedRegion = selectedRegion.name;

                        final selectedRegionModel =
                            BlocProvider.of<SearchCubit>(context)
                                .regionsData
                                ?.where((element) =>
                            element.name ==
                                BlocProvider.of<SearchCubit>(context)
                                    .selectedRegion)
                                .first;

                        BlocProvider.of<SearchCubit>(context).rentType ==
                            RentType.classic
                            ? BlocProvider.of<SearchCubit>(context)
                            .getBranches(
                            regionId: selectedRegionModel!.id ?? 0)
                            : BlocProvider.of<SearchCubit>(context)
                            .getAreas(
                            regionId: selectedRegionModel?.id);

                        onRegionSelected?.call(selectedRegion);
                        Navigator.pop(sheetContext);
                      },
                      child: Opacity(
                        opacity: selectedIndex == null ? 0.5 : 1,
                        child: Container(
                          width: double.infinity,
                          height: 52.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: buttonGradient,
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          child: Text(
                            locale.confirm,
                            style: AppTypography.buttonText18(sheetContext)
                                .copyWith(color: backgroundColor(sheetContext)),
                          ),
                        ),
                      ),
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
