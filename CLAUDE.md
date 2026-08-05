# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`darbak` is a Flutter car-rental mobile app (Android/iOS, with web/desktop folders also generated). The product brand is "Darbak" — launcher icon source is `assets/images/Darbak_logoo.png` (note the double `oo`). Dart SDK `^3.5.3`. App targets a `390x844` design size via `flutter_screenutil`.

The on-disk project folder is `E:\projects\darbak`. It was previously `E:\projects\fast-rent`; the Dart package, Android `applicationId`, iOS bundle id, and folder were all renamed to `darbak`. The application/bundle id is `com.abudiyab.darbak` (Android `namespace` + `applicationId`, iOS/macOS `PRODUCT_BUNDLE_IDENTIFIER`, Linux `APPLICATION_ID`); it was previously the default `com.example.darbak`. Do not change `package:darbak/...` imports back; do not rename the folder casually (Gradle, IDE, and pub cache references would all break). A sibling `~/.claude/projects/E--projects-fast-rent/memory/` slug still exists from the old name and holds older memories (e.g. `feedback_powershell_utf8.md`); new memories live under `E--projects-darbak/`.

## Commands

```bash
flutter pub get                  # install deps (run after pulling or editing pubspec.yaml)
flutter run                      # run on the currently selected device
flutter analyze                  # static analysis (uses package:flutter_lints)
flutter test                     # run tests in test/
flutter test test/widget_test.dart   # run a single test file
flutter test --plain-name "name" # run a single test by name
flutter build apk                # Android release
flutter build ios                # iOS release
dart run build_runner build --delete-conflicting-outputs   # regenerate Hive .g.dart adapters
dart run flutter_launcher_icons  # regenerate launcher icons (config in pubspec.yaml)
flutter clean                    # nuke build/ — fixes stale AssetManifest.bin hot-reload errors
```

`test/widget_test.dart` is still the default Flutter counter sample and does not match `App()` — treat it as scaffolding, not a real suite.

## Environment notes (Windows)

- **Pub cache lives on `E:\.pub-cache`**, not the default `%LOCALAPPDATA%\Pub\Cache`. The `PUB_CACHE` user env var is set to this path. Reason: on Windows, Kotlin's `RelocatableFileToPathConverter` crashes when project sources and pub cache are on different drive letters (`IllegalArgumentException: this and base files have different roots`). Keep `PUB_CACHE` and the project on the same drive.
- **`flutter pub get` may hit pub.dev's `advisoriesUpdated` decoding bug** (`FormatException: advisoriesUpdated must be a String`). Workaround: `flutter pub get --offline` once packages are cached; the post-solve advisories fetch is what crashes, packages still install.
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

### Networking

- A single `Dio` is registered as a lazy singleton in `service_locator.dart`. **`AppInterceptors`** (in `lib/core/helpers/interceptors/app_interceptor.dart`) is attached to that `Dio` once at the end of `setup()` — so every `sl<Dio>()` call inherits `baseUrl = mainApi`, the `Accept-Language` header, and the `Authorization: Bearer <token>` header (token pulled from `SharedPreferencesHelper` on every request). Do **not** call `sl<Dio>().interceptors.add(AppInterceptors(...))` again from feature code — it would double-fire the request hook.
- All endpoints are constants in `lib/core/constants/api_path.dart`. Active base URL is `productionApi = "https://api.daraksonksa.com/api"` (controlled by the `mainApi` const). Many endpoint constants are pre-prefixed with `mainApi`, so do not double-prefix when composing requests.

### Persistence

- **Hive** (`lib/core/helpers/cache/cache_helper.dart`) — TTL of 5 minutes (`cacheValidDuration`), boxes `branches_box`/`cars_box`/`cache_meta_box`, with metadata keys of the form `${key}_time`. Use `CacheHelper.isCacheValid(key)` before serving cached data.
- **SharedPreferences** wrapper at `lib/core/helpers/SharedPreference/pereferences.dart` (note spelling), exposed as `SharedPreferencesHelper` via GetIt. Auth token is read from here in the Dio interceptor.

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

- **`app_router.dart`** — the single `GoRouter appRouter` (wired into `MaterialApp.router` in `bloc_providers.dart`). `initialLocation: '/'` is `SplashScreenOld`. The router has two kinds of entries:
  1. **`StatefulShellRoute.indexedStack`** — the 4-tab shell (branches `/home`, `/fleet`, `/bookings`, `/profile`). Branch order is index 0–3 and must match `ShellBottomNavBar` and `Routes.shellBranchPaths`.
  2. **Top-level `GoRoute`s** — every other screen. **Multi-parameter destinations take a typed `*Args` class via `extra:`** — those arg classes (`AuthScreenArgs`, `CarsInformationArgs`, `PaymentMethodsArgs`, `InvoiceArgs`, `LocationPickerArgs`, etc.) are defined at the bottom of `app_router.dart`. Single-value routes pass the bare value as `extra` (e.g. `/offer-details` takes `int`, `/web-payment` takes `String?`). The `/booking-confirmed` route uses `BottomSheetPage` (in `bottom_sheet_page.dart`) for a modal-style transition.
