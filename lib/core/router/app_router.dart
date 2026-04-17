import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import 'router_refresh_notifier.dart';

class AppRouter {
  AppRouter({
    required AuthCubit authCubit,
    required bool isSupabaseConfigured,
  }) : _refreshNotifier = RouterRefreshNotifier(authCubit.stream) {
    router = GoRouter(
      initialLocation: LoginPage.path,
      refreshListenable: _refreshNotifier,
      routes: <RouteBase>[
        GoRoute(
          path: LoginPage.path,
          name: LoginPage.name,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: HomePage.path,
          name: HomePage.name,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: ProfilePage.path,
          name: ProfilePage.name,
          builder: (context, state) => const ProfilePage(),
        ),
      ],
      redirect: (context, state) {
        final authState = authCubit.state;
        final isLoading = authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading;
        final isLoggedIn = authState.status == AuthStatus.authenticated;
        final isGoingToLogin = state.matchedLocation == LoginPage.path;

        if (isLoading) {
          return null;
        }

        if (!isSupabaseConfigured) {
          return isGoingToLogin ? null : LoginPage.path;
        }

        if (!isLoggedIn) {
          return isGoingToLogin ? null : LoginPage.path;
        }

        if (isGoingToLogin) {
          return HomePage.path;
        }

        return null;
      },
    );
  }

  final RouterRefreshNotifier _refreshNotifier;
  late final GoRouter router;

  @visibleForTesting
  RouterRefreshNotifier get refreshNotifier => _refreshNotifier;
}
