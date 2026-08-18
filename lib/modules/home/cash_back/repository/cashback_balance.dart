import 'dart:convert';
import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/SharedPreference/pereferences.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/core/helpers/request_headers.dart';
import 'package:dio/dio.dart';

import '../models/cashbackbalance.dart';
import '../models/cashback_transactions.dart';

class CashbackRemoteDataSource {
  final Dio _dio;
  final SharedPreferencesHelper sharedPreferencesHelper;

  CashbackRemoteDataSource(this._dio, this.sharedPreferencesHelper);

  Future<CashbackBalance> getCashbackBalance() async {
    try {
      print('Cashback API: start');

      final token = await sharedPreferencesHelper.getToken();
      print('Token: $token');

      final Response response = await _dio.get(
        cashbackbalance,
        options: Options(
          responseType: ResponseType.plain,
          headers: RequestHeaders.forDio(
            token: token,
            otherHeaders: {
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

      final balance = CashbackBalance.fromMap(data);
      print('Parsed balance: $balance');

      return balance;
    } on DioException catch (DioException) {
      print('Dio error: ${DioException.response}');
      print('Dio message: ${DioException.message}');
      throw Failure.fromDioError(DioException);
    } catch (error) {
      print('Unexpected error: $error');
      throw Exception('..Oops $error');
    }
  }

  Future<CashbackTransactions> getCashbackTransactions({
    String? eventType, // 'redeemed', 'issued', 'revoked'
    String? recordState, // 'used', 'available', 'pending'
    String direction = 'desc', // 'asc', 'desc'
  }) async {
    try {
      print('Transactions API: start');

      final token = await sharedPreferencesHelper.getToken();

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'direction': direction,
      };

      if (eventType != null) {
        queryParams['event_type'] = eventType;
      }

      if (recordState != null) {
        queryParams['record_state'] = recordState;
      }

      print('Query params: $queryParams');

      final Response response = await _dio.get(
        cashbacktransactions,
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.plain,
          headers: RequestHeaders.forDio(
            token: token,
            otherHeaders: {
              "Accept": "application/json",
              "Accept-Language": langCode.isEmpty ? "en" : langCode,
            },
          ),
        ),
      );

      final data = json.decode(response.data) as Map<String, dynamic>;
      final transactions = CashbackTransactions.fromMap(data);

      return transactions;
    } on DioException catch (DioException) {
      print('Transactions Dio error: ${DioException.response}');
      print('Transactions Dio message: ${DioException.message}');
      throw Failure.fromDioError(DioException);
    } catch (error) {
      print('Transactions unexpected error: $error');
      throw Exception('..Oops $error');
    }
  }
}