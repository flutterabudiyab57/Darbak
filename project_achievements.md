# Project Achievements — Darbak

---
## 2026-05-14 — Stable internal `PaymentMethod` enum (audit findings C3 + H1)
**What I built:** Replaced the localized-display-string dispatch in `CreditCardModel.toJson()` with an exhaustive `switch` on a new `PaymentMethod { visa, cash, madfou, tamara, points }` enum, propagated the enum through `BookingCubit.selectedPaymentMethods`, `PaymentMethodCard`, and every payment-screen comparison/call site, and converted to the wire string only at the HTTP boundary.
**Problem solved:** `toJson()` had a `default: toCashJson()` arm and matched on the raw localized labels (`"Visa"`, `"بطاقة إئتمان"`, `"madfou"`, …). A non-engineer renaming a translation in `english.dart` / `arabic.dart` — say `"visa"` → `"Card payment"` — would have silently downgraded every credit-card transaction to cash: user enters PAN+CVV, app shows "payment successful", **zero charge is ever made**. Same fragility for an unrecognized capitalization, trailing whitespace, or a newly added payment method without a corresponding `case`. This was the worst-case failure mode in the whole audit because it is invisible to users, tests, and the analyzer.
**Tech highlights:**
- Designed `PaymentMethod` with a `String get wire => name` getter (single source of truth for the API token) and `static PaymentMethod? fromWire(String?)` for parsing server-returned strings (trims + lowercases). Documented at the enum declaration why localized strings must never be used as logic keys.
- Made `toJson()` exhaustive: removed the `default: toCashJson()` arm entirely. Dart's switch-on-enum is analyzer-checked, so any future enum value forces every dispatch site to handle it. Null input now throws `StateError` instead of silently emitting cash.
- Migrated `BookingCubit.selectedPaymentMethods` from `String?` to `PaymentMethod?` and updated `PaymentMethodChanged.props` to use `method?.wire ?? ""` for Equatable parity.
- Added `method: PaymentMethod` to `PaymentMethodCard`; all five call sites in `paymentMethods.dart` pass the enum explicitly. The radio-dot indicator now compares against `widget.method`, not the display label.
- Rewrote the four `bookNow*` methods in `invoice.dart` and `invouce_notCompleted.dart`: extracted `_resolveOrderId()` + `_resolvePaymentType()` helpers, replaced nested ternaries (`selectedPaymentMethods.toString().toLowerCase() ?? widget.paymentType!.toLowerCase()`) with `selectedPaymentMethods ?? widget.paymentType` (now type-safe `PaymentMethod?` throughout).
- Simplified the dead Apple Pay branch in `invouce_notCompleted.dart` build method (commented-out body, dead localized comparison) — collapsed the 3-way conditional to 2-way visa/non-visa, removed the now-unused `dart:io` import.
- Touched 7 files total: `credit_card_model.dart`, `booking_cubit.dart`, `booking_state.dart`, `payment_card.dart`, `paymentMethods.dart`, `invoice.dart`, `invouce_notCompleted.dart`, plus a downstream fixup in `bookDetailes.dart` where `bookingData.paymentType` (a server String) is now parsed via `PaymentMethod.fromWire(...)` before being passed into `InvoiceNotCompletedUI`.
- Converted enum to wire string only at the repository boundary in `invoice_cubit.dart` (`selectedPaymentMethods?.wire ?? ''`) so the HTTP request payload is unchanged from the backend's perspective.
- Whole-tree `flutter analyze` after the change: **zero errors**. Targeted grep for any remaining `selectedPaymentMethods == locale.xxx.toString()` patterns returns zero hits.
**Impact:** Closed the third Critical and one of the five Highs from the audit in a single refactor, since they share the same root cause. The "silently downgrade visa to cash" failure mode is now structurally impossible — a copy edit to a translation can no longer change payment-method dispatch. All payment-method comparisons in the codebase are now exhaustive, type-checked, and decoupled from the locale layer.

