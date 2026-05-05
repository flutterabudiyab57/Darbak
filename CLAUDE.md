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
3. `Firebase.initializeApp()` and `FirebaseMessaging.onBackgroundMessage` wiring.
4. `di.setup()` — `service_locator.dart` (GetIt) registers all blocs/cubits, repositories, remote/local datasources, and shared singletons (`Dio`, `SharedPreferencesHelper`, `DateHandler`). The setup function early-returns if `AuthBloc` is already registered, so it is safe to call more than once but will silently skip re-wiring — clear GetIt if you need a true reset.
5. `NotificationConfig.initialize()` — local + FCM notifications.
6. `runApp(App())` → `ScreenUtilInit` → `CreateBlocProviders(context)` mounts a `MultiBlocProvider` with the global blocs (Auth, Cars, Booking, Language, ForgetPassword, Profile, Additions, Invoice, Search, Filter, AllBooking, AllBranch, AllCars, Theme) wrapped in `BlocBuilder<LanguageCubit>` + `BlocBuilder<ThemeCubit>` + `AppLifeCycleManager` + `MaterialApp`.

If you add a feature-level cubit that should be globally available, register it in **both** `service_locator.dart` and `bloc_providers.dart`. Feature-local cubits should be provided closer to the screen instead.

### State management

`flutter_bloc` (Bloc + Cubit). Per-feature cubits are resolved from GetIt (`sl<X>()`) inside `BlocProvider.create`. Some cubits are `registerFactory` (new instance per request — e.g. `AuthBloc`, most form cubits), others are `registerLazySingleton` (shared instance — e.g. `BookingCubit`, `LanguageCubit`, `FilterCubit`, `SearchCubit`). Match this distinction when adding new cubits: stateful cross-screen state → singleton; per-screen form/flow state → factory.

### Networking

- A single `Dio` is registered as a lazy singleton in `service_locator.dart`. **`AppInterceptors`** (in `lib/core/helpers/interceptors/app_interceptor.dart`) is defined but **not currently attached** to the Dio instance in `setup()` — interceptors that set `baseUrl`, the `Accept-Language` header, and the `Bearer` token will not run unless you wire them in (`sl<Dio>().interceptors.add(AppInterceptors(sl()))`).
- All endpoints are constants in `lib/core/constants/api_path.dart`. Active base URL is `productionApi = "https://api.daraksonksa.com/api"` (controlled by the `mainApi` const). Many endpoint constants are pre-prefixed with `mainApi`, so do not double-prefix when composing requests.

### Persistence

- **Hive** (`lib/core/helpers/cache/cache_helper.dart`) — TTL of 5 minutes (`cacheValidDuration`), boxes `branches_box`/`cars_box`/`cache_meta_box`, with metadata keys of the form `${key}_time`. Use `CacheHelper.isCacheValid(key)` before serving cached data.
- **SharedPreferences** wrapper at `lib/core/helpers/SharedPreference/pereferences.dart` (note spelling), exposed as `SharedPreferencesHelper` via GetIt. Auth token is read from here in the Dio interceptor.

### Localization

Custom localization (no `arb`/`gen-l10n`). Strings live in `lib/language/languages/english.dart` and `arabic.dart` as `Map<String, String>`; `AppLocalizations` in `lib/language/locale.dart` exposes them as getters; `AppLocalizationsDelegate` is registered in `bloc_providers.dart`. Supported locales: `en`, `ar`. RTL via `intl.Bidi`.

**Migration in progress.** The codebase is being moved from inline `isRTL ? 'ar' : 'en'` ternaries to centralized `AppLocalizations` calls. As of the last pass, ~49 files still contain inline ternaries; do not add new ones. When you touch a file with inline ternaries, migrate them as part of the change:

1. Add a key to **both** `english.dart` and `arabic.dart` (lowerCamelCase, e.g. `'updateAvailable'`).
2. Add a corresponding getter on `AppLocalizations` in `locale.dart` (e.g. `String get updateAvailable => _localizedValues[locale.languageCode]!['updateAvailable']!;`).
3. Replace the call site with `AppLocalizations.of(context)!.<key>` (or `locale.<key>` if the method already has a `locale` variable).
4. Reuse an existing key when both English and Arabic match exactly — don't add duplicates. The dictionaries were de-orphaned recently (177 unused getters/keys removed); keep them lean.

Some existing getters are nullable (`String? get foo`) — at call sites where the surrounding type wants `String`, append `!`.

### Theming and styling

`ThemeCubit` (light/dark) lives in `lib/core/theme.dart` and is provided in `bloc_providers.dart` (it is created inline, **not** through GetIt). Custom font is `IBMPlexSansArabic` (declared in `pubspec.yaml`). All sizing should go through `flutter_screenutil` (`.w`, `.h`, `.sp`) since the design size is fixed at 390×844.

Color tokens and gradients live in `lib/core/constants/assets/app_colors.dart`. Each color has a `*Light` / `*Dark` constant plus a dynamic `*Color(BuildContext)` function that picks based on `Theme.of(context).brightness`. Use the dynamic functions in widgets; only use the constants if you specifically need the same color in both modes. The `linear()` gradient is the brand blue→green (`mainTypographyColor` → `SecondaryTypographyColor`) horizontal sweep.

### Firebase / FCM

`Firebase.initializeApp()` is called from `main.dart` and `_firebaseMessagingBackgroundHandler` is a top-level function annotated with `@pragma('vm:entry-point')` — both must stay or FCM will fail. Foreground/local notification config is in `lib/fcm_service/notification_config.dart`.

**`google-services.json` was deleted from `android/app/`** and the `com.google.gms.google-services` Gradle plugin was removed from `android/app/build.gradle.kts` and `android/settings.gradle.kts`. As a result, Android builds compile, but `Firebase.initializeApp()` will throw at runtime on Android until either (a) `google-services.json` is restored and the plugin re-added, or (b) the Firebase calls in `main.dart` and `lib/fcm_service/notification_config.dart` are removed/stubbed. iOS still expects `GoogleService-Info.plist`. Be aware before running the app on a real device.

## Conventions and gotchas

- **Folder name `presentaion`** is misspelled across the codebase — keep the misspelling so imports resolve.
- **Code-generation:** any change to a `@HiveType` class (currently only `BranchModel` and friends in `lib/modules/home/all_branching/data/models/branch_model.dart`) requires re-running `build_runner`.
- **`dependency_overrides`** in `pubspec.yaml` pins `intl: any` and `package_info_plus: ^8.3.1` — check for compatibility before bumping `intl` or any dep that depends on it.
- **Print statements** are commented out throughout `main.dart` and elsewhere; keep new logs gated similarly or remove before committing.
- **Service locator double-init guard:** `setup()` checks `sl.isRegistered<AuthBloc>()` and returns early. If you intentionally need to re-register, reset GetIt first (`sl.reset()`).
- **Bulk regex over Dart strings**: `[^'"]+` truncates at apostrophes inside double-quoted English (e.g. `"Let's"`). Use `"((?:[^"\\]|\\.)*)"` or two passes (one per quote style). After bulk substitutions always run `flutter analyze` and look for `Unterminated string literal` — that's the signature of mid-string truncation.
