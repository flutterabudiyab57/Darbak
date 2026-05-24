part of 'signin_bloc.dart';

@immutable
abstract class SignInEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SignIn extends SignInEvent {
  final String email;
  final String password;

  SignIn({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];

}
class ShowPasswordEvent extends SignInEvent{}