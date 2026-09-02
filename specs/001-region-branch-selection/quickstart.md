# Quickstart: Validating the Region & Branch Selection Rewrite

**Plan**: [plan.md](./plan.md) | **Contracts**: [contracts/](./contracts/)

How to prove each phase actually works. Every phase ends with analyze, **no commit**, and a stop.
Phases 4–9 do not begin until the previous phase is verified **on a real device** — a clean analyze
is not completion (Constitution Principle V).

## Prerequisites

```bash
flutter pub get --offline
```

`--offline` avoids pub.dev's `advisoriesUpdated` decoding bug and the known
`package_info_plus` / `device_info_plus` constraint conflict. Both are pre-existing and unrelated
to this feature.

**Always use the filtered scripts. Never run `flutter analyze` / `test` / `build` directly.**

```bash
powershell -ExecutionPolicy Bypass -File scripts/flutter_analyze_filtered.ps1
```

```bash
powershell -ExecutionPolicy Bypass -File scripts/flutter_test_filtered.ps1 test/modules/location
```

**Baseline: 78 issues.** Report the count after every phase. Any increase must be explained.

No `build_runner` run is needed at any point — the cache stores raw JSON and the new models carry
no `@HiveType` annotations.

---

## Phase 1 — Foundation

Create the branch first:

```bash
git checkout -b refactor/location-selection
```

**Nothing is wired. App behaviour must be identical.** The only proof at this stage is tests.

```bash
powershell -ExecutionPolicy Bypass -File scripts/flutter_test_filtered.ps1 test/modules/location
```

Expected to pass, grouped by the tables in
[remote-datasource.md](./contracts/remote-datasource.md) and
[repository-and-cache.md](./contracts/repository-and-cache.md), plus these model cases:

**Identity (Principle I)**

- `Branch.fromBranchesApi({id: 5, name: "الفرع"}) == Branch.fromCarBranchesApi({id: 5, text: "Branch"})`
- the two above have equal `hashCode`
- two branches with the same name and different ids are **not** equal

**Parsing**

- `lat: "24.7136"` → `24.7136`; `lat: "abc"` → `null`; `lat: null` → `null`
- the longitude comes from **`long`**, and a payload carrying `lng` instead yields `null`
- `book_today: 1` → `true`; `can_book_today: 0` → `false`; neither key present → `false`
- `name` falls back to `text`; `text` falls back to `name`
- `fromCarBranchesApi` sets `isPartial: true` and leaves `workTime` null
- `delivery_price` absent → `0`, not null

**Geometry (BD-1)**

- `polygon` vertices and `center` parse from **`lng`**, not `long`, and arrive as **numbers**, not
  strings — a payload using `long` inside a vertex yields `null`
- a branch with `polygon` and the same branch without it are **equal**, and have equal `hashCode` —
  geometry is excluded from `props`
- `polygon: null`, `polygon: []`, a non-list `polygon`, and a malformed vertex all degrade to
  `null` / a dropped vertex — **never a throw**
- `center: null` or malformed → `null`
- `Region` has **no** `center` field
- a partial (car-flow) branch has `polygon == null` and `center == null`

**Work time (Principle IV — fail open)**

- `work_time` absent → `isOpenAt` **true** for every input
- `work_time: null` → **true**
- `work_time` malformed (a string, a list) → **true**
- `{"timeopen": null}` → that window contributes nothing; the sibling window still applies
- `lock: "1"` → **false** for that day, and only that day
- `lock: 1` (int) → also **false**
- open `21:00` close `03:00` → **true** at `23:00` **and true at `01:00`**, false at `20:00`
- open `09:00` close `17:00` → true at `09:00`, true at `16:59`, false at `17:00`, false at `08:59`
- the **`afternone`** key populates the Dart field named `afternoon`
- a `sat`/`sun`/`mon`/`tue`/`wed`/`thu` entry with real morning/afternoon windows is parsed — see
  [R7](./research.md); the old model discarded these

**Filter**

- `LocationFilter.delivery()` and `.airport()` and `.car(id)` expose **no way to set `regionId`**
- two equal filters produce the same `cacheKey` string
- `cacheKey` field order is stable across constructions

**Manual check** — run the app. It must behave exactly as before; no new code is reachable.

---

## Phase 2 — Cubit

```bash
powershell -ExecutionPolicy Bypass -File scripts/flutter_test_filtered.ps1 test/modules/location/cubit
```

The full list is in [cubit-state-machine.md](./contracts/cubit-state-machine.md). The one that
matters most:

> **`disabling dropoff clears region and branch in ONE emit`** — exactly one state emitted, both
> null in it. Two emits mean an intermediate state exists holding a dropoff branch with no region.
> That is the shape of the defect FR-015 names.

Still not wired. The app must still behave exactly as before.

---

## Phase 3 — Picker screen

```bash
powershell -ExecutionPolicy Bypass -File scripts/flutter_test_filtered.ps1 test/modules/location
```

```bash
grep -rnE "context\.(read|watch)|BlocProvider\.of|BlocBuilder|BlocListener|BlocConsumer|BlocSelector|sl<" lib/modules/location/presentaion/pages/branch_picker_screen.dart lib/modules/location/presentaion/pages/branch_picker/
```

Must return **zero** matches. The gate is recursive and covers the **whole picker surface** — the
entry file plus every widget the picker owns — because a cubit read moved into a helper widget
breaks Principle II at runtime while passing a single-file check.

The widget test pumps the **full** `BranchPickerScreen` **with no provider ancestor at all**, with
a populated list *and* in the empty-state case, so every branch of the tree actually builds and a
helper widget's cubit read fails it too. If anyone adds a cubit read anywhere on that surface, the
test throws — which is the entire point. Do not "fix" it by wrapping the pump in a provider.

The old picker still works and is still the one the app uses.

---

## Phase 4 — Daily rent — **device verification starts here**

Analyze, then on a real device:

1. Open daily rent. **No region or branch is pre-filled.**
2. Select the region with the most branches. Count what is offered; compare against the server's
   reported total for that region. **They must match** (SC-003) — the old code showed page 1 only.
3. Select a branch. Change the region. **The branch must be cleared** (FR-009).
4. Enable separate dropoff. Choose a **different** region. Choose a dropoff branch.
   **It must register visibly** — this is the headline bug (SC-001).
5. Disable separate dropoff. Submit. **No dropoff value in the request** (FR-015, SC-005).
6. Open the time picker on a **Sunday-to-Thursday** date. Times outside the branch's hours must be
   **disabled, not hidden**. Expect this to be **stricter than before** — those days' hours were
   previously discarded at parse time ([R7](./research.md)). This is a fix; it will look like a
   regression.
7. Pick up today. Times less than two hours out must be disabled (FR-022).
8. Switch language mid-selection. Names change; **the selection survives** (FR-033, SC-008).
9. Submit in Arabic, then repeat in English. **The same branch id reaches the backend** (SC-002).
10. Turn airplane mode on and open the screen. A message and a retry — not a blank screen, not a
    silent failure (FR-038).
11. Tap a branch 10 times across the flow. **Every tap produces visible feedback** (SC-009).

Monthly, delivery, airport, and car flows are all still on the old code and must still work.

---

## Phase 5 — Monthly rent

Repeat every Phase 4 step in the monthly flow. Then re-run steps 2, 4 and 5 in **daily** rent to
confirm Phase 4 did not regress.

---

## Phase 6 — Delivery and airport

[BD-1](./plan.md#decision-record) is resolved: `Branch` carries `polygon` and `center`, `Region`
carries `polygon`. `delivery_rent_body.dart` reads all of these to constrain the areas map picker,
so step 6 below is a **required acceptance item**, not a spot check.

1. Open delivery. **The branch list appears immediately. There is no region selector** (FR-029).
2. The list spans regions — branches from more than one city are present.
3. Open airport. Same: immediate list, no region step, branches across all regions.
4. Pick a branch that also appears in daily rent's region list. **Same name, same id, one entity**
   (US5 scenario 3).
5. Dropoff selection works in both flows (SC-001).
6. **Areas behaviour-preservation check (BD-1) — required to pass Phase 6.** The delivery map
   location picker must receive the **same `bounds` and the same `centerOverride` it receives
   today**:
   - branch-derived case — pick a delivery branch, open the pickup location picker. The map is
     constrained to that branch's boundary and opens on that branch's centre
     (`_buildBoundsFromBranch` / `_getCenterFromBranch`).
   - region-derived case — open the dropoff location picker. The map is constrained to the
     region's boundary and opens on the polygon centroid (`_buildBoundsFromRegion` /
     `_getCenterFromRegion`).
   - dragging outside the boundary is rejected exactly as before (point-in-polygon containment).
   - a branch with no polygon still falls back to the device-location permission prompt, unchanged.

   This is a **behaviour-preservation check on an out-of-scope feature, not a new feature.** The
   only acceptable outcome is "indistinguishable from before". Compiling is not evidence.
