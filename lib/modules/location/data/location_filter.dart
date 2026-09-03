/// The explicit criteria that produce a branch list — by region, by delivery
/// capability, by airport capability, or by a specific car. Different
/// filters over one concept (Constitution Principle III), not different
/// concepts.
///
/// `regionId` applies ONLY to the region-filtered branch list. The delivery,
/// airport, and car filters are NOT region-scoped — verified on-device.
/// `delivery()`, `airport()` and `car()` accept no `regionId` by
/// construction, which is what makes "never send `regions` alongside them"
/// structurally unrepresentable rather than merely documented.
///
/// Unlike the domain models, a filter has no identity apart from its values:
/// `==`/`hashCode` cover all four fields.
class LocationFilter {
  final int? regionId;
  final bool homeDelivery;
  final bool airport;
  final int? carId;

  const LocationFilter._({
    this.regionId,
    this.homeDelivery = false,
    this.airport = false,
    this.carId,
  });

  /// Daily and monthly rent, once a region has been chosen.
  const LocationFilter.region(int id) : this._(regionId: id);

  /// Daily and monthly rent before a region has been chosen, and the dropoff
  /// fallback when no dropoff region has been selected.
  const LocationFilter.allRegions() : this._();

  const LocationFilter.delivery() : this._(homeDelivery: true);

  const LocationFilter.airport() : this._(airport: true);

  const LocationFilter.car(int carId) : this._(carId: carId);

  /// Fixed-order join so the string is stable across app runs and two equal
  /// filters always produce one key.
  String get cacheKey =>
      'r=${regionId ?? "_"}|hd=${homeDelivery ? 1 : 0}|ap=${airport ? 1 : 0}|car=${carId ?? "_"}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationFilter &&
          runtimeType == other.runtimeType &&
          regionId == other.regionId &&
          homeDelivery == other.homeDelivery &&
          airport == other.airport &&
          carId == other.carId;

  @override
  int get hashCode => Object.hash(regionId, homeDelivery, airport, carId);
}
