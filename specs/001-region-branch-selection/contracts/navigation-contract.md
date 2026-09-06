# Contract: `BranchPickerScreen` — Constitution Principle II

**NON-NEGOTIABLE.** This contract exists because violating it produced the drop-off bug this
rewrite exists to eliminate.

## The mechanism

The picker is pushed with **`Navigator.of(context, rootNavigator: true).push(...)`, called
directly** — not via `PersistentNavBarNavigator.pushNewScreen(..., withNavBar: false)`. The pushed
route is therefore placed **outside the caller's provider subtree**, exactly as it would be either
way: `withNavBar: false` in that helper resolves internally to this same `rootNavigator: true`, so
calling it directly is not a weaker placement — it is the identical placement, made explicit instead
of routed through a helper that also does something else.

**Why not the helper.** `PersistentNavBarNavigator.pushNewScreen<T>(...)` throws at runtime when
`T` is a concrete type. Its internal `_getPageRoute()` always builds an untyped
`CupertinoPageRoute<dynamic>` and then does `... as Route<T>` on it — a cast that fails with `type
'CupertinoPageRoute<dynamic>' is not a subtype of type 'Route<Branch>'`. This is a defect in
`persistent_bottom_nav_bar` 6.2.1 itself, discovered when `BranchPickerScreen` first needed a typed
return value (`Route<Branch>`, to get the picked branch back via `pop`). Every other call site in
this app invokes the helper with no generic argument at all (fire-and-forget, no return value), so
none of them exercises the bug. The exception is thrown **inside the tap handler**, after the
gesture has already been accepted, so nothing in the tap handler's own try/catch — there wasn't
one — could tell the renter what happened: the branch row is tapped and nothing visibly occurs.

