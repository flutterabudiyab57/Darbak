import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../core/constants/assets/app_colors.dart';
import '../../../core/helpers/enums.dart';
import '../../../core/helpers/helper_fun.dart';
import '../../../language/locale.dart';
import '../../widgets/components/appbar.dart';
import '../booking_packages/cars_list_package.dart';
import '../booking_packages/widgets/daily_rent_body.dart';
import '../cars/presentaion/bloc/cubit/cars_cubit.dart';
import '../profile/blocs/profile_cubit/profile_cubit.dart';
import '../search_screen/blocs/search_bloc/search_cubit.dart';
import '../search_screen/blocs/search_bloc/search_state.dart';
import '../search_screen/data/models/filter_model.dart';

class Clasic extends StatefulWidget {
  const Clasic({super.key});

  @override
  State<Clasic> createState() => _ClasicState();
}

class _ClasicState extends State<Clasic> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: CustomAppBar(
        title:locale.pickupFromTheBranch,
        showBackButton: true,
        // showThemeToggle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(
            children: [
              BlocConsumer<SearchCubit, SearchState>(
                listener: (context, state) async {
                  if (state is SearchInvalid) {
                    HelperFunctions.dialog(
                      context: context,
                      title: locale!.dateInvalid,
                      body: state.props.first.toString(),
                    );
                  } else if (state is SearchValidate) {
                    final matchingBranches = context
                        .read<SearchCubit>()
                        .branchesData
                        .where((element) =>
                            element.name ==
                            context.read<SearchCubit>().selectedReceiveBranch)
                        .toList();

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
                          .getAllCars(
                        1,
                        branchId: triggeredBranchModel.id,
                        castClass:
                            context.read<ProfileCubit>().custClass.toString(),
                      )
                          .then((value) {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: CarsListPackage(filterModel: filterModel),
                        );
                      });
                    } else {
                      print(
                          "No matching branch found for the selected receive branch");
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
                  return Column(
                    children: [
                      context.read<SearchCubit>().rentType == RentType.classic
                          ? DailyRentBody()
                          : Container(),
                      SizedBox(height: Device.get().isTablet ? 60.h : 14.h),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
