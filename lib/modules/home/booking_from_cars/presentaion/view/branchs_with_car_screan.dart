import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/helpers/auth_guard/require_auth.dart';
import 'package:darbak/core/helpers/helper_fun.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart' show BranchModel;
import 'package:darbak/modules/home/booking_from_cars/presentaion/view/widget/branchs.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart' hide Branch;
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/router/routes.dart';
import '../../../../../service_locator.dart';
import '../../../../widgets/Dashed_divider.dart';
import '../../../../widgets/components/appbar.dart';
import '../../../../widgets/show_error_dailog.dart';
import '../../../../widgets/time_select.dart';
import '../../../cars/presentaion/widget/car_search_item.dart';
import '../../../search_screen/blocs/search_bloc/search_state.dart';
import '../../../search_screen/presentaion/widget/rental_summary_card.dart';
import '../../../search_screen/presentaion/widget/shimmer_list.dart';
import '../../../../location/data/location_filter.dart';
import '../../../../location/data/location_repository.dart';
import '../../../../location/data/models/branch.dart';
import '../../../../location/presentaion/bloc/location_selection_cubit.dart';
import '../../../../location/presentaion/bloc/location_selection_state.dart';
import '../../../../location/presentaion/pages/branch_picker_screen.dart';

/// T054: `LocationSelectionCubit` is provided here, screen-scoped
/// (`registerFactory`), started with `LocationFilter.car(carId)` — this
/// flow has no region step, so `start()` fetches the car's partial branch
/// list directly. This replaces `BookingFromCarsCubit`'s only
/// responsibility (fetching that same branch list for selection); nothing
/// else in the app reads `BookingFromCarsCubit`, so it is no longer
/// provided here at all (not deleted — Phase 8 deletes).
///
/// `/branch-with-car` is a live route (`app_router.dart`), reached whenever
/// a renter books starting from a specific car.
class BranchWithCarScreen extends StatefulWidget {
  final DataCars carModel;
  const BranchWithCarScreen({Key? key, required this.carModel}) : super(key: key);

  static Widget entry({required DataCars carModel}) => BlocProvider<LocationSelectionCubit>(
        create: (_) => sl<LocationSelectionCubit>()
          ..start(LocationFilter.car(int.parse(carModel.id.toString()))),
        child: BranchWithCarScreen(carModel: carModel),
      );

  @override
  State<BranchWithCarScreen> createState() => _BranchWithCarScreenState();
}

class _BranchWithCarScreenState extends State<BranchWithCarScreen> {
  bool isLoading = false;

  /// T056: the full (non-partial) branch list, fetched directly from
  /// [LocationRepository] rather than through the cubit — `start()` never
  /// fetches this for a `car()` filter (it is not region-scoped), and this
  /// list exists purely to complete a partial branch by id before the time
  /// guard (T058) runs. A fetch failure leaves this empty, which makes
  /// completion a no-op and the guard fail open (Principle IV) — never
  /// surfaced as its own error state.
  List<Branch> _fullBranches = const [];

  @override
  void initState() {
    BlocProvider.of<SearchCubit>(context).clearAllDataSearched();
    super.initState();
    _loadFullBranches();
  }

  Future<void> _loadFullBranches() async {
    try {
      final branches = await sl<LocationRepository>().getBranches(const LocationFilter.allRegions());
      if (mounted) setState(() => _fullBranches = branches);
    } catch (_) {
      // Intentionally silent — see _fullBranches doc above.
    }
  }

