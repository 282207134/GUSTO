import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gusto/app.dart';
import 'package:gusto/core/store.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture all 60 screens on Android and exercise checkout', (
    tester,
  ) async {
    final store = AppStore()
      ..add(foods[0])
      ..add(foods[1])
      ..add(foods[4]);
    store.favorites.addAll(restaurants.map((r) => r.name));
    store.favorites.add(foods[1].id);
    await tester.pumpWidget(GustoApp(store: store));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    const first = int.fromEnvironment('CAPTURE_FROM', defaultValue: 1);
    const last = int.fromEnvironment('CAPTURE_TO', defaultValue: 20);
    for (var n = first; n <= last; n++) {
      navigatorKey.currentState!.pushReplacementNamed('/screen/$n');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Screen $n');
      await binding.takeScreenshot(n.toString().padLeft(2, '0'));
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    }
    navigatorKey.currentState!.pushReplacementNamed('/screen/22');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-to-order')));
    await tester.pumpAndSettle();
    expect(store.count, 4);
    await tester.tap(find.byKey(const Key('checkout')));
    await tester.pumpAndSettle();
    store.payment = 'Cash';
    store.changed();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();
    expect(store.ordered, true);
    navigatorKey.currentState!.pushNamed('/screen/27');
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('chat-input')),
      'Please leave it at the door.',
    );
    await tester.tap(find.byKey(const Key('send-message')));
    await tester.pumpAndSettle();
    expect(store.messages.last, 'Please leave it at the door.');
  });
}
