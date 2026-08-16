# Darbak QA — Progress & Resume Point

Last updated: 2026-08-16

---

## Goal

Two phases:
1. Fix confirmed defects found during the QA inventory (Batches A, B, C).
2. Generate a full Arabic RTL test-case suite (JSON + self-contained HTML dashboard) covering all feature modules.

---

## Current status

Batch A complete. Batch B is next (session security — secure storage + 401 handler + remove token globals).

---

## Completed

| Item | What changed | Files touched | How verified |
|---|---|---|---|
| A1 — Fix logout to preserve language | Replaced `preferences.clear()` (wiped ALL SharedPreferences) with `clearSession()` which removes only `token`, `USER_DATA`, `USER_PASSWORD`; deleted the `clear(String)` method whose parameter was ignored and which wiped everything — root cause of the original defect | `lib/core/helpers/SharedPreference/pereferences.dart`, `lib/modules/home/profile/blocs/profile_cubit/profile_cubit.dart` | Codebase-wide grep confirmed zero remaining callers of the old `clear(String)` before deletion |
| A2 — Isolate legacy car-search URL | Extracted the hardcoded `https://abudiyab-soft.com/cars/api` URL into a named constant `legacyCarSearchUrl` in `api_path.dart` | `lib/core/constants/api_path.dart`, `lib/modules/home/cars/presentaion/bloc/all_cars_cubit/all_cars_cubit.dart` | Manual review; **finding**: the search call constructs a bare `Dio()` instead of `sl<Dio>()`, so `AppInterceptors` never runs on it — no `Accept-Language`, no `Authorization` header, no configured timeouts. URL is now a constant but the Dio/auth bypass is still present. |
| A3 — Document LanguageCubit in CLAUDE.md | Corrected CLAUDE.md, which previously said "No LanguageCubit class found as a standalone file"; now correctly identifies `lib/modules/home/selectLanguage/languageCubit.dart` as the real cubit | `CLAUDE.md` | Read confirmed |
| Non-snake_case filename sweep | Listed all 42 Dart files in `lib/` that deviate from snake_case (camelCase, PascalCase, mixed); documented as a QA hazard | `qa/darbak_inventory.md` | Directory listing cross-checked |
| Inventory patches (session 2) | Added `SuccessBottomSheet` to Auth screens table; added descriptions for `ErrorPage` and `SuccessBottomSheet`; updated forgot-password flow; fixed stale localization entry; marked defect #5 FIXED; added defects #6–#9; added filename conventions warning | `qa/darbak_inventory.md` | Read-back verification |
| Deletion of two dead files | Deleted blank `lib/language/languageCubit.dart` (2 newlines) and empty `lib/core/helpers/helper/FigmaToFlutter.dart` (0 bytes); both confirmed by full-repo grep to have zero imports | Both files removed | `flutter analyze` after deletion: still 73 issues, no errors introduced |

---

## Decisions made (do not re-litigate)

- Notification CRUD endpoints are placeholders; backend not built. That module is **out of QA scope**. FCM delivery, `high_importance_channel` setup, `_safeDeviceToken()`, and `routeFromNotification` ARE in scope and testable.
- The legacy car-search URL stays as-is until backend provides a replacement endpoint; it is only isolated behind the constant `legacyCarSearchUrl`.
- Filenames are **NOT to be renamed**. The mixed-case convention is documented as a hazard, not fixed.
- The two dead files (`languageCubit.dart`, `FigmaToFlutter.dart`) are deleted (completed above).
- The vestigial globals in `langCode.dart` (`userToken`, `phoneStorage`) are approved for removal, scheduled as part of Batch B (B2).
- A global 401 handler will be added in Batch B (B3). Auth endpoints must be excluded by path match to prevent redirect on wrong-password 401.

---

## Blocked on backend (Mr. Ahmed) — none of these block Batch B or C

