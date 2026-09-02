---

description: "Task list for Region & Branch Selection Rewrite"
---

# Tasks: Region & Branch Selection Rewrite

**Input**: Design documents from `specs/001-region-branch-selection/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: **Required, not optional.** The plan makes unit, bloc and widget tests a deliverable of
plan Phases 1–3, and `contracts/navigation-contract.md` names one widget test as the *only*
mechanism that turns a future Principle II violation into a red test rather than a release-only
silent failure. Test tasks below are therefore first-class, not conditional.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel — different file, no dependency on an incomplete task
- **[Story]**: the user story from [spec.md](./spec.md) the task serves
- Every task names an exact file path

## Path Conventions

Flutter mobile app, feature-module + clean-architecture-lite. New code lives under
`lib/modules/location/`; tests mirror it under `test/modules/location/`. The folder `presentaion/`
is the project's established misspelling — **do not "fix" it**.

---

## Phase organisation — read this before starting

**The plan's nine phases are the delivery sequence and are DECIDED.** They are gated by
Constitution Principle V (device verification before the next phase). This task list therefore
keeps the plan's phase order as its execution order and labels each task with the user story it
serves, rather than re-cutting the work into one phase per story. Re-ordering to group by story
would break the device gates and OC-1.

| Plan phase | Task phase below | Stories advanced | Story completed here |
|---|---|---|---|
| 1 Foundation | Phase 2A | all | — |
| 2 Cubit | Phase 2B | all, US7 | — |
| 3 Picker screen | Phase 2C | US1, US2 | — |
| 4 Daily rent | Phase 3 | US1, US2, US3, US7 | **US1, US2, US3, US7** |
| 5 Monthly rent | Phase 4 | US5 | — |
| 6 Delivery + airport | Phase 5 | US5 | **US5** |
| 7 Book-from-car | Phase 6 | US6 | **US6** |
| 8 Booking draft | Phase 7 | US4 | **US4** |
| 9 Deletion | Phase 8 | — | — |

**Every task phase ends with**: `powershell -ExecutionPolicy Bypass -File
scripts/flutter_analyze_filtered.ps1`, issue count reported against the **78 baseline**, **no
commit**, **STOP**. Phases 3 onward additionally require on-device verification before the next
phase begins.

---

## Phase 1: Setup

**Purpose**: branch and test scaffolding. No production code.

- [ ] T001 Create and switch to branch `refactor/location-selection` off the current branch (`git switch -c refactor/location-selection`). Do not commit anything on it yet.
- [ ] T002 [P] Create the empty test tree `test/modules/location/{model,data,cubit}/` mirroring `test/modules/notifications/`, and confirm `bloc_test ^10.0.0` and `mocktail ^1.0.4` are present in `dev_dependencies` in `pubspec.yaml` (they are — verify, do not add).

**Checkpoint**: branch exists, app behaviour unchanged.

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: no flow conversion can begin until 2A, 2B and 2C are each complete and
analyze-gated. Nothing in this phase is wired to a screen — **app behaviour is unchanged
throughout.**

### Phase 2A — Models, datasource, cache, repository (plan Phase 1)

- [ ] T003 [P] Create `GeoPoint` in `lib/modules/location/data/models/geo_point.dart` — `double? lat`, `double? lng`, `Equatable` with `props => [lat, lng]` (content equality, unlike the entities). `GeoPoint.fromJson` reads key **`lng`**, never `long`, via the shared `_asDouble` helper (`num` → `toDouble()`, `String` → `double.tryParse`, else `null`). Never throws.
- [ ] T004 [P] Create `Paginated<T>` in `lib/modules/location/data/models/paginated.dart` — `data`, `currentPage`, `lastPage`, `total` per [data-model.md](./data-model.md#paginatedt). `Paginated.fromJson(json, itemParser)` tolerates: `{data, meta}`, `{data}` with no `meta` (single page), and a **bare JSON list** (single page, `total = length`). `links` is not modelled.
- [ ] T005 [P] Create `BranchWorkTime`, `BranchWorkDay` and `TimeWindow` in `lib/modules/location/data/models/branch_work_time.dart` — parse `alldays`/`fri`/`sat`/`sun`/`mon`/`tue`/`wed`/`thu` into `Map<int, BranchWorkDay>` keyed by `DateTime.weekday`, plus top-level `openAllDays`. **Read the API's `afternone` key verbatim and name the Dart field `afternoon`** (FR-036). Implement `bool isOpenAt(DateTime)` with the exact resolution order and midnight-crossing rule in [data-model.md](./data-model.md#branchworktime). Fails open everywhere except an explicit `lock`.
- [ ] T006 [US1] Create `Region` in `lib/modules/location/data/models/region.dart` — `int id`, `String name`, `String? city`, `List<GeoPoint>? polygon`. **`props => [id]`; polygon excluded** (BD-1). No `center` field. `Region.fromJson` drops elements without a usable integer `id`. Depends on T003.
- [ ] T007 [US1] Create `Branch` in `lib/modules/location/data/models/branch.dart` with the full field table from [data-model.md](./data-model.md#branch) and the two named factories `Branch.fromBranchesApi` (`isPartial = false`) and `Branch.fromCarBranchesApi` (`isPartial = true`). **No unnamed `fromJson`.** Parsing: `name = name ?? text`; `lat`/`lng` from **`lat`/`long` as Strings** via `double.tryParse`; `bookToday` from `book_today ?? can_book_today` as int 1/0 defaulting to `false`; `deliveryPrice` non-nullable `num` defaulting to `0`; `polygon`/`center` from the **numeric `lat`/`lng`** geometry shape. **`props => [id]`; geometry and everything else excluded.** Depends on T003, T005.
- [ ] T008 [P] Create `LocationFilter` in `lib/modules/location/data/location_filter.dart` — `const`-constructible, `==`/`hashCode` over **all four** fields, `cacheKey` as the fixed-order join `r=…|hd=…|ap=…|car=…`. Provide the five named constructors `region(id)`, `allRegions()`, `delivery()`, `airport()`, `car(id)`; **`delivery()`, `airport()` and `car()` accept no `regionId`**, which is what makes "never send `regions` alongside them" structurally unrepresentable.
- [ ] T009 [P] Create the module language resolver in `lib/modules/location/data/location_language.dart` — one function returning the active code, **defaulting to `'ar'` when the global `langCode` (`lib/core/constants/langCode.dart:1`) is empty**. Both the request header and the cache key MUST derive from this one function ([R5](./research.md)); the shared interceptor sends the raw global and can send `''` at boot.
- [ ] T010 [US1] Create `LocationRemoteDataSource` in `lib/modules/location/data/location_remote_datasource.dart` taking the shared `sl<Dio>()` by constructor (registered `lib/service_locator.dart:150`, interceptor at `:151`). Implement `getRegions()` and `getBranches(filter)` per [contracts/remote-datasource.md](./contracts/remote-datasource.md): the four-row routing table, `perPage=100`, `meta.last_page` pagination with a **hard cap of 10 pages**, dedupe by `id` across pages, **omit null query keys entirely**, car path takes no query params, and set `Accept-Language` explicitly per request from T009. **Never `package:http`, never a bare `Dio()`, never a second interceptor.** Depends on T004, T006, T007, T008, T009.
- [ ] T011 [P] Create `LocationCache` in `lib/modules/location/data/location_cache.dart` — one **`hive_ce`** box `"location_cache"` opened **lazily on first use**, raw JSON strings, no TypeAdapters and no `@HiveType`. Keys `regions:<lang>` / `branches:<lang>:<filter.cacheKey>`; value `{ "ts": epochMillis, "payload": <raw json> }`; TTL 24h regions, 6h branches; `read`, `write`, `readStale`. **Every operation in try/catch — a cache failure never reaches the caller.** Expired entries are NOT deleted (`readStale` needs them). Depends on T009.
- [ ] T012 [US1] Create `LocationRepository` in `lib/modules/location/data/location_repository.dart` implementing the exact resolution order in [contracts/repository-and-cache.md](./contracts/repository-and-cache.md): cache-first, network on miss/expiry/`forceRefresh`, and **stale-on-network-failure only when an expired entry exists** — a fresh miss with a dead network rethrows so the screen can offer the FR-038 retry. Depends on T010, T011.
- [ ] T013 [P] [US1] Register `LocationRemoteDataSource`, `LocationCache` and `LocationRepository` as lazy singletons in `lib/service_locator.dart`. Do **not** add them to `lib/bloc_providers.dart` — nothing is wired to a screen in this phase.
- [ ] T014 [P] Write `test/modules/location/model/branch_test.dart` — string `lat`/`long` parse to doubles; the `long` key is read and `lng` is not; `name ?? text`; `book_today`/`can_book_today` int flag and the absent-⇒-false default; `deliveryPrice` defaults to `0`; `fromCarBranchesApi` sets `isPartial = true` and leaves the rest null; **two branches with the same `id` but different names, languages and geometry are equal with equal `hashCode`**; a branch with polygon equals the same branch without it; malformed geometry yields `null` and never throws.
- [ ] T015 [P] Write `test/modules/location/model/branch_work_time_test.dart` — normal window; **midnight-crossing window (open 21:00, close 03:00) treated as one continuous period**; `open == close` treated as open all day; explicit `lock: "1"` ⇒ `false`; null/unparseable `timeopen` discards only that window while the other window on the day still applies; missing day with no `alldays` ⇒ `true`; entirely absent/malformed `work_time` ⇒ `true`; `afternone` is the key read.
- [ ] T016 [P] Write `test/modules/location/model/paginated_test.dart` — `{data, meta}`, `{data}` with no `meta`, and a bare list all parse; `lastPage` and `total` defaults.
- [ ] T017 [P] Write `test/modules/location/model/geo_point_test.dart` — parses from **`lng`**, not `long`; accepts numbers and tolerates strings; a malformed vertex is dropped rather than throwing; `Region` exposes no `center`.
- [ ] T018 [P] Write `test/modules/location/data/location_filter_test.dart` — `cacheKey` is stable and fixed-order; equal filters produce one key; region 7 vs region 8, `hd=1` vs `ap=1`, and car vs region keys all differ; the `delivery()`/`airport()`/`car()` constructors expose no way to set `regionId`.
- [ ] T019 [US1] Write `test/modules/location/data/location_remote_datasource_test.dart` covering **all thirteen** rows of the contract-test table in [contracts/remote-datasource.md](./contracts/remote-datasource.md), including `no-region filter omits the regions key` (absent, not present-and-null), `pagination follows meta.last_page`, `pagination caps at 10 pages`, `duplicate ids across pages collapse`, and `Accept-Language is sent explicitly` (the resolver's value, not `''`). Mock `Dio` with `mocktail`; no live network.
- [ ] T020 [P] Write `test/modules/location/data/location_cache_test.dart` — hit, miss, expiry, `readStale` ignoring TTL, and **a throwing box surfacing as a miss rather than an exception** for read, write and readStale alike.
- [ ] T021 [US1] Write `test/modules/location/data/location_repository_test.dart` covering all eleven rows of the contract-test table in [contracts/repository-and-cache.md](./contracts/repository-and-cache.md), especially `network failure with expired entry returns stale`, `network failure with no entry rethrows`, and `cache read throwing is a miss`.
- [ ] T022 Run `powershell -ExecutionPolicy Bypass -File scripts/flutter_test_filtered.ps1 test/modules/location` then `powershell -ExecutionPolicy Bypass -File scripts/flutter_analyze_filtered.ps1`; report the issue count against the 78 baseline. **No commit. STOP.**

**Checkpoint (plan Phase 1)**: the whole data layer exists and is tested. Nothing is wired. The app
behaves exactly as before.

### Phase 2B — Cubit (plan Phase 2)

- [ ] T023 [US2] Create `LocationSelectionState` in `lib/modules/location/presentaion/bloc/location_selection_state.dart` — immutable, `Equatable`, with the nine fields in [data-model.md](./data-model.md#locationselectionstate) including the explicit `separateDropoff` flag. Expose the named transformers **`clearPickupBranch()`, `clearDropoffBranch()`, and `clearDropoff()`** (region **and** branch, one object, one emit). **`copyWith` MUST NOT accept a nullable-clearing argument for these fields** — `copyWith(x: null)` is a silent no-op and is the single most likely path back to the stale-dropoff bug.
- [ ] T024 [US1] [US2] Create `LocationSelectionCubit` in `lib/modules/location/presentaion/bloc/location_selection_cubit.dart` with exactly the public surface and transition table in [contracts/cubit-state-machine.md](./contracts/cubit-state-machine.md). All selection rules live here, never in a screen. **No `emit` of an equal state, no revision counter, no in-place list mutation** — lists are replaced. The cubit holds no `BuildContext` and performs no navigation. Depends on T012, T023.
- [ ] T025 [US7] Implement `onLanguageChanged()` in `location_selection_cubit.dart` — refetch every list currently held with `forceRefresh`, then **re-resolve `pickupBranch`, `dropoffBranch`, `pickupRegion` and `dropoffRegion` by `id`** against the new lists. A selection missing from the new list is cleared, and `status` stays `ready`, not `failure`.
- [ ] T026 [US1] Register `LocationSelectionCubit` in `lib/service_locator.dart` as **`registerFactory`** — one instance per booking attempt. **Do not add it to `lib/bloc_providers.dart`**; an app-wide singleton is precisely the defect FR-017 exists to close.
- [ ] T027 [US2] Write `test/modules/location/cubit/location_selection_cubit_test.dart` covering **all seventeen** rows of the `bloc_test` table in [contracts/cubit-state-machine.md](./contracts/cubit-state-machine.md). The load-bearing ones: **`disabling dropoff clears region and branch in ONE emit`** (assert exactly one state emitted, both null in it), `selecting a pickup region clears the pickup branch`, `language change preserves selection by id` even when the branch moved list position, `fetch failure preserves existing selections`, and `no duplicate consecutive states`.
- [ ] T028 Run the location tests, then `scripts/flutter_analyze_filtered.ps1`; report against the 78 baseline. **No commit. STOP.**

**Checkpoint (plan Phase 2)**: the cubit exists and is tested. Still not wired to any screen.

### Phase 2C — Branch picker screen (plan Phase 3)

Built **alongside** the old picker. `BranchesListView` and the old flow keep working untouched.

- [ ] T029 [P] [US1] Create `BranchTile` in `lib/modules/location/presentaion/pages/branch_picker/branch_tile.dart` — renders name, address/region when present, and same-day availability, tolerating every field being null except `id` and `name` (US6 scenario 2). **Reads no cubit.** Keep it under `branch_picker/`, not in a shared widgets folder, so the Principle II grep gate covers it.
- [ ] T030 [US1] [US2] Create `BranchPickerScreen` in `lib/modules/location/presentaion/pages/branch_picker_screen.dart` per [contracts/navigation-contract.md](./contracts/navigation-contract.md) — constructor parameters `List<Branch> branches`, `int? selectedId`, `String? emptyMessage` and **nothing else** (no callback). Returns via `Navigator.pop(context, branch)` typed `Branch`. **Reads no cubit, scoped or global. Contains no `isReceive` flag or any equivalent by another name.** Marks the current selection by **`id`**, never by name or index. Renders `emptyMessage` for an empty list. All strings arrive already localized or come from `AppLocalizations` — no hardcoded UI text.
- [ ] T031 [US1] [US2] Write `test/modules/location/pages/branch_picker_screen_test.dart` covering all six rows of the test table in [contracts/navigation-contract.md](./contracts/navigation-contract.md). **The first test is the guard**: pump the **full screen bare, with no `BlocProvider` ancestor at all**, in both the populated-list and empty-state cases so every helper widget actually builds. If it ever fails, remove the cubit read — **never "fix" it by wrapping the pump in a provider.**
- [ ] T032 [US1] Run the Principle II static gate and confirm **zero** matches:
  `grep -rnE "context\.(read|watch)|BlocProvider\.of|BlocBuilder|BlocListener|BlocConsumer|BlocSelector|sl<" lib/modules/location/presentaion/pages/branch_picker_screen.dart lib/modules/location/presentaion/pages/branch_picker/`
- [ ] T033 Run the location tests, then `scripts/flutter_analyze_filtered.ps1`; report against the 78 baseline. **No commit. STOP.**

**Checkpoint (plan Phase 3)**: the full new stack exists and is tested end to end in isolation. The
old picker still serves every flow. **Foundation complete — flow conversion may begin.**

---

## Phase 3: Daily rent (plan Phase 4) — US1 🎯 MVP, US2, US3, US7

**Goal**: the daily-rent flow runs entirely on the new module — complete region-filtered branch
lists, working dropoff selection, time guarding, and language-stable identity.

**Independent test**: open daily rent, pick the region with the most branches, confirm the count
matches the server's reported total, select pickup and a different-region dropoff, disable dropoff
and confirm nothing stale is submitted, and confirm the submitted branch id is identical in Arabic
and English.

- [ ] T034 [US1] Provide `LocationSelectionCubit` from GetIt at the daily-rent screen in `lib/modules/home/booking_packages/ui/daily_package_screen.dart` via a `BlocProvider` scoped to that screen, and call `start(LocationFilter.allRegions())` once on mount. **Do not add it to `lib/bloc_providers.dart`.**
- [ ] T035 [US1] Replace region selection in `lib/modules/home/booking_packages/widgets/daily_rent_body.dart` with `selectPickupRegion(region)` driven by the cubit's region list, removing this screen's use of the `SearchCubit`/`AllBranchCubit` location fields. Leave `SearchCubit`'s date, package and search logic untouched — it is out of scope.
- [ ] T036 [US1] [US2] Replace both branch pickers in `daily_rent_body.dart` with the `PersistentNavBarNavigator.pushNewScreen<Branch>(context, screen: BranchPickerScreen(branches: options, selectedId: …), withNavBar: false)` call from the navigation contract, passing the result to **`setPickupBranch`** or **`setDropoffBranch`** at the call site. **The caller's choice of setter is the only thing that distinguishes pickup from dropoff** — no flag travels into the screen. Do not use `BranchesListView` here any more.
- [ ] T037 [US2] Wire the separate-dropoff toggle in `daily_rent_body.dart` to `setSeparateDropoff(bool)` and the dropoff region to `selectDropoffRegion`. Confirm at the call site that **nothing clears a sibling field in the widget** — all clearing is the cubit's.
- [ ] T038 [US3] Wire time guarding in the daily-rent date/time picker from `state.pickupBranch?.workTime` — disable (**not hide**) times less than two hours away, times where `isOpenAt` is false, and dropoff times at or before pickup. A `null` `workTime` leaves every time enabled (Principle IV). Keep `POST /available/time` in place as the final authority and surface its message on rejection.
- [ ] T039 [US1] [US7] Trigger `onLanguageChanged()` from the daily-rent screen when the app locale changes (`LanguageCubit`), so names refresh while the selection survives by id.
- [ ] T040 [US1] Add the FR-038 failure UI to `daily_rent_body.dart` — on `status: failure`, show `state.error` with a retry that calls `cubit.retry()`, without discarding selections already made.
- [ ] T041 Run `scripts/flutter_analyze_filtered.ps1`; report against the 78 baseline. **No commit.**
- [ ] T042 [US1] [US2] [US3] [US7] **Device-verify daily rent** against the Phase 4 checklist in [quickstart.md](./quickstart.md): full branch count for the largest region; pickup then dropoff in a different region; changing pickup region clears the pickup branch; disabling dropoff submits nothing stale; every tap gives feedback; time guard disables the right slots; language switch keeps the selection and changes the names. **Expect time guarding to become stricter than today** — the old `Mon` class parsed only `lock` for six of eight day keys ([R7](./research.md)), so real morning/afternoon windows now apply. That is the fix landing, not a regression. **STOP.**

**Checkpoint**: US1, US2, US3 and US7 are complete and device-verified in the daily-rent flow. Every
other flow is still on the old code and still works.

---

## Phase 4: Monthly rent (plan Phase 5) — US5

**Goal**: monthly rent behaves identically to daily rent in every respect covered by US1 and US2.

**Independent test**: repeat the entire Phase 3 independent test in the monthly-rent flow.

- [ ] T043 [US5] Provide and start `LocationSelectionCubit` with `LocationFilter.allRegions()` in `lib/modules/home/booking_packages/ui/monthly_package_screen.dart`, removing that screen's `AllBranchCubit` usage.
- [ ] T044 [US5] Convert region selection, both branch pickers, the dropoff toggle, the time guard, the language hook and the failure/retry UI in `lib/modules/home/booking_packages/widgets/monthly_rent_body.dart`, mirroring T035–T040 exactly. Reuse the same `BranchPickerScreen` — do not fork it.
- [ ] T045 Run `scripts/flutter_analyze_filtered.ps1`; report against the 78 baseline. **No commit.**
- [ ] T046 [US5] **Device-verify monthly rent** against the same checklist as T042. **STOP.**

**Checkpoint**: daily and monthly both on the new module.

---

## Phase 5: Delivery + airport (plan Phase 6) — US5

**Goal**: both service-filtered flows list their branches directly, spanning all regions, **with no
region step**, and the out-of-scope areas map picker behaves exactly as it does today.

**Independent test**: open delivery and airport; confirm the branch list appears immediately with no
region selector, that a branch seen in delivery is the same entity (same id) as in daily rent, and
that an empty result explains itself rather than showing a blank list.

- [ ] T047 [US5] Provide and start `LocationSelectionCubit` with **`LocationFilter.delivery()`** in `lib/modules/home/booking_packages/ui/delivery_package_screen.dart` and convert `lib/modules/home/booking_packages/widgets/delivery_rent_body.dart` to it. **Remove the region step from this flow** — `start` fetches branches directly. Retire `lib/modules/home/booking_packages/Delivery_widgets/region_selection_bottom_sheet.dart` and `delivery_branch_selection_sheet.dart` from this path in favour of `BranchPickerScreen`.
- [ ] T048 [US5] Repoint the areas geometry accessors in `delivery_rent_body.dart` — `_buildBoundsFromBranch()` (`:96`), `_buildBoundsFromRegion()` (`:114`), `_getCenterFromBranch()` (`:133`), `_getCenterFromRegion()` (`:139`) — at the new `Branch.polygon` / `Branch.center` and `Region.polygon` (BD-1). **This is behaviour preservation on an out-of-scope feature.** Do not improve, extend or redesign the areas feature; keep the null handling at `:98` and the `_pickLocation()` permission fallback (`:168`) exactly as they are.
- [ ] T049 [US5] Provide and start `LocationSelectionCubit` with **`LocationFilter.airport()`** in `lib/modules/home/booking_packages/ui/airboart_package_screen.dart` and convert `lib/modules/home/booking_packages/widgets/airbort_rent_body.dart`. No region step.
- [ ] T050 [US5] Add the FR-039 empty-state message to both flows via `BranchPickerScreen`'s `emptyMessage`, localized through `AppLocalizations` — add the key to **both** `lib/language/languages/english.dart` and `arabic.dart` plus a getter in `lib/language/locale.dart`. No hardcoded UI string.
- [ ] T051 Run `scripts/flutter_analyze_filtered.ps1`; report against the 78 baseline. **No commit.**
- [ ] T052 [US5] **Device-verify delivery and airport**: branch list appears with no region step; the same branch carries the same id as in daily rent; dropoff behaves as in US2; empty result is explained.
- [ ] T053 [US5] **Device-verify the areas behaviour-preservation acceptance item** ([plan.md](./plan.md#phase-6-acceptance--areas-behaviour-preservation)): the delivery map location picker receives the **same `bounds` and the same `centerOverride` it received before**, for both the branch-derived and the region-derived case — same boundary, same centre, same point-in-polygon rejection, and the same permission fallback when there is no polygon. Compiling is not evidence. **The only acceptable outcome is "indistinguishable from before". STOP.**

**Checkpoint**: US5 complete. Four of five flows converted.

---

## Phase 6: Book-from-car (plan Phase 7) — US6

**Goal**: the car flow lists the car's available branches directly from partial records, with no
region step, and submits an id that matches that branch everywhere else in the app.

**Independent test**: open a car, start booking, confirm the branch list appears immediately with no
region selector, that partial rows render name and same-day availability without errors or blank
rows, and that submission sends the same id that branch carries in daily rent.

- [ ] T054 [US6] Provide and start `LocationSelectionCubit` with **`LocationFilter.car(carId)`** in `lib/modules/home/booking_from_cars/presentaion/view/branchs_with_car_screan.dart`, replacing `BookingCarsCubit`'s branch list for selection purposes. No region step.
- [ ] T055 [US6] Convert the branch selection UI in `lib/modules/home/booking_from_cars/presentaion/view/widget/branchs.dart` and `branches_card.dart` to `BranchPickerScreen`, tolerating partial records — name and same-day flag render, missing address/coordinates/work-time produce neither an error nor an empty row (US6 scenario 2).
- [ ] T056 [US6] Implement branch completion by id in `lib/modules/location/data/location_repository.dart` (or a small helper beside it) per [data-model.md](./data-model.md#completing-a-partial-branch-phase-7): `full.firstWhereOrNull((b) => b.id == partial.id) ?? partial`. Call it **before any work-hours check runs** in the car flow.
- [ ] T057 [P] [US6] Add tests to `test/modules/location/data/location_repository_test.dart` for completion — a matched partial gains `workTime` and geometry; **an unmatched partial is returned unchanged and the time guard then fails open**; `complete(p, full) == p` holds because equality is on `id`.
- [ ] T058 [US6] Wire the time guard in the car flow to run against the **completed** branch, falling open when completion found no match. Keep `POST /available/time` as the final authority — it is the only remaining check in that case.
- [ ] T059 Run the location tests, then `scripts/flutter_analyze_filtered.ps1`; report against the 78 baseline. **No commit.**
- [ ] T060 [US6] **Device-verify book-from-car**: no region step; partial rows render; a selected branch's submitted id matches the id that branch has in daily rent; times remain available when completion fails. **STOP.**

**Checkpoint**: US6 complete. All five flows converted. The old picker is now unreachable from every
in-scope flow — **but its global scaffolding must still not be removed (OC-1).**

---

## Phase 7: Booking draft (plan Phase 8) — US4

**Goal**: the completed selection travels forward as an immutable value that downstream screens can
read but not change, and dies when the renter navigates back.

**Independent test**: complete a selection, proceed to additions and payment, confirm both read it
and neither can alter it, then navigate back and confirm the booking screen starts empty.

- [ ] T061 [US4] Create `BookingDraft` in `lib/modules/location/data/models/booking_draft.dart` — immutable, `pickupBranch`, `dropoffBranch` (null ⇒ same as pickup), `pickupAt`, `dropoffAt`, `car`. **No setters and no `copyWith` exposed to downstream screens.**
- [ ] T062 [US4] Build the `BookingDraft` in each converted booking body (`daily_rent_body.dart`, `monthly_rent_body.dart`, `delivery_rent_body.dart`, `airbort_rent_body.dart`, `branchs_with_car_screan.dart`) when selection completes, and pass it to the additions screen as a **constructor parameter**.
- [ ] T063 [US4] Change `lib/modules/home/additions/presentaion/pages/additions_screen.dart` to read the selection from the injected `BookingDraft` rather than from a shared cubit, and pass the same instance onward to payment as a constructor parameter.
- [ ] T064 [US4] Change `lib/modules/home/payment/paymentMethods.dart` and `lib/modules/home/payment/invoice.dart` to read the selection from the `BookingDraft`. Remove every write path from these screens back into location state.
- [ ] T065 [US4] Confirm no clearing code was added anywhere: navigating back destroys the draft and the factory-registered cubit, and that alone satisfies FR-017 and FR-020. If a `clear()` call was needed to make the test pass, the lifetime is wrong — fix the lifetime, not the symptom.
- [ ] T066 Run `scripts/flutter_analyze_filtered.ps1`; report against the 78 baseline. **No commit.**
- [ ] T067 [US4] **Device-verify**: additions and payment read the selection; neither can change it; back from additions leaves the booking screen empty; a second booking after completing or abandoning one shows zero pre-filled location values. **STOP.**

**Checkpoint**: all seven user stories complete and device-verified. The old code is dead but still
present.

---

## Phase 8: Deletion (plan Phase 9)

**⚠️ OC-1 PRECONDITION**: this phase MUST NOT begin until T042, T046, T052/T053, T060 and T067 have
**each** been device-verified. The global `AllBranchCubit` registration at `lib/bloc_providers.dart:31`
is load-bearing for the *old* picker: `BranchesListView` reads `context.read<AllBranchCubit>()`
(`branches_list_view.dart:59, 76`) from a root-navigator route, and that read resolves **only**
because of the global registration. Removing it while any flow still reaches that widget reproduces
the original "tapping does nothing" bug exactly. **The registration removal and the widget deletions
below land in this one phase, never split across phases.**

- [ ] T068 Delete the location fields from `lib/modules/home/search_screen/blocs/search_bloc/search_cubit.dart` (selected branch/region names and models, `clearAllDataSearched`'s location half). **Leave date, package and search logic untouched** — out of scope.
- [ ] T069 Fix the Principle I violation at `lib/modules/home/home_screen/clasic.dart:63-69`, which looks a branch up by `element.name == selectedReceiveBranch`. It needs an **id**, which `SearchCubit` no longer holds after T068 — route it through the new module or pass the id explicitly. **This is a name-match lookup and cannot survive as-is.**
- [ ] T070 Convert `lib/modules/home/all_branching/page/branches_screen.dart` (`:37, :88, :90, :158`) and `lib/modules/home/search_screen/presentaion/search_Screen.dart:58` off `AllBranchCubit` onto `LocationRepository` / the new models. These are outside the booking flow but hold the last references.
- [ ] T071 Delete `lib/modules/home/search_screen/presentaion/widget/branches_list_view.dart`, `lib/modules/home/search_screen/presentaion/widget/map_list_selection_view_tile.dart`, and `lib/modules/home/search_screen/presentaion/map_list_view.dart`.
- [ ] T072 Delete `lib/modules/home/all_branching/bloc/all_branching_cubit.dart` and its registration in `lib/service_locator.dart:87`, **and** the global provider at `lib/bloc_providers.dart:31` — all in this task, together.
- [ ] T073 Delete `branchs_service.dart` and its registration. **Do NOT attempt to remove `package:http` from `pubspec.yaml`** — 11 files import it and only this one is in scope ([R1](./research.md), constitution v1.0.1). That is separate, larger work.
- [ ] T074 [P] Delete now-orphaned old models and any `WorkTime`/`Mon` classes in `lib/modules/home/all_branching/data/models/branch_model.dart` that nothing references, and remove the duplicated `@HiveType(typeId: 7)` if the file survives. If any `@HiveType` class is removed, run `dart run build_runner build --delete-conflicting-outputs` to regenerate `lib/hive_registrar.g.dart`.
- [ ] T075 Re-run the Principle II grep gate from T032 and confirm it is still zero, and grep the whole of `lib/` for `AllBranchCubit`, `BranchesListView`, `MapListSelectionViewTile`, `MapListView` and `branchs_service` — all must return zero hits.
- [ ] T076 Run `scripts/flutter_test_filtered.ps1` (full suite) then `scripts/flutter_analyze_filtered.ps1`; report against the 78 baseline. Any increase MUST be explained. **No commit.**
- [ ] T077 **Device-verify all five flows end to end** after deletion — this is the regression sweep for SC-010 (none of the six previously-closed defects recur). **STOP.**

---

## Phase 9: Polish & Cross-Cutting

- [ ] T078 [P] Confirm no hardcoded UI strings were introduced anywhere under `lib/modules/location/` — every user-visible string goes through `AppLocalizations` with keys in **both** `lib/language/languages/english.dart` and `arabic.dart`.
- [ ] T079 [P] Confirm all sizing in the new screens uses `flutter_screenutil` (`.w`/`.h`/`.sp`) and `AppTypography` / theme-aware color getters rather than raw `TextStyle` and `Colors.*`, per CLAUDE.md.
- [ ] T080 Walk [quickstart.md](./quickstart.md) end to end as the final validation pass and record the result against SC-001 … SC-010 in [spec.md](./spec.md#success-criteria-mandatory).
- [ ] T081 Delete the plan file from `~/.claude/plans/` if one exists for this work, and propose the commit split to the developer. **Do not commit without explicit approval.**

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 (Setup)** → no dependencies.
- **Phase 2 (Foundational)** → blocks everything. Its three sub-phases are strictly ordered: 2A (data) → 2B (cubit, needs the repository) → 2C (picker, independent of the cubit by contract but gated with it).
- **Phases 3–7 (flow conversions)** → each depends on Phase 2 complete **and on the previous phase being device-verified** (Constitution Principle V). They are **not** parallelisable across each other; that is deliberate, not a staffing limitation.
- **Phase 8 (Deletion)** → depends on T042, T046, T052, T053, T060, T067 all device-verified (**OC-1**).
- **Phase 9 (Polish)** → after Phase 8.

### Story dependencies

- **US1, US2** — delivered together in Phase 3; US2's dropoff behaviour is meaningless without US1's pickup.
- **US3** — depends on US1 (needs a selected branch). Delivered in Phase 3.
- **US7** — implemented in Phase 2B (T025), verified in Phase 3 (T042).
- **US5** — depends on US1/US2 being proven in daily rent. Phases 4–5.
- **US6** — depends on the general model being proven. Phase 6.
- **US4** — depends on every flow being able to produce a completed selection. Phase 7.

### Parallel opportunities

Within Phase 2A the model files are genuinely independent: **T003, T004, T005 in parallel**, then
**T006 and T007** once `GeoPoint`/`BranchWorkTime` exist, with **T008, T009, T011** alongside them.
The unit tests **T014–T018, T020** are all independent files and can be written in parallel.
Everywhere else the ordering is real.

```bash
# Phase 2A models, in parallel:
Task: "Create GeoPoint in lib/modules/location/data/models/geo_point.dart"
Task: "Create Paginated<T> in lib/modules/location/data/models/paginated.dart"
Task: "Create BranchWorkTime in lib/modules/location/data/models/branch_work_time.dart"
Task: "Create LocationFilter in lib/modules/location/data/location_filter.dart"
```

---

## Implementation Strategy

**MVP** = Phase 1 + Phase 2 + Phase 3. That delivers US1, US2, US3 and US7 in the daily-rent flow —
the two structural fixes that matter most (identity by id, one complete list per filter) plus the
headline dropoff bug, on a real device. It is a shippable increment: the other four flows are
untouched and still work on the old code.

**Incremental delivery** thereafter is one flow per phase, each device-verified before the next
begins. Deletion is last and atomic.

**Parallel team strategy**: not applicable beyond Phase 2A. The conversion phases are sequential by
constitutional requirement, and OC-1 makes the deletion phase indivisible.

---

## Notes

- `[P]` = different file, no dependency on an incomplete task.
- **Never** run `flutter analyze`, `flutter test` or `flutter build` directly — always via `scripts/flutter_*_filtered.ps1`.
- **Never commit without explicit approval.** Every phase ends with STOP.
- Dart files must be UTF-8 **without BOM**; do not round-trip them through PowerShell 5.1 `Get-Content -Raw`, which corrupts Arabic strings.
- If a fix does not resolve the reported symptom, **stop and diagnose** rather than trying another fix. Two failed fixes in a row means the root cause has not been found.
