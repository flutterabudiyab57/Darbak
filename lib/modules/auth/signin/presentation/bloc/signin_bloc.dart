import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/signin_model.dart';
import '../../data/repositories/signin_repository_impl.dart';

part 'signin_event.dart';
part 'signin_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignInRepositoryImpl signInRepository;

  SignInBloc(this.signInRepository)
      : super(SignInInitial()) {
    on<SignIn>(_onSignInEvent);
  }

  FutureOr<void> _onSignInEvent(SignIn event, Emitter<SignInState> emit) async {
    emit(SignInLoading());
    final userData = SignInModel(
        email: event.email,
        password: event.password,
        device_token: event.device_token
    );

    try {
      final response = await signInRepository.signInRemoteDataSource
          .loginUsingEmailAndPassword(userData);

      if (response!['requires_verification'] == true) {
        emit(RegisterRequiresVerification(
          userId: response['user_id'].toString(),
          phone: response['phone'].toString(),
        ));
        return;
      }

      if (response.containsKey('token')) {
        await signInRepository.signInLocalDataSource.saveToken(response['token']);
        await signInRepository.signInLocalDataSource.savePassword(event.password);

        emit(SignInSuccess());
      } else {
        emit(SignInFailure(error: 'Unknown error, token not found'));
      }
    } catch (e) {
      emit(SignInFailure(error: e.toString()));
    }
  }
}