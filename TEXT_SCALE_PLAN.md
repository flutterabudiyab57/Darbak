# Text-Scale-Aware Sizing — Migration Plan

This plan introduces a small, opt-in helper (`num.hs(context)`) so that heights of text-holding widgets can grow/shrink with the system text scaler, in lockstep with the global `TextScaler.clamp(0.8, 1.1)` configured in `lib/bloc_providers.dart`.

The plan is intentionally narrow: ~12 high-payoff call sites, not a blanket sweep.

---

## 1. Inventory (what's actually in the codebase)

Scan performed across `lib/`:

| Pattern | Count | Scale matters? |
|---|---|---|
| `toolbarHeight: N.h` | 7 (1 already migrated) | **Yes — all** |
| `PreferredSize` with `Size.fromHeight(N.h)` | 2 | **Yes** |
| `ADGradientButton` default `height: 50.h` | 1 shared widget, many call sites | **Yes — holds text** |
| `ad_social_button.dart` `height: 50.h` | 1 | **Yes — holds text** |
| Form-field heights (`50–52.h`) | ~10 | **Yes — holds text input** |
| `SizedBox(height: N.h)` spacers | 326 across 75 files | **No — pure spacing** |
| `height: N.h` (cards, images, containers) | 546 across 99 files | **No for ~95%** |
| `.sp` (text + icon sizes) | 523 across 110 files | **No — already handled by `TextScaler`** |

**Conclusion:** real surface area is ~12 must-change sites + ~10 secondary, not hundreds.

---

## 2. The helper

Create `lib/core/helpers/text_scale_sizing.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension TextScaledSize on num {
  // Use for HEIGHTS of widgets that hold text:
  // toolbars, buttons with labels, text-form fields, text-wrapping containers.
  double hs(BuildContext context) =>
      h * MediaQuery.textScalerOf(context).scale(1.0);
}
```

One method only. Don't add `.ws` / `.sps` until there's a proven need — `sp` already scales with the system, and widths almost never need it.

---

## 3. Tier 1 — must change (high-payoff, ~10 minutes)

Direct clipping risk today when system scaling > 1.0×. **Migrating `CustomAppBar` alone cascades through every screen that uses it.**

| File | Line | Current | Change to |
|---|---|---|---|
| `lib/modules/widgets/components/appbar.dart` | 29 | `toolbarHeight: 80.h` | `toolbarHeight: 80.hs(context)` |
| `lib/modules/widgets/components/appbar.dart` | 57 | `Size.fromHeight(80.h)` | `Size.fromHeight(80.hs(context))` |
| `lib/clasic.dart` | 35 | `toolbarHeight: 100.h` | `toolbarHeight: 100.hs(context)` |
| `lib/modules/auth/register/presentaion/pages/register_page.dart` | 409 | `toolbarHeight: 70.h` | `toolbarHeight: 70.hs(context)` |
| `lib/modules/home/cars/presentaion/all_cars_screen.dart` | 109 | `toolbarHeight: 80.h` | `toolbarHeight: 80.hs(context)` |
| `lib/modules/home/payment/widget/web_payment.dart` | 61 | `toolbarHeight: 80.h` | `toolbarHeight: 80.hs(context)` |
| `lib/modules/home/booking_packages/ui/new_offers.dart` | 25 | `toolbarHeight: 100.h` | `toolbarHeight: 100.hs(context)` |
| `lib/modules/home/profile/page/profile.dart` | 43 | `Size.fromHeight(60.h)` | `Size.fromHeight(60.hs(context))` |

**Note:** `lib/modules/home/search_screen/presentaion/search_Screen.dart:221` is already done.

