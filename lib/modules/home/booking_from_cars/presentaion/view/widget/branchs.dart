import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/location/data/models/branch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../../core/constants/assets/assets.dart';

/// The car flow's single branch-selection row (T054-T055). Reads no cubit —
/// the current pick and the tap callback both arrive as constructor
/// parameters from `BranchWithCarScreen`, which owns the
/// `LocationSelectionCubit` and decides what tapping does (opening
/// `BranchPickerScreen` on the root navigator, per
/// contracts/navigation-contract.md). This row itself stays on the normal
/// navigator, so it is not part of the picker surface Constitution
/// Principle II restricts.
///
/// Previously this file also held a `HeroDialogRoute` popup
/// (`_PopupCard`/`SelectionTile`) that looked branches up by matching
/// `Datum.text` against `SearchCubit.selectedReceiveBranch`/
/// `selectedDriveBranch` — a Principle I violation. That popup is gone;
/// `BranchPickerScreen` replaces it and selection now flows by `Branch.id`.
class BranchTile extends StatelessWidget {
  final Branch? branch;
  final VoidCallback onTap;

  const BranchTile({Key? key, required this.branch, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        alignment: AlignmentDirectional.bottomStart,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: strokeGrayColor(context),
            width: 2.w,
          ),
          color: backgroundColor(context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  SvgPicture.asset(
                    Assets.icon_areaLocation,
                    width: 24.w,
                    color: iconDefaultColor(context),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      branch?.name ?? locale!.selectBranch.toString(),
                      style: AppTypography.paragraphColor16(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: iconDefaultColor(context),
              size: 40.sp,
            ),
          ],
        ),
      ),
    );
  }
}
