import 'package:flutter/material.dart';

class TabScrollRegistry {
  final Map<int, ScrollController> _controllers = {};

  void register(int tab, ScrollController controller) {
    _controllers[tab] = controller;
  }

  void unregister(int tab, ScrollController controller) {
    if (_controllers[tab] == controller) {
      _controllers.remove(tab);
    }
  }

  void scrollToTop(int tab) {
    final controller = _controllers[tab];
    if (controller == null || !controller.hasClients) return;
    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
