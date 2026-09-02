# Contract: `LocationCache` and `LocationRepository`

## `LocationCache`

`lib/modules/location/data/location_cache.dart`

```text
class LocationCache {
  Future<String?> read(String key);            // null on miss, expiry, or ANY failure
  Future<void> write(String key, String payloadJson);
  Future<String?> readStale(String key);       // ignores TTL; used only on network failure
}
```

### Storage

| Aspect | Value |
|---|---|
| Package | **`hive_ce` / `hive_ce_flutter`.** Never `package:hive` or `package:hive_flutter`. |
| Box | `"location_cache"` — a single box, opened lazily on first use |
| Format | **Raw JSON strings.** No TypeAdapters, no `@HiveType`, no `build_runner` |
| Value | `{ "ts": <epochMillis>, "payload": <raw json string> }` |

Lazy opening is deliberate: `main.dart`'s boot block swallows exceptions silently in release, so an
`openBox` failure there would be invisible. Opening inside `LocationCache` puts the failure inside
the try/catch that is already required to swallow it.

### Keys

```text
regions:<lang>
branches:<lang>:<filter.cacheKey>
```

`<lang>` comes from the module's single language resolver — the same value the datasource sends as
`Accept-Language` ([R5](../research.md)). **Language in the key means a language switch is a
natural cache miss requiring no manual invalidation** (constitution, Caching).

### TTL

| Data | TTL |
|---|---|
| regions | **24h** |
| branches | **6h** |

`read` returns `null` once `now - ts > ttl`. The entry is **not** deleted on expiry — `readStale`
needs it for the network-failure path below.

### Failure policy

**Every operation is wrapped in try/catch. A cache failure NEVER reaches the caller.** `read` and
`readStale` return `null`; `write` returns normally having done nothing. A corrupt entry, a closed
box, a full disk, and a JSON decode failure are all indistinguishable from a miss, by design — the
caller falls through to the network.

## `LocationRepository`

`lib/modules/location/data/location_repository.dart`

```text
class LocationRepository {
  Future<List<Region>> getRegions({bool forceRefresh = false});
  Future<List<Branch>> getBranches(LocationFilter filter, {bool forceRefresh = false});
}
```

### Resolution order

```text
1. forceRefresh?          → skip to 3
2. cache.read(key)        → hit? decode and return
3. remote fetch
   ├─ success             → cache.write(key, raw); return
   └─ failure
      ├─ cache.readStale(key) non-null → return STALE data
      └─ otherwise                     → rethrow
```

**The stale fallback applies only when the network fails and an expired entry exists.** It is not a
general staleness tolerance: a fresh miss with a dead network still throws, so the screen can show
the message and retry that FR-038 requires.

A decode failure on cached JSON is treated as a miss (the cache contract makes it indistinguishable
from one) and falls through to the network.

### Contract tests (Phase 1)

| Test | Asserts |
|---|---|
| `cache hit skips the network` | remote is never called |
| `cache miss fetches and writes` | remote called once, `write` called with the raw payload |
| `expired entry refetches` | `ts` older than TTL ⇒ remote called |
| `forceRefresh bypasses a fresh cache` | remote called despite a valid entry |
| `network failure with expired entry returns stale` | returns the stale list, does not throw |
| `network failure with no entry rethrows` | throws |
| `cache read throwing is a miss` | falls through to remote, does not propagate |
| `cache write throwing is swallowed` | caller still receives the fetched data |
| `different languages use different keys` | `ar` and `en` do not collide |
| `different filters use different keys` | region 7 and region 8 do not collide |
| `delivery and airport keys differ` | `hd=1` and `ap=1` do not collide |
