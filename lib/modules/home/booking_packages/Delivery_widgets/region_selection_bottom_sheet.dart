import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/style/style.dart';
import '../../../../language/locale.dart';
import '../../search_screen/data/models/regions_model.dart';

class RegionSelectionBottomSheet extends StatefulWidget {
  final List<RegionModel> regions;
  final String? selectedRegionName;
  final Function(RegionModel) onRegionSelected;
  final AppLocalizations? locale;

  const RegionSelectionBottomSheet({
    Key? key,
    required this.regions,
    required this.onRegionSelected,
    required this.locale,
    this.selectedRegionName,
  }) : super(key: key);

  @override
  State<RegionSelectionBottomSheet> createState() =>
      _RegionSelectionBottomSheetState();
}

class _RegionSelectionBottomSheetState
    extends State<RegionSelectionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final isRTL = widget.locale?.isDirectionRTL(context) ?? false;

    final regionsWithPolygon = widget.regions
        .where((r) => r.polygon != null && r.polygon!.isNotEmpty)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: backgroundColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: strokeGrayColor(context),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isRTL ? "اختر المنطقة" : "Choose Region",
                    style: AppTypography.headingColor18(context),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close,
                      color: iconGrayColor(context), size: 25.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: regionsWithPolygon.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 64.w, color: strokeGrayColor(context)),
                  SizedBox(height: 16.h),
                  Text(
                    isRTL ? "لا توجد مناطق" : "No regions found",
                    style: AppTypography.paragraphColor14(context),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 8.h),
              itemCount: regionsWithPolygon.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final region = regionsWithPolygon[index];
                final isSelected =
                    widget.selectedRegionName == region.city;

                return InkWell(
                  onTap: () {
                    widget.onRegionSelected(region);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? mainTypographyColor(context).withOpacity(0.1)
                          : backgroundColor(context),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? mainTypographyColor(context)
                            : strokeGrayColor(context),
                        width: isSelected ? 2.w : 1.5.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                region.city ??
                                    (isRTL
                                        ? "منطقة غير محددة"
                                        : "Unknown region"),
                                style:
                                AppTypography.headingColor14(context),
                              ),
                              if (region.name != null) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  region.name!,
                                  style: AppTypography.paragraphColor12(
                                      context),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color:
                            Theme.of(context).colorScheme.primary,
                            size: 24.w,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}