- **`order_via` string for Darbak orders:** `AllBookingCubit.getAllBooking` filters client-side to `order_via == 'Darakson App'`. The app brand is now "Darbak" — this filter string is almost certainly a copy-paste defect from a previous project. Until confirmed, the bookings list may be silently empty for all current users.
- **Replacement endpoint for the legacy car search:** `https://abudiyab-soft.com/cars/api?trem=...` is on an external domain, unauthenticated (bare `Dio()` instance). Backend must provide a production endpoint before this can be properly fixed.
- **FCM device token registration endpoint:** The token is fetched safely via `_safeDeviceToken()` but is never sent to the backend after login, so push notifications cannot be targeted to specific devices. Needs a `device_token` field (or separate endpoint) on login/logout.
- **Notification CRUD paths:** `api_path.dart` marks `notificationsList`, `notificationsMarkAllRead`, `notificationsMarkOneRead` as `// TODO(api): confirm path + method`.
- **Automated booking flow trigger:** When is the `/contracts/*` flow triggered vs the regular `/orders/*` flow? What screen, flag, or API response field determines which path is taken?

---

## Next up — Batch B (session security)

Execute in a single session. Run `flutter analyze` at the end and report the count.

### B1 — Migrate auth token to flutter_secure_storage

1. Add `flutter_secure_storage` to `pubspec.yaml` (this is the ONLY dependency change allowed in Batch B).
2. Create `lib/core/helpers/session/session_manager.dart` — `SessionManager` is the **single entry point** for reading, writing, and clearing the auth token. No other file may read the token key directly after this change.
   - `Future<String?> getToken()` — reads from secure storage
   - `Future<void> saveToken(String token)` — writes to secure storage
   - `Future<void> clearToken()` — deletes from secure storage
   - `Future<void> migrate()` — copies token from SharedPreferences key `"token"` to secure storage, then deletes it from SharedPreferences; guarded by a flag (SharedPreferences key `"token_migrated"`). Run once on app start. **Getting this wrong logs out every existing user on update.**
3. Call `SessionManager.migrate()` in `main.dart` after `di.setup()` and before `runApp`.
4. Update `AppInterceptors.onRequest` to call `await sl<SessionManager>().getToken()` instead of `SharedPreferencesHelper.getToken()`.
5. Update the login flow (`SignInRemoteDataSourceImpl`) to call `SessionManager.saveToken(token)` instead of `SharedPreferencesHelper.saveToken(...)`.
6. Update `ProfileCubit.logOut()` / `SharedPreferencesHelper.clearSession()` to also call `SessionManager.clearToken()`.
7. Register `SessionManager` as a `registerLazySingleton` in `service_locator.dart`.
8. Language stays in SharedPreferences — it is not sensitive. Do not touch it.

### B2 — Remove token globals (same change, not a separate session)

1. Delete `userToken` and `phoneStorage` from `lib/core/constants/langCode.dart`.
2. Delete the write site `userToken = ""` in `profile_cubit.dart` (logout body) — confirmed write-only, never read.
3. Delete `phoneStorage = phoneController.text;` in `forgotPassword.dart:212` — confirmed write-only.
4. Delete `phoneStorage = null;` in `change_password.dart:96` — confirmed write-only.
5. If `langCode` itself has zero reads (verify before touching), delete it too and remove the file. If it has reads, leave `langCode` but document why.

### B3 — Global 401 handler

1. In `app_interceptor.dart`, implement `onError` (currently empty):
   - If `error.response?.statusCode == 401` AND the request path does NOT match any of: `/login`, `/register`, `/register/verify`, `/register/resend-otp`, `/password/forget`, `/password/code`, `/password/reset`:
     - Call `SessionManager.clearToken()`.
     - Navigate to `/signin` using `appRouter` (the `GoRouter` instance is accessible as a top-level constant in `app_router.dart`).
     - Show a localized flushbar: `locale.sessionExpired` (add this key to both `english.dart` → `"Your session has expired. Please sign in again."` and `arabic.dart` → translation).
     - Guard against loop: if `GoRouter.routerDelegate.currentConfiguration.fullPath` already starts with `/signin`, do nothing.
