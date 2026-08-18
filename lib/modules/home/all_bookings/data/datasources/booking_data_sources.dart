import 'dart:convert';

import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/SharedPreference/pereferences.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/core/helpers/request_headers.dart';
import 'package:darbak/modules/home/all_bookings/data/model/booking_model.dart';
import 'package:dio/dio.dart';

class BookingDataSources {
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

  Future<Booking> getAllBooking({required String status}) async {
    final token = await sharedPreferencesHelper.getToken();
    try {
      final Dio dio = Dio();
      var uri = Uri.parse(getOrders);
      final Response response = await dio.post(
        data: {
          'status': status,
        },
        uri.toString(),
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
      );
      final dataOrders = json.decode(response.data);
      final Booking booking = Booking.fromMap(dataOrders);
      return booking;
    } on DioException catch (DioException) {
      throw Failure.fromDioError(DioException);
    } catch (error) {
      throw '..Oops $error';
    }
  }
}
