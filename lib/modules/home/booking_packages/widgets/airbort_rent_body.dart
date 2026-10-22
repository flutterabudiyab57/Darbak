import 'package:darbak/core/style/style.dart';
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
import '../../../widgets/Dashed_divider.dart';
import '../../../widgets/show_error_dailog.dart';
import '../../../widgets/time_select.dart';
import '../../all_branching/data/models/branch_model.dart' show BranchModel;
import '../../search_screen/presentaion/widget/rental_summary_card.dart';
import '../../../location/data/models/branch.dart';
import '../../../location/presentaion/bloc/location_selection_cubit.dart';
import '../../../location/presentaion/bloc/location_selection_state.dart';
import '../../../location/presentaion/pages/branch_picker_screen.dart';

/// Airport's branch picking, per specs/001-region-branch-selection/tasks.md
/// T049. Reads [LocationSelectionCubit] only — screen-scoped
/// (`registerFactory`, provided by `AirportPackageScreen`), started with
/// `LocationFilter.airport()` (no region step). There is no dropoff branch
/// concept here — the same picked branch is submitted as both receive and
/// drive (mirroring the pre-existing behaviour).
///
/// Previously read `searchCubit.airportBranchesData` via the book-from-car
/// `BranchTile` widget; that read goes away here (watch item 3) without
/// touching the book-from-car flow itself — this screen now uses
/// [BranchPickerScreen] instead.
class AirPortRentBody extends StatefulWidget {
  const AirPortRentBody({super.key});

  @override
  State<AirPortRentBody> createState() => _AirPortRentBodyState();
}

class _AirPortRentBodyState extends State<AirPortRentBody> {
  bool searchError = false;
  bool isLoading = false;

  Future<void> _pickBranch(
    BuildContext context,
    LocationSelectionCubit cubit,
    List<Branch> options,
    int? selectedId,
  ) async {
    final emptyMessage = AppLocalizations.of(context)!.noBranchesOfferService;
    final picked = await Navigator.of(context, rootNavigator: true).push<Branch>(
      CupertinoPageRoute<Branch>(
        builder: (_) => BranchPickerScreen(
          branches: options,
          selectedId: selectedId,
          emptyMessage: emptyMessage,
        ),
      ),
    );
    if (picked == null) return;
    cubit.setPickupBranch(picked);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, searchState) {
        return BlocBuilder<LocationSelectionCubit, LocationSelectionState>(
          builder: (context, locState) {
        final cubit = context.read<LocationSelectionCubit>();
        final searchCubit = context.read<SearchCubit>();
        final receiveDate = searchCubit.receiveDateValue;
        final driveDate = searchCubit.driveDateValue;

        searchCubit.updateDates(receiveDate, driveDate);
        final differenceInDays = searchCubit.differenceInDays;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            child: Column(
              spacing: 20.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale!.pickupFromAirports,
                      style: AppTypography.headingColor22(context),
                    ),
                    Text(
                      locale.chargedDailyPrice,
                      style: AppTypography.paragraphColor18(context),
                    ),
                  ],
                ),

                if (locState.status == LocationSelectionStatus.failure)
                  _FailureBanner(
                    message: locState.error ?? '',
                    onRetry: cubit.retry,
                  ),

                GestureDetector(
                  onTap: () => _pickBranch(
                    context,
                    cubit,
                    locState.pickupOptions,
                    locState.pickupBranch?.id,
                  ),
                  child: _SelectionRow(
                    label: locState.pickupBranch?.name ??
                        locale.selectBranch ??
                        locale.selectAirport,
                  ),
                ),
                TimeSelectTwoBox(
                  enableGuarding: true,
                  pickupWorkTime: locState.pickupBranch?.workTime,
                  dropoffWorkTime: locState.pickupBranch?.workTime,
                ),
                Center(child: RentalSummaryCard(differenceInDays: differenceInDays,)),
                dashedDivider(context),

                GestureDetector(
                  onTap: () async {
                    if (isLoading) return;
                    setState(() {
                      isLoading = true;
                    });
                    await onTap(context, locState.pickupBranch);
                    setState(() {
                      isLoading = false;
                    });

                    if (searchError) {
                      showErrorAlertDialog(
                        context,
                        locale.selectAirport,
                      );
                    }
                  },
                  child: isLoading
                      ? Center(
                      child: LoadingIndicator()

                  )
                      : ADGradientButton(locale.search),
                ),
              ],
            ),
          ),
        );
          },
        );
      },
    );
  }

  Future<void> onTap(BuildContext context, Branch? pickupBranch) async {
    try {
      final searchCubit = BlocProvider.of<SearchCubit>(context);

      if (pickupBranch == null) {
        setState(() {
          searchError = true;
        });
        return;
      }

      setState(() {
        searchError = false;
      });

      // Bridge into the legacy BranchModel the still-unconverted downstream
      // flow (FilterModel, CarsInformation, ...) expects. Only `id`/`name`
      // are ever read from it there — both come straight from the new
      // Branch, never re-resolved by matching a name (Principle I).
      final bridge = BranchModel(id: pickupBranch.id, name: pickupBranch.name);
      searchCubit.selectedDriveModel = bridge;
      searchCubit.selectedReceiveModel = bridge;

      await searchCubit.validateDelivery();
    } catch (e) {
      setState(() {
        searchError = true;
      });
    }
  }
}

class _SelectionRow extends StatelessWidget {
  final String label;

  const _SelectionRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

/// FR-038: shown alongside the normal selection UI, never instead of it.
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
