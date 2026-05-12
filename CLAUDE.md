# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`darbak` is a Flutter car-rental mobile app (Android/iOS, with web/desktop folders also generated). The product brand is "Darakson" / "Darbak" — launcher icon source is `assets/images/Darbak_logoo.png` (note the double `oo`). Dart SDK `^3.5.3`. App targets a `390x844` design size via `flutter_screenutil`.

The on-disk project folder is still named `fast-rent` (`E:\projects\fast-rent`) even though the Dart package, Android `applicationId`, iOS bundle id, etc. were all renamed to `darbak` (`com.example.darbak`). Do not change `package:darbak/...` imports back; do not rename the folder casually (Gradle, IDE, and pub cache references would all break).

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
```

`test/widget_test.dart` is still the default Flutter counter sample and does not match `App()` — treat it as scaffolding, not a real suite.

## Environment notes (Windows)

- **Pub cache lives on `E:\.pub-cache`**, not the default `%LOCALAPPDATA%\Pub\Cache`. The `PUB_CACHE` user env var is set to this path. Reason: on Windows, Kotlin's `RelocatableFileToPathConverter` crashes when project sources and pub cache are on different drive letters (`IllegalArgumentException: this and base files have different roots`). Keep `PUB_CACHE` and the project on the same drive.
- **`flutter pub get` may hit pub.dev's `advisoriesUpdated` decoding bug** (`FormatException: advisoriesUpdated must be a String`). Workaround: `flutter pub get --offline` once packages are cached; the post-solve advisories fetch is what crashes, packages still install.
- **Gradle/Kotlin daemons hold file locks** in `build/` and `android/app/`. If a delete or replace of any file inside the project tree fails with "file in use", run `android\gradlew.bat --stop` first. Closing Android Studio / VS Code is also often required.
- **Dart files must be UTF-8 without BOM.** `Get-Content -Raw` in Windows PowerShell 5.1 reads as cp1252 by default — round-tripping through it silently corrupts Arabic strings into mojibake. For bulk edits use `[System.IO.File]::ReadAllBytes` + `[System.Text.Encoding]::UTF8.GetString` for reading and `[System.IO.File]::WriteAllText(path, text, (New-Object System.Text.UTF8Encoding $false))` for writing. See `~/.claude/projects/E--projects-fast-rent/memory/feedback_powershell_utf8.md` for the full incident.

## Architecture

The app follows a **feature-module + clean-architecture-lite** layout. Each feature under `lib/modules/<feature>/` has its own `data/` (datasources, models, repositories) and `presentaion/` (note the spelling — `presentaion`, not `presentation`) with `bloc/` or `blocs/` subfolders. New features should match this convention even though the spelling is non-standard.

### Boot sequence (`lib/main.dart` → `lib/bloc_providers.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()` and orientation lock to portrait.
2. `initializeHive()` — opens Hive, registers all `BranchModel`-related adapters (`BranchModelAdapter`, `WorkTimeAdapter`, `AlldaysAdapter`, `FriAdapter`, `AfternoneAdapter`, `MonAdapter`), then calls `CacheHelper.init()` which opens boxes `branches_box`, `cars_box`, `cache_meta_box`. **Any new Hive type must be registered here** — adapters are not auto-discovered.
3. `di.setup()` — `service_locator.dart` (GetIt) registers all blocs/cubits, repositories, remote/local datasources, and shared singletons (`Dio`, `SharedPreferencesHelper`, `DateHandler`). The setup function early-returns if `AuthBloc` is already registered, so it is safe to call more than once but will silently skip re-wiring — clear GetIt if you need a true reset.
4. `runApp(App())` → `ScreenUtilInit` → `CreateBlocProviders(context)` mounts a `MultiBlocProvider` with the global blocs (Auth, Cars, Booking, Language, ForgetPassword, Profile, Additions, Invoice, Search, Filter, AllBooking, AllBranch, AllCars, Theme) wrapped in `BlocBuilder<LanguageCubit>` + `BlocBuilder<ThemeCubit>` + `AppLifeCycleManager` + `MaterialApp`.
5. `MaterialApp.builder` wraps every page with `MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), child: child!)` — text scale is **locked** regardless of the user's system font-size setting. Don't remove this; layouts depend on `flutter_screenutil`'s fixed 390×844 design and break under arbitrary scaling.

**Steps 2 and 3 are wrapped in `try { ... } catch (e, stackTrace) { }` with no logging in `main.dart`.** A corrupted Hive box or a missing GetIt registration will silently boot the app into a broken state. When investigating startup mysteries (blank screen, missing data, "X not registered" errors deep in a feature), add logging in that catch block first.

If you add a feature-level cubit that should be globally available, register it in **both** `service_locator.dart` and `bloc_providers.dart`. Feature-local cubits should be provided closer to the screen instead.

### State management

`flutter_bloc` (Bloc + Cubit). Per-feature cubits are resolved from GetIt (`sl<X>()`) inside `BlocProvider.create`. Some cubits are `registerFactory` (new instance per request — e.g. `AuthBloc`, most form cubits), others are `registerLazySingleton` (shared instance — e.g. `BookingCubit`, `LanguageCubit`, `FilterCubit`, `SearchCubit`). Match this distinction when adding new cubits: stateful cross-screen state → singleton; per-screen form/flow state → factory.

### Networking

- A single `Dio` is registered as a lazy singleton in `service_locator.dart`. **`AppInterceptors`** (in `lib/core/helpers/interceptors/app_interceptor.dart`) is defined but **not currently attached** to the Dio instance in `setup()` — interceptors that set `baseUrl`, the `Accept-Language` header, and the `Bearer` token will not run unless you wire them in (`sl<Dio>().interceptors.add(AppInterceptors(sl()))`).
- All endpoints are constants in `lib/core/constants/api_path.dart`. Active base URL is `productionApi = "https://api.daraksonksa.com/api"` (controlled by the `mainApi` const). Many endpoint constants are pre-prefixed with `mainApi`, so do not double-prefix when composing requests.

### Persistence

- **Hive** (`lib/core/helpers/cache/cache_helper.dart`) — TTL of 5 minutes (`cacheValidDuration`), boxes `branches_box`/`cars_box`/`cache_meta_box`, with metadata keys of the form `${key}_time`. Use `CacheHelper.isCacheValid(key)` before serving cached data.
- **SharedPreferences** wrapper at `lib/core/helpers/SharedPreference/pereferences.dart` (note spelling), exposed as `SharedPreferencesHelper` via GetIt. Auth token is read from here in the Dio interceptor.

### App shell and tab navigation

The 4-tab bottom-nav app structure lives in `lib/modules/shell/`, **not** in a `HomeScreen` (the old `lib/modules/home/home_screen/home_screen.dart` was deleted).

- **`AppShell`** (`app_shell.dart`) is the root tabbed widget. It renders an `IndexedStack` of the 4 root pages — index `0=SearchScreen`, `1=AllCarsScreen`, `2=AllBookingScreen`, `3=MyProfile` — with `ShellBottomNavBar` underneath. Hosts `SettingsCubit`, `TabNavigationCubit`, and a `TabScrollRegistry` (via a private `InheritedWidget`). Runs `_checkVersion` and `ProfileCubit.getProfile()` once on mount.
- **`ShellBottomNavBar`** (`bottom_nav_bar.dart`) is the `CurvedNavigationBar` instance — same visuals as before. It is the *only* place the nav appears.
- **`TabNavigationCubit`** (`tab_navigation_cubit.dart`) is a `Cubit<int>` holding the selected index. It exposes `context.jumpToShellTab(int)` — pops to the shell route then sets the index, so any deep screen can switch tabs.
- **`TabScrollRegistry`** (`tab_scroll_registry.dart`) maps tab index → `ScrollController`. Root tab pages register/unregister in `didChangeDependencies` / `dispose` (use `shellScrollRegistryOf(context)`). Tapping the same tab → shell calls `scrollToTop` on the registered controller. Tab 2 (`AllBookingScreen`) is intentionally *not* registered (nested TabBar makes it ambiguous) — same-tap there is a no-op.
- **`UpdateDialog`** (`update_dialog.dart`) — version-update prompt shown by `_checkVersion`.

**Visibility rule:** the bottom nav appears **only on the 4 root tabs**. Every screen pushed via `Navigator.push` / `MaterialPageRoute` covers the shell scaffold, so the nav is hidden for free — there is no `withNavBar: false` to set. Detail screens, payment, profile sub-pages, maps, etc. all push normally.

**Entry-point pattern.** Every "go home" or "land on tab N" action **must** push `AppShell(initialTab: N)` (use `pushAndRemoveUntil` for clean stacks). Landing inside the shell is what makes the nav appear. Hardcoding `MaterialPageRoute(builder: (_) => MyProfile())` etc. lands the page *outside* the shell with no nav — wrong. Examples:
- Logout → `AppShell(initialTab: 0)`
- Booking-confirmed "Go to Bookings" → `AppShell(initialTab: 2)`
- Avatar tap from inside the shell → `context.jumpToShellTab(3)` (no push)

**`persistent_bottom_nav_bar` is in `pubspec.yaml`** and `PersistentNavBarNavigator.pushNewScreen(...)` is still called in many places. Without a `PersistentTabView` ancestor, those calls fall back to a regular push, which is exactly what we want (nav hides). Don't add `PersistentTabView` — it would re-introduce per-tab nested navigators which conflict with the visibility rule.

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

**Text-scale-aware sizing — `num.hs(context)` / `.ws(context)` / `.sps(context)`.** Defined in `lib/core/helpers/text_scale_sizing.dart`, these multiply a screenutil value by the current `MediaQuery.textScalerOf(context).scale(1.0)`, so the dimension scales in lockstep with the system text scaler (clamped to `0.8–1.1` in `bloc_providers.dart`). Use them on heights of widgets that hold text — `toolbarHeight`, `PreferredSize.fromHeight`, button heights with labels, form-field heights, text-wrapping container heights. **Do NOT use them on `SizedBox` spacers, image / card / decoration dimensions, border radii, or `.sp` text/icon sizes** — those stay on plain `.h` / `.w` / `.sp` so the 390×844 design grid stays predictable. Tier-1 migration already covers the seven `toolbarHeight` call sites + the `PreferredSize` in `profile.dart`; the shared `CustomAppBar`'s `preferredSize` getter intentionally still returns `80.h` (no `BuildContext` available there) while its `build` renders `80.hs(context)` — a 1–8px measurement gap is acceptable within the clamp range.

### Push notifications (removed)

Firebase / FCM has been removed from the codebase: `main.dart` no longer calls `Firebase.initializeApp()`, `lib/fcm_service/` does not exist, and `grep -r FirebaseMessaging lib/` returns no hits. `google-services.json` is absent from `android/app/`, and the `com.google.gms.google-services` Gradle plugin is not declared in `android/app/build.gradle.kts` or `android/settings.gradle.kts`. iOS `GoogleService-Info.plist` is similarly absent. To reintroduce push, restore the platform config files, re-add the Gradle plugin, add `firebase_core` + `firebase_messaging` to `pubspec.yaml`, re-add `Firebase.initializeApp()` in `main.dart`, and wire `deviceToken` (see the gotcha below).

## Conventions and gotchas

- **Folder name `presentaion`** is misspelled across the codebase — keep the misspelling so imports resolve.
- **Code-generation:** any change to a `@HiveType` class (currently only `BranchModel` and friends in `lib/modules/home/all_branching/data/models/branch_model.dart`) requires re-running `build_runner`.
- **`dependency_overrides`** in `pubspec.yaml` pins `intl: any` and `package_info_plus: ^8.3.1` — check for compatibility before bumping `intl` or any dep that depends on it.
- **Print statements** are commented out throughout `main.dart` and elsewhere; keep new logs gated similarly or remove before committing.
- **Service locator double-init guard:** `setup()` checks `sl.isRegistered<AuthBloc>()` and returns early. If you intentionally need to re-register, reset GetIt first (`sl.reset()`).
- **Bulk regex over Dart strings**: `[^'"]+` truncates at apostrophes inside double-quoted English (e.g. `"Let's"`). Use `"((?:[^"\\]|\\.)*)"` or two passes (one per quote style). After bulk substitutions always run `flutter analyze` and look for `Unterminated string literal` — that's the signature of mid-string truncation.
- **`SplashScreenOld` is the active splash**, not deprecated despite the name. Wired up in `bloc_providers.dart` (`home: SplashScreenOld()`); source at `lib/modules/auth/splash_screen.dart`. Cross-fades between two states (`gradient1` background → white) over `Darbak_logo.png`, then navigates to `SelectLanguage` (first run) or `ComposeUi` based on the `isLanguageSelected` flag in `SharedPreferences`. `ComposeUi` then renders `AppShell` — that is how the shell first mounts.
- **`deviceToken` global is dead.** `String? deviceToken;` declared in `lib/core/constants/langCode.dart:9` is never assigned anywhere in the codebase. `signin_screen.dart:422` does `device_token: deviceToken.toString()`, which sends the literal string `"null"` to `/login` in `SignInModel.toMap()`. There is no separate "register device" / token-refresh endpoint. Reintroducing push means assigning this global from `FirebaseMessaging.instance.getToken()` at boot and listening to `onTokenRefresh`.
- **Stale `AssetManifest.bin` causes hot-reload `PathNotFoundException`.** If hot reload fails with `Cannot open file ... assets/<name>` for a path that doesn't exist anywhere in source (sometimes referencing the old `fast-rent` folder name), the cause is a stale `build/app/intermediates/.../AssetManifest.bin` from a previous build. Fix: `android\gradlew.bat --stop`, then `flutter clean && flutter pub get`, then re-run.
- **Asset folder convention.** `assets/icons/` holds SVGs; `assets/images/` holds raster images and a few Lottie JSONs (most Lottie files live in `assets/anim/`). Code uniformly references `assets/icons/<name>.svg` for SVGs — do not duplicate SVG icons into `assets/images/`. The `assets:` block in `pubspec.yaml` declares directories (not individual files), so dropping a file into a declared directory is enough to ship it; no manifest entry needed. After a recent cleanup, ~75 unreferenced files were deleted across both folders; `git log --diff-filter=D -- assets/` will show what was removed.
