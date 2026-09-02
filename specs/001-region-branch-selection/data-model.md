# Phase 1 Data Model: Region & Branch Selection Rewrite

**Date**: 2026-09-02 | **Plan**: [plan.md](./plan.md) | **Research**: [research.md](./research.md)

All types live under `lib/modules/location/data/models/`. All are immutable, `const`-constructible
where possible, and use `Equatable`.

**Governing rule — Constitution Principle I**: `Region` and `Branch` override `==` and `hashCode`
on **`id` only**. Not on name, **not on geometry**, not on any other field. This is what makes the
same branch arriving from `/branches` (key `name`) and from `/available/branches/{carId}` (key
`text`), in two different languages, one entity.

**Geometry is explicitly excluded from `==` and `hashCode`** (BD-1). `polygon` and `center` are
payload, not identity: a branch fetched with its polygon and the same branch fetched without it —
or with a re-surveyed boundary — are the same entity. `props` is `[id]` on both models, and adding
geometry to it would break the cross-endpoint equality the whole rewrite depends on, because the
car endpoint returns no geometry at all.

---

## `Region`

| Field | Type | Source key | Notes |
|---|---|---|---|
| `id` | `int` | `id` | Required. Identity. |
| `name` | `String` | `name` | Server-localized. Display only — never a lookup key. |
| `city` | `String?` | `city` | |
| `polygon` | `List<GeoPoint>?` | `polygon` | Boundary outline. Consumed by the areas map picker ([BD-1](./plan.md#decision-record)). |

Not modelled: `code`, `master_id`, `center`. None is read anywhere today; the region centre is
computed as a centroid of `polygon` (`delivery_rent_body.dart:139`), so `Region.center` was
deliberately **not** added. See [BD-2](./plan.md#decision-record).

**Equality**: `props => [id]` — `polygon` excluded.

**Parsing**: `Region.fromJson(Map<String, dynamic>)`. A missing or non-integer `id` is a parse
failure — regions without identity cannot be selected, and silently dropping them is preferable to
a list entry that cannot be submitted.

---

## `GeoPoint`

`lib/modules/location/data/models/geo_point.dart` — its own model file, shared by
`Region.polygon`, `Branch.polygon`, and `Branch.center`.

| Field | Type | Source key | Notes |
|---|---|---|---|
| `lat` | `double?` | `lat` | |
| `lng` | `double?` | **`lng`** | |

**Equality**: `props => [lat, lng]` — a coordinate has no identity apart from its values, so unlike
`Region` and `Branch` it compares on content.

### The geometry payload is a different shape from the branch's own coordinates

This is the trap in this model. The two coordinate representations on a single branch payload do
**not** match:

| | Key | Type on the wire | Parsed with |
|---|---|---|---|
| Branch's own position | `lat` / **`long`** | **String** (`"24.7136"`) | `double.tryParse` |
| Geometry (`polygon` vertices, `center`) | `lat` / **`lng`** | **number** (`24.7136`) | `toDouble()` — but guarded |

So the same conceptual value arrives under `long` as a string at the top level of a branch, and
under `lng` as a number inside `center` and each polygon vertex. Reusing one parser for both, or
assuming one key spelling, silently yields nulls.

`GeoPoint.fromJson` uses the shared `_asDouble` helper anyway (`num` → `toDouble()`, `String` →
`double.tryParse`, else `null`), so it tolerates a string if the backend ever sends one — but it
reads **`lng`**, never `long`. The current models parse geometry with a bare `json["lat"]?.toDouble()`
(`branch_model.dart:268`, `regions_model.dart:79`), which throws on a string; the helper removes
that sharp edge without changing behaviour for the shapes seen today.

### Parsing

| Target | Rule |
|---|---|
| `Region.polygon` | `json["polygon"]` — a list of `{lat, lng}` objects; `null` or absent → `null`; a non-list → `null`; individual malformed vertices are dropped |
| `Branch.polygon` | same |
| `Branch.center` | `json["center"]` — a single `{lat, lng}` object; `null`, absent, or malformed → `null` |

Geometry parsing **never throws**. A malformed polygon degrades to `null`, which the areas feature
already handles: `_buildBoundsFromBranch()` returns `null` for an empty or absent polygon
(`delivery_rent_body.dart:98`) and `_pickLocation()` falls back to a device-location permission
request. Failing soft here matches the existing behaviour exactly.

The car endpoint returns no geometry, so a partial `Branch` has `polygon == null` and
`center == null`. Phase 7's completion-by-id fills them in from the full list when a match exists.

---

## `Branch`

| Field | Type | Source key | Notes |
|---|---|---|---|
| `id` | `int` | `id` | Required. Identity. |
| `name` | `String` | `name ?? text` | **Two source keys.** `/branches` sends `name`; `/available/branches/{carId}` sends `text`. |
| `regionId` | `int?` | `region_id` | Absent on partial records. |
| `regionName` | `String?` | `region` | A string on the branch payload, not a nested object. Display only. |
| `address` | `String?` | `address` | Absent on partial records. |
| `lat` | `double?` | `lat` | **Arrives as a String.** `double.tryParse`, never a cast. |
| `lng` | `double?` | **`long`** | **The API key is `long`, not `lng`.** Also a String. |
| `phone` | `String?` | `phone` | |
| `locationUrl` | `String?` | `location_url` | |
| `workTime` | `BranchWorkTime?` | `work_time` | `null` on partial records ⇒ fail open. |
| `bookToday` | `bool` | `book_today ?? can_book_today` | Arrives as int `1`/`0`. **Default `false` when absent.** |
| `deliveryPrice` | `num` | `delivery_price` | Non-nullable, **default `0`** when absent (the car endpoint omits it). |
| `image` | `String?` | `image` | Car endpoint only. Display payload — see plan **[detail]** note. |
| `isPartial` | `bool` | — | **Never from JSON.** Set by the factory. |
| `polygon` | `List<GeoPoint>?` | `polygon` | Boundary outline. Keys are `lat`/**`lng`**, numeric — **not** the `lat`/`long` string pair above ([BD-1](./plan.md#decision-record)). |
| `center` | `GeoPoint?` | `center` | Same shape as a polygon vertex. |

**Equality**: `props => [id]` — `polygon` and `center` excluded, along with everything else.

### Factories

```text
Branch.fromBranchesApi(Map<String, dynamic> json)     // isPartial = false
Branch.fromCarBranchesApi(Map<String, dynamic> json)  // isPartial = true
```

There is no unnamed `fromJson`. Forcing the caller to name the source is what keeps `isPartial`
honest — it can never be inferred from field presence, because a full branch may legitimately have
a null `work_time`.

`fromCarBranchesApi` reads only `id`, `text`, `image`, `can_book_today`. Everything else is left
null / defaulted. It does **not** attempt to synthesise a `regionId`.

### Parsing helpers

| Helper | Behaviour |
|---|---|
| `_asInt(dynamic)` | `int` → itself; `String` → `int.tryParse`; anything else → `null` |
| `_asDouble(dynamic)` | `num` → `toDouble()`; `String` → `double.tryParse`; anything else → `null` |
| `_asBoolFlag(dynamic)` | `1` / `"1"` / `true` → `true`; everything else including `null` → `false` |

`_asBoolFlag` is deliberately asymmetric: absent means `false` for `book_today` (FR-035), and any
unrecognised value is treated as `false` rather than throwing.

### Completing a partial branch (Phase 7)

A partial branch has no `workTime`, so the time guard cannot run against it. Phase 7 completes it
by id from the full branch list before any work-hours check:

```text
Branch complete(Branch partial, List<Branch> full) =>
    full.firstWhereOrNull((b) => b.id == partial.id) ?? partial;
```

Because equality is on `id`, `complete(p, full) == p` is always true — completion swaps detail, not
identity. **If no match is found the partial is returned unchanged and the time guard fails open.**
That is intended (Principle IV) and is recorded as a known risk in the plan: a partial branch never
blocks a time, leaving `POST /available/time` as the only check in that flow.

---

## `BranchWorkTime`

Parses the `work_time` object.

```text
class BranchWorkTime {
  final bool openAllDays;             // top-level "openAllDays", int 1/0
  final BranchWorkDay? allDays;       // "alldays"
  final Map<int, BranchWorkDay> byWeekday;  // DateTime.monday..DateTime.sunday
  bool isOpenAt(DateTime dt);
}

class BranchWorkDay {
  final int? period;
  final TimeWindow? morning;          // "morning"
  final TimeWindow? afternoon;        // parsed from "afternone" — API misspelling
  final bool locked;                  // "lock" == "1" (or 1) ⇒ closed
}

class TimeWindow {
  final String? open;                 // "timeopen",  may be null
  final String? close;                // "timeclose", may be null
}
```

**Key mapping**: the JSON keys `alldays`, `fri`, `sat`, `sun`, `mon`, `tue`, `wed`, `thu` map to
`DateTime.friday`, `.saturday`, `.sunday`, `.monday`, `.tuesday`, `.wednesday`, `.thursday`.
`alldays` is stored separately, not as a weekday.

**The `afternone` misspelling is read verbatim from JSON and named `afternoon` in Dart.** FR-036 —
never normalise or "correct" the backend key.

Note that **every day key is parsed with the same shape**. The current model parses only `lock` for
six of the eight keys ([R7](./research.md)), so this is a deliberate widening.

### `isOpenAt(DateTime dt)` — resolution order

1. If the object failed to parse at all (`workTime == null`) → **`true`**.
2. Resolve the day: `byWeekday[dt.weekday]`, falling back to `allDays`.
   - If neither exists → **`true`** (no data for this day; fail open).
3. If the resolved day is `locked` → **`false`**. This is the one case where absence of doubt
   produces a block: `lock: "1"` is an explicit statement that the branch is closed (FR-025).
4. Collect the day's windows (`morning`, `afternoon`). Discard any window whose `open` or `close`
   is null or unparseable — **that window contributes nothing; the other window on the same day
   still applies.**
5. If no usable window survives:
   - `openAllDays == true` → **`true`**
   - otherwise → **`true`** (unparseable hours; fail open, Principle IV)
6. Otherwise → `true` if `dt`'s time-of-day falls inside any surviving window.

### Midnight-crossing windows

A window where `close <= open` (e.g. open `21:00`, close `03:00`) is **one continuous period**, not
an empty or inverted one (FR-026). Containment is:

```text
if (close > open)  inside = t >= open && t <  close;   // normal
else               inside = t >= open || t <  close;   // crosses midnight
```

A window with `open == close` is treated as crossing — i.e. open all day — rather than as a
zero-length window. Fail open.

### Fail-open summary — Principle IV

`isOpenAt` returns `true` for: a null/absent `work_time`; a malformed `work_time`; a day with no
entry and no `alldays` fallback; a day whose windows are all null or unparseable; a partial branch
(no `workTime` at all). It returns `false` only for an explicit `lock`, or for a time that falls
outside at least one well-formed window on a day that has one.

---

## `Paginated<T>`

From the `{data, links, meta}` envelope.

| Field | Type | Source | Notes |
|---|---|---|---|
| `data` | `List<T>` | `data` | Empty list when absent, never null. |
| `currentPage` | `int` | `meta.current_page` | Defaults to `1`. |
| `lastPage` | `int` | `meta.last_page` | Defaults to `1`. **The only correct stopping condition.** |
| `total` | `int` | `meta.total` | Defaults to `data.length`. Used to satisfy SC-003. |

`links` is not modelled — it is unused, and the car endpoint omits it entirely
([R3](./research.md)).

**Tolerant construction**: `Paginated.fromJson(json, itemParser)` accepts

- a data-wrapped object `{ "data": [...], "meta": {...} }`
- a data-wrapped object with no `meta` (the car endpoint) → single page
- a **bare list** `[...]` → single page, `total = length`

The bare-list branch is currently unreachable but is required by the architecture, because the car
endpoint is the least evidenced of the three.

---

## `LocationFilter`

`lib/modules/location/data/location_filter.dart` — not a model, but the type that makes "one list
per concept" work.

| Field | Type | Notes |
|---|---|---|
| `regionId` | `int?` | **Daily and monthly only.** |
| `homeDelivery` | `bool` | Default `false`. |
| `airport` | `bool` | Default `false`. |
| `carId` | `int?` | |

**`regionId` applies ONLY to the region-filtered list.** Delivery, airport, and car requests are
**not** region-scoped — verified on-device. A `regions` param must never accompany
`home_delivery=1`, `airport=1`, or a car request.

`const`-constructible. **`==` and `hashCode` over all four fields** — unlike the models. A filter is
a value, not an entity.

**`cacheKey`** — a fixed-order join so the string is stable across app runs and two equal filters
always produce one key:

```text
'r=${regionId ?? "_"}|hd=${homeDelivery ? 1 : 0}|ap=${airport ? 1 : 0}|car=${carId ?? "_"}'
```

Named constructors express the five flows without leaving the caller to assemble flag combinations:

| Constructor | Flow | Produces |
|---|---|---|
| `LocationFilter.region(int id)` | daily, monthly | `r=<id>\|hd=0\|ap=0\|car=_` |
| `LocationFilter.allRegions()` | dropoff fallback, daily/monthly with no region yet | `r=_\|hd=0\|ap=0\|car=_` |
| `LocationFilter.delivery()` | delivery | `r=_\|hd=1\|ap=0\|car=_` |
| `LocationFilter.airport()` | airport | `r=_\|hd=0\|ap=1\|car=_` |
| `LocationFilter.car(int carId)` | book-from-car | `r=_\|hd=0\|ap=0\|car=<id>` |

`delivery()`, `airport()` and `car()` take no `regionId` **by construction**, which is how the
"never send `regions` alongside them" rule is made unbreakable rather than merely documented.

---

## `LocationSelectionState`

`lib/modules/location/presentaion/bloc/location_selection_state.dart`. Immutable, `Equatable`,
`copyWith`. Full transition rules in
[contracts/cubit-state-machine.md](./contracts/cubit-state-machine.md).

| Field | Type | Meaning |
|---|---|---|
| `pickupRegion` | `Region?` | |
| `dropoffRegion` | `Region?` | **`null` means: same as pickup.** |
| `pickupBranch` | `Branch?` | |
| `dropoffBranch` | `Branch?` | **`null` means: same as pickup.** |
| `pickupOptions` | `List<Branch>` | Never null; empty is a valid, distinguishable state. |
| `dropoffOptions` | `List<Branch>` | |
| `status` | `Status` | `initial`, `loading`, `ready`, `failure` |
| `separateDropoff` | `bool` | Whether the renter enabled a separate dropoff. |
| `error` | `String?` | Set with `failure`, for the retry UI required by FR-038. |

`separateDropoff` is carried explicitly rather than inferred from `dropoffRegion != null`, because
"enabled but nothing chosen yet" (FR-013 — the pickup region applies) and "not enabled" (FR-015 —
nothing is submitted) are different states that would otherwise be indistinguishable.

---

## `BookingDraft` (Phase 8)

Immutable, constructed by the booking screen when selection completes, passed onward as a
**constructor parameter**. Additions and payment **read** it. There are no setters and no
`copyWith` exposed to those screens.

| Field | Type |
|---|---|
| `pickupBranch` | `Branch` |
| `dropoffBranch` | `Branch?` (null ⇒ same as pickup) |
| `pickupAt` | `DateTime` |
| `dropoffAt` | `DateTime` |
| `car` | the existing car model, unchanged |

Navigating back destroys it — **that is how the selection clears, with no clearing code** (FR-017,
FR-020).
