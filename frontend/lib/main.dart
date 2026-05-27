import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/admin_token_provider.dart';
import 'screens/user_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/login_screen.dart'; // Import nové login stránky

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monolitní navigace',
      theme: ThemeData.dark(),
      onGenerateRoute: (settings) {
        // Pokud uživatel zadal do prohlížeče domena.cz/admin
        if (settings.name == '/admin') {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => const AdminRouterBranch(),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const UserScreen(),
        );
      },
    );
  }
}

class AdminRouterBranch extends ConsumerWidget {
  const AdminRouterBranch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(adminTokenProvider);

    if (token != null) {
      return AdminScreen(
        onLogout: () {
          ref.read(adminTokenProvider.notifier).clearToken();
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
      );
    }

    return const LoginScreen();
  }
}
