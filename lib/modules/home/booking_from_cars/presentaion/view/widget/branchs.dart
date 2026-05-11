import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/booking_from_cars/model/branch_from_cars_model.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/widgets/components/custom_rect_tween.dart';
import 'package:darbak/modules/widgets/components/hero_dialog_route.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../../core/constants/assets/assets.dart';
import '../../../../../widgets/Dashed_divider.dart';

class BranchTile extends StatefulWidget {
  final List<Datum>? regions;
  final bool isRecieve;

  const BranchTile({Key? key, required this.regions, required this.isRecieve})
      : super(key: key);

  @override
  State<BranchTile> createState() => _BranchTileState();
}

class _BranchTileState extends State<BranchTile> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return _PopupCard(
            branches: widget.regions,
            isRecieve: widget.isRecieve,
            onChanged: (v) {
              setState(() {});
            },
          );
        }));
      },
      child: Hero(
        tag: widget.isRecieve.toString() + _heroTag,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin!, end: end!);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical:  8.h,horizontal: 10.w),
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
                        widget.isRecieve
                            ? BlocProvider.of<SearchCubit>(context)
                                    .selectedReceiveBranch ??
                                locale!.selectBranch.toString()
                            : BlocProvider.of<SearchCubit>(context)
                                    .selectedDriveBranch ??
                                locale!.selectBranch.toString(),
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
      ),
    );
  }
}

const String _heroTag = 'branceTag';

class _PopupCard extends StatefulWidget {
  final List<Datum>? branches;
  final bool isRecieve;
  final ValueChanged<void> onChanged;

  const _PopupCard(
      {Key? key,
      required this.branches,
      required this.isRecieve,
      required this.onChanged})
      : super(key: key);

  @override
  State<_PopupCard> createState() => _PopupCardState();
}

class _PopupCardState extends State<_PopupCard> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Hero(
          tag: widget.isRecieve.toString() + _heroTag,
          createRectTween: (begin, end) =>
              CustomRectTween(begin: begin!, end: end!),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: widget.branches!.isEmpty
                  ? Center(
                      child: Text(locale!.carNotAvailable!,
                          style: AppTypography.mainTypographyColor18(context)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.branches!.length,
                      itemBuilder: (context, index) {
                        final branch = widget.branches![index];
                        return SelectionTile(
                          text: branch.text,
                          availableCount: branch.availableCount, // ← أضف هذا
                          onTap: () {
                            if (widget.isRecieve) {
                              BlocProvider.of<SearchCubit>(context)
                                  .selectedReceiveBranch = branch.text;
                            } else {
                              BlocProvider.of<SearchCubit>(context)
                                  .selectedDriveBranch = branch.text;
                            }
                            widget.onChanged(true);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectionTile extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final int? availableCount; // ← أضف هذا

  const SelectionTile({
    Key? key,
    required this.onTap,
    required this.text,
    this.availableCount, // ← أضف هذا
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Bounce(
        onTap: onTap,
        child: Column(
          children: [
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          style: AppTypography.paragraphColor14(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (availableCount != null) ...[
                        SizedBox(height: 4.h),
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 4.h),
                            child: Text(
                                AppLocalizations.of(context)!
                                    .isDirectionRTL(context)
                                    ? 'العدد المتاح: $availableCount'
                                    : 'Available count: $availableCount',
                                style: AppTypography.mainTypographyColor14(context)),
                          ),
                        ),
                      ],

                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: dashedDivider(context),
            ),
          ],
        ),
      ),
    );
  }
}