  Branch _completed(Branch partial) => LocationRepository.completeBranch(partial, _fullBranches);

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
    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: CustomAppBar(
        title: locale!.choseBranch.toString(),
        showBackButton: true,
      ),
      body: BlocBuilder<LocationSelectionCubit, LocationSelectionState>(
        builder: (context, locState) {
          final cubit = context.read<LocationSelectionCubit>();

          if (locState.status == LocationSelectionStatus.initial ||
              locState.status == LocationSelectionStatus.loading) {
            return const Center(child: ShimmerLoadingList());
          }

          // T056/T058: completed BEFORE the time guard below reads workTime.
          final completedPickup =
              locState.pickupBranch != null ? _completed(locState.pickupBranch!) : null;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: Column(
                children: [
                  CarSearchItem(car: widget.carModel),
                  SizedBox(height: 6.h),

                  if (locState.status == LocationSelectionStatus.failure)
                    _FailureBanner(
                      message: locState.error ?? '',
                      onRetry: cubit.retry,
                    ),

                  BranchTile(
                    branch: locState.pickupBranch,
                    onTap: () => _pickBranch(
                      context,
                      cubit,
                      locState.pickupOptions,
                      locState.pickupBranch?.id,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // T058: guarded against the COMPLETED branch's work_time.
                  // A still-partial branch (no match found in
                  // _fullBranches) has a null workTime here, which leaves
                  // every slot enabled per Principle IV — POST
                  // /available/time (SearchCubit.validate()) remains the
                  // only remaining check in that case.
                  TimeSelectTwoBox(
                    enableGuarding: true,
                    pickupWorkTime: completedPickup?.workTime,
                    dropoffWorkTime: completedPickup?.workTime,
                  ),
                  SizedBox(height: 10.h),

                  BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, searchState) {
                      final searchCubit = BlocProvider.of<SearchCubit>(context);
                      final receiveDate = searchCubit.receiveDateValue;
                      final driveDate = searchCubit.driveDateValue;

                      searchCubit.updateDates(receiveDate, driveDate);

                      return Center(
                        child: RentalSummaryCard(
                          differenceInDays: searchCubit.differenceInDays,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  dashedDivider(context),
                  SizedBox(height: 12.h),

                  BlocConsumer<AdditionsCubit, AdditionsState>(
                    listener: (context, addState) {
                      if (addState is AdditionsFailed &&
                          addState.error.contains("Error Please LOGIN To Continue")) {
                        context.go('/home');
                      }
                    },
                    builder: (context, addState) {
                      return Bounce(
                        onTap: () async {
                          await requireAuth(
                            context,
                            onAuthenticated: () async {
                              setState(() => isLoading = true);
                              BlocProvider.of<AdditionsCubit>(context).clearAdditions();

                              if (completedPickup != null) {
                                await onTap(context, completedPickup);
                              } else {
                                showErrorAlertDialog(
                                  context,
                                  locale.mustSelectBranchFirst,
                                );
                              }
                              setState(() => isLoading = false);
                            },
                          );
                        },
                        child: isLoading
                            ? const Center(child: LoadingIndicator())
                            : ADGradientButton(locale.bookNow),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> onTap(BuildContext context, Branch completedBranch) async {
    final locale = AppLocalizations.of(context);
    final cubit = BlocProvider.of<SearchCubit>(context);
    final additionsCubit = BlocProvider.of<AdditionsCubit>(context);

    additionsCubit.clearAdditions();

    // Bridge into the legacy BranchModel the still-unconverted downstream
    // flow (AdditionsCubit, payment, ...) expects. Only `id`/`name` are ever
    // read from it there — both come straight from the new Branch, never
    // re-resolved by matching a name (Principle I). This flow has no
    // separate dropoff picker (only one BranchTile is ever rendered), so
    // the same branch is submitted for both, mirroring airport's behaviour.
    final bridge = BranchModel(id: completedBranch.id, name: completedBranch.name);
    cubit.selectedReceiveModel = bridge;
    cubit.selectedDriveModel = bridge;

    final receiveDate = cubit.receiveDateValue;
    final driveDate = cubit.driveDateValue;

    if (!driveDate.isAfter(receiveDate)) {
      HelperFunctions.dialog(
        context: context,
        title: locale!.dateInvalid,
        body: locale.dropOffMustBeAfterPickup,
      );
      return;
    }

    await cubit.validate();

    final state = cubit.state;

    if (state is SearchInvalid) {
      HelperFunctions.dialog(
        context: context,
        title: locale!.dateInvalid,
        body: state.message,
      );
      return;
    } else if (state is SearchValidate) {
      additionsCubit.getCarFeatures(context, widget.carModel.id.toString(), null);
      context.pushNamed(Routes.additions, extra: AdditionsArgs(datum: widget.carModel));
    }
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
