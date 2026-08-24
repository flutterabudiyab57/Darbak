# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`darbak` is a Flutter car-rental mobile app (Android/iOS, with web/desktop folders also generated). The product brand is "Darbak" — launcher icon source is `assets/images/Darbak_logoo.png` (note the double `oo`). Dart SDK `^3.5.3`. App targets a `390x844` design size via `flutter_screenutil`.

The on-disk project folder is `E:\projects\darbak`. It was previously `E:\projects\fast-rent`; the Dart package, Android `applicationId`, iOS bundle id, and folder were all renamed to `darbak`. The application/bundle id is `com.abudiyab.darbak` (Android `namespace` + `applicationId`, iOS/macOS `PRODUCT_BUNDLE_IDENTIFIER`, Linux `APPLICATION_ID`); it was previously the default `com.example.darbak`. Do not change `package:darbak/...` imports back; do not rename the folder casually (Gradle, IDE, and pub cache references would all break). A sibling `~/.claude/projects/E--projects-fast-rent/memory/` slug still exists from the old name and holds older memories (e.g. `feedback_powershell_utf8.md`); new memories live under `E--projects-darbak/`.

## Commands

```bash
flutter pub get                  # install deps (run after pulling or editing pubspec.yaml)
flutter run                      # run on the currently selected device
dart run build_runner build --delete-conflicting-outputs   # regenerate Hive .g.dart adapters
dart run flutter_launcher_icons  # regenerate launcher icons (config in pubspec.yaml)
flutter clean                    # nuke build/ — fixes stale AssetManifest.bin hot-reload errors
```

> **IMPORTANT — filtered scripts (Claude Code must ALWAYS use these instead of the raw commands):**
>
> | Raw command | Use this instead |
> |---|---|
> | `flutter analyze` | `powershell -ExecutionPolicy Bypass -File scripts/flutter_analyze_filtered.ps1` |
> | `flutter test [args]` | `powershell -ExecutionPolicy Bypass -File scripts/flutter_test_filtered.ps1 [args]` |
> | `flutter build <target> [args]` | `powershell -ExecutionPolicy Bypass -File scripts/flutter_build_filtered.ps1 <target> [args]` |
>
> The filtered scripts execute the original Flutter command, save the full output to a temp log, and return only errors, warnings, failures, exceptions, stack traces, file paths, and line numbers. This keeps Claude Code's context window free of megabytes of Gradle and pub noise.
>
> **Never run `flutter analyze`, `flutter test`, or `flutter build` directly.** Always go through the scripts above.

`test/widget_test.dart` is still the default Flutter counter sample and does not match `App()` — treat it as scaffolding, not a real suite.

## Environment notes (Windows)

- **Pub cache lives on `E:\.pub-cache`**, not the default `%LOCALAPPDATA%\Pub\Cache`. The `PUB_CACHE` user env var is set to this path. Reason: on Windows, Kotlin's `RelocatableFileToPathConverter` crashes when project sources and pub cache are on different drive letters (`IllegalArgumentException: this and base files have different roots`). Keep `PUB_CACHE` and the project on the same drive.
- **`flutter pub get` may hit pub.dev's `advisoriesUpdated` decoding bug** (`FormatException: advisoriesUpdated must be a String`). Workaround: `flutter pub get --offline` once packages are cached; the post-solve advisories fetch is what crashes, packages still install.
- **Dependency version conflict (known issue).** The project has an existing constraint conflict between `package_info_plus ^8.3.1` and `device_info_plus ^13.2.0` (different transitive `win32` versions). This does not prevent the app from building; it only blocks `flutter pub get` and `flutter analyze` without `--offline`. The filtered scripts work around this — use them for analyze/test. This is a pre-existing issue unrelated to code changes.
- **Gradle/Kotlin daemons hold file locks** in `build/` and `android/app/`. If a delete or replace of any file inside the project tree fails with "file in use", run `android\gradlew.bat --stop` first. Closing Android Studio / VS Code is also often required.
- **Dart files must be UTF-8 without BOM.** `Get-Content -Raw` in Windows PowerShell 5.1 reads as cp1252 by default — round-tripping through it silently corrupts Arabic strings into mojibake. For bulk edits use `[System.IO.File]::ReadAllBytes` + `[System.Text.Encoding]::UTF8.GetString` for reading and `[System.IO.File]::WriteAllText(path, text, (New-Object System.Text.UTF8Encoding $false))` for writing. The full incident is in the legacy memory folder: `~/.claude/projects/E--projects-fast-rent/memory/feedback_powershell_utf8.md`.

## Architecture

The app follows a **feature-module + clean-architecture-lite** layout. Each feature under `lib/modules/<feature>/` has its own `data/` (datasources, models, repositories) and `presentaion/` (note the spelling — `presentaion`, not `presentation`) with `bloc/` or `blocs/` subfolders. New features should match this convention even though the spelling is non-standard.

### Boot sequence (`lib/main.dart` → `lib/bloc_providers.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()` and orientation lock to portrait.
2. `initializeHive()` — opens Hive, calls the generated `Hive.registerAdapters()` (from `lib/hive_registrar.g.dart`, produced by `build_runner`), then calls `CacheHelper.init()` which opens boxes `branches_box`, `cars_box`, `cache_meta_box`. **Any new `@HiveType` class must be re-generated** (`dart run build_runner build --delete-conflicting-outputs`) for its adapter to appear in `hive_registrar.g.dart` and be registered here.
3. `di.setup()` — `service_locator.dart` (GetIt) registers all blocs/cubits, repositories, remote/local datasources, and shared singletons (`Dio`, `SharedPreferencesHelper`, `DateHandler`). The setup function early-returns if `SignInBloc` is already registered, so it is safe to call more than once but will silently skip re-wiring — clear GetIt if you need a true reset.
4. `runApp(App())` → `ScreenUtilInit` → `CreateBlocProviders(context)` mounts a `MultiBlocProvider` with the global blocs (`AuthStatusCubit`, `BookingCubit`, `LanguageCubit`, `ProfileCubit`, `AdditionsCubit`, `InvoiceCubit`, `SearchCubit`, `AllBookingCubit`, `ThemeCubit`) wrapped in `BlocBuilder<LanguageCubit>` + `BlocBuilder<ThemeCubit>` + `AppLifeCycleManager` + **`MaterialApp.router(routerConfig: appRouter)`** (see the Routing section). Other cubits (Cars, Filter, AllBranch, AllCars, ForgetPassword, etc.) live in GetIt only and are provided closer to the screen that uses them.
5. `MaterialApp.router`'s `builder` wraps every page with `MediaQuery(... textScaler: MediaQuery.textScalerOf(context).clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2))` — the system font scale is **clamped to 0.8–1.2**, not fully locked. Don't widen this range; layouts depend on `flutter_screenutil`'s fixed 390×844 design and break under arbitrary scaling. (The text-scale-aware `.hs`/`.ws`/`.sps` helpers rely on this clamp — see Theming.)

