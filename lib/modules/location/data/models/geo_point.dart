import 'package:equatable/equatable.dart';

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// A single lat/lng coordinate used for polygon vertices and centre points.
///
/// This is the geometry payload shape — key `lng`, numeric on the wire — which
/// is NOT the same shape as a branch's own position (key `long`, a String).
/// See data-model.md#geopoint for the contrast.
class GeoPoint extends Equatable {
  final double? lat;
  final double? lng;

  const GeoPoint({this.lat, this.lng});

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
    lat: _asDouble(json['lat']),
    lng: _asDouble(json['lng']),
  );

  /// Never throws. A malformed vertex should be dropped by the caller, not
  /// crash the whole polygon parse.
  static GeoPoint? tryParse(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return GeoPoint.fromJson(json);
  }

  @override
  List<Object?> get props => [lat, lng];
}
