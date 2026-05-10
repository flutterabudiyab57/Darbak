import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabNavigationCubit extends Cubit<int> {
  TabNavigationCubit({int initialTab = 0}) : super(initialTab);

  void go(int tab) => emit(tab);
}

extension TabJump on BuildContext {
  void jumpToShellTab(int tab) {
    Navigator.of(this).popUntil((route) => route.isFirst);
    read<TabNavigationCubit>().go(tab);
  }
}