The `try` block now also runs `Firebase.initializeApp()` (first) and `sl<PushNotificationService>().init()` (after `di.setup()`) — see the Push notifications section. **The whole block is wrapped in `try { ... } catch (e) { }`, and the catch only logs under `kDebugMode`** (a single `[FCM] boot init failed` line). In release the catch is silent, so a corrupted Hive box, a missing GetIt registration, or a Firebase init failure will silently boot the app into a broken state. When investigating startup mysteries (blank screen, missing data, "X not registered" errors deep in a feature), add logging in that catch block first.

If you add a feature-level cubit that should be globally available, register it in **both** `service_locator.dart` and `bloc_providers.dart`. Feature-local cubits should be provided closer to the screen instead.

### State management

`flutter_bloc` (Bloc + Cubit). Per-feature cubits are resolved from GetIt (`sl<X>()`) inside `BlocProvider.create`. Some cubits are `registerFactory` (new instance per request — e.g. `SignInBloc`, most form cubits), others are `registerLazySingleton` (shared instance — e.g. `BookingCubit`, `LanguageCubit`, `FilterCubit`, `SearchCubit`). Match this distinction when adding new cubits: stateful cross-screen state → singleton; per-screen form/flow state → factory.

**Selection Persistence Across Screens** — `SearchCubit` is a `registerLazySingleton`, so the same instance is shared app-wide. User selections (branch, dates, times, pickup/dropoff coords) stay in that singleton throughout the booking flow:

- **CarsInformation:** User views car details (clearAllDataSearched NOT called here)
- **BranchWithCarScreen:** User picks branch and dates (clearAllDataSearched called once on first entry)
- **Auth gate:** If guest, modal sheet covers BranchWithCarScreen; selections survive in SearchCubit
- **After login:** `requireAuth()` reruns the booking action; SearchCubit still has all selections

If the entire screen is replaced/popped (e.g., navigating back to /home), selections are lost. But for modal-overlay patterns (`requireAuth()`), selections persist because the screen never unmounts.

### Networking

- A single `Dio` is registered as a lazy singleton in `service_locator.dart`. **`AppInterceptors`** (in `lib/core/helpers/interceptors/app_interceptor.dart`) is attached to that `Dio` once at the end of `setup()` — so every `sl<Dio>()` call inherits `baseUrl = mainApi`, the `Accept-Language` header, and the `Authorization: Bearer <token>` header (token pulled from `SharedPreferencesHelper` on every request). Do **not** call `sl<Dio>().interceptors.add(AppInterceptors(...))` again from feature code — it would double-fire the request hook.
- All endpoints are constants in `lib/core/constants/api_path.dart`. Active base URL is `productionApi = "https://api.daraksonksa.com/api"` (controlled by the `mainApi` const). Many endpoint constants are pre-prefixed with `mainApi`, so do not double-prefix when composing requests.

**⚠️ Authentication & API Error Handling:**
- **Token requirement:** Most endpoints return 401 "Not Authenticated" if the Bearer token is missing or null. When the token is null (e.g., guest users or logout), requests must omit the Authorization header entirely (never send `"Bearer null"`).
- **Empty error interceptor:** `AppInterceptors.onError()` is currently a pass-through with no custom handling. 401 responses are **not** caught globally — errors propagate to individual datasources. There is **no automatic redirect to login or token refresh on 401**.
- **Individual error handling:** Each datasource catches exceptions independently (e.g., `ProfileService.getProfile()` throws `"Not Authenticated"` on 401). Check the state cubit to see how errors are handled upstream.
- **RequestHeaders helper** (`lib/core/helpers/request_headers.dart`) — Always use this for requests that may have missing auth:

```dart
// ✅ CORRECT — omits Authorization header for guests
final headers = RequestHeaders.forHttp(
  token: token,  // May be null for guests
  otherHeaders: { "Accept": "application/json" },
);

// ❌ WRONG — would send literal "Bearer null"
final headers = { "Authorization": "Bearer $token" };
```

The helper uses `TokenValidator.isValid(token)` which returns false for null/empty/"null" strings, ensuring the Authorization header is omitted entirely for unauthenticated requests. Datasources using `http` package call `RequestHeaders.forHttp()`; those using injected `Dio` inherit the interceptor pattern (see `app_interceptor.dart:48–50`).

### Persistence

- **Hive** (`lib/core/helpers/cache/cache_helper.dart`) — TTL of 5 minutes (`cacheValidDuration`), boxes `branches_box`/`cars_box`/`cache_meta_box`, with metadata keys of the form `${key}_time`. Use `CacheHelper.isCacheValid(key)` before serving cached data.
- **SharedPreferences** wrapper at `lib/core/helpers/SharedPreference/pereferences.dart` (note spelling), exposed as `SharedPreferencesHelper` via GetIt. Auth token is read from here in the Dio interceptor.

**Preference key constants** (see `lib/core/constants/preferences_constants.dart`):
- `token` — Bearer token; read on every Dio request. **Stored in plain SharedPreferences (not encrypted)** — consider migration to `flutter_secure_storage`.
- `isGuest` — Guest mode flag (boolean); set when user taps "Continue As Guest". If true, user is treated as logged out but can browse and access `requireAuth()` gates to trigger sign-in.
- `lang` — Locale ("en" or "ar"); default "ar"
- `isLanguageSelected` — First-run flag ("true" when user picks language)
- `hasSeenOnboarding` — First-run flag ("true" when user finishes onboarding)
- `userData`, `userPassword` — User profile data; cleared on logout

