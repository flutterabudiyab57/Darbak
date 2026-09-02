# Implementation Plan: Region & Branch Selection Rewrite

**Branch**: `refactor/location-selection` (to be created — first task of Phase 1; currently on `chore/spec-kit-setup`) | **Date**: 2026-09-02 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-region-branch-selection/spec.md`

**Status**: Architecture supplied and DECIDED by the developer. This plan records it and works
out the detail within it. It does not evaluate alternatives. Two points where the codebase
contradicted an assumption in the supplied architecture were raised in
[Decision Record](#decision-record); **both are now resolved** and no phase is blocked.

## Summary

Replace the region/branch selection substrate in the Darbak booking flow with a single feature
module at `lib/modules/location/`. One `Branch` concept behind an explicit `LocationFilter`, one
`LocationSelectionCubit` holding the whole selection, and pushed picker screens that are
constructor-driven and cubit-free. The three structural causes named in the spec — duplicated
identity, split state, parallel lists — are each answered by one structural element: identity on
`id` only, one cubit, one filtered list.

The rewrite is delivered in nine phases, building alongside the existing implementation and
deleting it only in Phase 9. Every phase leaves the app working; phases 4–9 are gated on
on-device verification.

## Technical Context

**Language/Version**: Dart `^3.5.3`, Flutter (stable), design size 390×844 via `flutter_screenutil`

**Primary Dependencies**: `flutter_bloc` (Cubit), `dio ^5.9.1` (shared instance from GetIt),
`hive_ce ^2.19.3` / `hive_ce_flutter ^2.3.4`, `equatable`, `get_it`, `go_router ^14.6.2`,
`persistent_bottom_nav_bar 6.2.1` (retained; migration out of scope)

**Storage**: Hive CE box `location_cache`, raw JSON strings, no TypeAdapters, no `@HiveType`

**Testing**: `flutter_test`, `bloc_test ^10.0.0`, `mocktail ^1.0.4` — all already in
`dev_dependencies`. Existing precedent for layout: `test/modules/notifications/{cubit,model}/`.
Run via `scripts/flutter_test_filtered.ps1`, never `flutter test` directly.

**Target Platform**: Android + iOS mobile app

**Project Type**: Mobile app, feature-module + clean-architecture-lite

**Performance Goals**: Branch list for any filter fully loaded in ≤2 network round trips at
`perPage=100` (48 branches total observed); cache hit serves without a network call.

**Constraints**: Arabic-first RTL; server-side localization via `Accept-Language` (no per-language
name fields); `flutter analyze` at or below the **78-issue baseline**; no visual redesign; the
areas feature untouched.

**Scale/Scope**: 9 regions, ~48 branches, 5 booking flows, 2 languages.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design — see
[Post-Design Re-check](#post-design-constitution-re-check).*

| Principle | Gate | Status |
|---|---|---|
| **I. Identity Is The ID, Never The Name** (NON-NEGOTIABLE) | No display string is stored alongside a model; no name-based lookup; `==`/`hashCode` on `id` only. | **PASS** — `Region`, `Branch` both key equality on `id`. No `String? selectedBranchName` field exists anywhere in the new module. |
| **II. Root-Navigator Screens Must Be Self-Contained** (NON-NEGOTIABLE) | Screens pushed with `withNavBar: false` read no cubit; data in via constructor, result out via `Navigator.pop`. | **PASS** — `BranchPickerScreen` takes `List<Branch>` as a constructor parameter and returns `Branch?`. No `isReceive` flag. Enforced by a contract test (see `contracts/`). |
| **III. One Source Of Truth Per Concept** | One list per concept driven by an explicit filter; immutable Equatable state; no manual emit to force rebuilds. | **PASS** — one `Branch` type, one `LocationFilter`, one `getBranches(filter)`. `pickupOptions`/`dropoffOptions` are two *views of the same concept under two filters*, not two concepts. |
| **IV. Fail Open On Validation Data** | Missing/null/unparseable validation input ⇒ operation PERMITTED. | **PASS** — `BranchWorkTime.isOpenAt` returns `true` on absent, null, or unparseable data; partial (car-flow) branches carry no `workTime` and therefore never block a time. |
| **V. Phased Delivery With Manual Verification** (NON-NEGOTIABLE) | Build alongside old; one screen at a time; delete only in the final phase; device-verified, not analyze-clean. | **PASS** — nine phases, deletion confined to Phase 9, phases 4–9 device-gated. |

**Technology Constraints check**

| Constraint | Status |
|---|---|
| All HTTP through the shared configured Dio; never `package:http`, never bare `Dio()` | **PASS for new code.** The shared instance is `sl<Dio>()`, registered at `lib/service_locator.dart:150` with `AppInterceptors` attached at `:151`. See [Research R2](./research.md). |
| Hive CE only (`hive_ce`, `hive_ce_flutter`); prefer raw JSON over TypeAdapters | **PASS** — `location_cache` stores raw JSON strings, zero adapters, so model changes need no migration and no `build_runner` run. |
| `persistent_bottom_nav_bar` retained | **PASS** — navigation mechanism unchanged. |
| Cache keys for server-localized data include the language code; cache failure never reaches the caller | **PASS** — keys are `regions:<lang>` and `branches:<lang>:<filter.cacheKey>`; every cache operation is wrapped in try/catch and falls through to the network. |

**Development Workflow check**: no commit without approval; `flutter analyze` (via
`scripts/flutter_analyze_filtered.ps1`) at the end of every phase with the issue count reported
against the 78 baseline; stop at each phase boundary; two failed fixes ⇒ stop and diagnose.

**Result: PASS. No violations. [Complexity Tracking](#complexity-tracking) is empty.**

## Decision Record

Two items were raised by the codebase verification the architecture asked for. Both have been
settled by the developer. Nothing here blocks a phase.

### BD-1 — `Branch` and `Region` carry geometry — **RESOLVED: add the fields**

**Decision (developer, 2026-09-02): APPROVED. Add the geometry fields.**

- `Region` — **add** `polygon` (`List<GeoPoint>?`). **Do not add `center`** — it is neither parsed
  nor used today; the region centre is computed from the polygon.
- `Branch` — **add** `polygon` (`List<GeoPoint>?`) and `center` (`GeoPoint?`).
- `GeoPoint` is created as its own model file, `lib/modules/location/data/models/geo_point.dart`.

**Rationale: geometry is payload, not identity.** Equality stays on `id` only, so Principle I is
untouched — a branch with geometry and the same branch without it remain the same entity.

**Rejected alternative:** keeping the old `BranchModel` alive purely as a map-bounds source. That
would reintroduce parallel models for one concept, violating Principle III — which is precisely the
disease this rewrite treats.

The finding that produced the decision follows.

#### Finding

The supplied architecture says to drop `polygon`/`center` from **`Region`** unless a map widget
uses them, and lists **`Branch`** fields without either. Verification found that a map widget uses
**both models'** geometry:

`lib/modules/home/booking_packages/widgets/delivery_rent_body.dart`

- `_buildBoundsFromBranch()` (line 96) reads `_selectedBranch?.polygon`
- `_getCenterFromBranch()` (line 133) reads `_selectedBranch?.center`
- `_buildBoundsFromRegion()` (line 114) reads `_selectedRegion?.polygon`
- `_getCenterFromRegion()` (line 139) computes a centroid from `_selectedRegion?.polygon`

These feed `LocationBounds` and `centerOverride` into the map location picker at
`Routes.locationPicker` — i.e. **the areas feature**, which the spec and the architecture both put
explicitly out of scope and require to keep its existing implementation untouched.

Phase 6 converts the delivery flow, which is exactly where `_selectedBranch` and `_selectedRegion`
live. Replacing them with geometry-free models would silently remove the geographic boundary
constraint from the delivery map picker — an out-of-scope regression.

**Findings, stated plainly:**

- `Region.polygon` — **used**. Kept.
- `Region.center` — **not used, and not even parsed today**. `RegionModel`
  (`lib/modules/home/search_screen/data/models/regions_model.dart:36`) has only
  `id`, `name`, `city`, `polygon`. The centre is computed from the polygon. Not added.
- `Branch.polygon` — **used**. Added.
- `Branch.center` — **used**. Added.

Because the areas feature must be behaviour-identical after Phase 6 rather than merely compiling,
Phase 6 carries an explicit behaviour-preservation acceptance item — see
[Phase 6 acceptance](#phase-6-acceptance-areas-behaviour-preservation).

### BD-2 — `Region` fields narrower than the spec's Key Entities (informational, blocks nothing)

The spec's Key Entities describes a region as carrying "a stable identifier, a localized name, a
city, a code, a parent reference, a boundary outline, and a centre point". The model keeps `id`,
`name`, `city`, and — per BD-1 — the boundary outline as `polygon`. `code`, `master_id`, and the
centre point are not parsed today either and nothing reads them.

Read as a description of the API payload rather than a modelling requirement, this is not a
conflict. Recorded so the narrowing is a visible decision rather than an omission. No action
needed unless the developer disagrees.

## Project Structure

### Documentation (this feature)

```text
specs/001-region-branch-selection/
├── plan.md              # This file
├── research.md          # Phase 0 output — codebase verification findings
├── data-model.md        # Phase 1 output — entities, parsing rules, equality
├── quickstart.md        # Phase 1 output — how to validate each phase
├── contracts/           # Phase 1 output — internal interface contracts
│   ├── remote-datasource.md
│   ├── repository-and-cache.md
│   ├── cubit-state-machine.md
│   └── navigation-contract.md
├── checklists/
│   └── requirements.md  # Spec quality checklist (already produced)
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/modules/location/                      # ALL new code. Nothing here exists yet.
├── data/
│   ├── models/
│   │   ├── region.dart                    # id, name, city, polygon
│   │   ├── branch.dart                    # two named factories; isPartial; polygon, center
│   │   ├── branch_work_time.dart          # isOpenAt(DateTime) — fails open
│   │   ├── geo_point.dart                 # lat/lng pair — polygon vertices and centres
│   │   └── paginated.dart                 # Paginated<T> from {data, links, meta}
│   ├── location_filter.dart               # regionId? / homeDelivery / airport / carId? + cacheKey
│   ├── location_remote_datasource.dart    # uses sl<Dio>()
│   ├── location_cache.dart                # Hive CE box "location_cache", raw JSON
│   └── location_repository.dart           # cache-first, stale-on-network-failure
└── presentaion/                           # project spelling — do not "fix"
    ├── bloc/
    │   ├── location_selection_cubit.dart
    │   └── location_selection_state.dart
    ├── pages/
    │   └── branch_picker_screen.dart      # constructor-driven, returns Branch?
    └── widgets/
        └── branch_tile.dart

