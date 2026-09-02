# Contract: `LocationSelectionCubit`

`lib/modules/location/presentaion/bloc/location_selection_cubit.dart`

Registered in GetIt as **`registerFactory`** — one instance per booking attempt. A singleton is
precisely the defect FR-017 exists to close, and is how the current selection survives leaving the
flow.

State fields are in [data-model.md](../data-model.md#locationselectionstate).

## Governing rules

- **All selection rules live here, not in screens.** A screen calls a setter and rebuilds on the
  new state. It never clears a sibling field itself.
- **No manual state emission to force rebuilds.** Equality drives rebuilds (Principle III). There is
  no `emit(state)` with an unchanged value, no incrementing revision counter, no `List` mutated in
  place then re-emitted. Lists are replaced, never mutated.
- The cubit holds **no `BuildContext`** and performs **no navigation**.

## Public surface

```text
Future<void> start(LocationFilter baseFilter);   // called once, on screen mount
Future<void> selectPickupRegion(Region region);
void         setPickupBranch(Branch branch);
void         setSeparateDropoff(bool enabled);
Future<void> selectDropoffRegion(Region region);
void         setDropoffBranch(Branch branch);
Future<void> onLanguageChanged();
Future<void> retry();
```

`start` takes the flow's base filter — `LocationFilter.delivery()`, `.airport()`, `.car(id)`, or
`.allRegions()` for daily/monthly. This is the single point where the flow's shape enters the
cubit; nothing downstream branches on "which flow am I".

## Transitions

| Trigger | Effect |
|---|---|
| `start(f)` — region flows (`f` has no service flag and no car) | `status: loading` → fetch regions → `status: ready`. `pickupOptions` stays empty; there is no branch list until a region is chosen. |
| `start(f)` — delivery, airport, car | `status: loading` → fetch branches for `f` directly → `pickupOptions` and `dropoffOptions` both set → `status: ready`. **No region fetch. No region step.** |
| `selectPickupRegion(r)` | `pickupRegion = r`, **`pickupBranch` cleared**, `status: loading` → fetch `LocationFilter.region(r.id)` → `pickupOptions` replaced → `status: ready`. If `dropoffRegion == null`, `dropoffOptions` is set to the same list (FR-013). |
| `setPickupBranch(b)` | `pickupBranch = b`. Nothing else changes. |
| `setSeparateDropoff(true)` | `separateDropoff = true`. `dropoffOptions` = the pickup region's list until a dropoff region is chosen. |
| `setSeparateDropoff(false)` | **`dropoffRegion` and `dropoffBranch` cleared together, atomically, in one emit.** `separateDropoff = false`. |
| `selectDropoffRegion(r)` | `dropoffRegion = r`, **`dropoffBranch` cleared**, fetch `LocationFilter.region(r.id)` → `dropoffOptions` replaced. |
| `setDropoffBranch(b)` | `dropoffBranch = b`. |
| `onLanguageChanged()` | Refetch every list currently held, then **re-resolve `pickupBranch` and `dropoffBranch` by `id`** against the new lists. Regions likewise. Selections survive with updated display names (FR-033). |
| `retry()` | Re-runs the last failed fetch. **Selections already made are preserved** (FR-038). |
| any fetch fails | `status: failure`, `error` set. **Existing selections and options are left intact** — a failure never clears the renter's work. |

## The three clearing rules — how they are made unbreakable

`copyWith(pickupBranch: null)` is a **silent no-op** in the standard `copyWith` idiom: the
implementation cannot tell "not supplied" from "supplied as null". Writing the clears that way is
the single most likely path back to the stale-dropoff bug.

The state therefore exposes explicit named transformers instead, and `copyWith` never accepts a
nullable-clearing argument for these three fields:

```text
state.clearPickupBranch()
state.clearDropoffBranch()
state.clearDropoff()        // dropoffRegion AND dropoffBranch, one object, one emit
```

`clearDropoff()` is a single transformer producing a single new state. It is not
`clearDropoffRegion()` followed by `clearDropoffBranch()`, because two emits mean an intermediate
state exists in which a dropoff branch is held with no region — briefly submittable, and exactly
the shape of the defect FR-015 names.

## `bloc_test` coverage (Phase 2)

| Test | Asserts |
|---|---|
| `start on a region flow fetches regions, not branches` | branch remote never called |
| `start on delivery fetches branches directly` | region remote never called; `pickupOptions` populated |
| `start on airport fetches branches directly` | region remote never called |
| `start on car fetches the car list directly` | all options `isPartial == true` |
| `selecting a pickup region clears the pickup branch` | `pickupBranch` is null in the emitted state |
| `selecting a pickup region replaces the options list` | new list, not appended |
| `dropoff with no region mirrors the pickup list` | `dropoffOptions == pickupOptions` |
| `selecting a dropoff region does not touch the pickup branch` | `pickupBranch` unchanged |
| `selecting a dropoff region clears the dropoff branch` | `dropoffBranch` is null |
| **`disabling dropoff clears region and branch in ONE emit`** | exactly one state emitted; both null in it |
| `disabling dropoff leaves pickup untouched` | `pickupRegion`, `pickupBranch` unchanged |
| `language change preserves selection by id` | same `id`, new `name` |
| `language change preserves selection when the branch moved list position` | resolved by id, not index |
| `language change with a branch missing from the new list` | selection cleared rather than stale — and `status: ready`, not `failure` |
| `fetch failure preserves existing selections` | `pickupBranch` survives `status: failure` |
| `retry after failure restores ready` | |
| `no duplicate consecutive states` | `emit` with an equal state produces nothing (Principle III) |
| `two branches with the same id are one selection` | equality on `id` holds through the cubit |