Most flags use string storage ("true" string, not bool type) because `SharedPreferencesHelper` provides only string get/set (no getBool/setBool). The `isGuest` flag uses `SharedPreferencesHelper.getIsGuest()` for a dedicated boolean getter.

**⚠️ Security Note:** Auth tokens are stored in plain `SharedPreferences` (not encrypted). On Android this is `shared_prefs.xml` (plaintext); on iOS it's `NSUserDefaults` (plaintext unless device-encrypted). Any attacker with file-system access can read the token. **Future work:** Migrate to `flutter_secure_storage` for encrypted key-value storage.

### App shell and tab navigation

The 4-tab bottom-nav app structure lives in `lib/modules/shell/`, **not** in a `HomeScreen` — no `home_screen.dart` exists in `lib/modules/home/home_screen/`; tabs are the branches of a `StatefulShellRoute`.

- **`ShellScaffold`** (`app_shell.dart`) is the `builder` of the `StatefulShellRoute.indexedStack` in `app_router.dart`. It wraps go_router's `StatefulNavigationShell` (the `IndexedStack` of the four branch navigators) with `ShellBottomNavBar` underneath. Hosts `SettingsCubit` and a `TabScrollRegistry` (via a private `_ShellScrollRegistryProvider` `InheritedWidget`). Runs `_checkVersion` and `ProfileCubit.getProfile()` once in `initState`.
- **`ShellBottomNavBar`** (`bottom_nav_bar.dart`) is the `CurvedNavigationBar` instance. It is the *only* place the nav appears.
- **Tab switching** is done via `navigationShell.goBranch(index)` inside `_handleNavTap`. There is no `TabNavigationCubit` — the selected index comes from `navigationShell.currentIndex`. Re-tapping the current tab calls `_scrollRegistry.scrollToTop(index)` instead of switching.
- **`TabScrollRegistry`** (`tab_scroll_registry.dart`) maps tab index → `ScrollController`. Root tab pages register/unregister in `didChangeDependencies` / `dispose` (use `shellScrollRegistryOf(context)`). Tab 2 (`AllBookingScreen`) is intentionally *not* registered (nested TabBar makes it ambiguous) — same-tap there is a no-op.
- **`UpdateDialog`** (`update_dialog.dart`) — version-update prompt shown by `_checkVersion`.

**Visibility rule:** the bottom nav appears **only inside the `StatefulShellRoute`**. Every detail route in the GoRouter is a top-level `GoRoute` on the root navigator, so pushing one covers this scaffold and hides the nav for free — there is no `withNavBar: false` to set.

**Entry-point pattern.** Each tab is its own branch with a stable path — `0=/home`, `1=/fleet`, `2=/bookings`, `3=/profile`. Navigate to a tab by going to its path:
- `context.go('/home')` — splash / logout / home
- `context.go('/bookings')` — booking-confirmed "Go to Bookings"
- `context.jumpToShellTab(3)` — tab jump from anywhere (defined in `lib/modules/shell/tab_jump.dart`; calls `context.go(Routes.pathForShellTab(tab))`)
- `Routes.pathForShellTab(n)` — the single authoritative mapping from index to path (defined in `routes.dart`)

`goBranch` preserves the target branch's existing stack (tabs remember their state across switches).

**`persistent_bottom_nav_bar` is in `pubspec.yaml`** but its `PersistentTabView`/`pushNewScreen` are no longer the routing mechanism — go_router is. Don't add `PersistentTabView`; it would re-introduce per-tab nested navigators that conflict with the visibility rule.

### Routing (go_router)

Navigation was migrated off `Navigator.push`/`MaterialPageRoute` onto **`go_router` (`^14.6.2`)**. The router lives in `lib/core/router/`:

- **`app_router.dart`** — the single `GoRouter appRouter` (wired into `MaterialApp.router` in `bloc_providers.dart`). `initialLocation: '/'` is `SplashScreenOld`. Auth pre-shell routes: `/language` → `SelectLanguage`, `/onboarding` → `OnBoarding` (3-page swipe intro, navigates to `/home` on finish/skip). The router has two kinds of entries:
  1. **`StatefulShellRoute.indexedStack`** — the 4-tab shell (branches `/home`, `/fleet`, `/bookings`, `/profile`). Branch order is index 0–3 and must match `ShellBottomNavBar` and `Routes.shellBranchPaths`.
  2. **Top-level `GoRoute`s** — every other screen. **Multi-parameter destinations take a typed `*Args` class via `extra:`** — those arg classes (`AuthScreenArgs`, `CarsInformationArgs`, `PaymentMethodsArgs`, `InvoiceArgs`, `LocationPickerArgs`, etc.) are defined at the bottom of `app_router.dart`. Single-value routes pass the bare value as `extra` (e.g. `/offer-details` takes `int`, `/web-payment` takes `String?`). The `/booking-confirmed` route uses `BottomSheetPage` (in `bottom_sheet_page.dart`) for a modal-style transition.
- **`routes.dart`** — `class Routes` with a `static const` name per route plus `shellBranchPaths` (the list `['/home', '/fleet', '/bookings', '/profile']`) and `pathForShellTab(int)`. **`extra` is not serializable**, so no route is reachable by deep link or app-restart restoration. Tab branch paths are the only routes navigable by plain URL string.
- **`notification_router.dart`** — `routeFromNotification(context, type:, data:)` is THE single source of truth mapping a notification `type` → destination (`cashback`→cashback, `booking`→`context.go('/bookings')`, `offer`→offer-details/offers, `update`/`unknown`→`context.go('/home')`). Both the in-app notifications screen and (eventually) FCM taps must route through it. Add new notification destinations here, not at call sites.
- **`tab_jump.dart`** — `extension TabJump on BuildContext` providing `context.jumpToShellTab(int)`, which calls `context.go(Routes.pathForShellTab(tab))`.

When adding a screen: add a `Routes` name, a `GoRoute` in `app_router.dart`, and (if it needs >1 param) an `*Args` class. Prefer `context.pushNamed`/`goNamed` over hardcoding path strings.