- **`routes.dart`** — `class Routes` with a `static const` name per route plus `shellBranchPaths` (the list `['/home', '/fleet', '/bookings', '/profile']`) and `pathForShellTab(int)`. **`extra` is not serializable**, so no route is reachable by deep link or app-restart restoration. Tab branch paths are the only routes navigable by plain URL string.
- **`notification_router.dart`** — `routeFromNotification(context, type:, data:)` is THE single source of truth mapping a notification `type` → destination (`cashback`→cashback, `booking`→`context.go('/bookings')`, `offer`→offer-details/offers, `update`/`unknown`→`context.go('/home')`). Both the in-app notifications screen and (eventually) FCM taps must route through it. Add new notification destinations here, not at call sites.
- **`tab_jump.dart`** — `extension TabJump on BuildContext` providing `context.jumpToShellTab(int)`, which calls `context.go(Routes.pathForShellTab(tab))`.

When adding a screen: add a `Routes` name, a `GoRoute` in `app_router.dart`, and (if it needs >1 param) an `*Args` class. Prefer `context.pushNamed`/`goNamed` over hardcoding path strings.

### Localization

Custom localization (no `arb`/`gen-l10n`). Strings live in `lib/language/languages/english.dart` and `arabic.dart` as `Map<String, String>`; `AppLocalizations` in `lib/language/locale.dart` exposes them as getters; `AppLocalizationsDelegate` is registered in `bloc_providers.dart`. Supported locales: `en`, `ar`. RTL via `intl.Bidi`.

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

**Backend/protocol strings stay hardcoded** — API endpoints, HTTP header keys (`Authorization`, `Bearer`, `Accept-Language`), font family (`'IBMPlexSansArabic'`), country codes (`'966'`), API response values compared against (`'OK'` in `data['status']`), asset paths, debug `print()` strings, and decorative emojis (`'❌ $msg'`) are not UI text and stay as-is.

**Note: nullable vs. non-nullable getters.** Older entries in `locale.dart` are `String? get foo` — call sites need `locale.foo!` where a non-null `String` is required. New keys are declared as `String get foo` (non-nullable) and don't need the `!`. Prefer non-nullable when adding new entries.

### Theming and styling

`ThemeCubit` (light/dark) lives in `lib/core/theme.dart` and is provided in `bloc_providers.dart` (it is created inline, **not** through GetIt). Custom font is `IBMPlexSansArabic` (declared in `pubspec.yaml`). All sizing should go through `flutter_screenutil` (`.w`, `.h`, `.sp`) since the design size is fixed at 390×844.

Color tokens and gradients live in `lib/core/constants/assets/app_colors.dart`. Each color has a `*Light` / `*Dark` constant plus a dynamic `*Color(BuildContext)` function that picks based on `Theme.of(context).brightness`. Use the dynamic functions in widgets; only use the constants if you specifically need the same color in both modes. The `linear()` gradient is the brand blue→green (`mainTypographyColor` → `SecondaryTypographyColor`) horizontal sweep.

**Text-scale-aware sizing — `num.hs(context)` / `.ws(context)` / `.sps(context)`.** Defined in `lib/core/helpers/text_scale_sizing.dart`, these multiply a screenutil value by the current `MediaQuery.textScalerOf(context).scale(1.0)`, so the dimension scales in lockstep with the system text scaler (clamped to `0.8–1.2` in `bloc_providers.dart`). Use them on heights of widgets that hold text — `toolbarHeight`, `PreferredSize.fromHeight`, button heights with labels, form-field heights, text-wrapping container heights. **Do NOT use them on `SizedBox` spacers, image / card / decoration dimensions, border radii, or `.sp` text/icon sizes** — those stay on plain `.h` / `.w` / `.sp` so the 390×844 design grid stays predictable. Tier-1 migration already covers the seven `toolbarHeight` call sites + the `PreferredSize` in `profile.dart`; the shared `CustomAppBar`'s `preferredSize` getter intentionally still returns `80.h` (no `BuildContext` available there) while its `build` renders `80.hs(context)` — a 1–8px measurement gap is acceptable within the clamp range.

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
- **`SplashScreenOld` is the active splash**, not deprecated despite the name. It is the `'/'` route of `appRouter`; source at `lib/modules/auth/splash_screen.dart`. Cross-fades between two states (`gradient1` background → white) over `Darbak_logo.png`, then `context.go('/home')` (returning user) or `context.go('/language')` (first run) based on the `isLanguageSelected` flag in `SharedPreferences`. Landing on `/home` mounts the shell's first branch. (`ComposeUi` no longer exists — that intermediate widget was removed in the go_router migration.)
- **Stale `AssetManifest.bin` causes hot-reload `PathNotFoundException`.** If hot reload fails with `Cannot open file ... assets/<name>` for a path that doesn't exist anywhere in source (sometimes referencing the old `fast-rent` folder name), the cause is a stale `build/app/intermediates/.../AssetManifest.bin` from a previous build. Fix: `android\gradlew.bat --stop`, then `flutter clean && flutter pub get`, then re-run.
- **Asset folder convention.** `assets/icons/` holds SVGs; `assets/images/` holds raster images and a few Lottie JSONs (most Lottie files live in `assets/anim/`). Code uniformly references `assets/icons/<name>.svg` for SVGs — do not duplicate SVG icons into `assets/images/`. The `assets:` block in `pubspec.yaml` declares directories (not individual files), so dropping a file into a declared directory is enough to ship it; no manifest entry needed. After a recent cleanup, ~75 unreferenced files were deleted across both folders; `git log --diff-filter=D -- assets/` will show what was removed.