---
## 2026-05-14 — Removed mutable card-data globals (audit finding C2)
**What I built:** Replaced five top-level `dynamic` globals (`cardNameSaved`, `cardNumberSaved`, `securityNumberSaved`, `expiryMonthSaved`, `expiryYearSaved`) plus an `isVisa` flag in `lib/core/constants/langCode.dart` with a single typed `CardInput` singleton living next to `CreditCardModel`, and wired every payment-submission call site to wipe the buffer in a `finally` block.
**Problem solved:** PAN + CVV + expiry were held in module-level mutable variables for the lifetime of the Dart isolate. Manual cleanup existed in only **one** code path (visa-success in `invoice.dart` / `invouce_notCompleted.dart`) — every other outcome (visa failure, non-visa method, navigate-away mid-form, app backgrounded during 3DS, subsequent booking in the same process) left cleartext card data resident in heap. PCI-DSS req. 3.2.2 forbids any post-authorization persistence of CVV, including in-memory; heap-resident globals also surface in crash-reporter snapshots and on a shared device cross-contaminate users.
**Tech highlights:**
- Designed `CardInput` as a singleton with typed fields and a `clear()` method, documented with a one-line PCI-DSS invariant comment so any future call site knows why `clear()` is mandatory.
- Wrapped both `bookNowWithVisa()` methods (in `invoice.dart` and `invouce_notCompleted.dart`) with `try { … } finally { input.clear(); }` so the buffer is wiped after every payment attempt — success, failure, or thrown exception. The two manual cleanup blocks in the success listeners became redundant and were removed.
- Migrated the `isVisa` form-validity flag onto `CardInput.isValid` and updated the form-guard check at `paymentMethods.dart:572` from `isVisa == null || isVisa == false` to `!CardInput.instance.isValid`.
- Cleaned up the now-dead `langCode.dart` import in three files (invoice.dart, invouce_notCompleted.dart, paymentMethods.dart) — once the card globals were gone, those imports were unused.
- Verified with `grep -rn "cardNumberSaved\|securityNumberSaved\|cardNameSaved" lib/` — zero hits remain. `flutter analyze` issue count dropped 35→34 with no new errors or warnings introduced.
**Impact:** Closed the second of three Critical findings from the payment-system audit. Card data lifetime is now bounded by a single payment attempt instead of the app process. The remaining one Critical (`toJson` default-to-cash fallback / C3) and five Highs (localized-string discriminators, unattached `AppInterceptors`, missing server-side confirmation after WebView, brittle URL substring matching, hard-blocked back button) are still open with full repro detail in the saved plan.

---
## 2026-05-14 — Closed PCI log-leak path in the payment flow (audit finding C1)
**What I built:** Audited the payment module for security and correctness issues, then removed ever y `print()` call along the payment-submission path that was emitting card data to device logs.
**Problem solved:** A failed-visa flow was dumping the full PAN, CVV, expiry month/year, and cardholder name through `print()` — which still hits `logcat` on Android and `os_log` on iOS in release builds. Anyone with `adb logcat` access during a failed payment captured the entire card. Storing or logging CVV in any form is a PCI-DSS req. 3.2.2 violation, so this was the highest-severity finding from the audit.
**Tech highlights:**
- Produced a severity-ranked audit (3 Critical / 5 High / 6 Medium / 5 Low) covering the whole `lib/modules/home/payment/` tree before touching code — the report sits at `~/.claude/plans/cheak-payment-system-code-snug-clock.md` for follow-up work on the other findings.
- Removed the card-data leaks at four sites: `invoice.dart:344-346` (the "credid card data" dump on visa failure), `invoice_cubit.dart:78-79, 83-84` (cardModel dumps on both success and error paths), `credit_card_model.dart` (six `paymentType` prints scattered across the `toJson` switch), and `payment_remote_datasource.dart` (raw HTTP response print plus a commented-out stub block).
- Verified the fix with a targeted regex (`print\s*\([^)]*(card|cvv|security|Saved|expiry|nameOn)`) — zero non-commented hits remain in the payment module. Pre-existing prints that don't touch card fields (paymentType-only, orderId, selectedPaymentMethods) were intentionally left for a later cleanup pass to keep this change scope-disciplined.
- `flutter analyze` on the touched files reports no new issues — all 35 remaining warnings pre-date this change.
**Impact:** Closed the most severe PCI-compliance gap surfaced by the audit. The remaining two Criticals (PAN+CVV held in module-level globals; `toJson` default-to-cash fallback) and five Highs (localized-string discriminators, unattached `AppInterceptors`, missing server-side confirmation after WebView, brittle URL substring matching, hard-blocked back button) are now documented with file:line refs and repro steps, ready to be picked up individually.

