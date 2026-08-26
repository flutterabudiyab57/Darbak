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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:darbak/core/router/routes.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:darbak/modules/shell/shell_bottom_bar_metrics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/assets/app_colors.dart';
import '../../../widgets/components/ad_gradient_btn.dart';
import '../../../widgets/components/gradient_hero_panel.dart';
import '../../booking_from_cars/presentaion/view/widget/branches_card.dart';
import '../../../../core/constants/api_path.dart';
import '../../../../core/constants/langCode.dart';
import '../../all_branching/bloc/all_branching_cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shell/app_shell.dart';
import '../../../shell/tab_jump.dart';
import '../../../shell/tab_scroll_registry.dart';
import '../../profile/blocs/profile_cubit/profile_cubit.dart';
import '../../../auth/signin/presentation/pages/signin_screen.dart';
import 'package:darbak/service_locator.dart';


class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  static Widget entry() => BlocProvider<AllBranchCubit>(
        create: (_) => sl<AllBranchCubit>(),
        child: SearchScreen(),
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
      // The search branch mounts once and is kept alive; this check is
      // token-guarded and runs at most once, so after sign-in the sheet
      // won't re-appear (no skip flag needed).
      _checkTokenAndShowLogin();
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
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity,),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FractionallySizedBox(
          child: SignInScreen(pushAddition: true, mode: SignInMode.gate),
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
        // No appBar: the hero panel is the first item of the scroll view so it
        // travels up with the content. With no appBar the body starts at y=0,
        // which is what lets the panel paint behind the status bar.
        body: ListView(
          controller: _scrollController,
          // ListView would otherwise inject MediaQuery padding at the top and
          // push the panel below the status bar; the panel's own SafeArea
          // handles that inset instead.
          padding: EdgeInsets.zero,
          children: [
            _buildHeroPanel(locale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                children: [
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
                   OffersSectionWidget(
                     onViewAllTap: () {
                       context.pushNamed(Routes.offers);
                     },
                   ),

                   SizedBox(height: 20.h,),
                   MonthlyPackageWidget(
                     onTap: () {
                       context.pushNamed(Routes.monthlyPackage);
                     },
                   ),
                ],
              ),
            ),
            SizedBox(height: shellBottomInset(context)),
          ],
        ),
      ),
    );
  }

  /// Height of the hero panel *below* the status bar.
  ///
  /// Figma frame is 390x844 — the same design size screenutil targets — so its
  /// pixels map 1:1 onto `.w` / `.h`.
  ///
  /// The panel lives inside the scroll view rather than in an `appBar`;
  /// [GradientHeroPanel] adds the status-bar inset on top of this value.
  static const double _heroPanelHeight = 400;

  Widget _buildHeroPanel(dynamic locale) {
    return GradientHeroPanel(
      height: _heroPanelHeight.hs(context),
      padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileSuccess || state is ProfileFailed) {
                return _buildProfileHeader(state, locale);
              }
              if (state is ProfileLoading ||
                  state is ProfileLogout ||
                  state is ProfileInitial) {
                return _buildLoadingHeader(locale);
              }
              return const SizedBox.shrink();
            },
          ),
          SizedBox(height: 27.h),
          // Figma insets the trip content to x=36 while the greeting row
          // sits at x=15; the extra 20 lands here.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _buildTripContent(locale),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingHeader(dynamic locale) {
    return _buildGreetingRow(
      title: '${locale.welcome2}',
      subtitle: '${locale.letsBookCar}',
      avatar: null,
      onAvatarTap: () => context.jumpToShellTab(3),
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

    return _buildGreetingRow(
      title: '${locale.welcome}$profileName',
      subtitle: '${locale.letsBookCar}',
      avatar: avatarImage,
      onAvatarTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          context.pushNamed(Routes.editProfile);
        }
      },
    );
  }

  /// Figma lays the bell at the far edge and the greeting + avatar at the
  /// opposite one. Under RTL the first child of a `Row` resolves to the right,
  /// so greeting-then-bell puts the bell on the visual left in Arabic and on
  /// the right in English — which is what each direction wants.
  Widget _buildGreetingRow({
    required String title,
    required String subtitle,
    required ImageProvider<Object>? avatar,
    required VoidCallback onAvatarTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Bounce(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 30.sp,
                  backgroundImage: avatar,
                  backgroundColor: onHeroPrimary.withValues(alpha: 0.15),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      title,
                      style: AppTypography.heroGreeting16(context),
                      minFontSize: 8,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AutoSizeText(
                      subtitle,
                      style: AppTypography.heroSubtitle16(context),
                      minFontSize: 8,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        // _buildNotificationButton(),
      ],
    );
  }
  Widget _buildNotificationButton() {
    return Bounce(
      onTap: () => context.pushNamed(Routes.notifications),
      child: Container(
      width: 45.w,
      height: 45.w,
      decoration: BoxDecoration(
        // Fixed white — the bell sits on the navy hero panel in both themes.
        color: onHeroPrimary,
        shape: BoxShape.circle,
        boxShadow: heroBellShadows,
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
                  colorFilter: ColorFilter.mode(
                    buttonColor(context),
                    BlendMode.srcIn,
                  ),
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

  Widget _buildTripContent(dynamic locale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // No explicit textAlign: under RTL `start` already resolves to the
        // right edge, and to the left edge in English.
        AutoSizeText(
          locale.makeYourTripEasier,
          style: AppTypography.heroTitle22(context),
          maxLines: 1,
          minFontSize: 12,
        ),
        SizedBox(height: 4.h),
        AutoSizeText(
          locale.enjoyWithUsInEveryDestination,
          style: AppTypography.heroSubtitle16(context),
          maxLines: 1,
          minFontSize: 10,
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _heroField(
              label: locale.receivingBranch,
              value: locale.branchs,
              icon: Icons.store_mall_directory,
              onTap: () {
                BlocProvider.of<SearchCubit>(context).clearAllDataSearched();
                context.pushNamed(Routes.classic);
              },
            ),
            _heroField(
              label: locale.receiveFromAirport,
              value: locale.airports,
              icon: Icons.airplane_ticket_outlined,
              onTap: () {
                BlocProvider.of<SearchCubit>(context).clearAllDataSearched();
                BlocProvider.of<SearchCubit>(context).getAirPortBranches();
                context.pushNamed(Routes.airportPackage);
              },
            ),
          ],
        ),
        SizedBox(height: 16.h),
        InkWell(
          onTap: () {
            context.pushNamed(Routes.searchAboutCar);
          },
          // Passing a solid backgroundColor disables ADGradientButton's
          // gradient, giving the white-on-navy CTA the design calls for.
          child: ADGradientButton(
            locale.searchCar,
            icon: Icons.search_rounded,
            height: 45.hs(context),
            iconSize: 21.sp,
            backgroundColor: onHeroPrimary,
            textColor: heroPanelGradient.colors.first,
            iconColor: heroPanelGradient.colors.first,
            textStyle: AppTypography.buttonText18(context)
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  /// One of the two hero selectors: a small bold label sitting above a
  /// white-outlined pill. Fixed 142 wide so the pair spans the 320 content
  /// column exactly (142 + 36 gap + 142).
  Widget _heroField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 142.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AutoSizeText(
            label,
            style: AppTypography.heroLabel12(context),
            maxLines: 1,
            minFontSize: 8,
          ),
          SizedBox(height: 8.h),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              height: 42.hs(context),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                border: Border.all(color: onHeroPrimary, width: 1.5.w),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: AutoSizeText(
                      value,
                      style: AppTypography.heroField16(context),
                      maxLines: 1,
                      minFontSize: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(icon, color: onHeroPrimary, size: 22.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}