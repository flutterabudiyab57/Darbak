import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/preferences_constants.dart';
import '../../domain/repositories/signin_repository.dart';
import '../datasources/loacal/sigin_local_datasource.dart';
import '../datasources/remote/signin_remote_datasource.dart';
import '../models/signin_model.dart';

class SignInRepositoryImpl extends SignInRepository {
  final SignInRemoteDataSourceImpl signInRemoteDataSource;
  final SignInLocalDataSourceImpl signInLocalDataSource;

  SignInRepositoryImpl(this.signInRemoteDataSource, this.signInLocalDataSource);

  @override
  Future<String?> loginUsingEmailAndPassword(SignInModel signInModel) async {
    try {
      final response = await signInRemoteDataSource.loginUsingEmailAndPassword(signInModel);

      if (response != null && response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PreferencesConstants.token, response['token']);

        if (response['user'] != null) {
          await prefs.setString(
              PreferencesConstants.userData,
              jsonEncode(response['user'])
          );
        }

        print('Token saved successfully: ${response['token']}');
        return response['token'];
      }
      return null;
    } catch (e) {
      print('Error in loginUsingEmailAndPassword: $e');
      rethrow;
    }
  }

  @override
  Future<String> forgetPassword(String phone) {
    throw UnimplementedError();
  }

  @override
  Future<bool> loginWithApple() => throw UnimplementedError();

  @override
  Future<bool> loginWithGoogle() => throw UnimplementedError();

  @override
  Future<String> postCode(String token, String code) =>
      throw UnimplementedError();

  @override
  Future<void> resetPassword(
      String token, String password, String confirmPassword) =>
      throw UnimplementedError();
}