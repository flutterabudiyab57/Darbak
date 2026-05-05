import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../../../../core/constants/api_path.dart';
import '../../../../../../core/helpers/exception/exceptions.dart';
import '../../models/signin_model.dart';

abstract class SignInRemoteDataSource {
  Future<Map<String,dynamic>?> loginUsingEmailAndPassword(SignInModel signInModel);

  Future<bool> loginWithGoogle();

  Future<bool> loginWithApple();

  Future<String> forgetPassword(String phone);

  Future<String> postCode(String token, String code);

  Future<void> resetPassword(
      String token, String password, String confirmPassword);
}

class SignInRemoteDataSourceImpl extends SignInRemoteDataSource {
  final Dio _dio = Dio();

  @override
  Future<Map<String,dynamic>?> loginUsingEmailAndPassword(SignInModel signInModel) async {
    try {
      print("📤 Sending SignIn request with data:");
      print(signInModel.toMap());

      final Response response = await _dio.post(
        mainApi + loginApi,
        options: Options(
            responseType: ResponseType.plain,
            headers: {"Accept": "application/json"}
        ),
        data: signInModel.toMap(),
      );

      final decodedData = json.decode(response.data) as Map<String, dynamic>;

      print("✅ Decoded Response:");

       if (decodedData['requires_verification'] == true) {
        print("⚠️ User requires OTP verification");
        decodedData['requires_verification'] = true;
      } else {
        decodedData['requires_verification'] = false;
      }

      return decodedData;
    } on DioError catch (dioError) {
      print("❌ DioError: ${dioError.response?.statusCode}");
      print("Response data: ${dioError.response?.data}");

      if (dioError.response?.statusCode == 403) {
        try {
          final data = json.decode(dioError.response?.data ?? '{}');
          if (data['requires_verification'] == true) {
            print("⚠️ DioError: requires verification detected");
            return data; // نرجع البيانات ليتم التعامل معها بالـ Bloc
          }
        } catch (_) {}
      }

      throw Failure.fromDioError(dioError);
    } catch (error) {
      print("❌ Unknown error: $error");
      throw '😢😢😢😢..Oops $error';
    }
  }

  @override
  Future<String> forgetPassword(String phone) {
    throw UnimplementedError();
  }

  @override
  Future<String> postCode(String token, String code) =>
      throw UnimplementedError();

  @override
  Future<void> resetPassword(String token, String password, String confirmPassword) =>
      throw UnimplementedError();

  @override
  Future<bool> loginWithApple() => throw UnimplementedError();

  @override
  Future<bool> loginWithGoogle() => throw UnimplementedError();
}