import 'package:flutter/material.dart';
import 'core/screens.dart';
import 'core/store.dart';
import 'core/theme.dart';
import 'core/widgets.dart';
import 'features/account.dart';
import 'features/auth.dart';
import 'features/browse.dart';
import 'features/orders.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class GustoApp extends StatelessWidget {
  final AppStore store;
  final int initialScreen;
  const GustoApp({super.key, required this.store, this.initialScreen = 15});
  @override
  Widget build(BuildContext context) => AppScope(
    store: store,
    child: MaterialApp(
      title: 'Gusto',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      navigatorKey: navigatorKey,
      initialRoute: '/screen/$initialScreen',
      onGenerateInitialRoutes: (route) => [_route(route)],
      onGenerateRoute: (settings) => _route(settings.name ?? '/screen/15'),
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFF0F0F2),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: child,
          ),
        ),
      ),
    ),
  );
  Route<dynamic> _route(String route) => MaterialPageRoute(
    settings: RouteSettings(name: route),
    builder: (context) {
      if (route == '/screens') return const ScreenGallery();
      final n = int.tryParse(route.split('/').last) ?? 15;
      return ScreenHost(n.clamp(1, 60));
    },
  );
}

class ScreenHost extends StatelessWidget {
  final int number;
  const ScreenHost(this.number, {super.key});
  @override
  Widget build(BuildContext context) {
    if (number <= 13 || number == 44) {
      return AuthPage(number, key: ValueKey(number));
    }
    if ([19, 20, 23, 24, 25, 26, 27, 31, 40, 41].contains(number)) {
      return OrdersPage(number, key: ValueKey(number));
    }
    if ([28, 29, 30, 32, 33, 34, 45, 50, 54, 55, 57].contains(number)) {
      return AccountPage(number, key: ValueKey(number));
    }
    return BrowsePage(number, key: ValueKey(number));
  }
}

class ScreenGallery extends StatelessWidget {
  const ScreenGallery({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Pixso Screens',
    body: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text(
          '60 screens · iPhone 11 Pro\nUI Kit: colors, typography, controls and icons',
          style: TextStyle(color: muted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        for (final group in [
          'Authentication',
          'Browse',
          'Orders & Delivery',
          'Account',
        ]) ...[
          SectionTitle(group),
          ...screens
              .where((s) => s.group == group)
              .map(
                (s) => MenuRow(
                  '#${s.number.toString().padLeft(2, '0')}  ${s.name}',
                  subtitle: 'Pixso ${s.nodeId}',
                  onTap: () => go(context, s.number),
                ),
              ),
        ],
      ],
    ),
  );
}
