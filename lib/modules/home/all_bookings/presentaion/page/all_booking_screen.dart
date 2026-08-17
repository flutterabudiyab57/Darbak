import 'package:darbak/language/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../widgets/components/appbar.dart';
import '../../../../widgets/components/error_image.dart';
import '../../../profile/blocs/profile_cubit/profile_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'mybookings.dart';
import '../../../../auth/blocs/auth_status_cubit.dart';

class AllBookingScreen extends StatefulWidget {
  final bool? isBottomSheet;

  AllBookingScreen({Key? key, this.isBottomSheet}) : super(key: key);

  @override
  State<AllBookingScreen> createState() => _AllBookingScreenState();
}

class _AllBookingScreenState extends State<AllBookingScreen> {
  Key _myBookingsKey = UniqueKey();

  @override
  void initState() {
    super.initState();
  }

  void _navigateToHome() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: CustomAppBar(
        title: locale.myBookings.toString(),
        // showThemeToggle: true,
      ),
      body: BlocBuilder<AuthStatusCubit, AuthState>(
        builder: (context, authState) {
          if (authState is AuthUnknown) {
            return const _BookingsSkeleton();
          }

          if (authState is AuthGuest || authState is! AuthAuthenticated) {
            return ErrorImage(
              refresh: () {
                setState(() {});
              },
              error: "Not Authenticated",
              onLoginSuccess: _navigateToHome,
            );
          }

          return BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileSuccess) {
                setState(() {
                  _myBookingsKey = UniqueKey();
                });
              }
            },
            builder: (context, state) {
              return MyBookings(key: _myBookingsKey);
            },
          );
        },
      ),
    );
  }
}

class _BookingsSkeleton extends StatelessWidget {
  const _BookingsSkeleton();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Skeletonizer.zone(
      child: Column(
        children: [
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.03),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Bone(
                height: 60.h,
                width: double.infinity,
                borderRadius: BorderRadius.all(Radius.circular(6.r)),
              ),
            ),
          ),
          for (int i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Bone(
                height: 140.h,
                width: double.infinity,
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
              ),
            ),
        ],
      ),
    );
  }
}