lib/modules/home/booking_packages/         # touched from Phase 4 onward
lib/modules/home/booking_from_cars/        # touched in Phase 7
lib/modules/home/additions/                # touched in Phase 8
lib/modules/home/payment/                  # touched in Phase 8

test/modules/location/
├── model/
│   ├── branch_test.dart
│   ├── branch_work_time_test.dart
│   └── paginated_test.dart
├── data/
│   ├── location_filter_test.dart
│   ├── location_remote_datasource_test.dart
│   ├── location_cache_test.dart
│   └── location_repository_test.dart
└── cubit/
    └── location_selection_cubit_test.dart
```

**Structure Decision**: a single new feature module at `lib/modules/location/`, matching the
project's existing `data/` + `presentaion/` convention (including the established misspelling of
`presentaion`). It is a *core-domain* module rather than a screen module — the booking flows under
`lib/modules/home/booking_packages/` and `lib/modules/home/booking_from_cars/` consume it. Test
layout mirrors `test/modules/notifications/`, the only existing test module.

## Architecture Detail

The architecture below is as supplied. Detail worked out within it is marked **[detail]**.

### Models — `lib/modules/location/data/models/`

`Region` — `int id`, `String name`, `String? city`, `List<GeoPoint>? polygon`.

`Branch` — `int id`, `String name`, `int? regionId`, `String? regionName`, `String? address`,
`double? lat`, `double? lng`, `String? phone`, `String? locationUrl`, `BranchWorkTime? workTime`,
`bool bookToday`, `num deliveryPrice`, `bool isPartial`, `List<GeoPoint>? polygon`,
`GeoPoint? center`.

`GeoPoint` — `double? lat`, `double? lng`. Its own model file. Note that the geometry payload uses
`lng`, whereas the branch's *own* coordinate pair uses `long` and arrives as strings — the two are
different shapes and are parsed differently ([data-model.md](./data-model.md#geopoint)).

**Geometry is excluded from `==` and `hashCode`** on both models — it is payload, not identity
(BD-1).

Parsing rules — verified, non-negotiable:

| Field | Rule |
|---|---|
| `name` | `json["name"] ?? json["text"]` |
| `bookToday` | `json["book_today"] ?? json["can_book_today"]`, arrives as int `1`/`0`, **default `false` when absent** |
| `lat` / `lng` | arrive as **strings** — `double.tryParse`, never a cast. The API key is **`long`**, not `lng` |
| `isPartial` | never from JSON. `Branch.fromBranchesApi` ⇒ `false`; `Branch.fromCarBranchesApi` ⇒ `true` |

**[detail]** `deliveryPrice` is `num` and non-nullable — default `0` when the key is absent, so
call sites never null-check a price. The car endpoint omits it entirely.

**[detail]** `Branch.fromCarBranchesApi` reads `id`, `text`, `image`, `can_book_today`. `image` is
not in the decided field list; it is carried on the model as `String? image` because US6 scenario 2
requires the car flow to render a name and same-day availability "without the missing fields
causing an error or an empty row", and the existing car list shows the image. It is display
payload, outside identity.

`BranchWorkTime` — parses the `work_time` object. Per-day keys `alldays`, `fri`, `sat`, `sun`,
`mon`, `tue`, `wed`, `thu`, plus top-level `openAllDays`. Each day may hold `period`,
`morning {timeopen, timeclose}`, `afternone {timeopen, timeclose}`, `lock`. **The API misspells
"afternoon" as `afternone` — parse that key, name the Dart field `afternoon`.** Values may be null.
`lock: "1"` means the day is closed. Closing times can cross midnight (open 21:00, close 03:00).

Exposes `bool isOpenAt(DateTime dt)`.

**CRITICAL** — missing, null, or unparseable `work_time` ⇒ `isOpenAt` returns `true`. Fail open.
Constitution Principle IV. Detailed resolution order and midnight handling are in
[data-model.md](./data-model.md).

`Paginated<T>` — `data`, `currentPage`, `lastPage`, `total`, from the `{data, links, meta}`
envelope.

**All models override `==` and `hashCode` on `id` ONLY.** Constitution Principle I. This is what
lets the same branch arriving from two endpoints, in two languages, compare equal — and it is what
makes `Branch.fromCarBranchesApi(x) == Branch.fromBranchesApi(y)` true for the same `id` despite
one being partial.

### Filter — `lib/modules/location/data/location_filter.dart`

```text
class LocationFilter {
  final int? regionId;      // daily and monthly only
  final bool homeDelivery;
  final bool airport;
  final int? carId;
  String get cacheKey;      // stable, fixed field order
}
```

**`regionId` applies ONLY to the region-filtered branch list.** The delivery, airport, and car
filters are **not** region-scoped — verified on-device. Never send a `regions` param alongside
`home_delivery=1`, `airport=1`, or a car request.

`const`-constructible; `==` and `hashCode` over **all** fields (unlike the models, which key on
`id` — a filter has no identity apart from its values).

**[detail]** `cacheKey` is a fixed-order join, e.g. `r=<id|_>|hd=<0|1>|ap=<0|1>|car=<id|_>`, so a
key is stable across app runs and two equal filters always produce one string.

### Remote datasource — `location_remote_datasource.dart`

```text
Future<List<Region>> getRegions()
Future<List<Branch>> getBranches(LocationFilter filter)
```

Endpoint routing:

| Condition | Request | Parsed with |
|---|---|---|
| `carId != null` | `GET {mainApi}/available/branches/{carId}` | `Branch.fromCarBranchesApi` |
| `homeDelivery` | `GET {mainApi}/branches?home_delivery=1` | `Branch.fromBranchesApi` |
| `airport` | `GET {mainApi}/branches?airport=1` | `Branch.fromBranchesApi` |
| otherwise | `GET {mainApi}/branches?home_delivery=0`, plus `regions=<regionId>` when `regionId != null` | `Branch.fromBranchesApi` |

Rules:

- Use the app's **shared configured Dio** — `sl<Dio>()`. **Never `package:http`, never a bare
  `Dio()`.** Both exist in the current code and bypass interceptors. Located and reported in
  [Research R2](./research.md).
- `perPage=100` on `/branches` calls. Verified honoured server-side.
- Pagination driven by `meta.last_page` read from page 1. **Hard cap 10 pages.** Never a hardcoded
  page count.
- **Never send a query param with a null value** — omit the key.
- The car endpoint may not use the same envelope. Handle **both** a bare list and a data-wrapped
  list. (Today's response is data-wrapped — see [Research R3](./research.md) — the tolerant parse
  stays regardless.)
- `Accept-Language` from the app's current language code. See [Research R5](./research.md) for the
  trap here: the shared interceptor sends the raw global `langCode`, which is `''` until
  `LanguageCubit` initialises.

### Cache — `location_cache.dart`

One Hive box: `"location_cache"`, raw JSON strings. `hive_ce` / `hive_ce_flutter`. **Never
`package:hive`. No TypeAdapters, no `@HiveType` annotations** — so nothing here ever needs
`build_runner`.

- Keys: `regions:<lang>` and `branches:<lang>:<filter.cacheKey>`. Language in the key means a
  language switch is a natural cache miss.
- Value: `{ "ts": <epochMillis>, "payload": <raw json> }`
- TTL: regions **24h**, branches **6h**.
- Every operation in try/catch. **A cache failure NEVER reaches the caller** — fall through to
  network.

**[detail]** The box is opened lazily on first use inside `LocationCache`, not in
`initializeHive()`. `main.dart`'s boot block is wrapped in a catch that is silent in release; an
open failure there would be invisible. Lazy opening keeps the failure inside the try/catch that is
already required to swallow it.

### Repository — `location_repository.dart`

```text
getRegions({forceRefresh})
getBranches(LocationFilter, {forceRefresh})
```

Cache-first, network on miss or expiry. **If the network fails AND an expired entry exists, return
the stale data rather than throwing — only in that case.** A network failure with no cached entry
at all propagates, so the screen can show the retry required by FR-038.

### Cubit — `LocationSelectionCubit`

State — immutable, Equatable, `copyWith`:

```text
Region? pickupRegion
Region? dropoffRegion    // null means: same as pickup
Branch? pickupBranch
Branch? dropoffBranch    // null means: same as pickup
List<Branch> pickupOptions
List<Branch> dropoffOptions
Status status
```

Rules enforced **in the cubit, not in screens**:

- Selecting a pickup region clears `pickupBranch` and refetches `pickupOptions`.
- Selecting a dropoff region clears `dropoffBranch`.
- Disabling separate-dropoff clears `dropoffRegion` **and** `dropoffBranch` together, atomically.
- A language change refetches and re-resolves the selected branches **by id**, so the selection
  survives with updated display names.

**No manual state emission to force rebuilds. Equality drives rebuilds.** Constitution
Principle III.

**[detail]** `copyWith` cannot express "set this field to null", so the clearing rules use explicit
sentinel-free named constructors on the state (`clearPickupBranch()`, `clearDropoff()`) rather than
`copyWith(pickupBranch: null)`, which would be a silent no-op. This is the single most likely place
to reintroduce the stale-dropoff bug; it is covered by a `bloc_test` in Phase 2.

**[detail]** Registered in GetIt as `registerFactory` — per-booking-attempt state, not app-wide.
A singleton is exactly the defect FR-017 exists to close.

### Navigation contract — Constitution Principle II

```dart
final picked = await PersistentNavBarNavigator.pushNewScreen<Branch>(
  context,
  screen: BranchPickerScreen(branches: options),
  withNavBar: false,
);
if (picked != null) cubit.setPickupBranch(picked);
```

`BranchPickerScreen`:

- receives its list as a **constructor parameter**
- reads **no** cubit, scoped or global
- does **not** know whether it is picking pickup or dropoff — there is **no `isReceive` flag
  anywhere in it**
- returns via `Navigator.pop(context, branch)`

**Non-negotiable.** `pushNewScreen(withNavBar: false)` resolves to `rootNavigator: true`, placing
the route outside the caller's provider subtree. A cubit read there throws inside the tap handler
and silently aborts it. That exact mechanism is the drop-off bug this rewrite exists to eliminate.
If the plan puts a cubit read in a pushed screen, the bug returns.

The caller decides pickup vs dropoff by which setter it calls with the returned value. That is the
whole of the distinction.

### Booking draft

When the booking screen completes, it builds an immutable `BookingDraft` (pickup branch, dropoff
branch, dates, car) and passes it to the next screen as a **constructor parameter**. Additions and
payment **read** it; they cannot mutate it. Navigating back destroys it — **that is how the
selection clears, with no clearing code.**

### Time guarding

Client-side, from the selected branch's `workTime`:

- times less than two hours away: **disabled**
- times outside working hours: **disabled**
- dropoff at or before pickup: **disabled**

**Disabled, not hidden.** Partial branches (`isPartial`, from the car flow) carry no `workTime`, so
all times remain available per Principle IV. `POST /available/time` stays in place as the final
authority.

## Phases

Each phase ends with: `scripts/flutter_analyze_filtered.ps1` (baseline **78**), **no commit**,
**STOP**. Phases 4–9 additionally require on-device verification before the next phase begins
(Constitution Principle V).

| # | Phase | Deliverable | Gate |
|---|---|---|---|
| 1 | Foundation | Create branch `refactor/location-selection`. Models, remote datasource, cache, repository, unit tests. **Nothing wired. App behaviour unchanged.** | analyze ≤78 |
| 2 | Cubit | `LocationSelectionCubit` + state + `bloc_test` coverage. **Still not wired.** | analyze ≤78 |
| 3 | Picker screen | `BranchPickerScreen` returning a `Branch`, built **alongside** the old picker. The old one keeps working. | analyze ≤78 |
| 4 | Daily rent | Convert daily rent. Everything else still on the old code. | analyze ≤78 + **device** |
| 5 | Monthly rent | Convert monthly rent. | analyze ≤78 + **device** |
| 6 | Delivery + airport | Convert both (filters, **no region step**). Carries the [areas behaviour-preservation check](#phase-6-acceptance-areas-behaviour-preservation). | analyze ≤78 + **device** |
| 7 | Book-from-car | Convert. Partial branches are completed by id from the full branch list **before any work-hours check runs**. | analyze ≤78 + **device** |
| 8 | Booking draft | `BookingDraft`; additions and payment read from it. | analyze ≤78 + **device** |
| 9 | Deletion | Delete location fields from `SearchCubit`, `AllBranchCubit` entirely, `MapListView`, `BranchesListView`, `MapListSelectionViewTile`, `branchs_service.dart`. | analyze ≤78 + **device** |

**Phase 9 note, from verification:** the "check whether `package:http` can be dropped from
`pubspec.yaml`" item has been **removed** from Phase 9 — the answer is already known to be no. The
package is imported by 11 files, only one of which (`branchs_service.dart`) is in this feature's
deletion scope; see [Research R1](./research.md) for the full list. Constitution v1.0.1 amends the
Technology Constraints paragraph accordingly. Removing the package entirely is separate, larger
work and is not a goal of this feature.

### Phase 6 acceptance — areas behaviour preservation

BD-1 exists to keep an **out-of-scope** feature working, so Phase 6 is not complete until that is
demonstrated rather than assumed:

> **The delivery map location picker MUST receive the same `bounds` and the same `centerOverride`
> it receives today.** Same boundary polygon, same centre, same containment behaviour, for both the
> branch-derived case (`_buildBoundsFromBranch` / `_getCenterFromBranch`) and the region-derived
> case (`_buildBoundsFromRegion` / `_getCenterFromRegion`).

This is a **behaviour-preservation check on an out-of-scope feature, not a new feature.** Nothing
about the areas feature is being improved, extended, or redesigned; the only acceptable outcome is
"indistinguishable from before". Compiling is not evidence — verify on the device that the map is
still constrained to the boundary and still opens centred where it did.

## Ordering Constraints

Hard sequencing rules. These are not risks to weigh — violating one breaks the app.

### OC-1 — The global `AllBranchCubit` registration must outlive every unconverted flow

**The global registration of `AllBranchCubit` (`lib/bloc_providers.dart:31`, backed by
`lib/service_locator.dart:87`) MUST NOT be removed while any unconverted flow still uses the old
picker.**

The old `BranchesListView` reads `context.read<AllBranchCubit>()`
(`lib/modules/home/search_screen/presentaion/widget/branches_list_view.dart:59, 76`) from a screen
pushed with `withNavBar: false` — i.e. onto the root navigator, outside the caller's provider
subtree. That read resolves **only** because the cubit is registered globally. Remove the global
registration while any flow still routes through that widget and the read throws
`ProviderNotFoundException` inside the tap handler, silently aborting it: the original "tapping
does nothing" bug, in its original form, in whichever flows had not yet been converted.

Therefore:

- Phases 4–8 leave `lib/bloc_providers.dart:31` **untouched**. The new picker and the old one
  coexist; each flow switches over as it is converted.
- Phase 9 removes it **only after phases 4, 5, 6, 7 and 8 have each been device-verified** — that
  is, only once no flow reaches the old picker at all.
- The removal of the global registration and the deletion of `BranchesListView` /
  `MapListSelectionViewTile` / `MapListView` land **in the same phase**. Splitting them across
  phases produces exactly the failure above.

This is why Phase 9 is deletion-only and why Principle V's device gate on phases 4–8 is load-bearing
here rather than merely good practice.

## Known Risks

- **`AllBranchCubit` is temporary global scaffolding** from the preceding bug-fix pass
  (`lib/service_locator.dart:87`, provided globally at `lib/bloc_providers.dart:31`). It is deleted
  in Phase 9. **Build nothing new on it.** Its global registration is load-bearing until then — see
  [OC-1](#oc-1--the-global-allbranchcubit-registration-must-outlive-every-unconverted-flow).
- **`branches_screen.dart` uses `AllBranchCubit` from outside the booking flow**
  (`lib/modules/home/all_branching/page/branches_screen.dart:37, 88, 90, 158`), as does
  `search_Screen.dart:58`. Phase 9 touches all of them.
- **`clasic.dart` uses `SearchCubit`, not `AllBranchCubit`** — a correction to the supplied risk
  note. `lib/modules/home/home_screen/clasic.dart:63-69` looks a branch up by
  `element.name == selectedReceiveBranch`. That is a live Principle I violation and a Phase 9
  target. Recorded because the fix is a different one than the note implies: it needs an id, and
  `SearchCubit` currently has no branch id to give it.
- **Completing a partial car branch by id may fail.** When it does, the work-hours check is skipped
  silently by design (fail open, Principle IV). Intended — but it means **a partial branch never
  blocks a time**, and `POST /available/time` is the only thing standing between the renter and an
  unserviceable slot in that flow.
- **The current `WorkTime` model discards most of the schedule.** `Mon` (used for `sat`, `sun`,
  `mon`, `tue`, `wed`, `thu`) parses **only `lock`** — morning and afternoon windows for six of the
  eight day keys are thrown away today (`branch_model.dart:244-256`). The new `BranchWorkTime`
  parses them, so **time guarding will become stricter than the app currently is** on those days.
  Expect behaviour change at Phase 4 device verification; it is a fix, not a regression, but it
  will look like one.
- **`langCode` is a mutable global defaulting to `''`** (`lib/core/constants/langCode.dart:1`), set
  by `LanguageCubit`. The shared Dio interceptor sends it raw, so an early request can carry an
  empty `Accept-Language`. The cache key and the request header **must** be derived from one
  resolver or the cache will store a payload under the wrong language. See
  [Research R5](./research.md).

## Post-Design Constitution Re-check

Re-evaluated after Phase 1 design artifacts were produced. **Still PASS.**

- Principle I — `data-model.md` fixes equality on `id` for `Region` and `Branch`; the geometry added
  under BD-1 is explicitly excluded from `==` and `hashCode`; no model carries a name-keyed lookup;
  `contracts/cubit-state-machine.md` re-resolves selections by id on language change.
- Principle II — `contracts/navigation-contract.md` states the picker's constructor-in / pop-out
  contract, extends the prohibition to every widget reachable only from the picker, and names the
  test that fails if a cubit read is added anywhere on that surface.
- Principle III — one `Branch`, one `LocationFilter`, one `getBranches`; state equality drives
  rebuilds; no manual emit appears in the cubit contract.
- Principle IV — `isOpenAt` fail-open behaviour is specified with its full resolution order in
  `data-model.md` and has dedicated test cases in `quickstart.md`.
- Principle V — phases are sequenced with explicit device gates; deletion is confined to Phase 9.
- Technology constraints — shared Dio only, Hive CE raw JSON only, language in every cache key,
  cache failures swallowed.

**BD-1 is resolved** (geometry added, excluded from equality). It was a scope-protection question —
does the out-of-scope areas feature keep working through Phase 6 — never a constitution violation,
and its resolution does not change the gate result. Phase 6 now carries an explicit
behaviour-preservation acceptance item to close it on the device.

## Complexity Tracking

No constitution violations. Table intentionally empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |
