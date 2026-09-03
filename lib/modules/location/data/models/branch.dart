import 'package:equatable/equatable.dart';

import 'branch_work_time.dart';
import 'geo_point.dart';

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Deliberately asymmetric: absent means false for book_today (FR-035), and
/// any unrecognised value is treated as false rather than throwing.
bool _asBoolFlag(dynamic value) {
  if (value == 1 || value == '1' || value == true) return true;
  return false;
}

List<GeoPoint>? _asPolygon(dynamic value) {
  if (value is! List) return null;
  return value.map(GeoPoint.tryParse).whereType<GeoPoint>().toList();
}

/// A physical location a car is collected from or returned to.
///
/// Equality is on `id` ONLY (Constitution Principle I) — this is what lets
/// the same branch arriving from `/branches` (key `name`) and from
/// `/available/branches/{carId}` (key `text`), in two different languages,
/// compare equal. `polygon` and `center` are payload, not identity, and are
/// excluded from `==`/`hashCode` (BD-1), same as everything else besides id.
///
/// There is no unnamed `fromJson`. Forcing the caller to name the source is
/// what keeps `isPartial` honest — it can never be inferred from field
/// presence, because a full branch may legitimately have a null `work_time`.
class Branch extends Equatable {
  final int id;
  final String name;
  final int? regionId;
  final String? regionName;
  final String? address;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? locationUrl;
  final BranchWorkTime? workTime;
  final bool bookToday;
  final num deliveryPrice;
  final String? image;
  final bool isPartial;
  final List<GeoPoint>? polygon;
  final GeoPoint? center;

  const Branch({
    required this.id,
    required this.name,
    this.regionId,
    this.regionName,
    this.address,
    this.lat,
    this.lng,
    this.phone,
    this.locationUrl,
    this.workTime,
    this.bookToday = false,
    this.deliveryPrice = 0,
    this.image,
    required this.isPartial,
    this.polygon,
    this.center,
  });

  /// Parses a full branch record from `/branches`, `/branches?home_delivery=1`
  /// or `/branches?airport=1`.
  factory Branch.fromBranchesApi(Map<String, dynamic> json) {
    return Branch(
      id: _asInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? json['text']?.toString() ?? '',
      regionId: _asInt(json['region_id']),
      regionName: json['region']?.toString(),
      address: json['address']?.toString(),
      // lat/long arrive as Strings, never a cast. The API key is "long", not "lng".
      lat: _asDouble(json['lat']),
      lng: _asDouble(json['long']),
      phone: json['phone']?.toString(),
      locationUrl: json['location_url']?.toString(),
      workTime: BranchWorkTime.tryParse(json['work_time']),
      bookToday: _asBoolFlag(json['book_today'] ?? json['can_book_today']),
      deliveryPrice: json['delivery_price'] != null ? (num.tryParse(json['delivery_price'].toString()) ?? 0) : 0,
      image: json['image']?.toString(),
      isPartial: false,
      polygon: _asPolygon(json['polygon']),
      center: GeoPoint.tryParse(json['center']),
    );
  }

  /// Parses a PARTIAL branch record from `/available/branches/{carId}`.
  /// Reads only id, text, image, can_book_today. Does not synthesise a
  /// regionId or any other field.
  factory Branch.fromCarBranchesApi(Map<String, dynamic> json) {
    return Branch(
      id: _asInt(json['id']) ?? 0,
      name: json['text']?.toString() ?? json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      bookToday: _asBoolFlag(json['can_book_today']),
      isPartial: true,
    );
  }

  @override
  List<Object?> get props => [id];
}
