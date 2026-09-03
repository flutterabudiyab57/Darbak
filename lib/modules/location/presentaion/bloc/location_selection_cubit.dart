import 'package:bloc/bloc.dart';

import '../../data/location_filter.dart';
import '../../data/location_language.dart';
import '../../data/location_repository.dart';
import '../../data/models/branch.dart';
import '../../data/models/region.dart';
import 'location_selection_state.dart';

/// All region/branch selection rules for the booking flow live here, never
/// in a screen. Registered `registerFactory` — one instance per booking
/// attempt (Constitution Principle III/FR-017); a singleton is exactly the
/// defect this rewrite exists to close.
///
/// Holds no `BuildContext` and performs no navigation.
class LocationSelectionCubit extends Cubit<LocationSelectionState> {
  final LocationRepository _repository;

  LocationSelectionCubit(this._repository)
      : super(LocationSelectionState(languageCode: currentLocationLanguage()));

  LocationFilter? _baseFilter;
  List<Region> _regions = const [];
  Future<void> Function()? _retryAction;

  bool _isDirect(LocationFilter f) => f.homeDelivery || f.airport || f.carId != null;

  /// Called once, on screen mount. `f` is the flow's base filter —
  /// `.delivery()`, `.airport()`, `.car(id)`, or `.allRegions()` for
  /// daily/monthly. This is the single point where the flow's shape enters
  /// the cubit; nothing downstream branches on "which flow am I".
  Future<void> start(LocationFilter baseFilter) async {
    _baseFilter = baseFilter;
    _retryAction = () => start(baseFilter);

    emit(state.copyWith(status: LocationSelectionStatus.loading));
    try {
      if (_isDirect(baseFilter)) {
        // Delivery, airport, car: no region step. Both option lists are the
        // same fetch — there is nothing to filter them by region with.
        final options = await _repository.getBranches(baseFilter);
        emit(state.copyWith(
          status: LocationSelectionStatus.ready,
          pickupOptions: options,
          dropoffOptions: options,
        ));
      } else {
        final regions = await _repository.getRegions();
        _regions = regions;
        // pickupOptions stays empty — there is no branch list until a
        // region is chosen.
        emit(state.copyWith(status: LocationSelectionStatus.ready));
      }
    } catch (e) {
      emit(state.copyWith(status: LocationSelectionStatus.failure, error: e.toString()));
    }
  }

  Future<void> selectPickupRegion(Region region) async {
    _retryAction = () => selectPickupRegion(region);

    emit(
      state.clearPickupBranch().copyWith(
        pickupRegion: region,
        status: LocationSelectionStatus.loading,
      ),
    );
    try {
      final options = await _repository.getBranches(LocationFilter.region(region.id));
      final mirrorDropoff = state.dropoffRegion == null;
      emit(state.copyWith(
        status: LocationSelectionStatus.ready,
        pickupOptions: options,
        // If no dropoff region has been chosen, the pickup region's list
        // applies to dropoff too (FR-013).
        dropoffOptions: mirrorDropoff ? options : state.dropoffOptions,
      ));
    } catch (e) {
      emit(state.copyWith(status: LocationSelectionStatus.failure, error: e.toString()));
    }
  }

  /// Nothing else changes.
  void setPickupBranch(Branch branch) => emit(state.withPickupBranch(branch));

  void setSeparateDropoff(bool enabled) {
    if (enabled) {
      // The pickup region's list applies until a dropoff region is chosen.
      emit(state.copyWith(separateDropoff: true, dropoffOptions: state.pickupOptions));
      return;
    }

    // dropoffRegion AND dropoffBranch clear together, atomically, in one
    // emit — never as two sequential transformers.
    emit(state.clearDropoff().copyWith(separateDropoff: false));
  }

  Future<void> selectDropoffRegion(Region region) async {
    _retryAction = () => selectDropoffRegion(region);

    emit(
      state.withDropoffRegion(region).clearDropoffBranch().copyWith(
        status: LocationSelectionStatus.loading,
      ),
    );
    try {
      final options = await _repository.getBranches(LocationFilter.region(region.id));
      emit(state.copyWith(status: LocationSelectionStatus.ready, dropoffOptions: options));
    } catch (e) {
      emit(state.copyWith(status: LocationSelectionStatus.failure, error: e.toString()));
    }
  }

