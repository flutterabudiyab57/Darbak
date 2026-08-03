import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/helpers/helper_fun.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/additions/presentaion/blocs/addition_cubit/additions_cubit.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:darbak/modules/home/booking_from_cars/presentaion/bloc/booking_cars_cubit.dart';
import 'package:darbak/modules/home/booking_from_cars/presentaion/bloc/booking_cars_state.dart';
import 'package:darbak/modules/home/booking_from_cars/presentaion/view/widget/branchs.dart';
import 'package:darbak/modules/home/cars/data/models/cars_model.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:bounce/bounce.dart';
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

class BranchWithCarScreen extends StatefulWidget {
  final DataCars carModel;
  const BranchWithCarScreen({Key? key, required this.carModel}) : super(key: key);

  @override
  State<BranchWithCarScreen> createState() => _BranchWithCarScreenState();
}

class _BranchWithCarScreenState extends State<BranchWithCarScreen> {
  bool isLoading = false;

  @override
  void initState() {
    BlocProvider.of<SearchCubit>(context).clearAllDataSearched();
    super.initState();
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
      body: BlocProvider(
        create: (context) => sl<BookingFromCarsCubit>()
          ..getBranchesWithCar(carId: int.parse(widget.carModel.id.toString())),
        child: BlocConsumer<BookingFromCarsCubit, BookingFromCarsState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is BookingFromCarsLoading) {
              return const Center(child: ShimmerLoadingList());
            }

            if (state is BookingFromCarsLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  child: Column(
                    children: [
                      CarSearchItem(car: widget.carModel),
                      SizedBox(height: 6.h),

                      BranchTile(regions: state.branchModel.data, isRecieve: true),
                      SizedBox(height: 6.h),

                      time_select_twoBox(context),
                      SizedBox(height: 10.h),

                      BlocBuilder<SearchCubit, SearchState>(
                        builder: (context, searchState) {
                          final cubit = BlocProvider.of<SearchCubit>(context);
                          final receiveDate = cubit.receiveDateValue;
                          final driveDate   = cubit.driveDateValue;

                          cubit.updateDates(receiveDate, driveDate);

                          return RentalSummaryCard(
                            receiveDate: receiveDate,
                            driveDate: driveDate,
                            differenceInDays: cubit.differenceInDays,
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
                            context.go('/signin');
                          }
                        },
                        builder: (context, addState) {
                          return Bounce(
                            onTap: () async {
                              setState(() => isLoading = true);
                              BlocProvider.of<AdditionsCubit>(context).clearAdditions();

                              if (BlocProvider.of<SearchCubit>(context).selectedReceiveBranch != null) {
                                await onTapFirst(context);
                                await onTap(context);
                              } else {
                                showErrorAlertDialog(
                                  context,
                                  locale.mustSelectBranchFirst,
                                );
                              }
                              setState(() => isLoading = false);
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
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }


  BranchModel _resolveBranch(BuildContext context, String branchText) {
    final match = context
        .read<BookingFromCarsCubit>()
        .branchesModel
        .data
        .firstWhere((e) => e.text == branchText);
    return BranchModel(id: match.id, name: match.text);
  }

  Future<void> onTapFirst(BuildContext context) async {
    final cubit = BlocProvider.of<SearchCubit>(context);
    final receiveBranch = _resolveBranch(context, cubit.selectedReceiveBranch!);
    cubit.selectedReceiveModel = receiveBranch;

    cubit.selectedDriveModel = cubit.selectedReceiveModel = cubit.selectedDriveBranch != null
        ? _resolveBranch(context, cubit.selectedDriveBranch!)
        : receiveBranch;
  }

  Future<void> onTap(BuildContext context) async {
    final locale = AppLocalizations.of(context);
    final cubit = BlocProvider.of<SearchCubit>(context);
    final additionsCubit = BlocProvider.of<AdditionsCubit>(context);

    additionsCubit.clearAdditions();

    final receiveBranch = _resolveBranch(context, cubit.selectedReceiveBranch!);
    cubit.selectedReceiveModel = receiveBranch;
    cubit.selectedDriveModel = cubit.selectedDriveBranch != null
        ? _resolveBranch(context, cubit.selectedDriveBranch!)
        : receiveBranch;

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
      context.pushNamed(Routes.additions,
          extra: AdditionsArgs(datum: widget.carModel));
    } else {
      print("BranchWithCarScreen: unexpected state $state");
    }
  }}