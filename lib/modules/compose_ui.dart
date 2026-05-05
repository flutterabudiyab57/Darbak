import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth/blocs/auth_bloc/auth_bloc.dart';
import 'home/home_screen/home_screen.dart';

class ComposeUi extends StatelessWidget {
  const ComposeUi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => HomeScreen());
}
