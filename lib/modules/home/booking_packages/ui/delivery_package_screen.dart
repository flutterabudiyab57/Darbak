import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/helpers/enums.dart';
import '../../../../core/helpers/helper_fun.dart';
import '../../../../core/router/routes.dart';
import '../../../../language/locale.dart';
import '../../../widgets/components/appbar.dart';
import '../../cars/presentaion/bloc/cubit/cars_cubit.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../search_screen/blocs/search_bloc/search_cubit.dart';
import '../../search_screen/blocs/search_bloc/search_state.dart';
import '../../search_screen/data/models/filter_model.dart';
import '../../search_screen/presentaion/widget/shimmer_list.dart';
import '../widgets/delivery_rent_body.dart';
import 'package:darbak/service_locator.dart';
import 'package:darbak/modules/location/data/location_filter.dart';
import 'package:darbak/modules/location/presentaion/bloc/location_selection_cubit.dart';

/// T047: `LocationSelectionCubit` is provided here, screen-scoped
/// (`registerFactory`, never added to `lib/bloc_providers.dart`), started
/// with `LocationFilter.delivery()` — this flow has no region step, so
/// `start()` fetches the delivery-capable branch list directly.
/// `/deliveryPackage` is a live route, reached from
/// `branches_card.dart` (book-from-car).
class DeliveryPackageScreen extends StatefulWidget {
  const DeliveryPackageScreen({super.key});

  static Widget entry() => MultiBlocProvider(
        providers: [
          BlocProvider<CarsCubit>(create: (_) => sl<CarsCubit>()),
          BlocProvider<LocationSelectionCubit>(
            create: (_) => sl<LocationSelectionCubit>()
              ..start(const LocationFilter.delivery()),
          ),
        ],
        child: const DeliveryPackageScreen(),
      );

  @override
  State<DeliveryPackageScreen> createState() => _DeliveryPackageScreenState();
}

class _DeliveryPackageScreenState extends State<DeliveryPackageScreen> {
  late bool searchError = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<SearchCubit>(context).clearAllDataSearched();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:backgroundColor(context),
      appBar: CustomAppBar(
        title:locale!.deliveryAndPickup,
        showBackButton: true,
        // showThemeToggle: true,
      ),
      body: ListView(
        children: [
          BlocConsumer<SearchCubit, SearchState>(
            listener: (context, state) async {
              if (state is SearchInvalid) {
                // Show error dialog for invalid state
                HelperFunctions.dialog(
                  context: context,
                  title: locale.dateInvalid,
                  body: state.props.first.toString(),
                );
              } else if (state is SearchValidate) {
                // Was: name-matching against `deliveryBranchesData`
                // (`element.name == selectedReceiveBranch`), which the new
                // location flow never populates — `DeliveryRentBody` sets
                // only `selectedReceiveModel`/`selectedDriveModel` (the
                // id/name bridge built from `LocationSelectionCubit`'s
                // `Branch`, Constitution Principle I).
                // `validateDelivery()` force-unwraps `selectedReceiveModel`,
                // so by the time this listener runs it is already
                // guaranteed non-null. Same fix as `clasic.dart`'s (T042)
                // and `monthly_package_screen.dart`'s (T045) SearchValidate
                // listeners.
                final triggeredBranchModel =
                    context.read<SearchCubit>().selectedReceiveModel;

                if (triggeredBranchModel != null) {
                  final searchCubit = context.read<SearchCubit>();
                  final filterModel = FilterModel.fromSelection(
                    selectedBranch: triggeredBranchModel,
                    locationCubit: context.read<LocationSelectionCubit>(),
                    searchCubit: searchCubit,
                    pickupLat: searchCubit.pickupLat,
                    pickupLong: searchCubit.pickupLong,
                    dropoffLat: searchCubit.dropoffLat,
                    dropoffLong: searchCubit.dropoffLong,
                  );
                  await BlocProvider.of<CarsCubit>(context)
                      .getAllCars(
                    1,
                    branchId: triggeredBranchModel.id,
                    castClass: context
                        .read<ProfileCubit>()
                        .custClass
                        .toString(),
                  )
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
                  child: Lottie.asset(
                    "assets/anim/loading_anim.json",
                    width: 100.w,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is SearchLoading) {
                return Center(
                  child: ShimmerLoadingList(),
                );
              } else {
                // Display the body content
                return Column(
                  children: [
                    context.read<SearchCubit>().rentType == RentType.classic
                        ? const DeliveryRentBody()
                        : Container(),
                    SizedBox(
                      height: Device.get().isTablet ? 100.h : 0.h,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
