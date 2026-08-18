import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../modules/auth/blocs/auth_status_cubit.dart';
import '../../../modules/auth/signin/presentation/pages/signin_screen.dart' show SignInScreen, SignInMode;

/// Single entry point for protecting auth-dependent actions (booking, favourites, etc.)
///
/// If user is authenticated, calls onAuthenticated() immediately.
/// Otherwise shows a sign-in bottom sheet and re-executes onAuthenticated()
/// after successful login.
///
/// Usage:
/// ```dart
/// await requireAuth(
///   context,
///   onAuthenticated: () async {
///     // User is logged in, perform the protected action
///     await _doProtectedAction();
///   },
/// );
/// ```
Future<void> requireAuth(
  BuildContext context, {
  required Future<void> Function() onAuthenticated,
}) async {
  final authState = context.read<AuthStatusCubit>().state;

  if (authState is AuthAuthenticated) {
    await onAuthenticated();
    return;
  }

  // Show the login UI (sign-in / register bottom sheet)
  if (context.mounted) {
    final result = await showModalBottomSheet<bool>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FractionallySizedBox(
          child: SignInScreen(mode: SignInMode.gate),
        ),
      ),
    );

    // After sheet closes, check if login succeeded
    if (context.mounted && result == true) {
      final newAuthState = context.read<AuthStatusCubit>().state;
      if (newAuthState is AuthAuthenticated) {
        await onAuthenticated();
      }
    }
  }
}
