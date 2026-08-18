import 'dart:convert';
import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/SharedPreference/pereferences.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/core/helpers/request_headers.dart';
import 'package:dio/dio.dart';

import '../models/apply_cashback_response.dart';

class ApplyCashbackRemoteDataSource {
  final Dio _dio;
  final SharedPreferencesHelper sharedPreferencesHelper;

  ApplyCashbackRemoteDataSource(this._dio, this.sharedPreferencesHelper);

  Future<ApplyCashbackResponse> applyCashbackToOrder({
    required String orderId,
    required double amount,
  }) async {
    try {
      print('Apply Cashback API: start');
      print('Order ID: $orderId');
      print('Amount: $amount');

      final token = await sharedPreferencesHelper.getToken();
      print('Token: $token');

      final String applyCashbackUrl = mainApi + '/cashback/apply-to-order';

      final Response response = await _dio.post(
        applyCashbackUrl,
        data: {
          'order_id': orderId,
          'amount': amount,
        },
        options: Options(
          responseType: ResponseType.plain,
          headers: RequestHeaders.forDio(
            token: token,
            otherHeaders: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Accept-Language": langCode.isEmpty ? "en" : langCode,
            },
          ),
        ),
      );

      print('Status code: ${response.statusCode}');
      print('Raw response: ${response.data}');

      final data = json.decode(response.data) as Map<String, dynamic>;
      print('Decoded data: $data');

      final applyCashbackResponse = ApplyCashbackResponse.fromMap(data);
      print('Parsed response: $applyCashbackResponse');

      return applyCashbackResponse;
    } on DioException catch (DioException) {
      print('Dio error: ${DioException.response}');
      print('Dio message: ${DioException.message}');
      throw Failure.fromDioError(DioException);
    } catch (error) {
      print('Unexpected error: $error');
      throw Exception('..Oops $error');
    }
  }
}