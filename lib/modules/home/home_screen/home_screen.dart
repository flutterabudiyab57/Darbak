
import 'dart:io';
import 'package:bounce/bounce.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/modules/home/profile/page/profile.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:darbak/modules/home/cars/presentaion/all_cars_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import '../../../core/constants/api_path.dart';
import '../../../core/helpers/settings/settings__cubit.dart';
import '../../../core/helpers/settings/settings_repository.dart';
import '../../../language/locale.dart';
import '../../widgets/components/ad_gradient_btn.dart';
import '../all_bookings/presentaion/page/all_booking_screen.dart';
import '../profile/blocs/profile_cubit/profile_cubit.dart';
import '../search_screen/presentaion/search_Screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key, this.skipLoginCheckInSearch = false})
      : super(key: key);
  final bool skipLoginCheckInSearch;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => SettingsCubit(SettingsRepository())..loadSettings(),
      child: _HomeScreenBody(skipLoginCheckInSearch: skipLoginCheckInSearch),
    );
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody({Key? key, required this.skipLoginCheckInSearch})
      : super(key: key);
  final bool skipLoginCheckInSearch;

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  int _selectedPos = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomKey = GlobalKey();
  late final PageController _pageController;

  List<Widget> get _pages => [
    SearchScreen(skipLoginCheck: widget.skipLoginCheckInSearch),
    AllCarsScreen(fromFilter: false, filterModel: null),
    AllBookingScreen(),
    MyProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPos);
    BlocProvider.of<ProfileCubit>(context).getProfile();
    _checkVersion();
    // _checkAndRequestGalleryPermission();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Future<void> _checkAndRequestGalleryPermission() async {
  //   Permission permission;
  //
  //   if (Platform.isAndroid) {
  //     final androidInfo = await DeviceInfoPlugin().androidInfo;
  //     permission = androidInfo.version.sdkInt >= 33
  //         ? Permission.photos
  //         : Permission.storage;
  //   } else {
  //     permission = Permission.photos;
  //   }
  //
  //   final status = await permission.status;
  //   if (status.isGranted) return;
  //
  //   final result = await permission.request();
  //   if (result.isPermanentlyDenied) _showPermissionDialog();
  // }

  Future<void> _checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(packageInfo.version);

      final response = await Dio().get(checkVersionUpdate);
      final data = response.data as Map<String, dynamic>;

      final appSettings = context.read<SettingsCubit>().current;

      if (Platform.isAndroid) {
        final serverAndroid = Version.parse(data['android'] as String);
        final isHuawei = await _isHuaweiDevice();

        if (currentVersion < serverAndroid) {
          final storeUrl =
          isHuawei ? appSettings.apps.huawei : appSettings.apps.android;
          if (mounted) _showUpdateDialog(storeUrl);
        }
      } else if (Platform.isIOS) {
        final serverIOS = Version.parse(data['ios'] as String);
        if (currentVersion < serverIOS) {
          if (mounted) _showUpdateDialog(appSettings.apps.apple);
        }
      }
    } catch (e) {
      debugPrint('checkVersion error: $e');
    }
  }

  Future<bool> _isHuaweiDevice() async {
    if (!Platform.isAndroid) return false;
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.manufacturer.toLowerCase() == 'huawei';
    } catch (_) {
      return false;
    }
  }

  // void _showPermissionDialog() {
  //   final locale = AppLocalizations.of(context)!;
  //   final isRTL = locale.isDirectionRTL(context);
  //
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: Text(
  //         isRTL ? 'إذن الوصول للصور' : 'Gallery Permission',
  //         style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 16.sp),
  //       ),
  //       content: Text(
  //         isRTL
  //             ? 'التطبيق يحتاج إذن الوصول للصور لتحديث صورة الملف الشخصي. يرجى تفعيل الإذن من الإعدادات.'
  //             : 'The app needs gallery access to update your profile picture. Please enable it from settings.',
  //         style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14.sp),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             isRTL ? 'إلغاء' : 'Cancel',
  //             style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14.sp),
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             openAppSettings();
  //             Navigator.pop(context);
  //           },
  //           child: Text(
  //             isRTL ? 'الإعدادات' : 'Settings',
  //             style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14.sp),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showUpdateDialog(String url) {
    showDialog(
      context: context,
      builder: (_) => _UpdateDialog(storeUrl: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: _BottomNavBar(
        navKey: _bottomKey,
        selectedIndex: _selectedPos,
        onTap: (index) {
          setState(() => _selectedPos = index);
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.navKey,
    required this.selectedIndex,
    required this.onTap,
  });

  final GlobalKey<CurvedNavigationBarState> navKey;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return CurvedNavigationBar(
      key: navKey,
      index: selectedIndex,
      backgroundColor: Colors.transparent,
      color: buttonTextColor(context),
      buttonBackgroundColor: Colors.transparent,
      height: 90.h,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        _navItem(context: context, assetPath: 'assets/icons/home.png', label: locale.home!, width: 30.w, height: 30.h, index: 0),
        _navItem(context: context, assetPath: 'assets/icons/car.png', label: locale.fleet!, width: 25.w, height: 25.h, index: 1),
        _navItem(context: context, assetPath: 'assets/icons/reservations.png', label: locale.finish!, width: 28.w, height: 28.h, index: 2),
        _navItem(context: context, assetPath: 'assets/icons/more.png', label: locale.more, width: 30.w, height: 30.h, index: 3),
      ],
      onTap: onTap,
    );
  }

  CurvedNavigationBarItem _navItem({
    required BuildContext context,
    required String assetPath,
    required String label,
    required double width,
    required double height,
    required int index,
  }) {
    final isSelected = index == selectedIndex;

    return CurvedNavigationBarItem(
      child: Container(
        width: 50.w,
        height: 50.h,
        decoration: isSelected
            ? BoxDecoration(
          gradient: gradient2(context),
          shape: BoxShape.circle,
        )
            : null,
        alignment: Alignment.center,
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          color: isSelected ? Colors.white : iconGrayColor(context),
        ),
      ),
      label: label,
      labelStyle: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        color: isSelected ? buttonBlueColor(context) : iconGrayColor(context),
        fontSize: 16.sp,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
      ),
    );
  }
}

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({required this.storeUrl});
  final String storeUrl;

  Future<void> _launch() async {
    if (await canLaunch(storeUrl)) await launch(storeUrl);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(8.h),
            child: SvgPicture.asset(
              'assets/icons/update_version.svg',
              height: MediaQuery.of(context).size.height * 0.12,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            locale.updateAvailable,
            style: AppTypography.mainTypographyColor14(context),
          ),
          SizedBox(height: 6.h),
          Text(
            locale.updateAvailableMessage,
            style: AppTypography.headingColor14(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Center(
            child: Bounce(
              onTap: () {
                _launch();
                Navigator.of(context).pop();
              },
              child: ADGradientButton(
                locale.updateNow,
                width: MediaQuery.of(context).size.width * 0.6,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}