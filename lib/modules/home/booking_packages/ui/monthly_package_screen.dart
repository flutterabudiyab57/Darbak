import 'package:darbak/modules/home/booking_packages/cars_monthly_screan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_state.dart';
import 'package:darbak/modules/home/search_screen/data/models/filter_model.dart';
import 'package:darbak/core/helpers/enums.dart';
import 'package:darbak/core/helpers/helper_fun.dart';

import '../../../../core/constants/assets/app_colors.dart';
import '../../../../language/locale.dart';
import '../../../widgets/components/appbar.dart';
import '../../all_branching/bloc/all_branching_cubit.dart';
import '../../cars/presentaion/bloc/cubit/cars_cubit.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../search_screen/presentaion/widget/shimmer_list.dart';
import '../widgets/monthly_rent_body.dart';
import 'package:darbak/service_locator.dart';

class MonthlyPackageScreen extends StatefulWidget {
  const MonthlyPackageScreen({super.key});

  static Widget entry() => MultiBlocProvider(
        providers: [
          BlocProvider<AllBranchCubit>(create: (_) => sl<AllBranchCubit>()),
          BlocProvider<CarsCubit>(create: (_) => sl<CarsCubit>()),
        ],
        child: const MonthlyPackageScreen(),
      );

  @override
  State<MonthlyPackageScreen> createState() => _MonthlyPackageScreenState();
}

class _MonthlyPackageScreenState extends State<MonthlyPackageScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AllBranchCubit>(context).getAllBranch();
    _getRegions();
  }

  Future<void> _getRegions() async {
    await BlocProvider.of<SearchCubit>(context).getRegions();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor(context),
      appBar:   CustomAppBar(
        title:locale!.isDirectionRTL(context)
            ? "الباقات الشهريه"
            : "Monthly Packages",
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
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: CarsMonthlyScreen.entry(filterModel: filterModel));
                  });
                } else {
                  print(
                      "No matching branch found for the selected receive branch");
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
                          ? MonthlyRentBody()
                          : Container(),
                      SizedBox(
                        height:20.h,
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
