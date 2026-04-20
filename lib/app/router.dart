import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../features/auth/presentation/login_screen.dart";
import "../features/librivox_books/presentation/listen_screen.dart";
import "../features/listen_history/presentation/history_screen.dart";
import "../features/listen_history/presentation/history_day_detail_screen.dart";
import "../features/player/presentation/now_playing_screen.dart";
import "../features/librivox_books/presentation/librivox_book_detail_screen.dart";
import "../features/librivox_sync/presentation/librivox_sync_screen.dart";
import "../features/profile/presentation/profile_screen.dart";
import "../features/profile/presentation/profile_edit_screen.dart";
import "../features/progress/presentation/progress_screen.dart";
import "../features/vocabulary/presentation/learned_words_screen.dart";
import "../features/vocabulary/presentation/today_screen.dart";
import "go_router_refresh.dart";
import "mini_player_bar.dart";
import "../features/auth/presentation/auth_providers.dart";

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "root");

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(goRouterRefreshProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: "/today",
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateChangesProvider);
      final loc = state.matchedLocation;
      final loggingIn = loc == "/login";

      return auth.when(
        data: (user) {
          if (user == null && !loggingIn) return "/login";
          if (user != null && loggingIn) return "/today";
          return null;
        },
        loading: () => null,
        error: (error, stackTrace) => loggingIn ? null : "/login",
      );
    },
    routes: [
      GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/today",
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/progress",
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/listen",
                builder: (context, state) => const ListenScreen(),
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
        path: "/player",
        builder: (context, state) {
          final autoplay = state.uri.queryParameters["autoplay"] == "1";
          return NowPlayingScreen(autoPlayOnOpen: autoplay);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: "/history",
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: "/librivox-sync",
        builder: (context, state) => const LibrivoxSyncScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: "/learned-words",
        builder: (context, state) => const LearnedWordsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: "/history/day/:dateKey",
        builder: (context, state) {
          final key = state.pathParameters["dateKey"]!;
          return HistoryDayDetailScreen(dateKey: key);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: "/profile/edit",
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: "/book/:bookId",
        builder: (context, state) {
          final id = state.pathParameters["bookId"]!;
          return LibrivoxBookDetailScreen(bookId: id);
        },
      ),
    ],
  );
});

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: "Hôm nay",
              ),
              NavigationDestination(
                icon: Icon(Icons.show_chart_outlined),
                selectedIcon: Icon(Icons.show_chart),
                label: "Tiến độ",
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: "Bài nghe",
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: "Hồ sơ",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