2. Add `sessionExpired` locale key to `lib/language/languages/english.dart` and `lib/language/languages/arabic.dart`, with a getter in `lib/language/locale.dart`.

### Batch B verification checklist (run before accepting)

1. Install the PREVIOUS build, log in, then install the new build over it WITHOUT uninstalling. The user must still be logged in.
2. Log out; confirm SharedPreferences no longer contains `"token"` and secure storage is cleared.
3. Enter a wrong password on the sign-in screen. Must show a field/inline error — **NOT** a redirect, **NOT** a session-expired message.
4. Force a 401 on an authenticated screen. Must redirect once, with no loop and no repeated flushbars.
5. Switch the app to Arabic, log out, reopen. The app must still be in Arabic.

---

## Then — Batch C (PLAN ONLY — write plan to qa/darbak_fix_plan.md, no code)

### C1 — Remove plaintext stored password

- `PreferencesConstants.userPassword = "USER_PASSWORD"` is saved on login and compared client-side in `Validate.validateOldPassword` (`reset_password` flow).
- Before planning: read `ResetPasswordScrean` and `RsetePasswordCubit` to confirm the API body. If PUT `/profile` already accepts `old_password` (it does — `body: {old_password, password, password_confirmation}`), the client-side compare is redundant and the saved plaintext password is unnecessary.
- Plan: remove `savePassword()` from the login flow, remove `userPassword` reads from `validateOldPassword`, rely solely on the server's validation response.

### C2 — Localize error strings

- `Failure.fromDioError` returns hardcoded English strings (`"Server Error"`, `"Not Authenticated"`, etc.) that propagate as cubit error state strings and reach the UI unlocalized.
- `AllBranchCubit` emits hardcoded Arabic strings for no-branches, no-internet, and no-cached-data states.
- `NetworkErrorWidget` has hardcoded Arabic/English defaults for its description parameter.
- Plan: replace raw strings with error codes or enum values at the cubit/failure layer; map them to locale keys at the UI layer. Do not put locale logic in cubits.

### C3 — Roll out safeApiCall to all datasources

- Only `NotificationsRemoteDataSource` uses the `safeApiCall` connectivity pre-check today.
- All other datasources call Dio directly — offline behaviour differs per screen.
- Plan: list every datasource file and every method needing wrapping; flag methods where wrapping changes the error type surfaced to the cubit.

---

## Then — Phase 2 (test-case generation)

- **Source of truth:** `qa/darbak_inventory.md` ONLY. Do NOT re-scan the codebase.
- **Must be split across runs:** ~48 routes × the coverage matrix will not fit in one run. Generate 2–3 modules at a time into separate JSON files, then merge.
- **Output:** `qa/darbak_test_cases.json` + a self-contained Arabic RTL HTML dashboard.
  - Module tabs built **dynamically** from the data, not hardcoded.
  - Search bar, stat cards that follow the active filter, CSV export with UTF-8 BOM, print stylesheet.
  - No external CDN — fully self-contained.
  - Each test case carries `route` and `source` fields tracing back to the inventory.
- **Specific cases that must not be forgotten:**
  - Legacy car-search bypasses the shared Dio: no `Accept-Language` header, no configured timeouts, no connectivity pre-check, no `Failure` error mapping.
  - `forgot-password ErrorPage` displays `locale.passwordChanged` on failure — same text as the success screen; likely a copy/paste bug, needs a case and a fix decision.
  - `ErrorPage` and `SuccessBottomSheet` were missing from the original inventory scan; they are now documented.
  - Delivery package screen differs substantially from the other three package screens (error dialog on no-match, GPS in FilterModel, case-insensitive branch matching).
  - `BookingConfirmedBottomSheet` swipe-to-dismiss is fully disabled; dismiss via only two explicit buttons.
  - After logout, the app navigates to tab 0 (`/home`) not to `/signin` — `AuthStatusCubit` is marked signed-out but no redirect guard fires.
