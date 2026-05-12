import 'package:bloc/bloc.dart';

import '../../../core/helpers/SharedPreference/pereferences.dart';

/// Tri-state auth status:
/// - null  → still resolving (read token from prefs on construction)
/// - false → signed out
/// - true  → signed in
class AuthStatusCubit extends Cubit<bool?> {
  final SharedPreferencesHelper preferences;

  AuthStatusCubit(this.preferences) : super(null) {
    _init();
  }

  Future<void> _init() async {
    final token = await preferences.getToken();
    emit(token != null && token.isNotEmpty);
  }

  void markSignedIn() => emit(true);
  void markSignedOut() => emit(false);
}
