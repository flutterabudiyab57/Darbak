import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../../../../../core/constants/api_path.dart';
import '../../../../../../core/constants/langCode.dart';
import '../../../../../../core/helpers/SharedPreference/pereferences.dart';
import '../../../../../../core/helpers/exception/exceptions.dart';
import '../../../../all_bookings/data/model/check_order_step_model.dart';
import '../../models/automated_step_one_order_model.dart';
import '../../models/step_one_order_model.dart';

class OrderAdditionsRemoteDatasource {
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
  Future<StepOneOrderModel?> getCarOrder({
    required String token,
    String? languageCode,
    required String carId,
    required String receiveBranchId,
    required String driveBranchId,
    required String receiveDate,
    required String driveDate,
    double? pickupLat,
    double? pickupLong,
    double? dropoffLat,
    double? dropoffLong,
  }) async {
    try {
      final body = {
        "car_id": carId,
        'receiving_branche': receiveBranchId.toString(),
        'delivery_branche': driveBranchId.toString(),
        'receiving_date': receiveDate,
        'delivery_date': driveDate,
        'order_via': "Darakson App",
      };

      if (pickupLat != null) {
        body['pickup_lat_delivery_service'] = pickupLat.toString();
      }

      if (pickupLong != null) {
        body['pickup_long_delivery_service'] = pickupLong.toString();
      }

      if (dropoffLat != null) {
        body['dropoff_lat_delivery_service'] = dropoffLat.toString();
      }

      if (dropoffLong != null) {
        body['dropoff_long_delivery_service'] = dropoffLong.toString();
      }
      final response = await http.post(
        Uri.parse(orderStepOnePath),
        headers: {
          "Accept": "application/json",
          "Accept-Language": langCode == '' ? "en" : langCode,
          "Authorization": "Bearer $token"
        },
        body: body,
      );
      //
       // debugPrint('║ 📡 Response Status: ${response.statusCode}');
      // debugPrint('║ 📡 Response Body:   ${response.body}');
      if (response.statusCode == 200) {
        return stepOneOrderModelFromMap(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Error Please LOGIN To Continue");
      } else if (response.statusCode == 419) {
        var data = json.decode(response.body);
        throw Exception(data['massage']);
      } else if (response.statusCode == 422) {
        var data = json.decode(response.body);
        throw Exception(data['title'] + '\n' + data['body']);
      } else {
        throw Exception();
      }
    } catch (error) {
      throw FetchDataException(data: "some thing wrong", details: error.toString());
    }
  }
  Future<AutomatedStepOneOrderModel?> getAutomatedCarOrder({
    required String token,
    String? languageCode,
    required String carId,
    required String receiveLocationId,
    required String driveLocationId,
    required String receiveDate,
    required String driveDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(step1Automation),
        headers: {
          "Accept": "application/json",
          "Accept-Language": langCode == '' ? "en" : langCode,
          "Authorization": "Bearer $token"
        },
        body: {
          "car_id": carId,
          'receiving_location': receiveLocationId.toString(),
          'delivery_location': driveLocationId.toString(),
          'receiving_date': receiveDate,
          'delivery_date': driveDate,
        },
      );
      if (response.statusCode == 200) {
        final order = automatedStepOneOrderModelFromJson(response.body);
        return order;
      } else if (response.statusCode == 401) {
        return throw Exception('Error Please LOGIN To Continue');
      } else if (response.statusCode == 419) {
        var data = json.decode(response.body);
        return throw Exception(data['massage']);
      } else if (response.statusCode == 422) {
        var data = json.decode(response.body);
        throw Exception(data['title'] + '\n' + data['body']);
      } else {
        return throw Exception();
      }
    } catch (error) {
      throw FetchDataException(data: "some thing wrong", details: error.toString());
    }
  }

  Future<CheckOrderStepModel> checkBookingSteps({required  dynamic orderId}) async {
    final token = await sharedPreferencesHelper.getToken();
    try {
      final Dio dio = Dio();
      var uri = Uri.parse(checkSteps);
      final Response response = await dio.post(
          uri.toString(),
          options: Options(responseType: ResponseType.plain, headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
            "Accept-Language": langCode == '' ? "en" : langCode,
          }),
          data: {
            "order_id": orderId,
          }
      );
      final checkOrderSteps = json.decode(response.data);
      final CheckOrderStepModel checkOrderStepModel = CheckOrderStepModel.fromMap(checkOrderSteps);
      log(response.toString());
      return checkOrderStepModel;
    } on DioError catch (dioError) {
      throw Failure.fromDioError(dioError);
    } catch (error) {
      throw '..Oops  $error';
    }
  }
}
