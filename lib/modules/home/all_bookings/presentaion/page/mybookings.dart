import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
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
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.03),
          child: Container(
            height: 60.h,
            padding: EdgeInsets.all(4.sp),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? backgroundColor(context)
                  : backgroundColor(context),
              borderRadius: BorderRadius.circular(6),
            ),
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

    return Container(
      margin:EdgeInsetsGeometry.symmetric(horizontal: 6.w) ,
      height: 50.h,
      decoration: BoxDecoration(
        gradient: isSelected ? secondary : null ,
        borderRadius: BorderRadius.circular(15.sp),
        border: isSelected
            ? null
            : Border.all(
                color: iconGrayColor(context),
                width:2.w,
              ),
      ),
      child: Center(
        child: Text(
          text,
          style: isSelected
              ? AppTypography.buttonText18(context)
              : AppTypography.headingColor18(context)
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
          style:AppTypography.mainTypographyColor20(context)
        ),
      ],
    );
  }
}