  void setDropoffBranch(Branch branch) => emit(state.withDropoffBranch(branch));

  /// Refetches every list currently held, then re-resolves the selected
  /// regions and branches BY ID against the refetched lists (FR-033). A
  /// selection missing from the new list is cleared rather than left
  /// stale or pointing at a now-wrong entity — but that is a normal
  /// successful outcome, not a fetch failure: `status` stays `ready`.
  Future<void> onLanguageChanged() async {
    final baseFilter = _baseFilter;
    if (baseFilter == null) return;
    _retryAction = onLanguageChanged;

    try {
      List<Region> newRegions = _regions;
      if (!_isDirect(baseFilter)) {
        newRegions = await _repository.getRegions(forceRefresh: true);
        _regions = newRegions;
      }

      List<Branch> newPickupOptions = state.pickupOptions;
      List<Branch> newDropoffOptions = state.dropoffOptions;

      if (_isDirect(baseFilter)) {
        newPickupOptions = await _repository.getBranches(baseFilter, forceRefresh: true);
        newDropoffOptions = newPickupOptions;
      } else {
        if (state.pickupRegion != null) {
          newPickupOptions = await _repository.getBranches(
            LocationFilter.region(state.pickupRegion!.id),
            forceRefresh: true,
          );
        }
        if (state.dropoffRegion != null) {
          newDropoffOptions = await _repository.getBranches(
            LocationFilter.region(state.dropoffRegion!.id),
            forceRefresh: true,
          );
        } else {
          newDropoffOptions = newPickupOptions;
        }
      }

      final resolvedPickupRegion = _resolveRegionById(state.pickupRegion, newRegions);
      final resolvedDropoffRegion = _resolveRegionById(state.dropoffRegion, newRegions);
      final resolvedPickupBranch = _resolveBranchById(state.pickupBranch, newPickupOptions);
      final resolvedDropoffBranch = _resolveBranchById(state.dropoffBranch, newDropoffOptions);

      var next = state.copyWith(
        status: LocationSelectionStatus.ready,
        pickupOptions: newPickupOptions,
        dropoffOptions: newDropoffOptions,
        // pickupRegion is not part of the three protected fields — the
        // standard copyWith no-op idiom is acceptable here: an
        // unresolvable pickup region simply keeps its last-known value.
        pickupRegion: resolvedPickupRegion,
        // Part of this same single state object, not a second emit. This is
        // what makes the emit distinguishable under Principle I's id-only
        // equality when only display names changed — see
        // LocationSelectionState's languageCode doc and
        // contracts/cubit-state-machine.md.
        languageCode: currentLocationLanguage(),
      );

      next = resolvedPickupBranch != null
          ? next.withPickupBranch(resolvedPickupBranch)
          : next.clearPickupBranch();

      if (state.dropoffRegion != null && resolvedDropoffRegion == null) {
        // The selected dropoff region itself vanished — clear both
        // together, same as disabling dropoff.
        next = next.clearDropoff();
      } else {
        if (resolvedDropoffRegion != null) {
          next = next.withDropoffRegion(resolvedDropoffRegion);
        }
        next = resolvedDropoffBranch != null
            ? next.withDropoffBranch(resolvedDropoffBranch)
            : next.clearDropoffBranch();
      }

      emit(next);
    } catch (e) {
      emit(state.copyWith(status: LocationSelectionStatus.failure, error: e.toString()));
    }
  }

  /// Re-runs the last failed fetch. Selections already made are preserved
  /// (FR-038) — that fell out naturally: every failure path above emits
  /// `state.copyWith(status: failure, ...)`, which carries every other
  /// field forward unchanged.
  Future<void> retry() async {
    final action = _retryAction;
    if (action == null) return;
    await action();
  }

  Region? _resolveRegionById(Region? current, List<Region> options) {
    if (current == null) return null;
    for (final r in options) {
      if (r.id == current.id) return r;
    }
    return null;
  }

  Branch? _resolveBranchById(Branch? current, List<Branch> options) {
    if (current == null) return null;
    for (final b in options) {
      if (b.id == current.id) return b;
    }
    return null;
  }
}
