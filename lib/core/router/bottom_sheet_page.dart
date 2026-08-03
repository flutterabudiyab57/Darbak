import 'package:flutter/material.dart';

/// A go_router-compatible [Page] that visually replicates the app's previous
/// `showModalBottomSheet(isScrollControlled: true, backgroundColor:
/// Colors.transparent, constraints: BoxConstraints(maxWidth: double.infinity),
/// isDismissible: false, enableDrag: false)` call, but as a real declarative
/// route. Registering the content as a route (instead of pushing it
/// imperatively) means a single `context.go(...)` handles both removing this
/// page and inserting the destination in one GoRouter reconciliation pass —
/// no manual `Navigator.pop` needed first.
class BottomSheetPage<T> extends Page<T> {
  final Widget child;

  const BottomSheetPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  // Matches Flutter's ModalBottomSheetRoute defaults (bottom_sheet.dart):
  // 250ms in / 200ms out, Material's standard decelerate easing.
  static const Duration _enterDuration = Duration(milliseconds: 250);
  static const Duration _exitDuration = Duration(milliseconds: 200);
  static const Curve _curve = Cubic(0.0, 0.0, 0.2, 1.0);

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      opaque: false,
      barrierDismissible: false, // matches isDismissible: false
      barrierColor: Colors.black54, // ModalBottomSheetRoute's default scrim
      transitionDuration: _enterDuration,
      reverseTransitionDuration: _exitDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return WillPopScope(
          onWillPop: () async => false, // system back does nothing
          child: Material(
            type: MaterialType.transparency, // backgroundColor: Colors.transparent
            child: Align(
              alignment: Alignment.bottomCenter,
              // No drag-to-dismiss gesture is attached, matching enableDrag: false.
              child: child,
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: _curve)),
          child: child,
        );
      },
    );
  }
}
