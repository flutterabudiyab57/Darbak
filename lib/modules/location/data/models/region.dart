import 'package:equatable/equatable.dart';

import 'geo_point.dart';

int? _asId(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

/// A geographic area the renter picks before choosing a branch.
///
/// Equality is on `id` ONLY (Constitution Principle I) — `polygon` is
/// payload, not identity, and is excluded from `==`/`hashCode` (BD-1).
///
/// `center` is deliberately NOT modelled: it is neither parsed nor used
/// today; the region centre is computed as a centroid of `polygon` by the
/// (out-of-scope) areas feature.
class Region extends Equatable {
  final int id;
  final String name;
  final String? city;
  final List<GeoPoint>? polygon;

  const Region({
    required this.id,
    required this.name,
    this.city,
    this.polygon,
  });

  /// Returns null for an element without a usable integer id — a region
  /// without identity cannot be selected, and dropping it silently is
  /// preferable to a list entry that cannot be submitted.
  static Region? tryParse(Map<String, dynamic> json) {
    final id = _asId(json['id']);
    if (id == null) return null;

    List<GeoPoint>? polygon;
    final rawPolygon = json['polygon'];
    if (rawPolygon is List) {
      polygon = rawPolygon.map(GeoPoint.tryParse).whereType<GeoPoint>().toList();
    }

    return Region(
      id: id,
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString(),
      polygon: polygon,
    );
  }

  @override
  List<Object?> get props => [id];
}
