import 'dart:developer';

import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/SharedPreference/pereferences.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/core/helpers/request_headers.dart';
import 'package:dio/dio.dart';

class CancelBookingDataSources {
  final Dio dio;

  final SharedPreferencesHelper sharedPreferencesHelper;

  CancelBookingDataSources(this.dio, this.sharedPreferencesHelper);

  Future<Response> cancelBooking({required int orderId}) async {
    final token = await sharedPreferencesHelper.getToken();
    try {
      final Response response = await dio.put(
        cancelOrder,
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
          "order_id": orderId,
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
  Future<Response> deleteBooking({required int orderId}) async {
    final token = await sharedPreferencesHelper.getToken();
    try {
      final Response response = await dio.post(
        deleteOrder,
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
          "order_id": orderId,
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
