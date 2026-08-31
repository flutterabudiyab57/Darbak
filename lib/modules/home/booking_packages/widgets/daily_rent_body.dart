import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_state.dart';
import 'package:darbak/modules/home/search_screen/presentaion/widget/region_tile.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../core/style/style.dart';
import '../../../widgets/Dashed_divider.dart';
import '../../../widgets/show_error_dailog.dart';
import '../../../widgets/time_select.dart';
import '../../all_branching/bloc/all_branching_cubit.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../search_screen/presentaion/widget/map_list_selection_view_tile.dart';
import '../../search_screen/presentaion/widget/rental_summary_card.dart';

class DailyRentBody extends StatefulWidget {
  const DailyRentBody({super.key});

  @override
  State<DailyRentBody> createState() => _DailyRentBodyState();
}

class _DailyRentBodyState extends State<DailyRentBody> {
  late bool searchError = false;
  bool _switchValue = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AllBranchCubit>(context).getAllBranch();
    _getRegions();
  }

  Future<void> _getRegions() async {
    await BlocProvider.of<SearchCubit>(context).getRegions();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final receiveDate =
            BlocProvider.of<SearchCubit>(context).receiveDateValue;
        final driveDate = BlocProvider.of<SearchCubit>(context).driveDateValue;

        print("Received: " + receiveDate.toString());
        print("Derive: " + driveDate.toString());
        context.read<SearchCubit>().updateDates(receiveDate, driveDate);
        final differenceInDays = context.read<SearchCubit>().differenceInDays;

        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: backgroundColor(context),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        locale!.choseBranch.toString(),
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: headingColor(context),
                          fontFamily: "ThmanyahSans",
                        ),
                      ),
                      Text(
                        locale.chargedDailyPrice,
                        style: AppTypography.paragraphColor18(context),
                      ),


                    ],
                  ),

                  SizedBox(height: 12.h,),
                  GestureDetector(
                    onTap: () {},
                    child: RegionTile(
                        regions:
                            BlocProvider.of<SearchCubit>(context).regionsData),
                  ),
                  SizedBox(height: 15.h),
                  BlocProvider.of<SearchCubit>(context).branchesData.isNotEmpty
                      ? MapListSelectionViewTile(
                          branches: context.read<SearchCubit>().branchesData,
                          areas: context.read<SearchCubit>().areasData,
                          isAutomated: false,
                          isReceive: true)
                      : SizedBox.shrink(),
                  SizedBox(height: 10.h),
                  _switchValue
                      ? MapListSelectionViewTile(
                          isAutomated: false,
                          branches: context.read<AllBranchCubit>().branchesData,
                          areas: context.read<SearchCubit>().areasData,
                          isReceive: false)
                      : SizedBox(),
                  _switchValue ? SizedBox(height: 8.h) : SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.5.w),
                      borderRadius: BorderRadius.circular(12.sp),
                      color: backgroundColor(context),

                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (BlocProvider.of<SearchCubit>(context)
                            .branchesData
                            .isNotEmpty)
                          Center(
                              child: Icon(
                            Icons.gps_fixed_sharp,
                            size: 18.sp,
                                color: mainTypographyColor(context),

                              )),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: BlocProvider.of<SearchCubit>(context)
                                  .branchesData
                                  .isNotEmpty
                              ? AutoSizeText(
                                  locale.deliverAnotherBranch.toString(),
                                  style:AppTypography.paragraphColor14(context),
                                )
                              : Container(),
                        ),
                        BlocProvider.of<SearchCubit>(context)
                                .branchesData
                                .isNotEmpty
                            ? SizedBox(
                                width: 64.w,
                                child: FittedBox(
                                  child: Switch.adaptive(
                                    activeColor:iconDefaultColor(context),
                                    inactiveTrackColor: Colors.grey,
                                    value: _switchValue,
                                    onChanged: (value) => setState(() {
                                      _switchValue = value;
                                    }),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),
                  const TimeSelectTwoBox(),
                  SizedBox(height: 14.h,),
                  Center(child: RentalSummaryCard(differenceInDays: differenceInDays,)),
                  SizedBox(height: 20.h),
                  dashedDivider(context),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () async {
                      if (isLoading) return;
                      setState(() {
                        isLoading = true;
                      });
                      await onTap(context);
                      setState(() {
                        isLoading = false;
                      });

                      if (searchError) {
                        showErrorAlertDialog(
                          context,
                          locale.selectRegionAndBranch,
                        );

                      }
                    },
                    child: isLoading
                        ? Center(
                        child: LoadingIndicator()
                          )
                        : ADGradientButton(locale.search),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  onTap(BuildContext context) async {
    try {
      print(BlocProvider.of<SearchCubit>(context).receiveTimeValue.toString() +
          "GGGF");
      print(BlocProvider.of<SearchCubit>(context).receiveDateValue.toString() +
          "GGG");
      print(BlocProvider.of<SearchCubit>(context).driveDateValue.toString() +
          "HHH");
      print(BlocProvider.of<SearchCubit>(context).selectedRegion.toString() +
          "GGG");
      print(
          BlocProvider.of<SearchCubit>(context).selectedDriveBranch.toString() +
              "fff");
      print(BlocProvider.of<SearchCubit>(context)
              .selectedReceiveModel!
              .id
              .toString() +
          "   ddddd");

      if (BlocProvider.of<ProfileCubit>(context).custClass == '1'.toString()) {
        setState(() {
          searchError = false;
        });
      }

      if (BlocProvider.of<SearchCubit>(context).selectedRegion == null ||
          BlocProvider.of<SearchCubit>(context).selectedReceiveBranch == null) {
        setState(() {
          searchError = true;
        });
      } else {
        setState(() {
          searchError = false;
        });
      }
      final triggeredBranchModel = context
          .read<SearchCubit>()
          .branchesData
          .where((element) =>
              element.name ==
              BlocProvider.of<SearchCubit>(context).selectedReceiveBranch)
          .first;
      BlocProvider.of<SearchCubit>(context).selectedReceiveModel =
          triggeredBranchModel;

      // drive
      if (BlocProvider.of<SearchCubit>(context).selectedDriveBranch != null) {
        final triggeredDriveBranchModel = context
            .read<AllBranchCubit>()
            .branchesData
            .where((element) =>
                element.name ==
                BlocProvider.of<SearchCubit>(context).selectedDriveBranch)
            .first;

        BlocProvider.of<SearchCubit>(context).selectedDriveModel =
            triggeredDriveBranchModel;
      } else {
        BlocProvider.of<SearchCubit>(context).selectedDriveModel =
            triggeredBranchModel;
        print(
            "rent driv1: ${BlocProvider.of<SearchCubit>(context).selectedDriveBranch}");
      }
      print(
          "rent driv2: ${BlocProvider.of<SearchCubit>(context).selectedDriveBranch}");
      // Validation
      await BlocProvider.of<SearchCubit>(context).validate();
    } catch (e) {
      print("validation Error: ${e.toString()} ");

      setState(() {
        searchError = true;
      });
    }
  }
}
