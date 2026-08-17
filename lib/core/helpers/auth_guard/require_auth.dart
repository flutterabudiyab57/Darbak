import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../modules/auth/blocs/auth_status_cubit.dart';
import '../../../modules/auth/signin/presentation/pages/signin_screen.dart' show SignInScreen, SignInMode;

/// Single entry point for protecting auth-dependent actions (booking, favourites, etc.)
///
/// Behaviour for Phase 1:
/// - If current auth state is AuthAuthenticated → call onAuthenticated()
/// - Otherwise → show the existing login UI (bottom sheet with sign-in / register)
///
/// Phase 2 will add pending-intent restore: actions triggered from FCM or deep links
/// will queue their intent, show login if needed, then re-execute on successful auth.
///
/// Usage:
/// ```dart
/// await requireAuth(
///   context,
///   onAuthenticated: () {
///     // User is logged in, perform the protected action
///     _doProtectedAction();
///   },
/// );
/// ```
Future<void> requireAuth(
  BuildContext context, {
  required VoidCallback onAuthenticated,
}) async {
  final authState = context.read<AuthStatusCubit>().state;

  if (authState is AuthAuthenticated) {
    onAuthenticated();
    return;
  }

  // Show the existing login UI (sign-in / register bottom sheet)
  if (context.mounted) {
    showModalBottomSheet(
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
  }
}