### Authentication Flow & Guest Mode

**Auth gating happens at the splash screen, not the router level.**

**File:** `lib/modules/auth/splash_screen.dart` (`SplashScreenOld`)

1. **On app boot:** Reads token from `SharedPreferences.get('token')` asynchronously (enforces min 300ms splash display).
2. **If token exists & not empty:** `context.go('/home')` immediately (Frame 2 never shown).
3. **If no token:** Shows Frame 2 (logo + two buttons):
   - **"ابدأ الحجز" (Start Booking)** — Routes to `/language`, `/onboarding`, or `/home` depending on first-run flags.
   - **"تسجيل الدخول" (Sign In)** — Routes to `/signin`.

**Guest mode:** A "Continue As Guest" button exists in `SignInScreen` (`lib/modules/auth/signin/presentation/pages/signin_screen.dart`). It sets an `isGuest` flag in SharedPreferences and navigates to `/home`. Guest mode is **now implemented** with the following behavior:
- ✅ `isGuest` flag is set in SharedPreferences when "Continue As Guest" is tapped.
- ✅ Splash screen (`SplashScreenOld`) checks for `isGuest` flag; if set, navigates directly to `/home`.
- ✅ API calls respect `if (token != null)` checks — datasources omit Authorization header for guests, preventing "Bearer null" errors.
- ✅ Auth-dependent screens show "Login Required" UI (Profile, Bookings tabs) for guest users.

**AuthStatusCubit** (`lib/modules/auth/blocs/auth_status_cubit.dart`): Tri-state cubit (`null` → resolving, `false` → signed out or guest, `true` → signed in). **Note:** The cubit emits `true` only if a token exists AND is not empty; guest mode is treated as `false` (logged out). Checked by Profile and Bookings tabs to show/hide auth-gated UI. Global singletons in GetIt.

**Auth-dependent screens:**
- **Profile tab (`profile.dart`):** Shows `LoginNoAuth()` widget (sign-in/register prompts) if `AuthStatusCubit` is `false` (applies to both guests and logged-out users).
- **Bookings tab (`all_booking_screen.dart`):** Shows `ErrorImage` ("Not Authenticated") if `AuthStatusCubit` is `false`.
- **Home/Search tab (`search_Screen.dart`):** Shows login bottom sheet if no token and not guest, but doesn't block page render. Guests can browse but cannot book without signing in.
- **Shell init (`app_shell.dart`):** Calls `ProfileCubit.getProfile()` on mount; for guests/unauthenticated users, this fails with 401 and error is silently caught and emitted.

**Auth-Gated Actions** — Some features (like "Book Now") require login but don't warrant full-screen navigation. Use the `requireAuth()` helper to gate actions in-place:

**File:** `lib/core/helpers/auth_guard/require_auth.dart`

The helper shows a sign-in modal sheet (SignInMode.gate) over the current screen, then retries the protected action after successful login without navigating away. For guest users, this modal becomes the sign-in entry point:

```dart
await requireAuth(
  context,
  onAuthenticated: () async {
    // This runs immediately if already authenticated,
    // or after successful login via modal sheet
    await performBooking();
  },
);
```

**Key behaviors:**
- Modal sheet appears over the current screen — user stays on BranchWithCarScreen during sign-in
- After login, `onAuthenticated()` callback runs with all screen state intact (SearchCubit selections, etc.)
- If user closes sheet without signing in, nothing happens — they're still on the original screen
- No navigation occurs; the sheet is the only UI change
- For guests, the `requireAuth()` flow is the primary sign-in mechanism; they cannot access auth-gated features until authenticated

**Modal vs. Navigation modes:**
- `SignInMode.gate` — Used by `requireAuth()`. Pops the sheet with result=true on login, no other navigation. Also used by guest users to sign in from booking flows.
- `SignInMode.entry` — Used for entry-point sign-in (splash, /signin route). Navigates to /home on login.

The difference: gate mode returns control to its caller (requireAuth), which decides what to do next. Entry mode owns the navigation flow.

**Guest mode implementation summary:**
1. ✅ `isGuest` flag is set in SharedPreferences when "Continue As Guest" is tapped.
2. ✅ `AuthStatusCubit._init()` emits `false` for guests (treated as logged out, not as a third state).
3. ✅ Datasources use `if (token != null)` checks to skip Bearer header for guests (see `app_interceptor.dart:48–50`).
4. ✅ API calls that require auth (e.g., `getProfile()`) skip or gracefully fail for guests.
5. ✅ Guest-specific UI is shown (no profile access, limited bookings, etc.) until authenticated via `requireAuth()`.

### Localization

Custom localization (no `arb`/`gen-l10n`). Strings live in `lib/language/languages/english.dart` and `arabic.dart` as `Map<String, String>`; `AppLocalizations` in `lib/language/locale.dart` exposes them as getters; `AppLocalizationsDelegate` is registered in `bloc_providers.dart`. Supported locales: `en`, `ar`. RTL via `intl.Bidi`.

**Runtime locale switching — `LanguageCubit`** (`lib/modules/home/selectLanguage/languageCubit.dart`). This class (`extends Cubit<Locale>`) is the single mechanism for reading and changing the active locale at runtime. On construction it calls `emitLocale()`, which reads `PreferencesConstants.lang` from SharedPreferences and emits the stored locale (defaulting to `ar`). Call `selectEngLanguage()` or `selectArabicLanguage()` to persist the choice and emit the new locale. `LanguageCubit` is registered as a `registerLazySingleton` in `service_locator.dart` and provided globally in `bloc_providers.dart` via `BlocProvider<LanguageCubit>`. The `BlocBuilder<LanguageCubit, Locale>` that wraps `CreateBlocProviders` rebuilds the entire `MaterialApp.router` on every locale change, so language switching is immediate and full-app-wide without a restart. The companion screen `SelectLanguage` (`lib/modules/home/selectLanguage/selectLanguage.dart`) resolves the cubit from the provider tree and calls these methods on confirmation.

