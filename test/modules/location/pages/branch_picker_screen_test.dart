import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/location/data/models/branch.dart';
import 'package:darbak/modules/location/presentaion/pages/branch_picker_screen.dart';

Branch fakeBranch({
  required int id,
  String name = 'Branch',
  String? address,
  String? regionName,
  bool bookToday = false,
}) {
  return Branch(
    id: id,
    name: name,
    address: address,
    regionName: regionName,
    bookToday: bookToday,
    isPartial: false,
  );
}

/// The app's real fixed design size — matches `main.dart`'s `ScreenUtilInit`,
/// so `.w`/`.h`/`.sp`/`.r` behave the same in tests as at runtime.
Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: child,
    ),
  );
}

void main() {
  group('BranchPickerScreen — Constitution Principle II guard', () {
    // THIS IS THE GUARD. It pumps the FULL screen with NO BlocProvider
    // ancestor anywhere in the tree — not scoped, not global — in both the
    // populated-list and empty-state cases, so every helper widget the
    // screen builds (BranchTile, the empty-state widget) actually mounts.
    //
    // If this test ever starts failing, the fix is to REMOVE the cubit read
    // that was added — never "fix" it by wrapping this pump in a
    // BlocProvider. Wrapping it in a provider defeats the entire point: this
    // test is what turns a Principle II violation into a red test here,
    // instead of a release-only silent failure inside a tap handler on the
    // root navigator (see contracts/navigation-contract.md).
    testWidgets(
      'renders bare, with no BlocProvider ancestor at all — populated and empty',
      (tester) async {
        final branches = [
          fakeBranch(id: 1, name: 'Alpha', address: '123 Main St'),
          fakeBranch(id: 2, name: 'Beta', regionName: 'Riyadh', bookToday: true),
        ];

        await tester.pumpWidget(_wrap(BranchPickerScreen(branches: branches)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Alpha'), findsOneWidget);
        expect(find.text('Beta'), findsOneWidget);

        await tester.pumpWidget(_wrap(const BranchPickerScreen(branches: [])));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  testWidgets('tapping a branch pops that Branch, by identity', (tester) async {
    final branches = [
      fakeBranch(id: 1, name: 'Alpha'),
      fakeBranch(id: 2, name: 'Beta'),
    ];
    Object? popped = 'not set';

    await tester.pumpWidget(_wrap(Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              popped = await Navigator.of(context).push<Branch>(
                MaterialPageRoute(
                  builder: (_) => BranchPickerScreen(branches: branches),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    )));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    expect(popped, same(branches[1]));
  });

  testWidgets('popping without a tap yields null', (tester) async {
    final branches = [fakeBranch(id: 1, name: 'Alpha')];
    Object? popped = 'not set';

    await tester.pumpWidget(_wrap(Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              popped = await Navigator.of(context).push<Branch>(
                MaterialPageRoute(
                  builder: (_) => BranchPickerScreen(branches: branches),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    )));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Back-out with no selection — the caller sees "no change".
    Navigator.of(tester.element(find.byType(BranchPickerScreen))).pop();
    await tester.pumpAndSettle();

    expect(popped, isNull);
  });

  testWidgets('selectedId marks the right row, by id — not name or index', (tester) async {
    final branches = [
      fakeBranch(id: 1, name: 'Alpha'),
      fakeBranch(id: 2, name: 'Beta'),
      fakeBranch(id: 3, name: 'Gamma'),
    ];

    await tester.pumpWidget(_wrap(BranchPickerScreen(branches: branches, selectedId: 2)));
    await tester.pumpAndSettle();

    // Exactly one selection indicator, on the row whose id matches — never on
    // the others, regardless of name or list position.
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    // The check icon sits within Beta's row (id 2), and nowhere else.
    expect(
      find.descendant(
        of: find.ancestor(of: find.text('Beta'), matching: find.byType(InkWell)),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.ancestor(of: find.text('Alpha'), matching: find.byType(InkWell)),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.ancestor(of: find.text('Gamma'), matching: find.byType(InkWell)),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsNothing,
    );
  });

  testWidgets('empty list shows the message, not a blank list', (tester) async {
    await tester.pumpWidget(_wrap(const BranchPickerScreen(
      branches: [],
      emptyMessage: 'No branches serve this request',
    )));
    await tester.pumpAndSettle();

    expect(find.text('No branches serve this request'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets(
    'two branches with equal names but different ids are distinct rows',
    (tester) async {
      final branches = [
        fakeBranch(id: 1, name: 'Same Name'),
        fakeBranch(id: 2, name: 'Same Name'),
      ];

      await tester.pumpWidget(_wrap(BranchPickerScreen(branches: branches)));
      await tester.pumpAndSettle();

      expect(find.text('Same Name'), findsNWidgets(2));
      expect(find.byKey(const ValueKey(1)), findsOneWidget);
      expect(find.byKey(const ValueKey(2)), findsOneWidget);
    },
  );
}
