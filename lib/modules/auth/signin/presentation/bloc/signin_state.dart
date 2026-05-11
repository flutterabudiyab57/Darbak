part of 'signin_bloc.dart';

@immutable
abstract class SignInState extends Equatable {
  @override
  List<Object> get props => [];
}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {

}

class SignInFailure extends SignInState {
  final String error;

  SignInFailure({required this.error});

  @override
  List<Object> get props => [error];
}
class ShowPassword extends SignInState{}
class RegisterRequiresVerification extends SignInState {
  final String userId;
  final String phone;

  RegisterRequiresVerification({required this.userId, required this.phone});

  @override
  List<Object> get props => [userId, phone];
}