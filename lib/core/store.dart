import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Food {
  final String id, name, description, image;
  final double price;
  const Food(this.id, this.name, this.description, this.image, this.price);
}

const foods = <Food>[
  Food(
    'rice',
    'Beans and rice',
    'Extra Cheese Slice, Refundable, ketchup',
    'rice',
    11.78,
  ),
  Food(
    'burger',
    'Big Burger',
    'Extra Cheese Slice, Green Salads',
    'burger',
    12.87,
  ),
  Food(
    'pizza',
    'Super pizza',
    'Tomato sauce, mozzarella cheese',
    'pizza',
    11.78,
  ),
  Food(
    'pasta',
    'Super Pasta',
    'The world cannot be imagined without pasta',
    'pasta',
    11.78,
  ),
  Food(
    'salad',
    'Indian salad',
    'Avocado, Tomato, Rocca, Ranch Sauce',
    'salad',
    19,
  ),
  Food(
    'kfc',
    'KFC - piece of Chicken',
    'Chicken Pieces Marinated With Rich Mix',
    'kfc-meal',
    32,
  ),
  Food('fries', 'French fries', 'French fries with paprika', 'fries', 3),
  Food(
    'bucket',
    'KFC - piece of Chicken (Box)',
    'Chicken Pieces Marinated',
    'bucket',
    11,
  ),
  Food(
    'steak',
    'Vegetable Chicken Steak',
    'Enjoy a sweet and sour taste with a mixture of boiled vegetables and a delicious steak',
    'steak-hero',
    32,
  ),
  Food(
    'soup',
    'Tomato soup',
    'Fresh tomatoes, basil and vegetables',
    'soup',
    2,
  ),
];

class Restaurant {
  final String name, description, image;
  final double rating;
  const Restaurant(this.name, this.description, this.image, this.rating);
}

const restaurants = [
  Restaurant(
    'Galaxy Pizza',
    'Pizza hut, Marga pizza, Tasty food',
    'pizza-logo',
    4.2,
  ),
  Restaurant(
    'Burger King',
    'Beef Burger, Chicken Burger, Mayo',
    'burger-king-logo',
    4.8,
  ),
  Restaurant(
    "McDonald’s",
    'Beef Burger, Chicken Burger',
    'mcdonalds-logo',
    4.4,
  ),
  Restaurant('KFC', 'French fries, chicken pieces, mayo', 'kfc-logo', 4.2),
];

class Address {
  final String title, detail;
  const Address(this.title, this.detail);
  Map<String, String> toJson() => {'title': title, 'detail': detail};
}

class AppStore extends ChangeNotifier {
  final SharedPreferences? preferences;
  AppStore([this.preferences]) {
    _restore();
  }
  String name = 'Emmalynn Mazzia', country = 'France', payment = 'Credit Card';
  String selectedRestaurant = 'Super Pizza', searchQuery = '';
  Food selectedFood = foods[8];
  Map<String, int> cart = {}, lastOrder = {};
  double orderTotal = 0;
  Set<String> favorites = {};
  List<Address> addresses = [
    const Address('Mixeco', 'Rosecrans Ave, Suite 200 El Segundo, USA'),
    const Address('London', '14 rue La Boétie, France, Paris'),
  ];
  List<String> cards = [];
  int addressIndex = 0;
  int? editingAddress;
  List<String> messages = [];
  bool notifications = false,
      newsletter = false,
      offers = true,
      eco = true,
      preorder = false,
      delivered = false;
  bool signedIn = false, ordered = false, promo = false;
  String sort = 'Picked for you (default)', dietary = '';
  String? menuCategory, cuisine;
  bool filterApplied = false;
  int minRating = 0;
  final Set<String> filterFlags = {};
  String viewedOrder = '948994';
  double orderSubtotal = 0, orderDiscount = 0;
  String orderPayment = 'Cash';
  RangeValues priceRange = const RangeValues(0, 60);
  double get subtotal =>
      cart.entries.fold(0, (s, e) => s + unitPrice(e.key) * e.value);
  double get delivery => subtotal > 0 ? 2 : 0;
  double get discount => promo ? subtotal * .15 : 0;
  double get total => subtotal + delivery - discount;
  int get count => cart.values.fold(0, (a, b) => a + b);
  Address get address => addresses[addressIndex.clamp(0, addresses.length - 1)];
  Food food(String id) => foods.firstWhere((f) => f.id == id.split('|').first);
  double unitPrice(String key) =>
      food(key).price +
      (key.contains('|') ? double.parse(key.split('|').last) : 0);
  void add(Food item, [int quantity = 1, double extra = 0]) {
    final key = extra == 0 ? item.id : '${item.id}|$extra';
    cart[key] = (cart[key] ?? 0) + quantity;
    changed();
  }

  void quantity(String id, int change) {
    final n = (cart[id] ?? 0) + change;
    if (n <= 0) {
      cart.remove(id);
    } else {
      cart[id] = n;
    }
    changed();
  }

  void favorite(String id) {
    if (!favorites.add(id)) favorites.remove(id);
    changed();
  }

  void changed() {
    notifyListeners();
    _save();
  }

  void placeOrder() {
    ordered = true;
    lastOrder = Map.of(cart);
    orderTotal = total;
    orderSubtotal = subtotal;
    orderDiscount = discount;
    orderPayment = payment;
    delivered = false;
    changed();
  }

  void confirmDelivery() {
    delivered = true;
    cart.clear();
    changed();
  }

