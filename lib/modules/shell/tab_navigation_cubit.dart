import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TabNavigationCubit extends Cubit<int> {
  TabNavigationCubit({int initialTab = 0}) : super(initialTab);

  void go(int tab) => emit(tab);
}

extension TabJump on BuildContext {
  void jumpToShellTab(int tab) {
    try {
      // Fast path — already inside the shell. Flip the cubit so AppShell
      // is not remounted (preserves IndexedStack tab state and avoids
      // re-running _checkVersion + ProfileCubit.getProfile in initState).
      read<TabNavigationCubit>().go(tab);
    } on ProviderNotFoundException {
      // Slow path — caller sits outside the shell. Re-enter via the router.
      GoRouter.of(this).go('/shell?tab=$tab');
    }
  }
}
