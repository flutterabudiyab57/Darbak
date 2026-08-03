
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

import '../../../../core/router/routes.dart';
import '../../../../language/locale.dart';
import '../../../widgets/components/appbar.dart';
import '../../all_branching/bloc/all_branching_cubit.dart';
import '../../cars/presentaion/bloc/cubit/cars_cubit.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../search_screen/presentaion/widget/shimmer_list.dart';


class DailyPackages extends StatefulWidget {
  const DailyPackages({super.key});

  @override
  State<DailyPackages> createState() => _DailyPackagesState();
}

class _DailyPackagesState extends State<DailyPackages> {

  bool? isAlertBoxOpened;

  @override
  void initState() {
    super.initState();
    isAlertBoxOpened = true;
    BlocProvider.of<AllBranchCubit>(context).getAllBranch();
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
                final matchingBranches = context.read<SearchCubit>().branchesData.where((element) =>
                element.name == context.read<SearchCubit>().selectedReceiveBranch).toList();
      
                if (matchingBranches.isNotEmpty) {
                  final triggeredBranchModel = matchingBranches.first;
      
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
                    receiveDateValue: context
                        .read<SearchCubit>()
                        .receiveDateValue
                        .toString(),
                    driveDateValue: context
                        .read<SearchCubit>()
                        .driveDateValue
                        .toString(),
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
