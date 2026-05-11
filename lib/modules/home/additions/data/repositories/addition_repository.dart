
import '../../../../../core/helpers/SharedPreference/pereferences.dart';
import '../../../../../core/helpers/helper/date_helper.dart';
import '../datasource/remote/order_addition_remote_datasource.dart';
import '../models/automated_step_one_order_model.dart';
import '../models/step_one_order_model.dart';


class AdditionRepository {
  final SharedPreferencesHelper preferences;
  final OrderAdditionsRemoteDatasource orderAdditionsRemoteDatasource;

  AdditionRepository(this.orderAdditionsRemoteDatasource, this.preferences);
  Future<StepOneOrderModel?> getCarOrder({
    String? languageCode,
    required String carId,
    required String receiveBranchId,
    required String driveBranchId,
    required DateTime receiveDate,
    required DateTime driveDate,
    required String receiveTimeValue,
    required String driveTimeValue,
    double? pickupLat,    // ✅
    double? pickupLong,   // ✅
    double? dropoffLat,   // ✅
    double? dropoffLong,  // ✅
  }) async {
    return await orderAdditionsRemoteDatasource.getCarOrder(
      token: await preferences.getToken() ?? "",
      carId: carId,
      receiveBranchId: receiveBranchId,
      driveBranchId: driveBranchId,
      receiveDate: receiveDate.toString(),
      driveDate: driveDate.toString(),
      pickupLat: pickupLat,    // ✅
      pickupLong: pickupLong,  // ✅
      dropoffLat: dropoffLat,  // ✅
      dropoffLong: dropoffLong, // ✅
    );
  }
  Future<AutomatedStepOneOrderModel?> getAutomatedCarOrder({
    String? languageCode,
    required String carId,
    required String receiveLocationId,
    required String driveLocationId,
    required DateTime receiveDate,
    required DateTime driveDate,
    required String receiveTimeValue,
    required String driveTimeValue,
  }) async {
    print(driveTimeValue);
    String receiveHour = receiveTimeValue
        .toString()
        .replaceAll("TimeOfDay", "")
        .replaceAll("(", "")
        .replaceAll(")", "");
    String deliveryHour = driveTimeValue
        .toString()
        .replaceAll("TimeOfDay", "")
        .replaceAll("(", "")
        .replaceAll(")", "");
    return await orderAdditionsRemoteDatasource.getAutomatedCarOrder(
      token: await preferences.getToken() ?? "",
      carId: carId,
      languageCode: languageCode,
      driveLocationId: driveLocationId,
      receiveLocationId: receiveLocationId,
      driveDate: DateHandler.mixDateWithHours(driveDate, deliveryHour),
      receiveDate: DateHandler.mixDateWithHours(receiveDate, receiveHour),
    );
  }


}
