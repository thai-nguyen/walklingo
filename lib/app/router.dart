import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../features/auth/presentation/login_screen.dart";
import "../features/catalog/presentation/catalog_screen.dart";
import "../features/catalog/presentation/episode_detail_screen.dart";
import "../features/listen_history/presentation/history_screen.dart";
import "../features/player/presentation/now_playing_screen.dart";
import "../features/profile/presentation/profile_screen.dart";
import "../features/tracking/presentation/walk_screen.dart";
import "go_router_refresh.dart";
import "../features/auth/presentation/auth_providers.dart";

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "root");

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(goRouterRefreshProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: "/catalog",
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateChangesProvider);
      final loc = state.matchedLocation;
      final loggingIn = loc == "/login";

      return auth.when(
        data: (user) {
          if (user == null && !loggingIn) return "/login";
          if (user != null && loggingIn) return "/catalog";
          return null;
        },
        loading: () => null,
        error: (error, stackTrace) => loggingIn ? null : "/login",
      );
    },
    routes: [
      GoRoute(
        path: "/login",
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/catalog",
                builder: (context, state) => const CatalogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/player",
                builder: (context, state) => const NowPlayingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/walk",
                builder: (context, state) => const WalkScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/history",
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/profile",
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: "/episode/:id",
        builder: (context, state) {
          final id = state.pathParameters["id"]!;
          return EpisodeDetailScreen(episodeId: id);
        },
      ),
    ],
  );
});

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: "Bài nghe",
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: "Phát",
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk),
            label: "Đi bộ",
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: "Lịch sử",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Hồ sơ",
          ),
        ],
      ),
    );
  }
}
