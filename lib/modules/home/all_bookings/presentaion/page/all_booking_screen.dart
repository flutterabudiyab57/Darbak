import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/helpers/SharedPreference/pereferences.dart';
import '../../../../widgets/components/appbar.dart';
import '../../../../widgets/components/error_image.dart';
import '../../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../../search_screen/presentaion/widget/shimmer_list.dart';
import 'mybookings.dart';

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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AppShell(
          skipLoginCheckInSearch: true,
        ),
      ),
          (route) => false,
    );
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
      body: FutureBuilder<String?>(
        future: SharedPreferencesHelper().get("token"),
        builder: (context, snapshot) {
          // Loading state while checking token
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: ShimmerLoadingList());
          }

          final bool hasToken = snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty;

          if (!hasToken) {
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