import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_state.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../core/style/style.dart';
import '../../../widgets/Dashed_divider.dart';
import '../../../widgets/show_error_dailog.dart';
import '../../../widgets/time_select.dart';
import '../../all_branching/data/models/branch_model.dart' show BranchModel;
import '../../search_screen/presentaion/widget/monthly_package_widget.dart';
import '../../search_screen/presentaion/widget/rental_summary_card.dart';
import '../../selectLanguage/languageCubit.dart';
import '../../../location/data/models/branch.dart';
import '../../../location/data/models/region.dart';
import '../../../location/presentaion/bloc/location_selection_cubit.dart';
import '../../../location/presentaion/bloc/location_selection_state.dart';
import '../../../location/presentaion/pages/branch_picker_screen.dart';

/// Monthly rent's region/branch picking, per
/// specs/001-region-branch-selection/tasks.md T044, mirroring T035-T040
/// (`daily_rent_body.dart`) exactly. Reads [LocationSelectionCubit] only — a
/// screen-scoped `registerFactory` instance provided by
/// `MonthlyPackageScreen.entry()`, per Constitution Principle III/FR-017.
///
/// The months grid (1/3/6/9/12) and `SearchCubit`'s date logic are untouched
/// — they read/write only `receiveDateValue`/`driveDateValue`, never the
/// location fields this conversion removes. `SearchCubit.selectedReceiveModel`/
/// `selectedDriveModel` are still assigned right before `validate()`, since
/// the downstream flow (`FilterModel`, `CarsInformation`, ...) is not
/// converted in this phase — that assignment is a deliberate bridge, built
/// from the new [Branch]'s `id`/`name` only.
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
    final locale = AppLocalizations.of(context)!;

    final List<String> monthsRanges = [
      "1 ${locale.month}",
      "3 ${locale.months}",
      "6 ${locale.months}",
      "9 ${locale.months}",
      "12 ${locale.months}",
    ];
    final List<int> monthsOptions = [1, 3, 6, 9, 12];

    return BlocListener<LanguageCubit, Locale>(
      listenWhen: (previous, current) =>
          previous.languageCode != current.languageCode,
      listener: (context, _) {
        // T039 (mirrored): names refresh, selection survives by id.
        context.read<LocationSelectionCubit>().onLanguageChanged();
      },
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<SearchCubit>(context);
          final receiveDate = cubit.receiveDateValue;
          final driveDate = cubit.driveDateValue;

          cubit.updateDates(receiveDate, driveDate);
          final differenceInDays = cubit.differenceInDays;

          return BlocBuilder<LocationSelectionCubit, LocationSelectionState>(
            builder: (context, locState) {
              final locCubit = context.read<LocationSelectionCubit>();

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

                      // T040 (mirrored) — FR-038 failure UI. Rendered
                      // alongside the normal selection rows, never in place
                      // of them: `status: failure` never clears
                      // pickupBranch/dropoffBranch/pickupRegion/
                      // dropoffRegion in the cubit.
                      if (locState.status == LocationSelectionStatus.failure)
                        _FailureBanner(
                          message: locState.error ?? '',
                          onRetry: locCubit.retry,
                        ),

                      GestureDetector(
                        onTap: () => _showRegionPicker(
                          context,
                          cubit: locCubit,
                          regions: locCubit.regions,
                          isDropoff: false,
                        ),
                        child: _SelectionRow(
                          label: locState.pickupRegion?.name ??
                              locale.selectRegion.toString(),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: locState.pickupOptions.isEmpty
                            ? null
                            : () => _pickBranch(
                                  context,
                                  cubit: locCubit,
                                  options: locState.pickupOptions,
                                  selectedId: locState.pickupBranch?.id,
                                  isDropoff: false,
                                ),
                        child: _SelectionRow(
                          label: locState.pickupBranch?.name ??
                              locale.selectBranch ??
                              locale.chooseMonthlyPackage,
                          enabled: locState.pickupOptions.isNotEmpty,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      if (locState.pickupOptions.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey, width: 1.5.w),
                            borderRadius: BorderRadius.circular(12.sp),
                            color: backgroundColor(context),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                child: Icon(
                                  Icons.gps_fixed_sharp,
                                  size: 18.sp,
                                  color: mainTypographyColor(context),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: AutoSizeText(
                                  locale.deliverAnotherBranch.toString(),
                                  style: AppTypography.paragraphColor14(context),
                                ),
                              ),
                              SizedBox(
                                width: 64.w,
                                child: FittedBox(
                                  child: Switch.adaptive(
                                    activeThumbColor: iconDefaultColor(context),
                                    inactiveTrackColor: Colors.grey,
                                    // T037 (mirrored): the widget calls
                                    // setSeparateDropoff and nothing else —
                                    // the cubit's clearDropoff() transformer
                                    // owns the clearing.
                                    value: locState.separateDropoff,
                                    onChanged: (value) =>
                                        locCubit.setSeparateDropoff(value),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (locState.separateDropoff) ...[
                          SizedBox(height: 10.h),
                          GestureDetector(
                            onTap: () => _showRegionPicker(
                              context,
                              cubit: locCubit,
                              regions: locCubit.regions,
                              isDropoff: true,
                            ),
                            child: _SelectionRow(
                              label: locState.dropoffRegion?.name ??
                                  locState.pickupRegion?.name ??
                                  locale.selectRegion.toString(),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          GestureDetector(
                            onTap: locState.dropoffOptions.isEmpty
                                ? null
                                : () => _pickBranch(
                                      context,
                                      cubit: locCubit,
                                      options: locState.dropoffOptions,
                                      selectedId: locState.dropoffBranch?.id,
                                      isDropoff: true,
                                    ),
                            child: _SelectionRow(
                              label: locState.dropoffBranch?.name ??
                                  locale.selectBranch ??
                                  locale.chooseMonthlyPackage,
                              enabled: locState.dropoffOptions.isNotEmpty,
                            ),
                          ),
                        ],
                      ],

                      SizedBox(height: 8.h),
                      MonthlyPackageWidget(),
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
                                    ? iconDefaultColor(context)
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
                      TimeSelectTwoBox(
                        enableGuarding: true,
                        pickupWorkTime: locState.pickupBranch?.workTime,
                        dropoffWorkTime: locState.dropoffBranch?.workTime ??
                            locState.pickupBranch?.workTime,
                      ),
                      SizedBox(height: 12.h),
                      Center(
                          child: RentalSummaryCard(
                              differenceInDays: differenceInDays)),
                      SizedBox(height: 12.h),
                      dashedDivider(context),
                      SizedBox(height: 15.h),
                      GestureDetector(
                        onTap: () async {
                          if (isLoading) return;
                          setState(() => isLoading = true);
                          await onTap(context, locState);
                          setState(() => isLoading = false);

                          if (searchError) {
                            showErrorAlertDialog(
                                context, locale.selectRegionAndBranch);
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
        },
      ),
    );
  }

  Future<void> _showRegionPicker(
    BuildContext context, {
    required LocationSelectionCubit cubit,
    required List<Region> regions,
    required bool isDropoff,
  }) {
    final locale = AppLocalizations.of(context)!;
    return showModalBottomSheet(
      useRootNavigator: true,
      backgroundColor: backgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.h),
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
                          locale.selectRegion.toString(),
                          style: AppTypography.headingColor18(sheetContext),
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
                            size: 20.sp, color: headingColor(sheetContext)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 420.h),
                child: regions.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 24.h),
                        child: Text(
                          locale.noBranchesToShow,
                          style: AppTypography.paragraphColor14(sheetContext),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: regions.length,
                        itemBuilder: (context, index) {
                          final region = regions[index];
                          final selectedId = isDropoff
                              ? cubit.state.dropoffRegion?.id
                              : cubit.state.pickupRegion?.id;
                          final isSelected = region.id == selectedId;
                          return ListTile(
                            title: Text(
                              region.name,
                              style:
                                  AppTypography.paragraphColor16(sheetContext),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle,
                                    color: mainTypographyColor(sheetContext))
                                : null,
                            onTap: () {
                              if (isDropoff) {
                                cubit.selectDropoffRegion(region);
                              } else {
                                cubit.selectPickupRegion(region);
                              }
                              Navigator.pop(sheetContext);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickBranch(
    BuildContext context, {
    required LocationSelectionCubit cubit,
    required List<Branch> options,
    required int? selectedId,
    required bool isDropoff,
  }) async {
    // Corrected navigator call per contracts/navigation-contract.md — NOT
    // PersistentNavBarNavigator.pushNewScreen<Branch>(...), which throws
    // "type 'CupertinoPageRoute<dynamic>' is not a subtype of type
    // 'Route<Branch>'" at runtime (persistent_bottom_nav_bar 6.2.1 defect,
    // found during daily-rent's T042 device verification). Pushing directly
    // on the root Navigator keeps the identical "outside the caller's
    // provider subtree" placement Constitution Principle II requires.
    final picked = await Navigator.of(context, rootNavigator: true).push<Branch>(
      CupertinoPageRoute<Branch>(
        builder: (_) =>
            BranchPickerScreen(branches: options, selectedId: selectedId),
      ),
    );
    if (picked == null) return;
    if (isDropoff) {
      cubit.setDropoffBranch(picked);
    } else {
      cubit.setPickupBranch(picked);
    }
  }

  Future<void> onTap(
      BuildContext context, LocationSelectionState locState) async {
    try {
      final searchCubit = BlocProvider.of<SearchCubit>(context);

      if (locState.pickupRegion == null || locState.pickupBranch == null) {
        setState(() => searchError = true);
        return;
      }
      setState(() => searchError = false);

      // Bridge into the legacy BranchModel the still-unconverted downstream
      // flow (FilterModel, CarsInformation, ...) expects. Only `id`/`name`
      // are ever read from it there — both come straight from the new
      // Branch, never re-resolved by matching a name (Principle I).
      searchCubit.selectedReceiveModel = BranchModel(
        id: locState.pickupBranch!.id,
        name: locState.pickupBranch!.name,
      );
      final dropoffBranch = locState.dropoffBranch ?? locState.pickupBranch!;
      searchCubit.selectedDriveModel = BranchModel(
        id: dropoffBranch.id,
        name: dropoffBranch.name,
      );

      await searchCubit.validate();
    } catch (e) {
      setState(() => searchError = true);
    }
  }
}

class _SelectionRow extends StatelessWidget {
  final String label;
  final bool enabled;

  const _SelectionRow({required this.label, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        height: 55.h,
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          border: Border.all(color: strokeGrayColor(context), width: 2.w),
          borderRadius: BorderRadius.circular(15.r),
          color: backgroundColor(context),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
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
}

/// T040 (mirrored) / FR-038: shown alongside the normal selection UI, never
/// instead of it — the cubit never discards a selection on fetch failure.
class _FailureBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailureBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bg2Color(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: buttonRedColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: AppTypography.paragraphColor14(context)),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              locale.retry,
              style: AppTypography.paragraphColor14(context)
                  .copyWith(color: buttonBlueColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