7. If a service has no branches, a message is shown — not a blank list (US5 scenario 4).

---

## Phase 7 — Book-from-car

1. Open a car, start booking. **Branch list immediately, no region step** (FR-030).
2. Rows render with name and same-day availability. **No error, no empty row** from the missing
   fields (FR-031).
3. Open the time picker for a car-flow branch **before** completion runs — all times available
   (fail open).
4. Confirm completion by id ran: a car branch that also exists in the full list should pick up its
   working hours and guard times accordingly.
5. Submit. **The id matches that branch's id elsewhere in the app** (US6 scenario 4).
6. Accept the known risk: if completion finds no match, the branch never blocks a time and
   `POST /available/time` is the only remaining check.

---

## Phase 8 — Booking draft

1. Complete a selection, go to additions. **The additions screen shows the selection** (FR-018).
2. Go on to payment. Same values (FR-018).
3. Confirm neither screen can change the selection (FR-019) — there is no setter to call.
4. Navigate **back** from additions to the booking screen. **The selection is cleared** (FR-020).
5. Complete a booking end to end, then start a new one. **Nothing is pre-filled** (FR-017, SC-004).
6. Abandon a booking mid-way, leave the flow, come back. **Nothing is pre-filled.**

---

## Phase 9 — Deletion

**Precondition — [OC-1](./plan.md#ordering-constraints):** do not start until phases 4, 5, 6, 7 and
8 have **each** been device-verified. The global `AllBranchCubit` registration
(`lib/bloc_providers.dart:31`) is the only reason the old `BranchesListView` survives being pushed
onto the root navigator; removing it while any flow still reaches the old picker reproduces the
original "tapping does nothing" bug in that flow.

Delete: location fields from `SearchCubit`, `AllBranchCubit` entirely (including
`lib/service_locator.dart:87` and `lib/bloc_providers.dart:31`), `MapListView`, `BranchesListView`,
`MapListSelectionViewTile`, `branchs_service.dart` — **all in this one phase**, not split across
phases.

Then re-verify **every** flow — deletion is the phase most likely to break something at a distance:

1. All five booking flows, full Phase 4 checklist each.
2. `branches_screen.dart` (the standalone branches list, outside the booking flow) — it used
   `AllBranchCubit` at lines 37, 88, 90, 158.
3. `search_Screen.dart` — called `getAllBranch()` at line 58.
4. `clasic.dart` — used `SearchCubit.branchesData` with a **name-match** lookup at lines 63–69.
   This is a live Principle I violation and needs an id, which `SearchCubit` does not currently
   hold. Budget real work here; the supplied risk note attributed this file to `AllBranchCubit`,
   which is not what it uses.
5. Confirm `MapListView`, `BranchesListView`, `MapListSelectionViewTile` have no remaining
   references:

```bash
grep -rn "MapListView\|BranchesListView\|MapListSelectionViewTile\|AllBranchCubit\|branchs_service" lib/
```

6. Final analyze. **Should be below 78** — this phase deletes code, so a lower count is the
   expected outcome.

The `package:http` removal check has been **dropped from Phase 9**. The answer is already known:
ten other files still import it ([R1](./research.md)), so the package stays in `pubspec.yaml`.
Constitution v1.0.1 records this. Removing it entirely is separate, larger work.

---

## Success criteria mapping

| Criterion | Verified at |
|---|---|
| SC-001 dropoff works in all five flows | Phases 4, 5, 6, 7 — step 4/5 each |
| SC-002 correct id in both languages | Phase 4 step 9 |
| SC-003 no branch hidden | Phase 4 step 2 |
| SC-004 nothing pre-filled | Phase 8 steps 5–6 |
| SC-005 no stale dropoff | Phase 4 step 5 |
| SC-006 unserviceable times unreachable | Phase 4 steps 6–7 |
| SC-007 nobody blocked by bad data | Phase 1 fail-open tests; Phase 7 step 3 |
| SC-008 language switch keeps place | Phase 4 step 8 |
| SC-009 every tap gives feedback | Phase 4 step 11 |
| SC-010 the six defects do not recur | Phase 9 step 1 |
| DG-001 analyze ≤ 78 | every phase |
| DG-002 device-verified before the next flow | phases 4–9 |
| DG-003 working state every phase | phases 1–3 explicitly assert unchanged behaviour |
| DG-004 deletion only at the end | Phase 9 |
