import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gusto/app.dart';
import 'package:gusto/core/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
    await loader.load();
  });
  test(
    'cart preserves configured prices, quantities, discount and delivery',
    () {
      final store = AppStore();
      store.add(foods[1], 2, 3);
      store.add(foods[6]);
      expect(store.count, 3);
      expect(store.subtotal, closeTo(34.74, .001));
      store.promo = true;
      expect(store.total, closeTo(31.529, .001));
      store.quantity('burger|3.0', -1);
      expect(store.count, 2);
      store.quantity('fries', -1);
      expect(store.cart.containsKey('fries'), false);
      store.favorite('KFC');
      expect(store.favorites, contains('KFC'));
      store.favorite('KFC');
      expect(store.favorites, isEmpty);
    },
  );

  test('order snapshot survives delivery and local storage reload', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = AppStore(prefs)
      ..add(foods[1], 2)
      ..favorite('KFC');
    store.promo = true;
    store.payment = 'Cash';
    store.placeOrder();
    final total = store.total;
    store.confirmDelivery();
    final restored = AppStore(prefs);
    expect(restored.cart, isEmpty);
    expect(restored.lastOrder['burger'], 2);
    expect(restored.orderTotal, total);
    expect(restored.orderSubtotal, closeTo(25.74, .001));
    expect(restored.delivered, true);
    expect(restored.favorites, contains('KFC'));
  });
  test('price, rating, cuisine and category filters affect results', () {
    final store = AppStore()..filterApplied = true;
    store.priceRange = const RangeValues(20, 60);
    expect(store.filteredRestaurants.map((r) => r.name), ['KFC']);
    store.resetFilters();
    store.filterApplied = true;
    store.minRating = 5;
    expect(store.filteredRestaurants, isEmpty);
    store.resetFilters();
    store.filterApplied = true;
    store.cuisine = 'Burger';
    expect(store.filteredRestaurants.length, 2);
    store.menuCategory = 'Vegan';
    expect(store.menuFoods.map((f) => f.id), ['rice', 'salad', 'soup']);
  });

  testWidgets('all 60 Pixso screens render without layout errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = AppStore()
      ..add(foods[0])
      ..add(foods[1])
      ..add(foods[4]);
    store.favorites.addAll(['KFC', foods[1].id]);
    await tester.pumpWidget(GustoApp(store: store));
    await tester.pumpAndSettle();
    for (var n = 1; n <= 60; n++) {
      navigatorKey.currentState!.pushReplacementNamed('/screen/$n');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Screen $n');
    }
  });

  testWidgets('add food, adjust quantity, checkout and confirm delivery', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = AppStore();
    await tester.pumpWidget(GustoApp(store: store, initialScreen: 22));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-to-order')));
    await tester.pumpAndSettle();
    expect(store.count, 1);
    expect(store.subtotal, 33); // Steak plus selected sauce.
    await tester.tap(find.byKey(const Key('checkout')));
    await tester.pumpAndSettle();
    store.payment = 'Cash';
    store.changed();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();
    expect(store.ordered, true);
    await tester.tap(find.text('Confirm Delivery'));
    await tester.pumpAndSettle();
    expect(store.delivered, true);
    expect(store.cart, isEmpty);
  });
}