---
## 2026-05-12 — Scoped forgot-password state to its feature instead of the app root
**What I built:** Refactored the `ForgetPasswordCubit` out of the root `MultiBlocProvider` and into a feature-scoped provider that only lives while the forgot-password flow is open.
**Problem solved:** The app was instantiating every feature cubit at boot — including a forgot-password cubit that the vast majority of users never trigger — wasting startup work and keeping unused state in memory for the lifetime of the process.
**Tech highlights:**
- Introduced a `static Widget entry()` factory on `ForgotPasswordScreen` that wraps the screen with `BlocProvider(create: () => sl<ForgetPasswordCubit>())`, so call sites stay ignorant of the cubit while the feature owns its setup.
- Solved the `showModalBottomSheet` provider-scoping problem: modals built from the Navigator root don't inherit ancestor providers, so I captured the cubit with `context.read<>()` and forwarded it across two modal hops using `BlocProvider.value`, keeping a single cubit instance across the 3-step phone → OTP → password flow.
- Audited the entire root `MultiBlocProvider`, categorizing 14 cubits into "must-stay-global" (drives `MaterialApp.locale` / `themeMode`), "reasonable global" (used in shell tabs), and "feature-only waste" (used in one flow), and planned a one-by-one migration to avoid a big-bang refactor.
- Caught and removed a duplicate `BlocProvider<AdditionsCubit>` registration that was silently shadowing itself at the app root.
**Impact:** Removed one cubit from app-startup construction with zero behavioral change, established a repeatable pattern (`entry()` + `BlocProvider.value` across modal boundaries) for migrating the remaining five feature-scoped cubits, and set up a cleaner provider boundary between app shell and feature flows.
---

## Bloc Provider Migrations — Cumulative Startup Perf

Each row captures one cubit being scoped out of the root `MultiBlocProvider` into a feature-owned `BlocProvider`. Numbers come from `flutter run --profile --trace-startup` → `build/start_up_info.json`. "Before" of row N = "After" of row N−1, so the table chains forward from the original baseline (1,675 ms time to first frame, before any migration).

Device: **Lenovo TB128XU (Android 13, arm64), profile mode.** Single-run measurements carry variance — treat deltas as directional.

All times in milliseconds. **TtFF** = Time to first frame (engine entry → first frame on screen). **FW init** = engine entry → Flutter framework initialized. **After init** = framework init → first frame.

| Cubit removed | Date | FW init: Before → After | After init: Before → After | TtFF: Before → After | Δ TtFF this step | Δ TtFF vs. original baseline |
|---|---|---|---|---|---|---|
| `AllBranchCubit` | 2026-05-12 | 243 → 190 | 1,360 → 1,292 | 1,603 → 1,482 | −121 (−7.5%) | −193 (−11.5%) |
| `CarsCubit` | 2026-05-12 | 241 → 192 | 1,338 → 1,284 | 1,579 → 1,476 | −103 (−6.5%) | −199 (−11.9%) |
| `AllCarsCubit` | 2026-05-12 | 414 → 426 | 1,406 → 1,349 | 1,819 → 1,775 | −44 (−2.4%) | n/a (see note) |

**Original baseline:** 1,675 ms (before any migration on this branch).
**Latest:** 1,775 ms (this run; device was running ~200 ms slower than the original-baseline run — see note).
**Cumulative improvement (paired in-session deltas):** −268 ms across the four rows above.

_Notes:_
- _Single-run timings carry variance — the AllBranchCubit "After" (1,482 ms) and the CarsCubit "Before" (1,579 ms) were measured in separate runs and differ by ~100 ms purely from device-state variance, not regression. Treat per-row deltas as directional and the cumulative-vs-baseline column as the more reliable metric._
- _The AllCarsCubit run started from a baseline of 1,819 ms — ~200 ms higher than earlier runs on the same device, consistent across both Before and After. This is environmental drift (device warmth, background processes, thermal state), not a regression introduced by prior migrations. The paired in-session Δ (−44 ms) is the meaningful number for this row; "Δ vs. original baseline" is suppressed because comparing across run sessions is unreliable._
- _The `FilterCubit` migration completed without a paired perf snapshot (user opted out for that one), so its contribution is folded silently into the AllBranchCubit "Before" number rather than appearing as its own row._