**Hard rule: no hardcoded UI strings.** Every string that renders in the UI must go through `AppLocalizations`. This includes inline `isRTL ? 'ar' : 'en'` ternaries — they are *also* hardcoded strings, just two of them. When you add or touch UI text:

1. Add a key to **both** `english.dart` and `arabic.dart` (lowerCamelCase, e.g. `'goToBookings'`). English is the **source of truth** — write it first, then translate.
2. Add a corresponding getter on `AppLocalizations` in `locale.dart` (e.g. `String get goToBookings => _localizedValues[locale.languageCode]!['goToBookings']!;`). Prefer non-nullable `String get` for new keys; fall back to `String? get` only if the key may legitimately be missing.
3. Replace the call site with `AppLocalizations.of(context)!.<key>` (or `locale.<key>` if the method already has a `locale` variable).
4. Reuse an existing key when both translations match exactly — don't duplicate. The dictionaries were de-orphaned recently (177 unused getters/keys removed); keep them lean.

**Migration is complete.** The codebase was fully swept — `lib/` is clean of:
- Inline `isDirectionRTL(context) ? 'ar' : 'en'` ternaries
- Inline `Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en'` (a.k.a. `isArabic ? ...`) ternaries
- Single-language hardcoded `Text("…")`, `msg: "…"`, `title: "…"`, snackbar/dialog content, toast messages, and similar UI strings

Verify before claiming a regression — these greps should all return **zero** non-comment hits inside `lib/` (excluding `lib/language/` and `lib/core/constants/privacy_policy.dart`):
```bash
grep -rEn "isDirectionRTL\(context\)\s*\?\s*['\"][^'\"\$]+['\"]" lib/
grep -rEn "languageCode\s*==\s*['\"]ar['\"]\s*\?\s*['\"]" lib/
grep -rEn "Text\(\s*['\"][A-Za-z][^'\"\$]{3,}['\"]" lib/
```

**The one intentional exception** is `lib/core/constants/privacy_policy.dart` — ~700 lines of legal text held as two `const String` blocks (`PrivacyAr` / `PrivacyEn`). The privacy/terms screen toggles between them by locale. Migrating multi-paragraph legal copy into the `Map<String,String>` would bloat the dictionaries with no benefit. Don't migrate this file.

**Backend/protocol strings stay hardcoded** — API endpoints, HTTP header keys (`Authorization`, `Bearer`, `Accept-Language`), font family (`'ThmanyahSans'`), country codes (`'966'`), API response values compared against (`'OK'` in `data['status']`), asset paths, debug `print()` strings, and decorative emojis (`'❌ $msg'`) are not UI text and stay as-is.

**Note: nullable vs. non-nullable getters.** Older entries in `locale.dart` are `String? get foo` — call sites need `locale.foo!` where a non-null `String` is required. New keys are declared as `String get foo` (non-nullable) and don't need the `!`. Prefer non-nullable when adding new entries.

### Theming and styling

`ThemeCubit` (light/dark) lives in `lib/core/theme.dart` and is provided in `bloc_providers.dart` (it is created inline, **not** through GetIt). Custom font is `ThmanyahSans` (four weights: 300/400/500/700/900; declared in `pubspec.yaml`). All sizing should go through `flutter_screenutil` (`.w`, `.h`, `.sp`) since the design size is fixed at 390×844.

Color tokens and gradients live in `lib/core/constants/assets/app_colors.dart`. Each color has a `*Light` / `*Dark` constant plus a dynamic `*Color(BuildContext)` function that picks based on `Theme.of(context).brightness`. Use the dynamic functions in widgets; only use the constants if you specifically need the same color in both modes. The `linear()` gradient is the brand blue→green (`mainTypographyColor` → `SecondaryTypographyColor`) horizontal sweep.

**`AppTypography`** (`lib/core/style/style.dart`) is the single source for text styles — e.g. `AppTypography.headingColor26(context)`, `.paragraphColor16(context)`, `.buttonText20(context)`. Always use these instead of inline `TextStyle(fontFamily: 'ThmanyahSans', ...)`. The `lightTheme()` / `darkTheme()` functions in the same file define the `ThemeData` returned to `MaterialApp.router`.

**Text-scale-aware sizing — `num.hs(context)` / `.ws(context)` / `.sps(context)`.** Defined in `lib/core/helpers/text_scale_sizing.dart`, these multiply a screenutil value by the current `MediaQuery.textScalerOf(context).scale(1.0)`, so the dimension scales in lockstep with the system text scaler (clamped to `0.8–1.2` in `bloc_providers.dart`). Use them on heights of widgets that hold text — `toolbarHeight`, `PreferredSize.fromHeight`, button heights with labels, form-field heights, text-wrapping container heights. **Do NOT use them on `SizedBox` spacers, image / card / decoration dimensions, border radii, or `.sp` text/icon sizes** — those stay on plain `.h` / `.w` / `.sp` so the 390×844 design grid stays predictable. Tier-1 migration already covers the seven `toolbarHeight` call sites + the `PreferredSize` in `profile.dart`; the shared `CustomAppBar`'s `preferredSize` getter intentionally still returns `80.h` (no `BuildContext` available there) while its `build` renders `80.hs(context)` — a 1–8px measurement gap is acceptable within the clamp range.

### FigmaGradientBox

**Why raw Figma `Alignment` values are wrong.** Figma (and gradient-export plugins) describe linear gradient endpoints in a userSpace coordinate system — `x1`, `y1`, `x2`, `y2` in an SVG `<linearGradient gradientUnits="userSpaceOnUse">` are pixel offsets from the **top-left corner of the shape**, ranging from `0` to `figmaWidth` / `figmaHeight`. Flutter's `Alignment` uses a different origin and scale: `Alignment(0, 0)` is the center of the box, and the range is `−1` (top-left) to `+1` (bottom-right). Copying plugin-exported values verbatim into `LinearGradient(begin: Alignment(x1, y1), end: Alignment(x2, y2))` silently produces a gradient that starts and ends at completely different positions — the visual result looks wrong with no analyzer warning.

**Rule: always use `FigmaGradientBox` for Figma-sourced gradients** (`lib/core/style/figma_gradient_box.dart`). Never hand-roll a `LinearGradient` with plugin-exported alignment values. The widget accepts raw pixel coordinates and converts them internally:

