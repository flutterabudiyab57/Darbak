import 'package:equatable/equatable.dart';

import '../../data/models/branch.dart';
import '../../data/models/region.dart';

enum LocationSelectionStatus { initial, loading, ready, failure }

/// Internal marker distinguishing "argument not supplied" from "argument
/// supplied as null" for [LocationSelectionState.copyWith]'s `error` field —
/// the one nullable field copyWith IS allowed to clear.
const Object _unset = Object();

/// Immutable selection state for the region/branch picking flow.
///
/// `dropoffRegion == null` / `dropoffBranch == null` means "same as pickup"
/// (FR-013), not "not loaded yet" — there is no separate loading flag for
/// dropoff.
///
/// [copyWith] deliberately has NO parameter for [pickupBranch],
/// [dropoffBranch], or [dropoffRegion]. `copyWith(x: null)` is a silent
/// no-op under the usual idiom — the implementation cannot tell "not
/// supplied" from "supplied as null" — and that is the single most likely
/// path back to the stale-dropoff bug this rewrite exists to eliminate.
/// Those three fields are set and cleared only through the named
/// transformers below.
///
/// [languageCode] — what this state MEANS is not "these branches are
/// selected", it is "these branches are selected, rendered in this
/// language". Without it, a language-only refresh (same ids, same list
/// order, only display names changed) produces a state that is genuinely
/// `==` the previous one under Principle I's id-only equality on
/// [Branch]/[Region] — bloc's built-in equal-state dedup (Principle III)
/// then correctly, silently drops the emit, and the UI never sees the
/// refreshed names (see `contracts/cubit-state-machine.md` for the full
/// writeup, including the rejected alternatives). Carrying the language in
/// the state makes the two states actually different, so the emit goes
/// through under the ordinary equality rules — this is not a revision
/// counter: it holds real, user-visible meaning, and changes only when the
/// language actually changes.
class LocationSelectionState extends Equatable {
  final Region? pickupRegion;
  final Region? dropoffRegion;
  final Branch? pickupBranch;
  final Branch? dropoffBranch;
  final List<Branch> pickupOptions;
  final List<Branch> dropoffOptions;
  final LocationSelectionStatus status;
  final bool separateDropoff;
  final String? error;
  final String languageCode;

  const LocationSelectionState({
    this.pickupRegion,
    this.dropoffRegion,
    this.pickupBranch,
    this.dropoffBranch,
    this.pickupOptions = const [],
    this.dropoffOptions = const [],
    this.status = LocationSelectionStatus.initial,
    this.separateDropoff = false,
    this.error,
    this.languageCode = 'ar',
  });

  /// Cannot set or clear [pickupBranch], [dropoffBranch], or [dropoffRegion]
  /// — use the named transformers instead.
  LocationSelectionState copyWith({
    Region? pickupRegion,
    List<Branch>? pickupOptions,
    List<Branch>? dropoffOptions,
    LocationSelectionStatus? status,
    bool? separateDropoff,
    Object? error = _unset,
    String? languageCode,
  }) {
    return LocationSelectionState(
      pickupRegion: pickupRegion ?? this.pickupRegion,
      dropoffRegion: dropoffRegion,
      pickupBranch: pickupBranch,
      dropoffBranch: dropoffBranch,
      pickupOptions: pickupOptions ?? this.pickupOptions,
      dropoffOptions: dropoffOptions ?? this.dropoffOptions,
      status: status ?? this.status,
      separateDropoff: separateDropoff ?? this.separateDropoff,
      error: identical(error, _unset) ? this.error : error as String?,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  LocationSelectionState withPickupBranch(Branch branch) => LocationSelectionState(
    pickupRegion: pickupRegion,
    dropoffRegion: dropoffRegion,
    pickupBranch: branch,
    dropoffBranch: dropoffBranch,
    pickupOptions: pickupOptions,
    dropoffOptions: dropoffOptions,
    status: status,
    separateDropoff: separateDropoff,
    error: error,
    languageCode: languageCode,
  );

  LocationSelectionState clearPickupBranch() => LocationSelectionState(
    pickupRegion: pickupRegion,
    dropoffRegion: dropoffRegion,
    pickupBranch: null,
    dropoffBranch: dropoffBranch,
    pickupOptions: pickupOptions,
    dropoffOptions: dropoffOptions,
    status: status,
    separateDropoff: separateDropoff,
    error: error,
    languageCode: languageCode,
  );

  LocationSelectionState withDropoffBranch(Branch branch) => LocationSelectionState(
    pickupRegion: pickupRegion,
    dropoffRegion: dropoffRegion,
    pickupBranch: pickupBranch,
    dropoffBranch: branch,
    pickupOptions: pickupOptions,
    dropoffOptions: dropoffOptions,
    status: status,
    separateDropoff: separateDropoff,
    error: error,
    languageCode: languageCode,
  );

  LocationSelectionState clearDropoffBranch() => LocationSelectionState(
    pickupRegion: pickupRegion,
    dropoffRegion: dropoffRegion,
    pickupBranch: pickupBranch,
    dropoffBranch: null,
    pickupOptions: pickupOptions,
    dropoffOptions: dropoffOptions,
    status: status,
    separateDropoff: separateDropoff,
    error: error,
    languageCode: languageCode,
  );

  LocationSelectionState withDropoffRegion(Region region) => LocationSelectionState(
    pickupRegion: pickupRegion,
    dropoffRegion: region,
    pickupBranch: pickupBranch,
    dropoffBranch: dropoffBranch,
    pickupOptions: pickupOptions,
    dropoffOptions: dropoffOptions,
    status: status,
    separateDropoff: separateDropoff,
    error: error,
    languageCode: languageCode,
  );

  /// Clears [dropoffRegion] AND [dropoffBranch] together, as one object —
  /// never as two sequential transformers. Two emits would mean an
  /// intermediate state exists in which a dropoff branch is held with no
  /// region: briefly submittable, and exactly the shape of the defect
  /// FR-015 names.
  LocationSelectionState clearDropoff() => LocationSelectionState(
    pickupRegion: pickupRegion,
    dropoffRegion: null,
    pickupBranch: pickupBranch,
    dropoffBranch: null,
    pickupOptions: pickupOptions,
    dropoffOptions: dropoffOptions,
    status: status,
    separateDropoff: separateDropoff,
    error: error,
    languageCode: languageCode,
  );

  @override
  List<Object?> get props => [
    pickupRegion,
    dropoffRegion,
    pickupBranch,
    dropoffBranch,
    pickupOptions,
    dropoffOptions,
    status,
    separateDropoff,
    error,
    languageCode,
  ];
}
