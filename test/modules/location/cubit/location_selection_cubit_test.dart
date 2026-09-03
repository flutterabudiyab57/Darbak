import 'package:bloc_test/bloc_test.dart';
import 'package:darbak/core/constants/langCode.dart' as global_lang;
import 'package:darbak/modules/location/data/location_filter.dart';
import 'package:darbak/modules/location/data/location_repository.dart';
import 'package:darbak/modules/location/data/models/branch.dart';
import 'package:darbak/modules/location/data/models/region.dart';
import 'package:darbak/modules/location/presentaion/bloc/location_selection_cubit.dart';
import 'package:darbak/modules/location/presentaion/bloc/location_selection_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

Region fakeRegion({int id = 1, String name = 'Region'}) => Region(id: id, name: name);

Branch fakeBranch({int id = 1, String name = 'Branch', bool isPartial = false}) =>
    Branch(id: id, name: name, isPartial: isPartial);

void main() {
  setUpAll(() {
    registerFallbackValue(const LocationFilter.allRegions());
  });

  late MockLocationRepository repo;

  setUp(() {
    repo = MockLocationRepository();
  });

  tearDown(() {
    global_lang.langCode = '';
  });

  group('start', () {
    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'on a region flow fetches regions, not branches',
      setUp: () {
        when(() => repo.getRegions()).thenAnswer((_) async => [fakeRegion()]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) => c.start(const LocationFilter.allRegions()),
      expect: () => [
        const LocationSelectionState(status: LocationSelectionStatus.loading),
        const LocationSelectionState(status: LocationSelectionStatus.ready),
      ],
      verify: (_) {
        verifyNever(() => repo.getBranches(any()));
      },
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'on delivery fetches branches directly',
      setUp: () {
        when(() => repo.getBranches(any())).thenAnswer((_) async => [fakeBranch()]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) => c.start(const LocationFilter.delivery()),
      expect: () => [
        const LocationSelectionState(status: LocationSelectionStatus.loading),
        LocationSelectionState(
          status: LocationSelectionStatus.ready,
          pickupOptions: [fakeBranch()],
          dropoffOptions: [fakeBranch()],
        ),
      ],
      verify: (_) {
        verifyNever(() => repo.getRegions());
      },
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'on airport fetches branches directly',
      setUp: () {
        when(() => repo.getBranches(any())).thenAnswer((_) async => [fakeBranch()]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) => c.start(const LocationFilter.airport()),
      expect: () => [
        const LocationSelectionState(status: LocationSelectionStatus.loading),
        LocationSelectionState(
          status: LocationSelectionStatus.ready,
          pickupOptions: [fakeBranch()],
          dropoffOptions: [fakeBranch()],
        ),
      ],
      verify: (_) {
        verifyNever(() => repo.getRegions());
      },
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'on car fetches the car list directly, all partial',
      setUp: () {
        when(() => repo.getBranches(any())).thenAnswer(
          (_) async => [fakeBranch(id: 1, isPartial: true), fakeBranch(id: 2, isPartial: true)],
        );
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) => c.start(const LocationFilter.car(9)),
      verify: (c) {
        expect(c.state.status, LocationSelectionStatus.ready);
        expect(c.state.pickupOptions.every((b) => b.isPartial), isTrue);
        expect(c.state.dropoffOptions.every((b) => b.isPartial), isTrue);
      },
    );
  });

  group('selectPickupRegion', () {
    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'clears the pickup branch',
      setUp: () {
        when(() => repo.getBranches(any())).thenAnswer((_) async => [fakeBranch(id: 5)]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        c.setPickupBranch(fakeBranch(id: 5));
        await c.selectPickupRegion(fakeRegion(id: 1));
      },
      verify: (c) {
        expect(c.state.pickupBranch, isNull);
      },
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'replaces the options list, does not append',
      setUp: () {
        var call = 0;
        when(() => repo.getBranches(any())).thenAnswer((_) async {
          call++;
          return call == 1 ? [fakeBranch(id: 1)] : [fakeBranch(id: 2)];
        });
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        await c.selectPickupRegion(fakeRegion(id: 1));
        await c.selectPickupRegion(fakeRegion(id: 2));
      },
      verify: (c) {
        expect(c.state.pickupOptions.map((b) => b.id).toList(), [2]);
      },
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'dropoff with no region mirrors the pickup list',
      setUp: () {
        when(() => repo.getBranches(any())).thenAnswer((_) async => [fakeBranch(id: 3)]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) => c.selectPickupRegion(fakeRegion(id: 1)),
      verify: (c) {
        expect(c.state.dropoffOptions, c.state.pickupOptions);
      },
    );
  });

  group('selectDropoffRegion', () {
    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'does not touch the pickup branch',
      setUp: () {
        when(() => repo.getBranches(any())).thenAnswer((_) async => [fakeBranch(id: 1)]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        c.setPickupBranch(fakeBranch(id: 42));
        await c.selectDropoffRegion(fakeRegion(id: 2));
      },
      verify: (c) {
        expect(c.state.pickupBranch?.id, 42);
      },
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'clears the dropoff branch',
      setUp: () {
        when(() => repo.getBranches(any())).thenAnswer((_) async => [fakeBranch(id: 1)]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        c.setDropoffBranch(fakeBranch(id: 99));
        await c.selectDropoffRegion(fakeRegion(id: 2));
      },
      verify: (c) {
        expect(c.state.dropoffBranch, isNull);
      },
    );
  });

  group('setSeparateDropoff', () {
    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'disabling dropoff clears region and branch in ONE emit',
      build: () => LocationSelectionCubit(repo),
      seed: () => LocationSelectionState(
        separateDropoff: true,
        dropoffRegion: fakeRegion(id: 2),
        dropoffBranch: fakeBranch(id: 20),
      ),
      act: (c) => c.setSeparateDropoff(false),
      expect: () => [
        predicate<LocationSelectionState>(
          (s) => s.dropoffRegion == null && s.dropoffBranch == null && s.separateDropoff == false,
        ),
      ],
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'disabling dropoff leaves pickup untouched',
      build: () => LocationSelectionCubit(repo),
      seed: () => LocationSelectionState(
        pickupRegion: fakeRegion(id: 1),
        pickupBranch: fakeBranch(id: 7),
        separateDropoff: true,
      ),
      act: (c) => c.setSeparateDropoff(false),
      verify: (c) {
        expect(c.state.pickupRegion?.id, 1);
        expect(c.state.pickupBranch?.id, 7);
      },
    );
  });

  group('onLanguageChanged', () {
    // Covers a real language switch (en → ar): selection preserved by id,
    // display name updated to the new language. Contrast with the ar→en test
    // below, which also verifies languageCode and the exactly-ONE-emit
    // guarantee via skip+predicate.
    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'preserves selection by id, with the new name',
      setUp: () {
        // Start in English so the language switch to Arabic is a real signal
        // change that makes the emitted state genuinely != its predecessor.
        global_lang.langCode = 'en';
        // Bare calls (no forceRefresh) come from start()/selectPickupRegion();
        // the forceRefresh:true calls come only from onLanguageChanged() —
        // mocktail matches on the exact call shape, so these need separate stubs.
        when(() => repo.getRegions()).thenAnswer((_) async => [fakeRegion(id: 1, name: 'Riyadh')]);
        when(() => repo.getRegions(forceRefresh: true))
            .thenAnswer((_) async => [fakeRegion(id: 1, name: 'الرياض')]);
        when(() => repo.getBranches(any())).thenAnswer((_) async => [fakeBranch(id: 7, name: 'Main')]);
        when(() => repo.getBranches(any(), forceRefresh: true))
            .thenAnswer((_) async => [fakeBranch(id: 7, name: 'الرئيسي')]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        await c.start(const LocationFilter.allRegions());
        await c.selectPickupRegion(fakeRegion(id: 1));
        c.setPickupBranch(fakeBranch(id: 7, name: 'Main'));
        global_lang.langCode = 'ar'; // the actual language switch
        await c.onLanguageChanged();
      },
      verify: (c) {
        expect(c.state.pickupBranch?.id, 7);
        expect(c.state.pickupBranch?.name, 'الرئيسي');
        expect(c.state.status, LocationSelectionStatus.ready);
      },
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'preserves selection when the branch moved list position',
      setUp: () {
        when(() => repo.getRegions()).thenAnswer((_) async => [fakeRegion(id: 1)]);
        when(() => repo.getRegions(forceRefresh: true)).thenAnswer((_) async => [fakeRegion(id: 1)]);
        when(() => repo.getBranches(any()))
            .thenAnswer((_) async => [fakeBranch(id: 7, name: 'A'), fakeBranch(id: 8, name: 'B')]);
        // Reordered on the refetch: id 7 now comes second.
        when(() => repo.getBranches(any(), forceRefresh: true)).thenAnswer(
          (_) async => [fakeBranch(id: 8, name: 'B-ar'), fakeBranch(id: 7, name: 'A-ar')],
        );
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        await c.start(const LocationFilter.allRegions());
        await c.selectPickupRegion(fakeRegion(id: 1));
        c.setPickupBranch(fakeBranch(id: 7, name: 'A'));
        await c.onLanguageChanged();
      },
      verify: (c) {
        expect(c.state.pickupBranch?.id, 7);
        expect(c.state.pickupBranch?.name, 'A-ar');
      },
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'a branch missing from the new list is cleared, status stays ready',
      setUp: () {
        when(() => repo.getRegions()).thenAnswer((_) async => [fakeRegion(id: 1)]);
        when(() => repo.getRegions(forceRefresh: true)).thenAnswer((_) async => [fakeRegion(id: 1)]);
        when(() => repo.getBranches(any())).thenAnswer((_) async => [fakeBranch(id: 7, name: 'A')]);
        when(() => repo.getBranches(any(), forceRefresh: true))
            .thenAnswer((_) async => [fakeBranch(id: 99, name: 'Different Branch')]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        await c.start(const LocationFilter.allRegions());
        await c.selectPickupRegion(fakeRegion(id: 1));
        c.setPickupBranch(fakeBranch(id: 7, name: 'A'));
        await c.onLanguageChanged();
      },
      verify: (c) {
        expect(c.state.pickupBranch, isNull);
        expect(c.state.status, LocationSelectionStatus.ready);
      },
    );

    // Covers a real language switch (ar → en): opposite direction from the
    // en→ar test above. Also explicitly asserts the languageCode field in the
    // emitted state and — via skip+predicate — that exactly ONE state is
    // emitted by the language change itself (no extra interim state).
    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'a language change from ar to en emits exactly ONE state, with the '
      'new languageCode and the selected branch carrying the new name at '
      'the same id',
      setUp: () {
        global_lang.langCode = 'ar';
        when(() => repo.getRegions()).thenAnswer((_) async => [fakeRegion(id: 1)]);
        when(() => repo.getRegions(forceRefresh: true)).thenAnswer((_) async => [fakeRegion(id: 1)]);
        when(() => repo.getBranches(any()))
            .thenAnswer((_) async => [fakeBranch(id: 7, name: 'الرئيسي')]);
        when(() => repo.getBranches(any(), forceRefresh: true))
            .thenAnswer((_) async => [fakeBranch(id: 7, name: 'Main')]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        // Prior emissions: start() -> [loading, ready] (2), selectPickupRegion()
        // -> [loading, ready] (2), setPickupBranch() -> [1]. Five states before
        // the language change itself, skipped below so `expect` isolates it.
        await c.start(const LocationFilter.allRegions());
        await c.selectPickupRegion(fakeRegion(id: 1));
        c.setPickupBranch(fakeBranch(id: 7, name: 'الرئيسي'));
        global_lang.langCode = 'en';
        await c.onLanguageChanged();
      },
      skip: 5,
      expect: () => [
        predicate<LocationSelectionState>(
          (s) =>
              s.languageCode == 'en' &&
              s.pickupBranch?.id == 7 &&
              s.pickupBranch?.name == 'Main',
        ),
      ],
    );

    // BD-3 known residual (see plan.md § BD-3 and contracts/cubit-state-machine.md).
    // A backend rename with NO language change — same langCode before and after —
    // is NOT reflected in the UI. The re-resolved next-state carries the new name
    // from the mock but is otherwise identical: same languageCode, same id. Because
    // Branch equality is id-only (Principle I) and languageCode is unchanged,
    // Equatable sees the two states as equal, and bloc's built-in dedup
    // (Principle III) silently drops the emit. This is accepted behaviour.
    blocTest<LocationSelectionCubit, LocationSelectionState>(
      '(BD-3 accepted residual) a backend rename with no language change '
      'produces no new state — dedup swallows the emit',
      setUp: () {
        global_lang.langCode = 'ar'; // language never changes in this test
        when(() => repo.getRegions()).thenAnswer((_) async => [fakeRegion(id: 1)]);
        when(() => repo.getRegions(forceRefresh: true)).thenAnswer((_) async => [fakeRegion(id: 1)]);
        when(() => repo.getBranches(any()))
            .thenAnswer((_) async => [fakeBranch(id: 7, name: 'الرئيسي')]);
        // Backend renamed the branch — same id, same language, different name.
        when(() => repo.getBranches(any(), forceRefresh: true))
            .thenAnswer((_) async => [fakeBranch(id: 7, name: 'الفرع الجديد')]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        await c.start(const LocationFilter.allRegions());
        await c.selectPickupRegion(fakeRegion(id: 1));
        c.setPickupBranch(fakeBranch(id: 7, name: 'الرئيسي'));
        // langCode is NOT changed — this simulates a backend rename only.
        await c.onLanguageChanged();
      },
      // Skip the 5 setup states; the language-change emit is deduped → zero
      // additional states. The picker still shows the old name.
      skip: 5,
      expect: () => [],
    );
  });

  group('failure and retry', () {
    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'fetch failure preserves existing selections',
      setUp: () {
        when(() => repo.getBranches(any())).thenAnswer((_) async => [fakeBranch(id: 1)]);
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        await c.start(const LocationFilter.delivery());
        c.setPickupBranch(fakeBranch(id: 1));
        when(() => repo.getBranches(any())).thenThrow(Exception('network down'));
        await c.selectDropoffRegion(fakeRegion(id: 2));
      },
      verify: (c) {
        expect(c.state.pickupBranch?.id, 1);
        expect(c.state.status, LocationSelectionStatus.failure);
      },
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'retry after failure restores ready',
      setUp: () {
        var call = 0;
        when(() => repo.getRegions()).thenAnswer((_) async {
          call++;
          if (call == 1) throw Exception('network down');
          return [fakeRegion()];
        });
      },
      build: () => LocationSelectionCubit(repo),
      act: (c) async {
        await c.start(const LocationFilter.allRegions());
        await c.retry();
      },
      verify: (c) {
        expect(c.state.status, LocationSelectionStatus.ready);
      },
    );
  });

  group('equality and dedup', () {
    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'no duplicate consecutive states — an equal emit produces nothing',
      build: () => LocationSelectionCubit(repo),
      act: (c) {
        c.setPickupBranch(fakeBranch(id: 1, name: 'First'));
        // Same id, different name — an equal state under id-only equality.
        c.setPickupBranch(fakeBranch(id: 1, name: 'Second'));
      },
      expect: () => [
        const LocationSelectionState().withPickupBranch(fakeBranch(id: 1, name: 'First')),
      ],
    );

    blocTest<LocationSelectionCubit, LocationSelectionState>(
      'two branches with the same id are one selection',
      build: () => LocationSelectionCubit(repo),
      act: (c) {
        c.setPickupBranch(fakeBranch(id: 4, name: 'X'));
        c.setPickupBranch(fakeBranch(id: 4, name: 'Y'));
      },
      expect: () => [
        const LocationSelectionState().withPickupBranch(fakeBranch(id: 4, name: 'X')),
      ],
      verify: (c) {
        expect(c.state.pickupBranch, fakeBranch(id: 4, name: 'anything'));
      },
    );
  });
}