  static const categoryIds = <String, List<String>>{
    'Pizza': ['pizza'],
    'Pizza Hut': ['pizza'],
    'Italian': ['pasta', 'pizza'],
    'Burgers': ['burger'],
    'Burger': ['burger'],
    'American': ['burger', 'kfc', 'fries'],
    'Sea Food': ['pasta'],
    'Steak': ['steak'],
    'Chicken': ['kfc', 'fries', 'bucket'],
    'Vegan': ['rice', 'salad', 'soup'],
    'Salads': ['salad'],
    'Asian Food': ['rice', 'pasta'],
    'Asian': ['rice', 'pasta'],
    'Grill': ['steak', 'kfc'],
  };
  List<Food> get menuFoods => foods
      .where(
        (f) =>
            menuCategory == null ||
            (categoryIds[menuCategory] ?? []).contains(f.id),
      )
      .toList();
  double restaurantPrice(Restaurant r) => r.name == 'KFC'
      ? 32
      : r.name == 'Burger King'
      ? 13
      : 12;
  List<Restaurant> get filteredRestaurants {
    final result = restaurants.where((r) {
      if (!filterApplied) return true;
      final price = restaurantPrice(r);
      if (price < priceRange.start ||
          price > priceRange.end ||
          r.rating < minRating) {
        return false;
      }
      if (dietary.isNotEmpty && r.name == 'KFC') return false;
      if (filterFlags.contains('Free Delivery') &&
          !['KFC', 'Galaxy Pizza'].contains(r.name)) {
        return false;
      }
      if (cuisine == 'Burger' || cuisine == 'American') {
        return ['Burger King', 'McDonald’s'].contains(r.name);
      }
      if (['Pizza', 'Pizza Hut', 'Italian', 'Pasta'].contains(cuisine)) {
        return r.name == 'Galaxy Pizza';
      }
      if ([
        'Vegan',
        'Salads',
        'Asian',
        'French',
        'Mexican',
        'Sea Food',
      ].contains(cuisine)) {
        return r.name == 'Galaxy Pizza' || r.name == 'Burger King';
      }
      return true;
    }).toList();
    if (['Most Popular', 'Top Rated'].contains(sort)) {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    }
    if (sort == 'Cost Low to High') {
      result.sort((a, b) => restaurantPrice(a).compareTo(restaurantPrice(b)));
    }
    if (sort == 'Cost High to Low') {
      result.sort((a, b) => restaurantPrice(b).compareTo(restaurantPrice(a)));
    }
    if (sort == 'Delivery time' || sort == 'Nearest Me') {
      result.sort(
        (a, b) => restaurants.indexOf(b).compareTo(restaurants.indexOf(a)),
      );
    }
    return result;
  }

  void resetFilters() {
    filterApplied = false;
    cuisine = null;
    dietary = '';
    minRating = 0;
    filterFlags.clear();
    sort = 'Picked for you (default)';
    priceRange = const RangeValues(0, 60);
    changed();
  }

  void _restore() {
    final raw = preferences?.getString('gusto.v1');
    if (raw == null) return;
    try {
      final d = jsonDecode(raw) as Map<String, dynamic>;
      name = d['name'] ?? name;
      country = d['country'] ?? country;
      cart = Map<String, int>.from(d['cart'] ?? {});
      lastOrder = Map<String, int>.from(d['lastOrder'] ?? {});
      orderTotal = (d['orderTotal'] as num?)?.toDouble() ?? 0;
      payment = d['payment'] ?? payment;
      orderSubtotal = (d['orderSubtotal'] as num?)?.toDouble() ?? 0;
      orderDiscount = (d['orderDiscount'] as num?)?.toDouble() ?? 0;
      orderPayment = d['orderPayment'] ?? 'Cash';
      promo = d['promo'] ?? false;
      favorites = Set<String>.from(d['favorites'] ?? []);
      cards = List<String>.from(d['cards'] ?? []);
      if (d['addresses'] is List && (d['addresses'] as List).isNotEmpty) {
        addresses = (d['addresses'] as List)
            .map((a) => Address(a['title'], a['detail']))
            .toList();
      }
      addressIndex = d['addressIndex'] ?? 0;
      notifications = d['notifications'] ?? false;
      newsletter = d['newsletter'] ?? false;
      offers = d['offers'] ?? true;
      signedIn = d['signedIn'] ?? false;
      ordered = d['ordered'] ?? false;
      delivered = d['delivered'] ?? false;
      messages = List<String>.from(d['messages'] ?? []);
    } on FormatException {
      preferences?.remove('gusto.v1');
    }
  }

  void _save() {
    preferences?.setString(
      'gusto.v1',
      jsonEncode({
        'name': name,
        'country': country,
        'cart': cart,
        'lastOrder': lastOrder,
        'orderTotal': orderTotal,
        'orderSubtotal': orderSubtotal,
        'orderDiscount': orderDiscount,
        'orderPayment': orderPayment,
        'payment': payment,
        'promo': promo,
        'favorites': favorites.toList(),
        'cards': cards,
        'addresses': addresses.map((a) => a.toJson()).toList(),
        'addressIndex': addressIndex,
        'notifications': notifications,
        'newsletter': newsletter,
        'offers': offers,
        'signedIn': signedIn,
        'ordered': ordered,
        'delivered': delivered,
        'messages': messages,
      }),
    );
  }
}

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);
  static AppStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
