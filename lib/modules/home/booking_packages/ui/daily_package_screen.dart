
import 'package:darbak/modules/home/booking_packages/widgets/daily_rent_body.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_state.dart';
import 'package:darbak/modules/home/search_screen/data/models/filter_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:darbak/core/helpers/enums.dart';
import 'package:darbak/core/helpers/helper_fun.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter/material.dart';

import 'package:darbak/service_locator.dart';
import 'package:darbak/modules/location/data/location_filter.dart';
import 'package:darbak/modules/location/presentaion/bloc/location_selection_cubit.dart';

import '../../../../core/router/routes.dart';
import '../../../../language/locale.dart';
import '../../../widgets/components/appbar.dart';
import '../../cars/presentaion/bloc/cubit/cars_cubit.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../search_screen/presentaion/widget/shimmer_list.dart';

/// Own entry point for [DailyRentBody] besides `/classic` (`Clasic`). Both
/// parents provide a screen-scoped [LocationSelectionCubit] — `registerFactory`,
/// never added to `lib/bloc_providers.dart` (FR-017: an app-wide singleton is
/// the defect this rewrite exists to close).
class DailyPackages extends StatefulWidget {
  const DailyPackages({super.key});

  static Widget entry() => BlocProvider<LocationSelectionCubit>(
        create: (_) => sl<LocationSelectionCubit>()
          ..start(const LocationFilter.allRegions()),
        child: const DailyPackages(),
      );

  @override
  State<DailyPackages> createState() => _DailyPackagesState();
}

class _DailyPackagesState extends State<DailyPackages> {

  bool? isAlertBoxOpened;

  @override
  void initState() {
    super.initState();
    isAlertBoxOpened = true;
    BlocProvider.of<ProfileCubit>(context).getProfile();
    _getRegions();
  }

  Future<void> _getRegions() async {
    await BlocProvider.of<SearchCubit>(context).getRegions();
  }




  @override
  Widget build(BuildContext context) {

    final locale = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  CustomAppBar(
        title:locale!.pickUpFromBranch,
        showBackButton: true,
        // showThemeToggle: true,
      ),
      body: ListView(
        children: [
          BlocConsumer<SearchCubit, SearchState>(
            listener: (context, state) async {
              if (state is SearchInvalid) {
                HelperFunctions.dialog(
                  context: context,
                  title: locale.dateInvalid,
                  body: state.props.first.toString(),
                );
              } else if (state is SearchValidate) {
                // Was: name-matching against `branchesData`
                // (`element.name == selectedReceiveBranch`), which no longer
                // exists on SearchCubit after T068. Same fix already applied
                // to the live daily-rent path (`clasic.dart`, T042) — this
                // file (`/daily-package`) is not linked from anywhere in the
                // app (see the class doc comment), but must still compile.
                final triggeredBranchModel =
                    context.read<SearchCubit>().selectedReceiveModel;

                if (triggeredBranchModel != null) {
                  final filterModel = FilterModel.fromSelection(
                    selectedBranch: triggeredBranchModel,
                    locationCubit: context.read<LocationSelectionCubit>(),
                    searchCubit: context.read<SearchCubit>(),
                  );

                  await BlocProvider.of<CarsCubit>(context)
                      .getAllCars(1,
                      branchId: triggeredBranchModel.id,
                      castClass: context
                          .read<ProfileCubit>()
                          .custClass
                          .toString())
                      .then((value) {
                    context.pushNamed(Routes.carsListPackage, extra: filterModel);
                  });
                } else {
                  print(
                      "No matching branch found for the selected receive branch");
                }
              } else if (state is SearchCheckLoading) {
                Center(
                  child: Lottie.asset("assets/anim/loading_anim.json",width: 100.w),
                );
              }
            },
            builder: (context, state) {
              if (state is SearchLoading) {
                return Center(
                  child: ShimmerLoadingList(),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () async {
                    _getRegions();
                  },
                  child: Column(
                    children: [
                      context.read<SearchCubit>().rentType == RentType.classic
                          ? DailyRentBody()
                          : Container(),
      
                      SizedBox(
                        height: Device.get().isTablet ? 100.h : 20.h,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
      
        ],
      ),
    );
  }
}