`appbar.dart` line 57 is inside `Size get preferredSize => …` — that getter has no `BuildContext`. Two options:
- **(a)** Change the getter to a method `Size preferredSizeFor(BuildContext context)` and have call sites pass context (Flutter doesn't really support this — `PreferredSizeWidget` requires the getter contract).
- **(b)** Keep `preferredSize` returning the base value (`80.h`) but actually render with `toolbarHeight: 80.hs(context)` inside `build`. Flutter measures via `preferredSize` for layout, so this can cause a 1–8px mismatch — acceptable within the clamp range and what most apps do.

Recommended: **(b)**. Document it in `CLAUDE.md`.

---

## 4. Tier 2 — should change (optional, do after Tier 1 ships)

Shared widgets where the *default* height holds text:

| File | Line | Current | Change to |
|---|---|---|---|
| `lib/modules/widgets/components/ad_gradient_btn.dart` | 42 | `height: height ?? 50.h` | `height: height ?? 50.hs(context)` |
| `lib/modules/widgets/components/ad_social_button.dart` | 15 | `height: 50.h` | `height: 50.hs(context)` |
| `lib/modules/widgets/components/ad_prim_text_form/DynamicPhoneField_WithCountry.dart` | 165 | `height: 52.h` | `height: 52.hs(context)` |
| `lib/modules/widgets/components/ad_prim_text_form/ad_prim_text_form.dart` | (text-field heights only) | — | — |

After Tier 1 + Tier 2: ~90% of real clipping risk is covered.

---

## 5. Tier 3 — do NOT change

- All **326** `SizedBox(height: N.h)` spacers — these are layout gaps, not text containers. Scaling them makes the design grid bouncy without fixing any clipping.
- All **container / image / card / decoration** heights.
- All **border radii**, padding around icons, decorative spacing.
- Everything **`.sp`** — `TextScaler` already handles text and icon sizes.

Resist a blanket `.h → .hs` sweep. The clamp is `0.8–1.1`, so scaling 500+ dimensions just compounds visual drift for no accessibility win.

---

## 6. Documentation

Append one paragraph to `CLAUDE.md` under "Theming and styling":

> **`num.hs(context)`** scales a height by the current system text scaler. Use it on `toolbarHeight`, `PreferredSize.fromHeight`, button heights with text labels, and form-field heights. Don't use it on spacers, images, or decoration — those should stay on plain `.h` so the 390×844 design grid stays predictable. Defined in `lib/core/helpers/text_scale_sizing.dart`.

Without this note, a future contributor will either ignore `.hs` entirely (inconsistent) or use it everywhere (defeats the design grid).

---

## 7. Pros

- **Small, bounded surface** — ~12 must-change sites; not hundreds.
- **One pattern** — single extension method, one import where used.
- **Cascading leverage** — fixing `CustomAppBar` and `ADGradientButton` propagates to many screens for free.
- **Opt-in & reversible** — existing `.h` keeps working; `.hs` collapses to `.h` mathematically if you revert to `TextScaler.noScaling`.
- **Bounded blast radius** — clamp `0.8–1.1` keeps the worst-case deviation at ±20%.
- **Discoverable** — short suffix, one-line note in `CLAUDE.md`.
- **Pairs naturally with `Expanded` / `AutoSizeText`** — `.hs` handles vertical room; `Expanded` handles horizontal overflow. They're complementary, not redundant.

## 8. Cons

- **`BuildContext` requirement** — `.hs(context)` can't be used in `const`. None of the Tier-1 sites are `const`, so not a practical issue here.
- **`PreferredSize` mismatch** — `preferredSize` getter has no context; rendering with `.hs(context)` inside `build` can produce a 1–8px layout/measure mismatch within the clamp range. Almost always invisible.
- **Two visually similar tokens** (`.h` vs `.hs`) — code review must catch wrong usage. Mitigation: keep `.hs` rare and intentional.
- **Tier 2 is a judgment call** — if QA never reports button/form clipping, doing Tier 2 is over-engineering.
- **Tiny per-build cost** — each call site adds an O(1) `MediaQuery.textScalerOf` lookup. Negligible.
- **Doesn't help horizontal overflow** — if a label is too wide at 1.1×, height won't save it. Use `Expanded` + `AutoSizeText` there (e.g. the `_buildProfileHeader` fix).

---

## 9. Honest alternative

Your clamp is `0.8–1.1` (only +10% upward). The actual visual difference is small.

- **Skip the migration entirely** if QA reports no text clipping today.
- **Or tighten the clamp to `1.0` / `noScaling`** and stop worrying.

The migration above is the *right* answer if you want to keep the `0.8–1.1` accessibility window. It's the *wrong* answer if you don't actually want scaling.

---

## 10. Execution checklist

When you're ready:

- [ ] **Step A** — Create `lib/core/helpers/text_scale_sizing.dart` with the `TextScaledSize` extension.
- [ ] **Step B** — Migrate 7 Tier-1 sites (table in §3 above). 1 sed-able pattern per site.
- [ ] **Step C** — Run `flutter analyze` — expect zero new findings.
- [ ] **Step D** — Add the paragraph in §6 to `CLAUDE.md`.
- [ ] **Step E** — (Optional) Migrate Tier 2 sites (§4).
- [ ] **Step F** — Smoke-test on device: open SearchScreen, Profile, Payment, Cars, Register at system text scale 1.0× and 1.5× (1.5× is what the OS sends — clamp brings it down to 1.1×).

Estimated time: **~10 minutes** for Steps A–D. Tier 2 adds ~5 minutes.

---

## 11. What I will NOT do without explicit approval

- Touch `SizedBox(height: N.h)` spacers.
- Touch `.sp` text/icon sizes.
- Touch image, container, card, or decoration heights/widths that don't hold text.
- Add `.ws` or `.sps` helper methods speculatively.
- Modify `bloc_providers.dart` (the clamp).
- Rename or refactor existing widgets.
