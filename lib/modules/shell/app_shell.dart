import 'dart:io';

import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/helpers/settings/settings__cubit.dart';
import 'package:darbak/core/helpers/settings/settings_repository.dart';
import 'package:darbak/modules/home/profile/blocs/profile_cubit/profile_cubit.dart';
import 'package:darbak/modules/shell/bottom_nav_bar.dart';
import 'package:darbak/modules/shell/tab_scroll_registry.dart';
import 'package:darbak/modules/shell/update_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

/// Exposes the shell's [TabScrollRegistry] to the four tab pages so a same-tab
/// re-tap can scroll that tab's list back to the top. Root tab pages register
/// their [ScrollController] in `didChangeDependencies` via
/// [shellScrollRegistryOf] and unregister in `dispose`.
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

/// The tabbed app shell, now built as the `builder` of the root
/// `StatefulShellRoute.indexedStack`. It wraps go_router's [navigationShell]
/// (the IndexedStack of the four branch navigators) with the persistent
/// bottom-nav chrome. Each tab is its own branch with its own navigator and
/// preserved state; switching tabs is `navigationShell.goBranch(index)`.
///
/// The bottom nav appears only here — every detail route stays top-level (on
/// the root navigator), so pushing one covers this scaffold and hides the nav.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => SettingsCubit(SettingsRepository())..loadSettings(),
      child: _ShellScaffoldBody(navigationShell: navigationShell),
    );
  }
}

class _ShellScaffoldBody extends StatefulWidget {
  const _ShellScaffoldBody({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_ShellScaffoldBody> createState() => _ShellScaffoldBodyState();
}

class _ShellScaffoldBodyState extends State<_ShellScaffoldBody> {
  final TabScrollRegistry _scrollRegistry = TabScrollRegistry();

  @override
  void initState() {
    super.initState();
    // One-time shell side effects — run once when the shell first mounts, not
    // on every branch switch (the branch navigators persist, this State does
    // not rebuild across goBranch).
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
    // Same-tab re-tap scrolls that tab to the top; otherwise switch branch.
    // goBranch restores the target branch's existing stack (preserves state).
    if (index == widget.navigationShell.currentIndex) {
      _scrollRegistry.scrollToTop(index);
      return;
    }
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return _ShellScrollRegistryProvider(
      registry: _scrollRegistry,
      child: Scaffold(
        extendBody: true,
        body: widget.navigationShell,
        bottomNavigationBar: ShellBottomNavBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onTap: _handleNavTap,
        ),
      ),
    );
  }
}