```dart
// inside _FigmaGradientBoxState:
Alignment _toAlignment(Offset point, double width, double height) {
  final relX = point.dx / width;
  final relY = point.dy / height;
  return Alignment(relX * 2 - 1, relY * 2 - 1);
}
```

**Usage:**

```dart
FigmaGradientBox(
  figmaWidth:    358,                        // bounding box of the shape element
  figmaHeight:   120,                        // NOT the SVG viewBox (see below)
  gradientStart: const Offset(0, 60),        // x1, y1 from <linearGradient>
  gradientEnd:   const Offset(358, 60),      // x2, y2 from <linearGradient>
  colors: const [Color(0xFF1A6FBF), Color(0xFF16A87E)],
  stops:  const [0.0, 1.0],
  borderRadius: BorderRadius.circular(16.r),
  padding: EdgeInsets.all(16.w),
  child: const YourContentWidget(),
)
```

**Extracting values from a Figma SVG export:**

1. Select the shape in Figma and export as SVG.
2. Open the file and locate the `<linearGradient gradientUnits="userSpaceOnUse" x1="…" y1="…" x2="…" y2="…">` element. Those four attributes are `gradientStart = Offset(x1, y1)` and `gradientEnd = Offset(x2, y2)`.
3. Find the shape's `<path>` or `<rect>` and measure its bounding box — **not** the `<svg viewBox>`, which often adds extra margin for drop-shadow filters. The shape's own bounding box is `figmaWidth` × `figmaHeight`.

**Why runtime measurement instead of `AspectRatio`.** An earlier version used `AspectRatio(aspectRatio: figmaWidth / figmaHeight)` so the coordinate transform could be computed at build time. That caused `RenderFlex` overflow on wide/tablet screens (reproduced on a Lenovo TB128XU): `flutter_screenutil` padding scales with actual device width, and locking the height via `AspectRatio` left too little room for padding plus content. The current widget uses `GlobalKey` + `RenderBox` + `WidgetsBinding.instance.addPostFrameCallback` to measure its actual rendered size and recompute `_toAlignment` against it, so the gradient is always accurate regardless of final dimensions.

**Do not reintroduce `AspectRatio` inside this widget.** If a call site needs a locked aspect ratio, apply it there — not inside the shared widget.

### Push notifications (FCM)

Firebase Cloud Messaging is wired up via **`firebase_core`**, **`firebase_messaging`**, and **`flutter_local_notifications`** (in `pubspec.yaml`). All messaging logic lives in **`lib/core/helpers/notifications/push_notification_service.dart`** — a core helper (not a feature module), registered as a GetIt lazy singleton in `service_locator.dart` and initialized once from `main.dart`.

Boot wiring (inside the guarded `try` in `main.dart`, now with `kDebugMode` `debugPrint` logging): `await Firebase.initializeApp()` (native config — **no `firebase_options.dart`**; reads `android/app/google-services.json` and the iOS plist) → `initializeHive()` → `di.setup()` → `await sl<PushNotificationService>().init()`.

`PushNotificationService.init()`:
- Registers the **top-level** `firebaseMessagingBackgroundHandler` (annotated `@pragma('vm:entry-point')`, re-inits Firebase in its own isolate). **Keep this top-level** — a class method would be tree-shaken and killed-state delivery would silently break.
- Initializes `flutter_local_notifications` and creates the Android channel `high_importance_channel` (`Importance.high`). This id is shared with the `com.google.firebase.messaging.default_notification_channel_id` meta-data in `AndroidManifest.xml`, so foreground (locally shown) and background (OS-shown) notifications use one channel. Manifest also adds `POST_NOTIFICATIONS` and a `default_notification_icon` of `@mipmap/ic_launcher` (TODO: swap for a monochrome status-bar drawable).
- Requests permission via `FirebaseMessaging.requestPermission()` (covers iOS + Android 13 `POST_NOTIFICATIONS`; **not** `permission_handler`).
- Foreground `onMessage` → displays a heads-up banner via `flutter_local_notifications` (FCM does not auto-display while foregrounded).

**Device token:** always fetched through the guarded `_safeDeviceToken()` (try/catch → `null`, never throws) so the app survives devices without Google Play Services (`MISSING_INSTANCEID_SERVICE`). The public `getDeviceToken()` wrapper exposes it. **Token-to-backend wiring is NOT done** — sending the token on login / deregistering on logout (e.g. a `device_token` field in `SignInModel.toMap()`) is a separate future task.

**Two things still pending:**
- **iOS is not functional.** `ios/Runner/GoogleService-Info.plist` is absent and `ios/Runner.xcodeproj` is untouched; the Dart is cross-platform-correct but iOS push needs the plist added + registered in Xcode and APNs configured.
- **Tap-to-navigate from an FCM push (Phase C) is still not wired.** `PushNotificationService` does **not** subscribe to `onMessageOpenedApp` / `getInitialMessage` — tapping a system-tray push just opens the app. The destination-mapping half is done, though: `routeFromNotification` in `lib/core/router/notification_router.dart` is ready, and the in-app notifications screen already uses it. Wiring Phase C means calling `routeFromNotification` from those two FCM callbacks (needs a navigation context — `appRouter` can route without a `BuildContext`).

### In-app notifications module (`lib/modules/notifications/`)

Separate from FCM: a normal feature module (matching `data/` + `presentaion/` layout) for the **notifications list screen** (`/notifications` route, `NotificationsScreen.entry()`).

- **`NotificationsCubit`** (registered `registerFactory`) does paginated load (`getNotifications` resets, `loadMore` appends — `_perPage = 15`), plus **optimistic** `markOneAsRead` / `markAllAsRead` that revert on failure. States: `NotificationsInitial/Loading/Loaded/Empty/Error/NoInternet`.
- **`NotificationsRemoteDataSource`** uses the DI `Dio` (inherits Bearer token). **The API is PROVISIONAL** — endpoints `notificationsList` / `notificationsMarkOneRead` / `notificationsMarkAllRead` in `api_path.dart` are marked `TODO(api): confirm path + method`, and `NotificationItem.fromJson` / `NotificationsPage.fromJson` parse a guessed shape. When the real backend JSON arrives, only the model `fromJson` and those path constants change.
- **`NotificationType`** (`presentaion/widget/notification_type.dart`) is the enum (`cashback/booking/offer/update/unknown`) used for both the per-type icon/color (Figma swatches, no theme token) and routing via `routeFromNotification`. Tapping a card marks-as-read then routes through `routeFromNotification`.

