import 'package:dio/dio.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/modules/home/profile/page/widget/login_noAuth.dart';
import 'package:darbak/modules/shell/app_shell.dart';
import 'package:darbak/modules/shell/tab_scroll_registry.dart';
import 'package:darbak/modules/widgets/call_us.dart';
import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/profile/page/privacy_policy/privacy_policy.dart';
import 'package:darbak/modules/home/profile/page/widget/card_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../../core/helpers/SharedPreference/pereferences.dart';
import '../../../widgets/components/ad_gradient_btn.dart';
import '../../../widgets/components/appbar.dart';
import '../../all_bookings/presentaion/bloc/allbooking_cubit.dart';
import '../../all_branching/page/branches_screen.dart';
import '../../cash_back/screen/CashBackScreen.dart';
import '../../complaints/screen/complaint_screen.dart';
import '../../complaints/cubit/complaint_cubit.dart';
import '../../complaints/data/complaint_repository.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../selectLanguage/selectLanguage.dart';
import '../blocs/profile_cubit/profile_cubit.dart';
import 'edit_profile/presentaion/page/edit_profile.dart';
import '../../../auth/blocs/auth_status_cubit.dart';
import 'favourites/favourites.dart';

class MyProfile extends StatelessWidget {
  final bool showBackButton;

  const MyProfile({Key? key, this.showBackButton = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.hs(context)),
        child: Stack(
          children: [
            CustomAppBar(
              title: locale.myAccount,
              showThemeToggle: true,
              showBackButton: showBackButton,

            )
          ],
        ),
      ),
      body: BlocBuilder<AuthStatusCubit, bool?>(
        builder: (context, isAuthenticated) {
          if (isAuthenticated == null) {
            return const _ProfileSkeleton();
          }
          if (!isAuthenticated) {
            return LoginNoAuth();
          }
          return _ProfileContent();
        },
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            for (int i = 0; i < 8; i++)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                child: Bone(
                  height: 55.h,
                  width: double.infinity,
                  borderRadius: BorderRadius.all(Radius.circular(16.r)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent({Key? key}) : super(key: key);

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  final ScrollController _scrollController = ScrollController();
  TabScrollRegistry? _registry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final registry = shellScrollRegistryOf(context);
    if (registry != _registry) {
      _registry?.unregister(3, _scrollController);
      _registry = registry;
      _registry?.register(3, _scrollController);
    }
  }

  @override
  void dispose() {
    _registry?.unregister(3, _scrollController);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      child: Column(
        spacing: 15.h,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          CardTileWidget(
            title: locale.editProfile.toString(),
            icon: Assets.prooff,
            ontap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: EditProfile(),
              );
            },
          ),
          CardTileWidget(
            title: locale.wallet.toString(),
            icon: Assets.icon_wallet,
            ontap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: CashbackScreen(),
              );
            },
          ),
          CardTileWidget(
            title: locale.selectLanguage.toString(),
            icon: Assets.profile_language,
            ontap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: SelectLanguage(),
              );
            },
          ),
          CardTileWidget(
            title: locale.branches!,
            icon: Assets.icon_picker,
            ontap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: BranchesScreen.entry(),
              );
            },
          ),
          CardTileWidget(
            title: locale.privacyPolicy.toString(),
            icon: Assets.profile_privacy,
            ontap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: PrivacyPolicyScreen(),
              );
            },
          ),
          CardTileWidget(
            title: locale.favorite.toString(),
            icon: Assets.profile_favorites,
            ontap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: Favourites(),
                withNavBar: false,
              );
            },
          ),
          CardTileWidget(
            title: locale.callUs.toString(),
            ontap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: CallUs(),
              );
            },
            icon: Assets.callUs,
          ),
          CardTileWidget(
            title: Localizations.localeOf(context).languageCode == 'ar'
                ? 'شكاوي'
                : 'Complaints',
            ontap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: BlocProvider(
                  create: (_) => ComplaintCubit(ComplaintRepository(Dio())),
                  child: ComplaintScreen(),
                ),
              );
            },
            icon: Assets.icon_complaint,
          ),
          GestureDetector(
            onTap: () {
              _showLogoutDialog(context, locale);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 10.h),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      Assets.logout,
                      width: 30.w,
                      height: 30.h,
                      color: Color(0xffFF0004),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      locale.logout.toString(),
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffFF0004),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 182.h),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations locale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
          decoration: BoxDecoration(
            color: buttonWhiteColor(context),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.logout.toString(),
                style: AppTypography.headingColor20(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                locale.areYouSurelogout.toString(),
                style: AppTypography.paragraphColor16(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.r),
                      onTap: () => Navigator.pop(context),
                      child: ADGradientButton(
                        locale.no.toString(),
                        backgroundColor: buttonSecondaryColor(context),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.r),
                      onTap: () async {
                        Navigator.pop(context);

                        await SharedPreferencesHelper().remove("token");
                        context.read<ProfileCubit>().logOut();
                        context.read<AllBookingCubit>().booking = null;
                        context.read<AuthStatusCubit>().markSignedOut();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppShell(
                              skipLoginCheckInSearch: false,
                            ),
                          ),
                          (route) => false,
                        );
                      },
                      child: ADGradientButton(
                        locale.yes,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
