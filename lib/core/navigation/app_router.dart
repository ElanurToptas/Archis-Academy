import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/view/register_view.dart';
import '../../features/auth/view/login_view.dart';

final _rootKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const register = '/register';
  static const login = '/login';
}

final router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: AppRoutes.register,
  routes: [
    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (context, state) => _buildPage(const RegisterView(), state),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => _buildPage(const LoginView(), state),
    ),
  ],
);


Page _buildPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