### Shared widget library (`lib/modules/widgets/`)

Reusable UI components live here — prefer them over writing new ones from scratch:

- **`CustomAppBar`** (`components/appbar.dart`) — themed `AppBar` with optional back button and `AnimatedThemeToggleButton`; `preferredSize` uses `80.h`.
- **`ADGradientButton`** (`components/ad_gradient_btn.dart`) — primary CTA button with the brand gradient.
- **`ad_prim_text_form.dart`** / **`DynamicPhoneField_WithCountry.dart`** — standard form fields used across auth + booking flows.
- **`showResponsive_Flushbar.dart`** — the app's standard snackbar/toast wrapper (uses `another_flushbar`).
- **`FormValidator`** (`lib/core/helpers/validation/form_validator.dart`) — static validators for password, email, phone, passport, credit card, etc.; delegates to `Validate` class in the same folder.

## Adding a New Feature

Follow this pattern for consistency with the existing feature-module architecture.

**File structure:**
```
lib/modules/<feature>/
  data/
    datasources/
      remote/
        <feature>_remote_datasource.dart
      local/
        <feature>_local_datasource.dart
    models/
      <feature>_model.dart
    repositories/
      <feature>_repository.dart
  presentaion/  # ← Note the misspelling — do not fix
    bloc/
      <feature>_cubit.dart  # or state_bloc.dart for complex state machines
    pages/
      <feature>_screen.dart
    widgets/
      <feature>_widget.dart
```

**Steps:**

1. **Model:** Create `<feature>_model.dart` with JSON parsing (`fromJson` / `toMap`).
2. **Remote datasource:** Create `<feature>_remote_datasource.dart` using `sl<Dio>()` (inherits interceptor + token).
3. **Repository:** Create `<feature>_repository.dart` that abstracts datasource (optional if datasource is simple).
4. **Cubit:** Create `<feature>_cubit.dart` extending `Cubit<State>`. Decide: `registerFactory` (per-screen) or `registerLazySingleton` (global).
5. **State class:** Define state classes (e.g., `<Feature>Initial`, `<Feature>Loading`, `<Feature>Loaded`, `<Feature>Error`).
6. **Register in service locator:** Add to `lib/service_locator.dart` — both the datasource and cubit.
7. **Create screen:** Build `<feature>_screen.dart` with `BlocProvider<YourCubit>` wrapping `BlocBuilder`.
8. **Add route:** Add `GoRoute` to `lib/core/router/app_router.dart` (and optional `*Args` class if needed).
9. **Register route name:** Add constant to `lib/core/router/routes.dart`.

**Auth-dependent features:** If your feature's datasource needs authentication:
- Always check `if (token != null)` before adding the Bearer header (see `app_interceptor.dart:48–50`).
- Catch exceptions and emit error states instead of crashing.
- Use `BlocBuilder<AuthStatusCubit>` to gate UI for unauthenticated users (see Profile tab pattern).

## Conventions and gotchas

