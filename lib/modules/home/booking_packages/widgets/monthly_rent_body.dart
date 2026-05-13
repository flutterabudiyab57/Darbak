import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_state.dart';
import 'package:darbak/modules/home/search_screen/presentaion/widget/region_tile.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
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
import '../../search_screen/presentaion/widget/monthly_package_widget.dart';
import '../../search_screen/presentaion/widget/rental_summary_card.dart';

class MonthlyRentBody extends StatefulWidget {
  const MonthlyRentBody({super.key});

  @override
  State<MonthlyRentBody> createState() => _MonthlyRentBodyState();
}

class _MonthlyRentBodyState extends State<MonthlyRentBody> {
  late bool searchError = false;
  bool isLoading = false;
  int? selectedMonths;

  void _onPackageSelected(int months) {
    final today = DateTime.now().toLocal().add(const Duration(hours: 2));
    final endDate = today.add(Duration(days: months * 30));

    setState(() {
      selectedMonths = months;
    });

    final cubit = BlocProvider.of<SearchCubit>(context);
    cubit.receiveDateValue = today;
    cubit.driveDateValue = endDate;
    cubit.updateDates(today, endDate);
    cubit.changeState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final List<String> monthsRanges = [
      "1 ${locale!.month}",
      "3 ${locale.months}",
      "6 ${locale.months}",
      "9 ${locale.months}",
      "12 ${locale.months}",
    ];
    final List<int> monthsOptions = [1, 3, 6, 9, 12];

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final cubit = BlocProvider.of<SearchCubit>(context);
        final receiveDate = cubit.receiveDateValue;
        final driveDate = cubit.driveDateValue;

        if (receiveDate != null && driveDate != null) {
          cubit.updateDates(receiveDate, driveDate);
        }
        final differenceInDays = cubit.differenceInDays;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.chooseMonthlyPackage,
                  style: AppTypography.headingColor22(context),
                ),
                SizedBox(height: 4.h),
                Text(
                  locale.chargedMonthlyPrice,
                  style: AppTypography.paragraphColor18(context),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () {},
                  child: RegionTile(regions: cubit.regionsData),
                ),
                SizedBox(height: 12.h),
                cubit.branchesData.isNotEmpty
                    ? MapListSelectionViewTile(
                  branches: cubit.branchesData,
                  areas: cubit.areasData,
                  isAutomated: false,
                  isReceive: true,
                )
                    : const SizedBox.shrink(),
                SizedBox(height: 8.h),
                MonthlyPackageWidget(onTap: () {}),
                SizedBox(height: 12.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.w,
                    childAspectRatio: 3,
                  ),
                  itemCount: monthsOptions.length,
                  itemBuilder: (context, index) {
                    final months = monthsOptions[index];
                    final isSelected = selectedMonths == months;

                    return GestureDetector(
                      onTap: () => _onPackageSelected(months),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? buttonPrimaryBgColor(context)
                              : buttonSecondaryColor(context),
                          borderRadius: BorderRadius.circular(15.sp),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          monthsRanges[index],
                          style: isSelected
                              ? AppTypography.buttonText20(context)
                              : AppTypography.headingColor20(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                time_select_twoBox(context),
                SizedBox(height: 12.h),
                RentalSummaryCard(
                  receiveDate: receiveDate,
                  driveDate: driveDate,
                  differenceInDays: differenceInDays,
                ),
                SizedBox(height: 12.h),
                dashedDivider(context),
                SizedBox(height: 15.h),

                GestureDetector(
                  onTap: () async {
                    if (isLoading) return;
                    setState(() => isLoading = true);
                    await onTap(context);
                    setState(() => isLoading = false);

                    if (searchError) {
                      showErrorAlertDialog(context, locale.selectRegionAndBranch);
                    }
                  },
                  child: isLoading
                      ? const Center(child: LoadingIndicator())
                      : ADGradientButton(locale.search),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onTap(BuildContext context) async {
    try {
      final cubit = BlocProvider.of<SearchCubit>(context);

      if (BlocProvider.of<ProfileCubit>(context).custClass == '1') {
        setState(() => searchError = false);
      }

      if (cubit.selectedRegion == null || cubit.selectedReceiveBranch == null) {
        setState(() => searchError = true);
        return;
      }
      setState(() => searchError = false);

      final triggeredBranchModel = cubit.branchesData.firstWhere(
            (e) => e.name == cubit.selectedReceiveBranch,
      );
      cubit.selectedReceiveModel = triggeredBranchModel;

      if (cubit.selectedDriveBranch != null) {
        final triggeredDriveBranchModel =
        BlocProvider.of<AllBranchCubit>(context).branchesData.firstWhere(
              (e) => e.name == cubit.selectedDriveBranch,
        );
        cubit.selectedDriveModel = triggeredDriveBranchModel;
      } else {
        cubit.selectedDriveModel = triggeredBranchModel;
      }
      await cubit.validate();
    } catch (e) {
      print("validation Error: ${e.toString()}");
      setState(() => searchError = true);
    }
  }
}