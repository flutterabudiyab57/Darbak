import 'package:darbak/modules/home/profile/page/reset_password/datasources/remote/reset_password_datasources.dart';
import 'package:darbak/modules/home/profile/page/reset_password/presentaion/bloc/rsete_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RsetePasswordCubit extends Cubit<RsetePasswordState> {
  RsetePasswordCubit(this.resetPasswordDataSource)
      : super(RsetePasswordInitial());
  final ResetPasswordDataSource resetPasswordDataSource;

  Future<void> rsetePassword({
    required String oldPassWord,
    required String newPassWord,
    required String confirmPassWord,
  }) async {
    emit(RsetePasswordLoading());

    try {
      await resetPasswordDataSource.resetPassword(
        oldPassWord: oldPassWord,
        newPassWord: newPassWord,
        confirmPassWord: confirmPassWord,
      );

      emit(RsetePasswordLoaded());
    } catch (e) {
      emit(RsetePassWordError(e.toString()));
    }
  }
}