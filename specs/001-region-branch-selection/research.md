# Phase 0 Research: Region & Branch Selection Rewrite

**Date**: 2026-09-02 | **Plan**: [plan.md](./plan.md)

The architecture was supplied as decided. This document records only the codebase verification it
explicitly asked for, plus the unknowns that verification exposed. No alternatives to the
architecture are evaluated.

---

## R1 — Where does `package:http` actually live?

**Asked because**: the constitution states `package:http` "is legacy and exists only in
`branchs_service.dart`, which is scheduled for deletion; when it is removed, check whether `http`
can be dropped from `pubspec.yaml` entirely", and Phase 9 ends with that check.

**Decision**: `package:http` **cannot** be dropped in Phase 9. Plan for the check to answer "no".

**Finding**: 11 files import `package:http/http.dart`, only one of which is in scope for deletion.

| File | In Phase 9 scope? |
|---|---|
| `lib/modules/home/search_screen/data/datasources/remote/branchs_service.dart` | **Yes — deleted** |
| `lib/core/helpers/Maps/map_select_location.dart` | No — areas feature, out of scope |
| `lib/modules/auth/register/data/datasources/remote/register_remote_datasource.dart` | No |
| `lib/modules/auth/register/presentaion/pages/otp_register.dart` | No |
| `lib/modules/auth/forgotPassword/data/datasources/forget_password_data_sourse.dart` | No |
| `lib/modules/home/profile/data/datasources/remote/profile_sevice.dart` | No |
| `lib/modules/home/profile/data/datasources/remote/delete_profile.dart` | No |
| `lib/modules/home/profile/page/edit_profile/datasources/remote/edit_remote_dataSource.dart` | No |
| `lib/modules/home/profile/page/favourites/datasources/favourites_services.dart` | No |
| `lib/modules/home/additions/data/datasource/remote/order_addition_remote_datasource.dart` | No |
| `lib/modules/home/search_screen/data/datasources/remote/offers_remte_datasource.dart` | No |

**Rationale**: the constraint on *new* code is unaffected — new code uses the shared Dio, never
`package:http`. Only the Phase 9 expectation and the constitution's wording need correcting.

**Alternatives considered**: none. This is a factual lookup.

---

## R2 — Where is the shared configured Dio?

**Asked because**: the architecture requires new code to use it and explicitly forbids
`package:http` and bare `Dio()`, both of which exist in the current code.

**Decision**: resolve it as `sl<Dio>()` from GetIt. Do **not** attach another interceptor.

**Finding**:

- Registered at `lib/service_locator.dart:150` — `sl.registerLazySingleton(() => Dio());`
- `AppInterceptors` attached once at `lib/service_locator.dart:151`, with
  `sl<SharedPreferencesHelper>()`.
- `AppInterceptors.onRequest` (`lib/core/helpers/interceptors/app_interceptor.dart:30-53`) sets
  `options.baseUrl = mainApi`, a 120s send/connect timeout, `accept` and `content-type` of
  `application/json`, `Accept-Language: langCode`, and `Authorization: Bearer <token>` when a token
  exists.
- `AppInterceptors.onError` (line 56) is a bare pass-through. **401s are not handled globally** —
  each caller handles its own errors.

**Consequences for the new datasource**:

- `baseUrl` is already `mainApi`, so a relative path (`/branches`) and an absolute one
  (`mainApi + '/branches'`) both work. The architecture writes `{mainApi}/branches`; keep that
  form for legibility. It is not a double prefix — Dio ignores `baseUrl` for absolute URLs.
- Auth headers and timeouts come for free. Adding a second `AppInterceptors` would double-fire
  `onRequest`; do not.
- **Bare `Dio()` is widespread** in the current code (~25 sites, including
  `booking_cars_remote_datasource.dart:9`, `all_branching_remote_datasource.dart:10`,
  `search_Screen.dart:48`). Each bypasses the interceptor and therefore sends no auth header and no
  `Accept-Language`. New code must not add to this.

**Alternatives considered**: none — the constitution fixes this.

---

## R3 — Does the car-branches endpoint use the `{data, links, meta}` envelope?

**Asked because**: the architecture says "the car endpoint may not use the same envelope. Inspect
the real response and handle both a bare list and a data-wrapped list."

**Decision**: keep the tolerant parse — accept both shapes. Today's shape is **data-wrapped**.

**Finding**: `lib/modules/home/booking_from_cars/model/branch_from_cars_model.dart:18-22` parses
`json["data"]` as a list and an optional `json["meta"]`. There is no `links`. The datasource
(`booking_cars_remote_datasource.dart:12-33`) requests with `ResponseType.plain` and
`json.decode`s manually — an odd choice that works but hides Dio's own JSON handling.

