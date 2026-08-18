import 'dart:convert';
import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/helpers/SharedPreference/pereferences.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/core/helpers/request_headers.dart';
import 'package:dio/dio.dart';

class ResetPasswordDataSource {
  final Dio _dio;
  final SharedPreferencesHelper sharedPreferencesHelper;

  ResetPasswordDataSource(this._dio, this.sharedPreferencesHelper);

  Future<void> resetPassword({
    required String oldPassWord,
    required String newPassWord,
    required String confirmPassWord,
  }) async {
    try {
      print('Reset Password API: start');

      final token = await sharedPreferencesHelper.getToken();
      print('Token: $token');

      final String resetPasswordUrl = mainApi + '/profile';

      final Response response = await _dio.put(
        resetPasswordUrl,
        data: {
          'old_password': oldPassWord,
          'password': newPassWord,
          'password_confirmation': confirmPassWord,
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

      // التحقق من نجاح العملية
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to reset password');
      }

      final data = json.decode(response.data) as Map<String, dynamic>;
      print('Decoded data: $data');

    } on DioException catch (dioError) {
      print('Dio error: ${dioError.response}');
      print('Dio message: ${dioError.message}');

      // معالجة الأخطاء من الـ API
      if (dioError.response?.data != null) {
        try {
          final errorData = json.decode(dioError.response!.data);
          print('Error data: $errorData');

          // لو الـ API بيرجع رسالة خطأ محددة
          if (errorData['message'] != null) {
            throw errorData['message'];
          }
        } catch (e) {
          print('Error parsing error response: $e');
        }
      }

      throw Failure.fromDioError(dioError);
    } catch (error) {
      print('Unexpected error: $error');
      throw Exception('Oops $error');
    }
  }
}