import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:darbak/modules/location/data/models/branch.dart';
import 'package:darbak/modules/location/presentaion/bloc/location_selection_cubit.dart';
import '../../blocs/search_bloc/search_cubit.dart';

class FilterModel {
  final String? receiveTimeValue;
  final String? driveTimeValue;
  final BranchModel? selectedBranch;
  final String? receiveDateValue;
  final String? driveDateValue;
  final double? pickupLat;
  final double? pickupLong;
  final double? dropoffLat;
  final double? dropoffLong;

  /// The new-module [Branch] objects and combined date/time values behind
  /// this filter's [selectedBranch] bridge — carried through the car-list
  /// screens so `cars_info.dart` can build a [BookingDraft] once a specific
  /// car is chosen (Phase 7, T062). `selectedBranch` above stays as the
  /// id/name bridge the car-list screens already filter by; these four are
  /// additive, not a replacement.
  final Branch? pickupBranch;
  final Branch? dropoffBranch;
  final DateTime? pickupAt;
  final DateTime? dropoffAt;

  FilterModel({
    this.receiveTimeValue,
    this.driveTimeValue,
    this.selectedBranch,
    this.receiveDateValue,
    this.driveDateValue,
    this.pickupLat,
    this.pickupLong,
    this.dropoffLat,
    this.dropoffLong,
    this.pickupBranch,
    this.dropoffBranch,
    this.pickupAt,
    this.dropoffAt,
  });

  /// T062: the single place all four converted rent-body parent screens
  /// (`clasic.dart`, `monthly_package_screen.dart`, `delivery_package_screen.dart`,
  /// `airboart_package_screen.dart`) build their `SearchValidate`-listener
  /// `FilterModel`, instead of five near-identical copies of the same
  /// `pickupBranch`/`dropoffBranch`/`pickupAt`/`dropoffAt` population. Only
  /// `pickupLat`/`pickupLong`/`dropoffLat`/`dropoffLong` (delivery's map-pin
  /// address, unrelated to branch identity) still vary per call site.
  factory FilterModel.fromSelection({
    required BranchModel selectedBranch,
    required LocationSelectionCubit locationCubit,
    required SearchCubit searchCubit,
    double? pickupLat,
    double? pickupLong,
    double? dropoffLat,
    double? dropoffLong,
  }) {
    final locState = locationCubit.state;
    return FilterModel(
      selectedBranch: selectedBranch,
      receiveTimeValue: searchCubit.receiveTimeValue.hour.toString(),
      driveTimeValue: searchCubit.driveTimeValue.hour.toString(),
      receiveDateValue: searchCubit.receiveDateValue.toString(),
      driveDateValue: searchCubit.driveDateValue.toString(),
      pickupLat: pickupLat,
      pickupLong: pickupLong,
      dropoffLat: dropoffLat,
      dropoffLong: dropoffLong,
      pickupBranch: locState.pickupBranch,
      dropoffBranch: locState.dropoffBranch,
      pickupAt: searchCubit.receiveDateValue,
      dropoffAt: searchCubit.driveDateValue,
    );
  }

  factory FilterModel.fromMap(Map<String, dynamic> json) => FilterModel(
    receiveDateValue: json['receiveDateValue'],
    driveDateValue: json['driveDateValue'],
    receiveTimeValue: json["receiveTimeValue"],
    driveTimeValue: json['driveTimeValue'],
    selectedBranch: json["selectedBranch"] == null
        ? null
        : BranchModel.fromMap(json["selectedBranch"]),
    pickupLat: json['pickup_lat_delivery_service'],
    pickupLong: json['pickup_long_delivery_service'],
    dropoffLat: json['dropoff_lat_delivery_service'],
    dropoffLong: json['dropoff_long_delivery_service'],
  );

  Map<String, dynamic> toJson() => {
    'receiveTimeValue': receiveTimeValue,
    'driveTimeValue': driveTimeValue,
    "receiveDateValue": receiveDateValue,
    "driveDateValue": driveDateValue,
    "selectedBranch": selectedBranch?.toMap(),
    'pickup_lat_delivery_service': pickupLat,
    'pickup_long_delivery_service': pickupLong,
    'dropoff_lat_delivery_service': dropoffLat,
    'dropoff_long_delivery_service': dropoffLong,
  };
}