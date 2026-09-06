import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_state.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
import '../../search_screen/presentaion/widget/rental_summary_card.dart';
import '../../selectLanguage/languageCubit.dart';
import '../../../location/data/models/branch.dart';
import '../../../location/data/models/region.dart';
import '../../../location/presentaion/bloc/location_selection_cubit.dart';
import '../../../location/presentaion/bloc/location_selection_state.dart';
import '../../../location/presentaion/pages/branch_picker_screen.dart';

/// Daily rent's region/branch picking, per
/// specs/001-region-branch-selection/tasks.md T035-T040. Reads
/// [LocationSelectionCubit] only — a screen-scoped `registerFactory`
/// instance provided by this widget's parent (`Clasic` or `DailyPackages`),
/// per Constitution Principle III/FR-017.
///
/// `SearchCubit`'s date, package and search (validate) logic is untouched —
/// only its LOCATION fields (`selectedRegion`, `regionsData`, `branchesData`,
/// `selectedReceiveBranch`/`selectedDriveBranch` name-matching) stop being
/// read here. `SearchCubit.selectedReceiveModel`/`selectedDriveModel` are
/// still assigned right before `validate()`, since the downstream flow
/// (`FilterModel`, `CarsInformation`, ...) is not converted in this phase —
/// that assignment is a deliberate bridge, built from the new [Branch]'s
/// `id`/`name` only, which is all any downstream consumer actually reads.
class DailyRentBody extends StatefulWidget {
  const DailyRentBody({super.key});

  @override
  State<DailyRentBody> createState() => _DailyRentBodyState();
}

class _DailyRentBodyState extends State<DailyRentBody> {
  bool searchError = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return BlocListener<LanguageCubit, Locale>(
      listenWhen: (previous, current) =>
          previous.languageCode != current.languageCode,
      listener: (context, _) {
        // T039: names refresh, selection survives by id.
        context.read<LocationSelectionCubit>().onLanguageChanged();
      },
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, searchState) {
          final receiveDate =
              BlocProvider.of<SearchCubit>(context).receiveDateValue;
          final driveDate =
              BlocProvider.of<SearchCubit>(context).driveDateValue;
          context.read<SearchCubit>().updateDates(receiveDate, driveDate);
          final differenceInDays = context.read<SearchCubit>().differenceInDays;

          return BlocBuilder<LocationSelectionCubit, LocationSelectionState>(
            builder: (context, locState) {
              final cubit = context.read<LocationSelectionCubit>();

              return Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(color: backgroundColor(context)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale.choseBranch.toString(),
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
                        SizedBox(height: 12.h),

                        // T040 — FR-038 failure UI. Rendered alongside the
                        // normal selection rows below, never in place of
                        // them: `status: failure` never clears
                        // pickupBranch/dropoffBranch/pickupRegion/
                        // dropoffRegion in the cubit, so nothing here is
                        // discarded by showing it.
                        if (locState.status == LocationSelectionStatus.failure)
                          _FailureBanner(
                            message: locState.error ?? '',
                            onRetry: cubit.retry,
                          ),

                        GestureDetector(
                          onTap: () => _showRegionPicker(
                            context,
                            cubit: cubit,
                            regions: cubit.regions,
                            isDropoff: false,
                          ),
                          child: _SelectionRow(
                            label: locState.pickupRegion?.name ??
                                locale.selectRegion.toString(),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        GestureDetector(
                          onTap: locState.pickupOptions.isEmpty
                              ? null
                              : () => _pickBranch(
                                    context,
                                    cubit: cubit,
                                    options: locState.pickupOptions,
                                    selectedId: locState.pickupBranch?.id,
                                    isDropoff: false,
                                  ),
                          child: _SelectionRow(
                            label: locState.pickupBranch?.name ??
                                locale.selectBranch ??
                                locale.choseBranch.toString(),
                            enabled: locState.pickupOptions.isNotEmpty,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        if (locState.pickupOptions.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey, width: 1.5.w),
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
                                      activeColor: iconDefaultColor(context),
                                      inactiveTrackColor: Colors.grey,
                                      // T037: the widget calls
                                      // setSeparateDropoff and nothing else —
                                      // no field is nulled here. The cubit's
                                      // clearDropoff() transformer owns that.
                                      value: locState.separateDropoff,
                                      onChanged: (value) =>
                                          cubit.setSeparateDropoff(value),
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
                                cubit: cubit,
                                regions: cubit.regions,
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
                                        cubit: cubit,
                                        options: locState.dropoffOptions,
                                        selectedId: locState.dropoffBranch?.id,
                                        isDropoff: true,
                                      ),
                              child: _SelectionRow(
                                label: locState.dropoffBranch?.name ??
                                    locale.selectBranch ??
                                    locale.choseBranch.toString(),
                                enabled: locState.dropoffOptions.isNotEmpty,
                              ),
                            ),
                          ],
                        ],

                        SizedBox(height: 14.h),
                        TimeSelectTwoBox(
                          enableGuarding: true,
                          pickupWorkTime: locState.pickupBranch?.workTime,
                          dropoffWorkTime: locState.dropoffBranch?.workTime ??
                              locState.pickupBranch?.workTime,
                        ),
                        SizedBox(height: 14.h),
                        Center(
                          child: RentalSummaryCard(
                              differenceInDays: differenceInDays),
                        ),
                        SizedBox(height: 20.h),
                        dashedDivider(context),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () async {
                            if (isLoading) return;
                            setState(() => isLoading = true);
                            await onTap(context, locState);
                            setState(() => isLoading = false);

                            if (searchError) {
                              showErrorAlertDialog(
                                context,
                                locale.selectRegionAndBranch,
                              );
                            }
                          },
                          child: isLoading
                              ? const Center(child: LoadingIndicator())
                              : ADGradientButton(locale.search),
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
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
                              style: AppTypography.paragraphColor16(sheetContext),
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
    // NOT PersistentNavBarNavigator.pushNewScreen<Branch>(...): that helper's
    // internal _getPageRoute() builds an untyped CupertinoPageRoute<dynamic>
    // and casts it `as Route<T>`, which throws
    // "type 'CupertinoPageRoute<dynamic>' is not a subtype of type
    // 'Route<Branch>'" at runtime whenever T is a concrete type. Every other
    // call site in the app uses the helper without a generic argument
    // (fire-and-forget), so this is the only place that hits it. Pushing
    // directly on the root Navigator sidesteps the buggy cast while keeping
    // the same "outside the caller's provider subtree" placement Constitution
    // Principle II requires (`withNavBar: false` in the helper resolves to
    // exactly this same `rootNavigator: true`).
    final picked = await Navigator.of(context, rootNavigator: true).push<Branch>(
      CupertinoPageRoute<Branch>(
        builder: (_) => BranchPickerScreen(branches: options, selectedId: selectedId),
      ),
    );
    if (picked == null) return;
    if (isDropoff) {
      cubit.setDropoffBranch(picked);
    } else {
      cubit.setPickupBranch(picked);
    }
  }

  Future<void> onTap(BuildContext context, LocationSelectionState locState) async {
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

/// T040 / FR-038: shown alongside the normal selection UI, never instead of
/// it — the cubit never discards a selection on fetch failure.
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