Each element (`Datum`, line 30) carries `id`, `text`, `image`, `can_book_today`, and — beyond what
the spec's Verified Inputs records — `stock_count` and `available_count`, both nullable.

**Consequences**:

- `Branch.fromCarBranchesApi` maps `text` → `name` and `can_book_today` → `bookToday`, exactly as
  decided.
- The `{data, meta}` envelope has no `links`, so `Paginated<T>` must treat `links` as optional.
- `stock_count` / `available_count` are not modelled. They are availability counters, not location
  data, and nothing in the spec's requirements references them. Recorded so the omission is
  deliberate.
- The tolerant bare-list branch stays in the parser as instructed, even though it is currently
  unreachable — the endpoint is the one least covered by verified evidence.

**Alternatives considered**: parsing only the data-wrapped shape. Rejected — the architecture
requires tolerance, and the cost is three lines.

---

## R4 — Are `polygon` and `center` used by a map widget?

**Asked because**: the architecture says to drop them from `Region` "UNLESS a map widget actually
uses them. Verify this in the codebase before dropping; report what you find."

**Decision**: escalated at the time of writing. **Since resolved by the developer (2026-09-02):
APPROVED — add `polygon` to `Region`, add `polygon` and `center` to `Branch`, create `GeoPoint` as
its own model, omit `Region.center`. Geometry is payload, not identity, and is excluded from `==`
and `hashCode`.** See [plan.md → BD-1](./plan.md#decision-record). The finding below is unchanged.

**Finding**: `lib/modules/home/booking_packages/widgets/delivery_rent_body.dart` uses geometry from
**both** models to constrain the map location picker:

| Line | Code | Reads |
|---|---|---|
| 96 | `_buildBoundsFromBranch()` | `_selectedBranch?.polygon` |
| 114 | `_buildBoundsFromRegion()` | `_selectedRegion?.polygon` |
| 133 | `_getCenterFromBranch()` | `_selectedBranch?.center` |
| 139 | `_getCenterFromRegion()` | `_selectedRegion?.polygon` (computes a centroid) |
| 168–182 | `_pickLocation()` | passes both into `LocationPickerArgs(bounds:, centerOverride:)` |

`_selectedBranch` is a `BranchModel`, `_selectedRegion` a `RegionModel` (declared at lines 44–45).
Those feed `Routes.locationPicker` → `MapSelectLocation`, whose `LocationBounds.isPointInside`
(`lib/core/helpers/Maps/map_select_location.dart:39-40`) does point-in-polygon containment. **This
is the areas feature** — explicitly out of scope, required to keep its existing implementation
untouched.

Field-by-field:

| Field | Present today? | Used? | Verdict |
|---|---|---|---|
| `Region.polygon` | Yes — `regions_model.dart:47` | **Yes** | Keep |
| `Region.center` | **No** — not parsed at all; the centre is a centroid computed from the polygon | No | Safe to drop |
| `Branch.polygon` | Yes — `branch_model.dart:66` | **Yes** | Not in the decided field list — **BD-1** |
| `Branch.center` | Yes — `branch_model.dart:68` | **Yes** | Not in the decided field list — **BD-1** |

**Rationale for escalating rather than choosing**: Phase 6 converts the delivery flow, which is
precisely where these four call sites live. Adding the fields silently would be a change to the
decided model; omitting them silently would strip the geographic constraint from an out-of-scope
feature. Both are the developer's call.

**Alternatives considered**: recorded in BD-1 rather than here, since they are decisions and not
findings.

---

## R5 — Where does the language code come from, for both the header and the cache key?

**Asked because**: the datasource must send `Accept-Language` "from the app's current language
code", and every cache key must embed the same code. If the two disagree, the cache stores a
payload under the wrong language and a language switch stops being a natural miss.

**Decision**: derive both from **one** resolver inside the location module. Send `Accept-Language`
explicitly on every request rather than relying on the interceptor, and use the identical resolved
value to build the cache key.

**Finding**:

- `langCode` is a **mutable global** — `lib/core/constants/langCode.dart:1`, initialised to `''`.
- It is written in exactly three places, all in
  `lib/modules/home/selectLanguage/languageCubit.dart`: line 14
  (`= await prefs.get(PreferencesConstants.lang) ?? "ar"`), line 20 (`= 'en'`), line 26
  (`= 'ar'`).
- `AppInterceptors` sends it **raw**: `acceptLangHeader: langCode`
  (`app_interceptor.dart:45`). No empty-string guard.
- Every other datasource in the app guards it individually, and **they all default to `en`** —
  e.g. `langCode == '' ? "en" : langCode`, 30+ occurrences. But `LanguageCubit` and
  `PreferencesConstants.lang` both default to **`ar`**. The app's stated default is Arabic; the
  network layer's fallback is English.

**The trap**: `LanguageCubit`'s constructor calls `emitLocale()`, which is `async`. Between app
start and that future completing, `langCode` is `''`. A request issued in that window carries an
empty `Accept-Language`, and its response would be cached under whatever the resolver said —
mismatching the payload's actual language.

**Consequences**:

- The location module exposes one internal resolver, e.g.
  `String get _lang => langCode.isEmpty ? 'ar' : langCode;` — defaulting to **`ar`**, matching
  `LanguageCubit` and `PreferencesConstants.lang`, not the `en` the other datasources use. The
  discrepancy is pre-existing and out of scope to fix elsewhere; the location module simply must
  not inherit the wrong one.
- The datasource sets `Accept-Language` in per-request `Options.headers` with that resolved value.
  Per-request headers win over the interceptor's, so the header and the key cannot diverge.
- The cache key uses the same `_lang`.

**Alternatives considered**: reading the locale from `BuildContext` via `Localizations.localeOf`.
Rejected — the datasource and cache have no context, and threading one through the data layer to
read a value the global already holds is worse.

---

## R6 — Test tooling and layout

**Asked because**: phases 1 and 2 deliver unit and bloc tests, and the plan needs to name where
they go and what they use.

**Decision**: `flutter_test` + `bloc_test` + `mocktail`, laid out at `test/modules/location/`
mirroring the existing notifications module.

**Finding**: `pubspec.yaml` `dev_dependencies` already has `bloc_test: ^10.0.0` (line 68),
`mocktail: ^1.0.4` (line 75), and `flutter_test` (line 71). No new dependency is needed.

The only real test module today is `test/modules/notifications/` with `cubit/`, `model/`, and
`helpers/` subfolders. `test/widget_test.dart` is still the untouched Flutter counter sample and
does not compile against `App()` — it is scaffolding, not a suite, and Phase 1 should not be
blocked by it.

Tests are run through `scripts/flutter_test_filtered.ps1`, never `flutter test` directly.

**Alternatives considered**: `mockito` — rejected, not in the project, and `mocktail` needs no
codegen.

---

## R7 — What does the current `work_time` model actually parse?

**Asked because**: `BranchWorkTime` replaces an existing `WorkTime`, and the plan needs to know
whether the new behaviour is a like-for-like port or a behaviour change.

**Decision**: it is a **behaviour change**, and a stricter one. Record it as a risk so the Phase 4
device verification does not read it as a regression.

**Finding**: in `lib/modules/home/all_branching/data/models/branch_model.dart`:

- `Alldays` (line 172) parses `period`, `morning`, `afternone` — but **no `lock`**.
- `Fri` (line 196) parses `period`, `morning`, `afternone`, `lock` — the complete shape.
- `Mon` (line 244) parses **`lock` only** — and `Mon` is the type used for `sat`, `sun`, `mon`,
  `tue`, `wed`, and `thu` (lines 150–155).

So today, for six of the eight day keys, the morning and afternoon windows are **discarded at
parse time**. Only Friday and the all-days entry carry real hours. Any current time-guarding on
those six days is running on absent data — i.e. failing open by accident rather than by design.

The new `BranchWorkTime` parses one uniform day shape for all keys, so Sunday-to-Thursday hours
start being enforced for the first time.

Also noted while reading: `branch_model.dart:275-276` carries a **duplicated
`@HiveType(typeId: 7)`** annotation on `BranchCenter`. Pre-existing, unrelated, and plausibly one
of the 78 baseline analyze issues. Not touched by this feature.

**Alternatives considered**: replicating the current lossy parse to avoid behaviour change.
Rejected — FR-021 and FR-025 require real per-day hours, and the spec states that where old
behaviour and these requirements conflict, the requirements win.

---

## Resolved unknowns

Every `NEEDS CLARIFICATION` from the Technical Context is closed:

| Unknown | Resolved by |
|---|---|
| Shared Dio location | R2 — `lib/service_locator.dart:150` |
| Car endpoint envelope | R3 — data-wrapped `{data, meta}`, no `links` |
| Whether `polygon`/`center` may be dropped | R4 — **escalated as BD-1**, not silently decided |
| Language source for header and cache key | R5 — one module-local resolver, defaulting to `ar` |
| Test tooling and layout | R6 — `bloc_test` + `mocktail`, `test/modules/location/` |
| Whether new work-time parsing changes behaviour | R7 — yes, stricter on six day keys |
| Whether `package:http` can be dropped in Phase 9 | R1 — no, 10 other importers remain |