Diagnosed on-device: pickup options loaded correctly (the row's enabled state changed), the tap
handler was entering (confirmed with a temporary debug print), but the push itself threw before any
route ever mounted. No `ProviderNotFoundException`, no Principle II violation — a plain library
bug, unrelated to what runs on which navigator.

**This does not weaken Principle II — it strengthens it.** The screen is still placed on the root
navigator, still outside the caller's provider subtree, so the no-cubit rule below is unchanged and
still load-bearing. What changed is *how* we reach the root navigator: explicitly, by name, instead
of implicitly through a third-party helper's `withNavBar: false` flag resolving to it internally.
An explicit `rootNavigator: true` at the call site is easier to audit than a boolean whose meaning
lives in another package's source.

Separately, and still true: today the Principle II gate is masked, not fixed, for the parts of the
picker surface not yet converted — `BranchesListView` reads `context.read<AllBranchCubit>()`
(`lib/modules/home/search_screen/presentaion/widget/branches_list_view.dart:59, 76`) and survives
only because `AllBranchCubit` is registered **globally** at `lib/bloc_providers.dart:31` as
temporary scaffolding. Phase 9 deletes that registration. **The picker rewrite and that deletion
must land together**, or the bug returns in its original form.

## The contract

```dart
final picked = await Navigator.of(context, rootNavigator: true).push<Branch>(
  CupertinoPageRoute<Branch>(
    builder: (_) => BranchPickerScreen(branches: options),
  ),
);
if (picked != null) cubit.setPickupBranch(picked);
```

**Phases 4-7 must copy this call, not `PersistentNavBarNavigator.pushNewScreen<Branch>(...)`.** The
latter compiles, passes `flutter analyze`, and only fails at runtime on the exact tap path a renter
uses — nothing catches it earlier.

**Bottom nav bar coverage is unaffected.** `withNavBar: false` in the old call and
`rootNavigator: true` in the new one target the *same* Navigator — there was never a second
navigator to lose. In this app every booking screen (`Clasic` included) is already a top-level
`GoRoute` on that same root navigator, which is what covers `ShellBottomNavBar` for free (see
CLAUDE.md's Routing section). Pushing `BranchPickerScreen` onto that root navigator stacks it above
the already-covering booking screen — the bar was hidden before this route existed and stays hidden
identically after, by construction, not by a separately-tuned setting. The developer's device
session (2026-09-06) reached and used the picker screen without reporting the nav bar showing
through; this was not isolated as its own explicit visual check, so treat this guarantee as
architectural (same Navigator target as before) rather than a dedicated on-device confirmation.

`BranchPickerScreen` MUST:

- receive its list as a **constructor parameter** — `final List<Branch> branches`
- read **no cubit**, scoped or global. No `context.read`, no `context.watch`, no `BlocProvider.of`,
  no `BlocBuilder`, no `BlocListener`, no `sl<SomeCubit>()`
- **not know whether it is picking pickup or dropoff.** There is **no `isReceive` flag anywhere in
  it**, and no equivalent by another name
- return via `Navigator.pop(context, branch)`, typed `Branch`
- pop `null` (or nothing) on back-out, which the caller treats as "no change"

The **caller** decides pickup vs dropoff by which setter it passes the result to. That is the whole
of the distinction, and it lives on the side of the boundary that still has the provider.

## The prohibition covers the whole picker surface, not one file

**Any widget reachable only from `BranchPickerScreen` is bound by the same prohibition.** The rule
is about what runs on the root navigator, and every descendant of the pushed route runs there. A
row widget, an empty-state widget, a search field, a sheet the picker opens — each is as far outside
the caller's provider subtree as the screen itself, and a cubit read in any of them throws the same
`ProviderNotFoundException` inside the same tap handler.

Splitting the screen into helper widgets is fine and expected. Moving a cubit read into one of them
is not, and must not be able to slip past the gate merely because it now lives in a different file.

**The picker surface** is `lib/modules/location/presentaion/pages/branch_picker_screen.dart` plus
every widget it owns. Keep those widgets under
`lib/modules/location/presentaion/pages/branch_picker/` so the surface is a directory the gate can
name. A picker helper placed in the shared `presentaion/widgets/` folder is outside the gate's
reach — do not put one there.

## What the screen may read

`AppLocalizations.of(context)`, `Theme.of(context)`, `MediaQuery`, and the ScreenUtil extensions —
all inherited widgets available on the root navigator. The prohibition is on **cubits**, not on
`InheritedWidget`s generally.

## Permitted constructor parameters

| Parameter | Type | Why |
|---|---|---|
| `branches` | `List<Branch>` | the list to display |
| `selectedId` | `int?` | to mark the current selection — **an id, never a name** (Principle I) |
| `emptyMessage` | `String?` | the "no branches offer this service" text required by US5 scenario 4, passed in already localized |

Nothing else. In particular, no callback parameter — the result travels back through `pop`, not
through a closure that captures the caller's context.

## Tests (Phase 3)

| Test | Asserts |
|---|---|
| `renders from constructor list with no providers in the tree` | the **full screen** is pumped **bare**, with no `BlocProvider` ancestor at all — if the screen *or any helper widget it builds* reads a cubit, this test throws |
| `tapping a branch pops that Branch` | `pop` result is the tapped `Branch`, by identity |
| `popping without a tap yields null` | caller sees "no change" |
| `selectedId marks the right row` | marking is by id, not by name or index |
| `empty list shows the message, not a blank list` | US5 scenario 4 / FR-039 |
| `two branches with equal names but different ids are distinct rows` | Principle I — names are not identity |

**The first test is the guard.** Pumping with no provider ancestor is what makes a future
`context.read` a red test rather than a release-only silent failure. Two conditions make it a real
guard rather than a formality:

1. **It must not be "fixed" by wrapping the pump in a provider.** If it starts failing, a cubit
   read was added — remove the read, not the test.
2. **It must pump the FULL screen**, with enough data that every branch of the widget tree actually
   builds — a populated list *and* the empty-state case, so a helper widget's cubit read fails the
   test too. Pumping a stripped-down subtree, a single row in isolation, or a screen whose list is
   empty so the row widgets never build would let a helper's cubit read pass unnoticed. That is the
   exact gap the static gate below also closes.

## Static check

A grep gate for Phase 3, cheap enough to re-run at every later phase. It covers the **whole picker
surface** — the entry file plus every widget the picker owns — not just the entry file, because a
cubit read moved into a helper widget breaks Principle II at runtime while passing a single-file
check:

```bash
grep -rnE "context\.(read|watch)|BlocProvider\.of|BlocBuilder|BlocListener|BlocConsumer|BlocSelector|sl<" lib/modules/location/presentaion/pages/branch_picker_screen.dart lib/modules/location/presentaion/pages/branch_picker/
```

Must return **zero** matches.

`BlocConsumer` and `BlocSelector` are included alongside `BlocBuilder` and `BlocListener` — all
four resolve a provider from the ancestor tree and fail identically on the root navigator.

If a picker helper is ever placed outside those two paths, **the gate stops covering it**. Either
move it back under `branch_picker/` or extend the path list in this contract — silently leaving it
uncovered is how Principle II gets violated again.
