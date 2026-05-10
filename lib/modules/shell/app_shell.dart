import 'dart:io';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/helpers/settings/settings__cubit.dart';
import 'package:darbak/core/helpers/settings/settings_repository.dart';
import 'package:darbak/modules/home/all_bookings/presentaion/page/all_booking_screen.dart';
import 'package:darbak/modules/home/cars/presentaion/all_cars_screen.dart';
import 'package:darbak/modules/home/profile/blocs/profile_cubit/profile_cubit.dart';
import 'package:darbak/modules/home/profile/page/profile.dart';
import 'package:darbak/modules/home/search_screen/presentaion/search_Screen.dart';
import 'package:darbak/modules/shell/bottom_nav_bar.dart';
import 'package:darbak/modules/shell/tab_navigation_cubit.dart';
import 'package:darbak/modules/shell/tab_scroll_registry.dart';
import 'package:darbak/modules/shell/update_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

class _ShellScrollRegistryProvider extends InheritedWidget {
  const _ShellScrollRegistryProvider({
    required this.registry,
    required super.child,
  });

  final TabScrollRegistry registry;

  static TabScrollRegistry? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ShellScrollRegistryProvider>()
        ?.registry;
  }

  @override
  bool updateShouldNotify(_ShellScrollRegistryProvider oldWidget) =>
      registry != oldWidget.registry;
}

TabScrollRegistry? shellScrollRegistryOf(BuildContext context) =>
    _ShellScrollRegistryProvider.maybeOf(context);

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    this.initialTab = 0,
    this.skipLoginCheckInSearch = false,
  });

  final int initialTab;
  final bool skipLoginCheckInSearch;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(SettingsRepository())..loadSettings(),
        ),
        BlocProvider<TabNavigationCubit>(
          create: (_) => TabNavigationCubit(initialTab: initialTab),
        ),
      ],
      child: _AppShellBody(
        skipLoginCheckInSearch: skipLoginCheckInSearch,
      ),
    );
  }
}

class _AppShellBody extends StatefulWidget {
  const _AppShellBody({required this.skipLoginCheckInSearch});

  final bool skipLoginCheckInSearch;

  @override
  State<_AppShellBody> createState() => _AppShellBodyState();
}

class _AppShellBodyState extends State<_AppShellBody> {
  final GlobalKey<CurvedNavigationBarState> _bottomKey = GlobalKey();
  final TabScrollRegistry _scrollRegistry = TabScrollRegistry();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SearchScreen(skipLoginCheck: widget.skipLoginCheckInSearch),
      const AllCarsScreen(fromFilter: false, filterModel: null),
      AllBookingScreen(),
      const MyProfile(),
    ];
    BlocProvider.of<ProfileCubit>(context).getProfile();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(packageInfo.version);

      final response = await Dio().get(checkVersionUpdate);
      final data = response.data as Map<String, dynamic>;

      if (!mounted) return;
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

  void _showUpdateDialog(String url) {
    showDialog(
      context: context,
      builder: (_) => UpdateDialog(storeUrl: url),
    );
  }

  void _handleNavTap(int index) {
    final cubit = context.read<TabNavigationCubit>();
    if (cubit.state == index) {
      _scrollRegistry.scrollToTop(index);
      return;
    }
    cubit.go(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabNavigationCubit, int>(
      builder: (context, selectedIndex) {
        return _ShellScrollRegistryProvider(
          registry: _scrollRegistry,
          child: Scaffold(
            extendBody: true,
            body: IndexedStack(
              index: selectedIndex,
              children: _pages,
            ),
            bottomNavigationBar: ShellBottomNavBar(
              navKey: _bottomKey,
              selectedIndex: selectedIndex,
              onTap: _handleNavTap,
            ),
          ),
        );
      },
    );
  }
}
