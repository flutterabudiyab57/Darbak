import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/constants/preferences_constants.dart';
import '../../../core/helpers/SharedPreference/pereferences.dart';
import '../../../core/helpers/token_validator.dart';

/// Three-state auth status cubit.
/// Emits one of: AuthUnknown (boot), AuthGuest (guest mode), AuthAuthenticated (logged in)
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state during app boot — still resolving auth status
class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// User is in guest mode (explicitly chose guest or session cleared)
/// NEVER treat this as authenticated.
class AuthGuest extends AuthState {
  const AuthGuest();
}

/// User is authenticated with a valid token
class AuthAuthenticated extends AuthState {
  final String token;
  const AuthAuthenticated(this.token);

  @override
  List<Object?> get props => [token];
}

class AuthStatusCubit extends Cubit<AuthState> {
  final SharedPreferencesHelper preferences;

  AuthStatusCubit(this.preferences) : super(const AuthUnknown()) {
    _init();
  }

  Future<void> _init() async {
    final token = await preferences.getToken();

    if (TokenValidator.isValid(token)) {
      emit(AuthAuthenticated(token!));
      return;
    }

    final isGuest = await preferences.getIsGuest();
    if (isGuest) {
      emit(const AuthGuest());
      return;
    }

    emit(const AuthGuest());
  }

  /// Called on successful login — saves token and clears guest flag
  Future<void> markSignedIn(String token) async {
    await preferences.set(PreferencesConstants.token, token);
    await preferences.remove(PreferencesConstants.isGuest);
    emit(AuthAuthenticated(token));
  }

  /// Called on logout — clears token and guest flag, emits guest state
  Future<void> markSignedOut() async {
    await preferences.remove(PreferencesConstants.token);
    await preferences.remove(PreferencesConstants.isGuest);
    emit(const AuthGuest());
  }

  /// Called when "continue as guest" is tapped — sets guest flag
  Future<void> markAsGuest() async {
    await preferences.setBool(PreferencesConstants.isGuest, true);
    emit(const AuthGuest());
  }
}
