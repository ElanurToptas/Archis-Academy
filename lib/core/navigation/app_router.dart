import 'package:archis_academy/features/auth/repository/auth_repository.dart';
import 'package:archis_academy/features/home/view/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/view/register_view.dart';
import '../../features/auth/view/login_view.dart';

final _rootKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const register = '/register';
  static const login = '/login';
  static const home = '/';
}

final authRepo = AuthRepository(); 

final router = GoRouter(
  navigatorKey: _rootKey,
  redirect: (context, state) async {
    
    final isLoggedIn = await authRepo.checkAuthStatus();
    
    final isGoingToLogin = state.matchedLocation == AppRoutes.login;
    final isGoingToRegister = state.matchedLocation == AppRoutes.register;

    if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
      return AppRoutes.login;
    }

    if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
      return AppRoutes.home;
    }
    
    return null; 
  },
  routes: [
    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (context, state) => _buildPage(const RegisterView(), state),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => _buildPage(const LoginView(), state),
    ),
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) => _buildPage(const HomePage(), state),
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
