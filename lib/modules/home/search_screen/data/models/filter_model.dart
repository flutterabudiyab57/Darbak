import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';

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
  });

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