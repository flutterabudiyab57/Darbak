import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/constants/assets/assets.dart';
import '../../../../core/style/style.dart';
import '../../../../language/locale.dart';
import '../../all_branching/data/models/branch_model.dart';

class BranchSelectionBottomSheet extends StatefulWidget {
  final List<BranchModel> branches;
  final String? selectedBranchName;
  final Function(BranchModel) onBranchSelected;
  final AppLocalizations? locale;

  const BranchSelectionBottomSheet({
    Key? key,
    required this.branches,
    required this.onBranchSelected,
    required this.locale,
    this.selectedBranchName,
  }) : super(key: key);

  @override
  State<BranchSelectionBottomSheet> createState() =>
      _BranchSelectionBottomSheetState();
}

class _BranchSelectionBottomSheetState
    extends State<BranchSelectionBottomSheet> {
  late List<BranchModel> _filteredBranches;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredBranches = List.from(widget.branches);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.locale?.isDirectionRTL(context) ?? false;

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
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isRTL ? "اختر فرع التوصيل" : "Choose Delivery Branch",
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
            child: _filteredBranches.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 64.w, color: strokeGrayColor(context)),
                  SizedBox(height: 16.h),
                  Text(
                    isRTL ? "لا توجد نتائج" : "No results found",
                    style: AppTypography.paragraphColor14(context),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: _filteredBranches.length,
              separatorBuilder: (_, __) => SizedBox(height: 20.h),
              itemBuilder: (context, index) {
                final branch = _filteredBranches[index];
                final isSelected =
                    widget.selectedBranchName == branch.name;

                return InkWell(
                  onTap: () {
                    widget.onBranchSelected(branch);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? mainTypographyColor(context).withValues(alpha: 0.1)
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
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch.name ??
                                    (isRTL
                                        ? "فرع غير محدد"
                                        : "Unknown branch"),
                                style: AppTypography.headingColor14(
                                    context),
                              ),
                              if (branch.phone != null) ...[
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(Icons.phone_outlined,
                                        size: 14.w,
                                        color:
                                        iconDefaultColor(context)),
                                    SizedBox(width: 4.w),
                                    Text(
                                      branch.phone!,
                                      style: AppTypography
                                          .paragraphColor12(context),
                                    ),
                                  ],
                                ),
                              ],
                              if (branch.deliveryPrice != null) ...[
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                        Icons.local_shipping_outlined,
                                        size: 14.w,
                                        color:
                                        iconDefaultColor(context)),
                                    SizedBox(width: 4.w),
                                    Text(
                                      isRTL
                                          ? "رسوم تسليم+استلام= ${branch.deliveryPrice}"
                                          : "Delivery + Receipt Fees = ${branch.deliveryPrice}",
                                      style: AppTypography
                                          .paragraphColor14(context),
                                    ),
                                    SizedBox(width: 4.w),
                                    SvgPicture.asset(
                                      Assets.icon_riyal,
                                      width: 12.w,
                                      color: paragraphColor(context),
                                    ),
                                  ],
                                ),
                              ],

                              // ✅ بادج يوضح إن الفرع عنده منطقة توصيل محددة
                              if (branch.polygon != null &&
                                  branch.polygon!.isNotEmpty) ...[
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.map_outlined,
                                      size: 13.w,
                                      color: iconDefaultColor(context),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      isRTL
                                          ? "منطقة توصيل محددة"
                                          : "Defined delivery zone",
                                      style: TextStyle(
                                        fontFamily: 'ThmanyahSans',
                                        fontSize: 11.sp,
                                        color:
                                        iconDefaultColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
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