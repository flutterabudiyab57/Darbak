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

import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/router/routes.dart';
import '../../../../language/locale.dart';
import '../../../widgets/components/appbar.dart';
import '../../cars/presentaion/bloc/cubit/cars_cubit.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../search_screen/presentaion/widget/shimmer_list.dart';
import '../widgets/airbort_rent_body.dart';
import 'package:darbak/service_locator.dart';
import 'package:darbak/modules/location/data/location_filter.dart';
import 'package:darbak/modules/location/presentaion/bloc/location_selection_cubit.dart';

/// T049: `LocationSelectionCubit` is provided here, screen-scoped
/// (`registerFactory`), started with `LocationFilter.airport()` — this flow
/// has no region step, so `start()` fetches the airport-capable branch list
/// directly. `/airportPackage` is a live route, reached from
/// `search_Screen.dart`.
class AirportPackageScreen extends StatefulWidget {
  const AirportPackageScreen({super.key});

  static Widget entry() => MultiBlocProvider(
        providers: [
          BlocProvider<CarsCubit>(create: (_) => sl<CarsCubit>()),
          BlocProvider<LocationSelectionCubit>(
            create: (_) => sl<LocationSelectionCubit>()
              ..start(const LocationFilter.airport()),
          ),
        ],
        child: const AirportPackageScreen(),
      );

  @override
  State<AirportPackageScreen> createState() => _AirportPackagesState();
}

class _AirportPackagesState extends State<AirportPackageScreen> {
  bool? isAlertBoxOpened;

  @override
  void initState() {
    super.initState();
    isAlertBoxOpened = true;
    _getRegions();
  }

  Future<void> _getRegions() async {
    await BlocProvider.of<SearchCubit>(context).getRegions();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: CustomAppBar(
        title: locale!.airportsTitle,
        showBackButton: true,
        // showThemeToggle: true,
      ),
      body: Container(
        child: ListView(
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
                  // Was: name-matching against `airportBranchesData`
                  // (`element.name == selectedReceiveBranch`), which the new
                  // location flow never populates — `AirPortRentBody` sets
                  // only `selectedReceiveModel`/`selectedDriveModel` (the
                  // id/name bridge built from `LocationSelectionCubit`'s
                  // `Branch`, Constitution Principle I).
                  // `validateDelivery()` force-unwraps `selectedReceiveModel`,
                  // so by the time this listener runs it is already
                  // guaranteed non-null. Same fix as `clasic.dart`'s (T042),
                  // `monthly_package_screen.dart`'s (T045) and
                  // `delivery_package_screen.dart`'s (T047) SearchValidate
                  // listeners.
                  final triggeredBranchModel =
                      context.read<SearchCubit>().selectedReceiveModel;

                  if (triggeredBranchModel != null) {
                    final filterModel = FilterModel(
                      selectedBranch: triggeredBranchModel,
                      receiveTimeValue: context
                          .read<SearchCubit>()
                          .receiveTimeValue
                          .hour
                          .toString(),
                      driveTimeValue: context
                          .read<SearchCubit>()
                          .driveTimeValue
                          .hour
                          .toString(),
                      receiveDateValue:
                          context.read<SearchCubit>().receiveDateValue.toString(),
                      driveDateValue:
                          context.read<SearchCubit>().driveDateValue.toString(),
                    );

                    await BlocProvider.of<CarsCubit>(context)
                        .getAllCars(1,
                            branchId: triggeredBranchModel.id,
                            castClass:
                                context.read<ProfileCubit>().custClass.toString())
                        .then((value) {
                      context.pushNamed(Routes.carsListPackage, extra: filterModel);
                    });
                  } else {
                    HelperFunctions.dialog(
                      context: context,
                      title: locale.branchError,
                      body: locale.invalidBranchSelected,
                    );
                  }
                } else if (state is SearchCheckLoading) {
                  Center(
                    child: Lottie.asset("assets/anim/loading_anim.json",
                        width: 100.w),
                  );
                }
              },
              builder: (context, state) {
                if (state is SearchLoading) {
                  return Center(
                    child: ShimmerLoadingList(
                      itemCount: 5,
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      _getRegions();
                    },
                    child: Column(
                      children: [
                        context.read<SearchCubit>().rentType == RentType.classic
                            ? AirPortRentBody()
                            : Container(),
                        SizedBox(
                          height: Device.get().isTablet ? 100.h : 0.h,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
