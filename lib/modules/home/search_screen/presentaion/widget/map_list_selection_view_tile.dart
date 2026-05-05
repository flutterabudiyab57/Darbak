import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/data/models/areas_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/style/style.dart';
import '../map_list_view.dart';

class MapListSelectionViewTile extends StatelessWidget {
  final List<BranchModel>? branches;
  final List<AreasModel>? areas;
  final bool isReceive;
  final bool isAutomated;
  final bool isDisabled;

  const MapListSelectionViewTile({
    Key? key,
    required this.branches,
    required this.isReceive,
    required this.areas,
    required this.isAutomated,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: isDisabled
          ? () {}
          : () {
        if (isAutomated || branches != null) {
          PersistentNavBarNavigator.pushNewScreen(context,
              screen: MapListView(
                isAutomated: isAutomated,
                areas: areas,
                branches: branches,
                isReceive: isReceive,
              ),
              withNavBar: false);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.03),
        height: 45.h,
        decoration: BoxDecoration(
          border: Border.all(color: strokeGrayColor(context), width: 2.w),
          borderRadius: BorderRadius.circular(15.r),
          color: backgroundColor(context),

        ),
        child: Row(
          children: [
            isReceive
                ? Center(
              child: SvgPicture.asset(
                Assets.icon_picker,
                width: 24.w,
                color: mainTypographyColor(context),
              ),
            )
                : SvgPicture.asset(
              Assets.img_recive_branch,
              height: 24.h,
              width: 24.w,
              color: mainTypographyColor(context),

            ),
            SizedBox(
              width: 12.w,
            ),
            Expanded(
              child: Text(
                isAutomated
                    ? isReceive
                    ? BlocProvider.of<SearchCubit>(context)
                    .selectedReceiveArea ??
                    locale.pickUpArea.toString()
                    : BlocProvider.of<SearchCubit>(context)
                    .selectedDriveArea ??
                    locale.dropOffArea.toString()
                    : isReceive
                    ? BlocProvider.of<SearchCubit>(context)
                    .selectedReceiveBranch ??
                    locale.choseBranch.toString()
                    : BlocProvider.of<SearchCubit>(context)
                    .selectedDriveBranch ??
                    locale.dropOffBranch.toString(),
                style: AppTypography.paragraphColor14(context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_outlined,
              color: mainTypographyColor(context),
              size: 16.sp,
            ),
          ],
        ),      ),
    );
  }
}
