import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../core/helpers/enums.dart';
import '../../../../core/helpers/helper_fun.dart';
import '../../../../language/locale.dart';
import '../../../widgets/components/appbar.dart';
import '../../cars/presentaion/bloc/cubit/cars_cubit.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../search_screen/blocs/search_bloc/search_cubit.dart';
import '../../search_screen/blocs/search_bloc/search_state.dart';
import '../../search_screen/data/models/filter_model.dart';
import '../../search_screen/presentaion/widget/shimmer_list.dart';
import '../cars_list_package.dart';
import '../widgets/delivery_rent_body.dart';

class DeliveryPackageScreen extends StatefulWidget {
  const DeliveryPackageScreen({super.key});

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
                // Matching logic for branches
                final matchingBranches = context.read<SearchCubit>()
                    .deliveryBranchesData.where((element) =>
                element.name!.trim().toLowerCase() ==
                    context
                        .read<SearchCubit>()
                        .selectedReceiveBranch!
                        .trim()
                        .toLowerCase())
                    .toList();

                print("selectedReceiveBranch: ${ context
                    .read<SearchCubit>()
                    .selectedReceiveBranch!
                    .trim()
                    .toLowerCase()}");

                print("matchingBranches: ${ matchingBranches}");

                if (matchingBranches.isNotEmpty) {
                  // Handle matched branch
                  final triggeredBranchModel = matchingBranches.first;
                  print("Matching branch found: ${triggeredBranchModel.name}");

                  final filterModel = FilterModel(
                    selectedBranch: triggeredBranchModel,
                    receiveTimeValue: context.read<SearchCubit>().receiveTimeValue.hour.toString(),
                    driveTimeValue: context.read<SearchCubit>().driveTimeValue.hour.toString(),
                    receiveDateValue: context.read<SearchCubit>().receiveDateValue.toString(),
                    driveDateValue: context.read<SearchCubit>().driveDateValue.toString(),
                    pickupLat: context.read<SearchCubit>().pickupLat,
                    pickupLong: context.read<SearchCubit>().pickupLong,
                    dropoffLat: context.read<SearchCubit>().dropoffLat,
                    dropoffLong: context.read<SearchCubit>().dropoffLong,
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
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: CarsListPackage(filterModel: filterModel));
                  });
                } else {
                  print(
                      "No matching branch found for the selected receive branch: ${context.read<SearchCubit>().selectedReceiveBranch}");
                  HelperFunctions.dialog(
                    context: context,
                    title: locale!.branchError,
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
