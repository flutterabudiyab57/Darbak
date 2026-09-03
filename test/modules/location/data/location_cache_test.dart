import 'dart:convert';
import 'dart:io';

import 'package:darbak/modules/location/data/location_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

// LocationCache opens its own Hive box internally with no injection point,
// so these tests exercise the real box rather than a mock. Each test uses a
// unique key to avoid cross-test interference within the shared box.

void main() {
  late Directory tempDir;
  late LocationCache cache;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('location_cache_test');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() {
    cache = LocationCache();
  });

  Future<Box> box() async {
    if (Hive.isBoxOpen('location_cache')) return Hive.box('location_cache');
    return Hive.openBox('location_cache');
  }

  test('read on a missing key is a miss', () async {
    final result = await cache.read('missing:key');
    expect(result, isNull);
  });

  test('write then read is a hit and returns the same payload', () async {
    await cache.write('hit:key', '{"foo":"bar"}');
    final result = await cache.read('hit:key');
    expect(result, '{"foo":"bar"}');
  });

  test('an expired entry is a miss via read, but readStale still returns it', () async {
    final b = await box();
    final expiredTs = DateTime.now()
        .subtract(const Duration(hours: 25)) // older than the 24h regions TTL
        .millisecondsSinceEpoch;
    await b.put(
      'regions:expired',
      json.encode({'ts': expiredTs, 'payload': 'stale-payload'}),
    );

    expect(await cache.read('regions:expired'), isNull);
    expect(await cache.readStale('regions:expired'), 'stale-payload');
  });

  test('readStale ignores TTL entirely for a fresh entry too', () async {
    await cache.write('fresh:key', 'fresh-payload');
    expect(await cache.readStale('fresh:key'), 'fresh-payload');
  });

  test('a corrupted entry (malformed JSON) is a miss on read, not an exception', () async {
    final b = await box();
    await b.put('corrupt:read', 'this is not valid json{{{');

    expect(() => cache.read('corrupt:read'), returnsNormally);
    expect(await cache.read('corrupt:read'), isNull);
  });

  test('a corrupted entry (malformed JSON) is a miss on readStale, not an exception', () async {
    final b = await box();
    await b.put('corrupt:stale', 'this is not valid json{{{');

    expect(() => cache.readStale('corrupt:stale'), returnsNormally);
    expect(await cache.readStale('corrupt:stale'), isNull);
  });

  test('an entry missing its ts or payload field is a miss, not an exception', () async {
    final b = await box();
    await b.put('incomplete:key', json.encode({'ts': null, 'payload': 'x'}));

    expect(await cache.read('incomplete:key'), isNull);
  });

  test('write never throws for ordinary string payloads', () async {
    expect(() => cache.write('write:normal', 'a plain payload'), returnsNormally);
    await cache.write('write:normal', 'a plain payload');
    expect(await cache.read('write:normal'), 'a plain payload');
  });
}
