import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bounce/bounce.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/search_screen/blocs/search_bloc/search_cubit.dart';
import 'package:darbak/modules/home/search_screen/presentaion/widget/monthly_package_widget.dart';
import 'package:darbak/modules/home/search_screen/presentaion/widget/offers_section_widget.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:darbak/core/router/routes.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../widgets/components/ad_gradient_btn.dart';
import '../../booking_from_cars/presentaion/view/widget/branches_card.dart';
import '../../home_screen/clasic.dart';
import '../../../../core/constants/api_path.dart';
import '../../../../core/constants/langCode.dart';
import '../../all_branching/bloc/all_branching_cubit.dart';
import '../../booking_packages/ui/airboart_package_screen.dart';
import '../../booking_packages/ui/monthly_package_screen.dart';
import '../../cars/presentaion/search_cars/search_about_car.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shell/app_shell.dart';
import '../../../shell/tab_navigation_cubit.dart';
import '../../../shell/tab_scroll_registry.dart';
import '../../offers/offers_tap_screen.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../../auth/signin/presentation/pages/signin_screen.dart';
import 'package:darbak/service_locator.dart';


class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key, this.skipLoginCheck = false}) : super(key: key);
  final bool skipLoginCheck;

  static Widget entry({bool skipLoginCheck = false}) =>
      BlocProvider<AllBranchCubit>(
        create: (_) => sl<AllBranchCubit>(),
        child: SearchScreen(skipLoginCheck: skipLoginCheck),
      );

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  String? points;
  Dio dio = Dio();
  bool _loginSheetShown = false;
  final ScrollController _scrollController = ScrollController();
  TabScrollRegistry? _registry;

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AllBranchCubit>(context).getAllBranch();
    _getRegions();
    BlocProvider.of<SearchCubit>(context).getOffers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.skipLoginCheck) {
        _checkTokenAndShowLogin();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final registry = shellScrollRegistryOf(context);
    if (registry != _registry) {
      _registry?.unregister(0, _scrollController);
      _registry = registry;
      _registry?.register(0, _scrollController);
    }
  }

  @override
  void dispose() {
    _registry?.unregister(0, _scrollController);
    _scrollController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _checkTokenAndShowLogin() async {
    if (_loginSheetShown) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      _showSignInBottomSheet();
    }
  }

  void _showSignInBottomSheet() {
    if (_loginSheetShown) return;
    _loginSheetShown = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity,),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FractionallySizedBox(
          child: SignInScreen(pushAddition: true),
        ),
      ),
    ).then((_) {
      _loginSheetShown = false;
    });
  }

  Future<void> _getRegions() async {
    await BlocProvider.of<SearchCubit>(context).getRegions();
  }

  Future<void> _fetchPointsData({required String idNumber}) async {
    try {
      final response = await dio.get(
        '${oracleApi}/customerSync/$idNumber',
        options: Options(headers: {
          "Accept": "application/json",
          'Accept-Language': langCode.isEmpty ? 'en' : langCode,
          'Content-Type': 'application/json',
        }),
      );

      final fetchedPoints = response.data['points'];
      if (mounted) {
        setState(() {
          points = fetchedPoints?.toString() ?? '0';
        });
      }
      print("Points fetching Successfully: $points");
    } catch (e) {
      print("Points fetching Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final locale = AppLocalizations.of(context);

    return Directionality(
      textDirection: locale!.isDirectionRTL(context)
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor(context),
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 80.hs(context),
          leadingWidth: 1.sw,
          leading: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return _buildLoadingHeader(locale);
              }

              if (state is ProfileSuccess || state is ProfileFailed) {
                return _buildProfileHeader(state, locale);
              }

              if (state is ProfileLogout || state is ProfileInitial) {
                return _buildLoadingHeader(locale);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        body: Padding(
          padding:   EdgeInsets.all(12.w),
          child: ListView(
            controller: _scrollController,
             children: [
              _buildTripCard(locale),
              SizedBox(height: 20.h,),
               Branches_Card(),
              // SizedBox(height: 20.h,),
              //  Image.asset(
              //    "assets/images/main-card.png",
              //    width: 78.w,
              //    height: 50.h,
              //    fit: BoxFit.fill,
              //  ),

               SizedBox(height: 20.h,),
               MonthlyPackageWidget(
                 onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => MonthlyPackageScreen.entry()),
                   );
                 },
               ),
               SizedBox(height: 20.h,),

               OffersSectionWidget(
                onViewAllTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OffersScreen()),
                  );
                },
              ),
              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingHeader(dynamic locale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Bounce(
                onTap: () {
                  context.jumpToShellTab(3);
                },
                child: DottedBorder(
                  borderType: BorderType.Circle,
                  padding: EdgeInsets.all(2.sp),
                  color: mainTypographyColor(context),
                  strokeWidth: 2.w,
                  child: Container(
                    padding: EdgeInsets.all(2.sp),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: strokeGrayColor(context), width: 1.0.w),
                    ),
                    child: CircleAvatar(
                      radius: 20.sp,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 7.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    '${locale.welcome2}',
                    style: TextStyle(
                      fontFamily: 'ThmanyahSans',
                      color: headingColor(context),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    minFontSize: 8,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AutoSizeText(
                    '${locale.letsBookCar}',
                    style: TextStyle(
                      color: paragraphColor(context),
                      fontFamily: 'ThmanyahSans',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileState state, dynamic locale) {
    final profileName = (state is ProfileSuccess)
        ? state.profileModel.name ?? ''
        : '';

    final idNumber = (state is ProfileSuccess &&
        state.profileModel.customerData != null)
        ? state.profileModel.customerData!.idNumber ?? ''
        : "0";

    final ImageProvider<Object>? avatarImage =
    ((state is ProfileSuccess &&
        state.profileModel.avatar != null &&
        state.profileModel.avatar!.isNotEmpty)
        ? NetworkImage(state.profileModel.avatar!)
        : const AssetImage('assets/icons/avatar.png'))
    as ImageProvider<Object>?;

    if (points == null) {
      _fetchPointsData(idNumber: idNumber);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bounce(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              if (token != null) {
                context.pushNamed(Routes.editProfile);
              }
            },
            child: DottedBorder(
              borderType: BorderType.Circle,
              padding: EdgeInsets.all(2.sp),
              color: mainTypographyColor(context),
              strokeWidth: 2.w,
              child: Container(
                padding: EdgeInsets.all(2.sp),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: strokeGrayColor(context), width: 1.0.w),
                ),
                child: CircleAvatar(
                  radius: 20.sp,
                  backgroundImage: avatarImage,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      '${locale.welcome}$profileName',
                      style: AppTypography.headingColor16(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AutoSizeText(
                      '${locale.letsBookCar}',
                      style: AppTypography.paragraphColor16(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Spacer(),
              //  _buildNotificationButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildNotificationButton() {
    return Bounce(
      onTap: () => context.pushNamed(Routes.notifications),
      child: Container(
      width: 45.w,
      height: 45.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: strokeGrayColor(context),
          width: 1.5.w,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 23.w,
          height: 24.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 1.h,
                child: SvgPicture.asset(
                  'assets/icons/notifications_Icon.svg',
                  color:Colors.blue,
                  width: 21.w,
                  height: 23.h,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB2C36),
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.11, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTripCard(dynamic locale) {
    return Container(
      padding:  EdgeInsets.all(20.w),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff0A708D).withValues(alpha: .5),
            Color(0xFF2BC181).withValues(alpha: .125),
            Color(0xff0A708D).withValues(alpha: .5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: strokeGrayColor(context), width: 1.5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            locale.makeYourTripEasier,
            style: AppTypography.headingColor26(context),
          ),
          AutoSizeText(
            locale.enjoyWithUsInEveryDestination,
            style: AppTypography.paragraphColor16(context),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    locale.receivingBranch,
                    style: AppTypography.headingColor14(context),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: _responsiveButton(
                      locale.branchs,
                          () {
                        BlocProvider.of<SearchCubit>(context)
                            .clearAllDataSearched();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Clasic.entry()),
                        );
                      },
                      Icon(
                        Icons.store_mall_directory,
                        color: strokeMainColor(context),
                        size: 25.sp,

                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    locale.receiveFromAirport,
                    style: AppTypography.headingColor14(context),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: _responsiveButton(
                      locale.airports,
                          () {
                        BlocProvider.of<SearchCubit>(context)
                            .clearAllDataSearched();
                        BlocProvider.of<SearchCubit>(context)
                            .getAirPortBranches();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AirportPackageScreen.entry()),
                        );
                      },
                      Icon(
                        Icons.airplane_ticket_outlined,
                        color: strokeMainColor(context),
                        size: 25.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Center(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, _, __) => SearchCarScreen(),
                    transitionsBuilder: (context, animation, _, child) =>
                        FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: ADGradientButton(
                locale.searchCar,
                icon: Icons.search_rounded,
                height:45.h,
                iconSize: 21.sp,
              )
              ,
            ),
          )
        ],
      ),
    );
  }

  Widget _responsiveButton(String label, VoidCallback onTap, Icon icon) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: strokeGrayColor(context), width: 1.5.w),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.h,vertical: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headingColor16(context),
                ),
              ),
              SizedBox(width: 18.w),
              icon,
            ],
          ),
        ),
      ),
    );
  }
}