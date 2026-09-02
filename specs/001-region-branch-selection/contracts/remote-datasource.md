# Contract: `LocationRemoteDataSource`

`lib/modules/location/data/location_remote_datasource.dart`

```text
class LocationRemoteDataSource {
  LocationRemoteDataSource(this._dio);   // sl<Dio>() — the shared configured instance
  Future<List<Region>> getRegions();
  Future<List<Branch>> getBranches(LocationFilter filter);
}
```

## Transport

| Rule | Detail |
|---|---|
| Client | **`sl<Dio>()` only.** Registered at `lib/service_locator.dart:150`; `AppInterceptors` attached at `:151`. **Never `package:http`. Never a bare `Dio()`.** |
| Interceptor | Already provides `baseUrl = mainApi`, 120s timeouts, `Accept`/`Content-Type: application/json`, and `Authorization: Bearer <token>`. **Do not attach a second interceptor** — it would double-fire `onRequest`. |
| `Accept-Language` | Set **explicitly per request** from the module's single language resolver. Per-request headers win over the interceptor's, which sends the raw global `langCode` and can be empty at boot ([R5](../research.md)). The same resolved value builds the cache key. |
| Errors | `DioException` propagates to the repository. The datasource does not translate, retry, or swallow. `AppInterceptors.onError` is a pass-through — there is no global 401 handling. |

## `getRegions()`

`GET {mainApi}/regions`

Envelope `{data, links, meta}`. Nine regions, single page — **no pagination loop**. Parse each
element with `Region.fromJson`; drop elements without a usable integer `id`.

## `getBranches(LocationFilter filter)`

### Endpoint routing

Exactly one branch of this table applies, evaluated in this order:

| Condition | Request | Parser |
|---|---|---|
| `filter.carId != null` | `GET {mainApi}/available/branches/{carId}` | `Branch.fromCarBranchesApi` |
| `filter.homeDelivery` | `GET {mainApi}/branches?home_delivery=1&perPage=100` | `Branch.fromBranchesApi` |
| `filter.airport` | `GET {mainApi}/branches?airport=1&perPage=100` | `Branch.fromBranchesApi` |
| otherwise | `GET {mainApi}/branches?home_delivery=0&perPage=100`, plus `regions=<regionId>` **only when `regionId != null`** | `Branch.fromBranchesApi` |

### Query parameter rules

- **`perPage=100`** on every `/branches` call. Verified honoured server-side (a requested 100 came
  back as `per_page: 100`). Without it the server defaults to 15.
- **Never send a param with a null value — omit the key.** Build the map conditionally; do not pass
  `{'regions': null}` and rely on Dio to drop it.
- **`regions` is never sent alongside `home_delivery=1`, `airport=1`, or a car request.** The
  routing table makes this structural: those three cases never read `filter.regionId`. The
  `LocationFilter` named constructors make it unrepresentable in the first place
  ([data-model.md](../data-model.md#locationfilter)).
- The car endpoint takes **no** query parameters — no `perPage`, no `regions`.

### Pagination

```text
page 1  → parse Paginated<Branch>
lastPage = paginated.lastPage
for page in 2..min(lastPage, 10):
    fetch and append
```

- Driven by **`meta.last_page` read from page 1**. Never a hardcoded page count — the previous
  implementation's fixed 3-page loop and its page-1-only region fetch are exactly what hid branches
  from renters.
- **Hard cap 10 pages.** A server that reports a runaway `last_page` must not spin the client.
  Hitting the cap returns what was collected; it does not throw.
- Observed today: 48 branches, `last_page: 4` at the default 15/page — so at `perPage=100` this is
  a **single request**. The loop exists for correctness, not for the current data volume.
- Deduplicate by `id` when concatenating pages. Equality is on `id`, so a `Set<Branch>` or a
  `distinct`-by-id pass is enough. Guards against overlap if the server repaginates mid-sequence.

### Response shape tolerance

`Paginated.fromJson` accepts a data-wrapped object with `meta`, a data-wrapped object without
`meta`, and a **bare list**. The car endpoint is data-wrapped today with `{data, meta}` and no
`links` ([R3](../research.md)); the bare-list branch is required by the architecture regardless,
because that endpoint is the least evidenced of the three.

## Contract tests (Phase 1)

| Test | Asserts |
|---|---|
| `region filter sends regions and perPage` | query is exactly `{home_delivery: 0, perPage: 100, regions: 7}` |
| `no-region filter omits the regions key` | `'regions'` is **absent** from the query map, not present-and-null |
| `delivery filter never sends regions` | query is exactly `{home_delivery: 1, perPage: 100}` |
| `airport filter never sends regions` | query is exactly `{airport: 1, perPage: 100}` |
| `car filter hits the car path with no query` | path is `/available/branches/42`, query is empty |
| `car filter marks results partial` | every returned `Branch.isPartial == true` |
| `branches filter marks results complete` | every returned `Branch.isPartial == false` |
| `pagination follows meta.last_page` | `last_page: 3` ⇒ exactly 3 requests, pages 2 and 3 appended |
| `pagination caps at 10 pages` | `last_page: 50` ⇒ exactly 10 requests |
| `single page issues one request` | `last_page: 1` ⇒ no second request |
| `bare list response parses` | a top-level JSON array yields the branches, one page |
| `duplicate ids across pages collapse` | same id on pages 1 and 2 ⇒ one entry |
| `Accept-Language is sent explicitly` | header equals the resolver's value, not `''` |

Mocked with `mocktail` against a `Dio` double. No live network in tests.
