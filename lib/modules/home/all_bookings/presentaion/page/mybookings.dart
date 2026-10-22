import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/all_bookings/presentaion/page/widget/bookingStatus/previousOrders.dart';
import 'package:darbak/modules/home/all_bookings/presentaion/page/widget/bookingStatus/running_now.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/allbooking_cubit.dart';

class MyBookings extends StatefulWidget {
  const MyBookings({Key? key}) : super(key: key);

  @override
  _MyBookingsState createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AllBookingCubit>(context).getAllBooking(state: 'running');

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var locale = AppLocalizations.of(context)!;

    return Column(
      children: [
        SizedBox(height: 21.h),
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TabBar(
              controller: tabController,
              indicator: const BoxDecoration(),
              labelPadding: EdgeInsets.zero,
              dividerColor: Colors.transparent,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              tabs: [
                _buildTab(
                  index: 0,
                  size: size,
                  text: locale.ongoingBooking,
                ),
                _buildTab(
                  index: 1,
                  size: size,
                  text: locale.previousBooking,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              RunningNow(),
              PreviousOrders(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab({
    required int index,
    required Size size,
    required String text,
  }) {
    final bool isSelected = currentIndex == index;

    // Figma: text tabs with an underline on the active one, not filled pills.
    return Container(
      height: 40.hs(context),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2.w,
            color: isSelected ? headingColor(context) : Colors.transparent,
          ),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: isSelected
              ? AppTypography.headingColor18(context)
              : AppTypography.headingColor18(context)
                  .copyWith(color: iconGrayColor(context)),
        ),
      ),
    );
  }

  Widget whenOrdersNull(locale) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/emptystate.png'),
        SizedBox(height: 25.sp),
        Text(
          locale.noCarsBooking1.toString(),
          style: AppTypography.secondaryTypographyColor20(context),
        ),
      ],
    );
  }
}
