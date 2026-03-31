import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';

/// A mixin or helper class to provide a standardized guest guard for protected actions.
/// Can be used in both ConsumerWidgets (via ref) and ConsumerStatefulWidgets (via ref).
mixin GuestGuardMixin {
  /// Checks if the user is authenticated. 
  /// If [authenticated], executes [onAuthenticated].
  /// If NOT [authenticated], shows a snackbar and redirects to [Login].
  void guardAction({
    required BuildContext context,
    required WidgetRef ref,
    required VoidCallback onAuthenticated,
    String message = 'Please log in to perform this action',
  }) {
    final isAuthenticated = ref.read(isAuthenticatedProvider);

    if (isAuthenticated) {
      onAuthenticated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF282828),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Login',
            textColor: Colors.white,
            onPressed: () {
              context.push('/login');
            },
          ),
        ),
      );
    }
  }
}

/// A global helper function for when a mixin isn't convenient (e.g., inside deep logic).
void guardProtectedAction({
  required BuildContext context,
  required WidgetRef ref,
  required VoidCallback onAuthenticated,
  String message = 'Please log in to perform this action',
}) {
  final isAuthenticated = ref.read(isAuthenticatedProvider);

  if (isAuthenticated) {
    onAuthenticated();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF282828),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () {
            context.push('/login');
          },
        ),
      ),
    );
  }
}