- **Known misspellings to preserve** — these are baked into imports across the codebase, fixing them is a large unrelated change:
  - Folder name `presentaion/` (every feature's UI layer uses this; should be `presentation/`)
  - `lib/core/helpers/SharedPreference/pereferences.dart` (should be `preferences.dart`)
  - `lib/modules/home/home_screen/clasic.dart` exporting class `Clasic` (should be `classic.dart` / `Classic`) — imported by `search_Screen.dart`
- **Code-generation:** any change to a `@HiveType` class (currently only `BranchModel` and friends in `lib/modules/home/all_branching/data/models/branch_model.dart`) requires re-running `build_runner` to regenerate both the `*.g.dart` adapter file and `lib/hive_registrar.g.dart` (the aggregated `registerAdapters()` called from `initializeHive()`).
- **`dependency_overrides`** in `pubspec.yaml` pins `intl: any` and `package_info_plus: ^8.3.1` — check for compatibility before bumping `intl` or any dep that depends on it.
- **Print statements** are commented out throughout `main.dart` and elsewhere; keep new logs gated similarly or remove before committing.
- **Service locator double-init guard:** `setup()` checks `sl.isRegistered<SignInBloc>()` and returns early. If you intentionally need to re-register, reset GetIt first (`sl.reset()`).
- **Bulk regex over Dart strings**: `[^'"]+` truncates at apostrophes inside double-quoted English (e.g. `"Let's"`). Use `"((?:[^"\\]|\\.)*)"` or two passes (one per quote style). After bulk substitutions always run `flutter analyze` and look for `Unterminated string literal` — that's the signature of mid-string truncation.
- **SharedPreferencesHelper quirk:** `get(key)` returns `Future<String?>?` (nullable Future of nullable String). When reading preferences, check if the Future itself is null before awaiting:
  ```dart
  final future = SharedPreferencesHelper().get(key);
  final value = future != null ? await future : null;
  ```
  Do NOT pass the result to `Future.wait()` without null-checking first. The helper provides only string get/set; there is no `getBool`/`setBool` pair, so boolean flags use string storage ("true" string).
- **Startup flow and first-run routing.** `SplashScreenOld` (the active splash, route `'/'` at `lib/modules/auth/splash_screen.dart`) follows this priority:
  
  1. Read token and `isGuest` flag asynchronously (enforces min 300ms display via Stopwatch)
  2. If token exists and not empty → `context.go('/home')` immediately (authenticated user, Frame 2 never shown)
  3. If `isGuest` flag is set → `context.go('/home')` immediately (guest user, Frame 2 never shown)
  4. If neither → show Frame 2 with two buttons:
     - "ابدأ الحجز" (Start Booking) → checks first-run flags (`isLanguageSelected` / `hasSeenOnboarding`), routes: missing language → `/language`; missing onboarding → `/onboarding`; both set → `/home`
     - "تسجيل الدخول" (Sign In) → `context.go('/signin')`
  
  First-run logged-in users: splash → home (skip language/onboarding).
  First-run guests: splash → home (skip language/onboarding, access guest mode features).
  First-run unauthenticated: splash → language selection → onboarding → home.
  Returning logged-in users: splash → direct to home.
  Returning guests: splash → direct to home (guest mode).
  Returning unauthenticated users: splash → sign-in or guest entry buttons.
  
  (`ComposeUi` no longer exists — removed in go_router migration.)
- **Stale `AssetManifest.bin` causes hot-reload `PathNotFoundException`.** If hot reload fails with `Cannot open file ... assets/<name>` for a path that doesn't exist anywhere in source (sometimes referencing the old `fast-rent` folder name), the cause is a stale `build/app/intermediates/.../AssetManifest.bin` from a previous build. Fix: `android\gradlew.bat --stop`, then `flutter clean && flutter pub get`, then re-run.
- **Asset folder convention.** `assets/icons/` holds SVGs; `assets/images/` holds raster images and a few Lottie JSONs (most Lottie files live in `assets/anim/`). Code uniformly references `assets/icons/<name>.svg` for SVGs — do not duplicate SVG icons into `assets/images/`. The `assets:` block in `pubspec.yaml` declares directories (not individual files), so dropping a file into a declared directory is enough to ship it; no manifest entry needed. After a recent cleanup, ~75 unreferenced files were deleted across both folders; `git log --diff-filter=D -- assets/` will show what was removed.

## Filtered Flutter command scripts (`scripts/`)

All three scripts live in `scripts/` at the project root. They are **Windows-only PowerShell** (`pwsh`). Run them from the project root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/flutter_analyze_filtered.ps1
powershell -ExecutionPolicy Bypass -File scripts/flutter_test_filtered.ps1
powershell -ExecutionPolicy Bypass -File scripts/flutter_test_filtered.ps1 test/foo.dart
powershell -ExecutionPolicy Bypass -File scripts/flutter_build_filtered.ps1 apk
powershell -ExecutionPolicy Bypass -File scripts/flutter_build_filtered.ps1 apk --release
```

Each script:
1. Runs the underlying `flutter` command and captures all output.
2. Saves the **full** raw output to a timestamped file in `$env:TEMP` (path is printed so you can inspect it manually).
3. Prints only **filtered** output to stdout: errors, warnings, hints, failures, exceptions, stack traces, file paths, and line numbers.
4. Exits with the same exit code as the underlying Flutter command, so CI and shell conditionals keep working.

**What is filtered out:** normal build-progress lines, dependency download logs, per-test dot sequences, verbose Gradle task logs (unless they contain FAILED/error), and any other noise that does not indicate a problem.

**Fallback:** if the exit code is non-zero but no recognisable pattern matched, the scripts dump the last 30–40 raw lines so the failure is never silently swallowed.

Extra arguments are forwarded verbatim — the scripts are transparent wrappers.

## Debugging & Troubleshooting

### App won't start or shows blank screen

Check the guarded `try` block in `main.dart` (lines 33–50). The catch is silent in release mode, so Firebase init failure, corrupted Hive box, or missing GetIt registration will cause silent boot failure. **Add logging in the catch block to diagnose startup issues.**

### "Bearer null" or 401 errors on API calls

1. Check if a token should exist: Is the user logged in? Run `await SharedPreferencesHelper().getToken()` in a debugger.
2. If token is null and you're hitting an API that requires auth, the call will fail with 401.
3. If you want to support unauthenticated (guest) requests, add `if (token != null)` check before adding the Bearer header.
4. Remember: String interpolation of null produces `"Bearer null"` (literal string "null"), not empty or omitted.

### Profile/Bookings tab shows "Not Authenticated" but user is logged in

Check `AuthStatusCubit.emit()` in `_init()`:
```dart
emit(token != null && token.isNotEmpty);  // ← Both conditions must pass
```
- Token exists but is empty string → emits `false` (treated as logged out).
- Token is null → emits `false`.
- Only if token exists AND not empty → emits `true`.

### Hot reload shows stale AssetManifest errors

```bash
android\gradlew.bat --stop
flutter clean
flutter pub get
flutter run
```

The `build/` folder has cached asset manifests. Gradle daemon holds locks on them.

### "X is not registered" errors deep in a feature

The service locator failed to wire up a cubit or datasource. Check:
1. Is the class registered in `service_locator.dart`?
2. Did you forget to call `di.setup()` in `main.dart`? (It is called, but check the catch block isn't swallowing errors.)
3. If you added a global cubit, did you register it in **both** `service_locator.dart` AND `bloc_providers.dart`?

### App boots but navigation doesn't work

Check `appRouter` in `bloc_providers.dart` (line 62). The router is wired into `MaterialApp.router`, but if the route name doesn't exist in `routes.dart` or the GoRoute is missing from `app_router.dart`, navigation silently fails.

### "Stale object reference" or Hive adapter errors

A `@HiveType` class was modified but the adapter wasn't regenerated:
```bash
dart run build_runner build --delete-conflicting-outputs
```

This regenerates `*.g.dart` adapters and `lib/hive_registrar.g.dart` (the aggregated register call).

### Locale/language isn't switching across the whole app

`LanguageCubit` is a global singleton that rebuilds the entire `MaterialApp.router`. If a screen isn't rebuilding on locale change:
1. Verify the screen is wrapped in `BlocBuilder<LanguageCubit>` or uses `AppLocalizations.of(context)` (which depends on the locale).
2. Check that you're calling `selectEngLanguage()` or `selectArabicLanguage()` on the cubit (not just updating SharedPreferences).
3. The top-level rebuild is triggered by the cubit emit, not prefs directly.

### Dio interceptor is firing twice or not at all

The Dio interceptor is added once in `service_locator.dart:151` at the end of `setup()`. Do NOT add it again from feature code:
```dart
// ❌ WRONG — will double-fire
sl<Dio>().interceptors.add(AppInterceptors(...));

// ✅ RIGHT — use the singleton
final dio = sl<Dio>();  // Already has interceptor
```
