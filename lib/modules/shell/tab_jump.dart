import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';

/// Jump to one of the shell's four tabs from anywhere — inside a branch, inside
/// a pushed detail route, or outside the shell entirely.
///
/// With `StatefulShellRoute`, navigating to a branch's root location switches
/// to that branch (preserving the other branches' state). A single
/// `go(pathForShellTab(tab))` works uniformly from every call site, replacing
/// the old fast/slow-path split that existed while the shell was a single
/// `/shell?tab=N` route.
extension TabJump on BuildContext {
  void jumpToShellTab(int tab) => go(Routes.pathForShellTab(tab));
}
