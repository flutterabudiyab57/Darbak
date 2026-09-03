import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../language/locale.dart';
import '../../../widgets/components/appbar.dart';
import '../../data/models/branch.dart';
import 'branch_picker/branch_tile.dart';

/// The single branch picker for every booking flow, per
/// contracts/navigation-contract.md. Always reached via
/// `PersistentNavBarNavigator.pushNewScreen<Branch>(..., withNavBar: false)`,
/// which places this route OUTSIDE the caller's provider subtree
/// (`Navigator.of(context, rootNavigator: true)`).
///
/// **Constitution Principle II, NON-NEGOTIABLE: this screen and every widget
/// it owns read NO cubit — scoped or global.** No ancestor-provider lookup
/// of any kind (the flutter_bloc build-context resolvers, in any of their
/// widget or extension forms) and no service-locator resolution. Such a
/// lookup here throws a "provider not found" exception inside the tap
/// handler, aborting it silently before navigation runs — the exact
/// drop-off bug this rewrite exists to eliminate. See
/// `test/modules/location/pages/branch_picker_screen_test.dart` for the
/// guard test, and never "fix" a failure of that test by wrapping it in a
/// provider — remove the offending lookup instead.
///
/// This screen also does not know whether it is picking a pickup or a
/// dropoff location — there is no `isReceive` flag or equivalent here. The
/// caller alone decides that, by which setter it passes the popped [Branch]
/// to.
class BranchPickerScreen extends StatelessWidget {
  final List<Branch> branches;
  final int? selectedId;
  final String? emptyMessage;

  const BranchPickerScreen({
    super.key,
    required this.branches,
    this.selectedId,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      // showThemeToggle MUST stay false (its default) here. That flag is what
      // gates whether CustomAppBar builds its theme-toggle button, and that
      // button resolves the global ThemeCubit on tap — an ancestor-provider
      // lookup, which this root-navigator-pushed screen must never perform,
      // per Constitution Principle II. The picker's own grep gate does not
      // reach into CustomAppBar's file, so nothing here would statically
      // catch a flip to `true` — only the no-provider render test in
      // branch_picker_screen_test.dart would, and only once someone has
      // already shipped the change locally. Leave this false.
      appBar: CustomAppBar(
        title: locale.selectBranch ?? '',
        showBackButton: true,
      ),
      body: SafeArea(
        child: branches.isEmpty
            ? _EmptyBranchList(message: emptyMessage ?? locale.noBranchesToShow)
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return BranchTile(
                    key: ValueKey(branch.id),
                    branch: branch,
                    isSelected: branch.id == selectedId,
                    onTap: () => Navigator.pop(context, branch),
                  );
                },
              ),
      ),
    );
  }
}

/// The "no branches offer this service" state (US5 scenario 4 / FR-039).
/// Owned by [BranchPickerScreen] — part of the picker surface, reads no
/// cubit.
class _EmptyBranchList extends StatelessWidget {
  final String message;

  const _EmptyBranchList({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
