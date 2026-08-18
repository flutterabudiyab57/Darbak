import 'dart:developer';

import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/SharedPreference/pereferences.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/core/helpers/request_headers.dart';
import 'package:dio/dio.dart';

class CancelBookingAutomationDataSources {
  final Dio dio;

  final SharedPreferencesHelper sharedPreferencesHelper;

  CancelBookingAutomationDataSources(this.dio, this.sharedPreferencesHelper);

  Future<Response> cancelBookingAutomation({required int orderId}) async {
    final token = await sharedPreferencesHelper.getToken();
    try {
      final Response response = await dio.post(
        cancelBookingAutomationPath,
        options: Options(
          responseType: ResponseType.plain,
          headers: RequestHeaders.forDio(
            token: token,
            otherHeaders: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Accept-Language": langCode == '' ? "en" : langCode,
            },
          ),
        ),
        data: {
          "contract_id": orderId,
        },
      );
      log(response.toString());
      return response;
    } on DioException catch (DioException) {
      throw Failure.fromDioError(DioException);
    } catch (error) {
      throw '..Oops $error';
    }
  }
}
