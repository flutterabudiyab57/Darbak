
import '../../../../../../core/constants/preferences_constants.dart';
import '../../../../../../core/helpers/SharedPreference/pereferences.dart';
import '../../models/user_data_model.dart';

abstract class SignInLocalDataSource {
  saveUserData(UserData userData);

  getUserData();

  saveToken(String token);

  getToken();
  Future<void> savePassword(String password);

  Future<String?> getSavedPassword();

  Future<void> deletePassword();
}

class SignInLocalDataSourceImpl extends SignInLocalDataSource {
  final SharedPreferencesHelper preferences;

  SignInLocalDataSourceImpl(this.preferences);

  @override
  saveUserData(UserData userData) async =>
      await preferences.set(PreferencesConstants.userData, userData.toString());

  @override
  getUserData() async =>
      UserData.fromJson(preferences.get(PreferencesConstants.userData) as Map<String, dynamic>);

  @override
  saveToken(String token) async =>
      await preferences.set(PreferencesConstants.token, token);

  @override
  getToken() async =>
      preferences.get(PreferencesConstants.token);

  @override
  Future<void> savePassword(String password) async {
    await preferences.set(PreferencesConstants.userPassword, password);
  }

  @override
  Future<String?> getSavedPassword() async {
    return preferences.get(PreferencesConstants.userPassword) as String?;
  }

  @override
  Future<void> deletePassword() async {
    await preferences.remove(PreferencesConstants.userPassword);
  }
}