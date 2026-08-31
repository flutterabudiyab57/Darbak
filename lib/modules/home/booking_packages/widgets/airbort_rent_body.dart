import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_state.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../widgets/Dashed_divider.dart';
import '../../../widgets/show_error_dailog.dart';
import '../../../widgets/time_select.dart';
import '../../all_branching/data/models/branch_model.dart';
import '../../booking_from_cars/presentaion/view/widget/branchs.dart';
import '../../booking_from_cars/model/branch_from_cars_model.dart';
import '../../search_screen/presentaion/widget/rental_summary_card.dart';

class AirPortRentBody extends StatefulWidget {
  const AirPortRentBody({super.key});

  @override
  State<AirPortRentBody> createState() => _AirPortRentBodyState();
}

class _AirPortRentBodyState extends State<AirPortRentBody> {
  late bool searchError = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final searchCubit = context.read<SearchCubit>();
        final receiveDate = searchCubit.receiveDateValue;
        final driveDate = searchCubit.driveDateValue;

        print("Received: " + receiveDate.toString());
        print("Derive: " + driveDate.toString());
        context.read<SearchCubit>().updateDates(receiveDate, driveDate);
        final differenceInDays = context.read<SearchCubit>().differenceInDays;

        final airportBranchesList = searchCubit.airportBranchesData
            .map((branch) => Datum(
          id: branch.id ?? 0,
          text: branch.name ?? '',
          image: '',
          canBookToday: branch.bookToday ?? 0,
        ))
            .toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            child: Column(
              spacing:20.h,
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


                if (airportBranchesList.isNotEmpty)
                  BranchTile(
                    regions: airportBranchesList,
                    isRecieve: true,
                  ),
                 const TimeSelectTwoBox(),
                Center(child: RentalSummaryCard(differenceInDays: differenceInDays,)),
                dashedDivider(context),

                GestureDetector(
                  onTap: () async {
                    if (isLoading) return;
                    setState(() {
                      isLoading = true;
                    });
                    await onTap(context);
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
  }

  Future<void> onTap(BuildContext context) async {
    try {
      final searchCubit = BlocProvider.of<SearchCubit>(context);

      if (searchCubit.selectedReceiveBranch == null) {
        setState(() {
          searchError = true;
        });
        print("Error: Airport branch is not selected.");
        return;
      }

      setState(() {
        searchError = false;
      });

      final triggeredAirportBranch = searchCubit.airportBranchesData.firstWhere(
            (element) => element.name == searchCubit.selectedReceiveBranch,
        orElse: () => BranchModel(),
      );

      if (triggeredAirportBranch.id == null) {
        print("No matching airport branch found.");
        setState(() {
          searchError = true;
        });
        return;
      }

      searchCubit.selectedDriveModel = triggeredAirportBranch;
      searchCubit.selectedReceiveModel = triggeredAirportBranch;

      await searchCubit.validateDelivery();
    } catch (e) {
      print("Error in onTap: $e");
      setState(() {
        searchError = true;
      });
    }
  }
}