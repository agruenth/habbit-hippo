import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/hippo/presentation/home_screen.dart';
import 'features/habits/presentation/habits_screen.dart';
import 'features/world/presentation/world_screen.dart';
import 'features/friends/presentation/friends_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/article/presentation/article_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'core/constants/app_theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authAsync.isLoading) return null;
      final isAuth = authAsync.value?.isAuthenticated ?? false;
      final onAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register' || state.matchedLocation.startsWith('/onboarding');
      if (!isAuth && !onAuthPage) return '/login';
      if (isAuth && onAuthPage) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const LoginScreen()), // TODO: register screen
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/article', builder: (_, __) => const ArticleScreen()),
      GoRoute(path: '/chat/:friendId', builder: (_, state) => ChatScreen(friendId: state.pathParameters['friendId']!)),
      ShellRoute(
        builder: (context, state, child) => _ScaffoldWithNav(child: child, location: state.matchedLocation),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/world', builder: (_, __) => const WorldScreen()),
          GoRoute(path: '/habits', builder: (_, __) => const HabitsScreen()),
          GoRoute(path: '/friends', builder: (_, __) => const FriendsScreen()),
        ],
      ),
    ],
  );
});

class _ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  final String location;

  const _ScaffoldWithNav({required this.child, required this.location});

  int get _currentIndex => switch (location) {
        '/' => 0,
        '/world' => 1,
        '/habits' => 2,
        '/friends' => 3,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _NavItem(icon: '🦛', label: 'Hippo', active: _currentIndex == 0, onTap: () => GoRouter.of(context).go('/')),
                _NavItem(icon: '🗺', label: 'World', active: _currentIndex == 1, onTap: () => GoRouter.of(context).go('/world')),
                _NavItem(icon: '✅', label: 'Habits', active: _currentIndex == 2, onTap: () => GoRouter.of(context).go('/habits')),
                _NavItem(icon: '💧', label: 'Friends', active: _currentIndex == 3, onTap: () => GoRouter.of(context).go('/friends')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon, label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: active ? 23 : 21)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.primary : AppColors.textSoft,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
