import 'package:flutter/material.dart';
import '../core/store.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

const categoryNames = [
  'Pizza',
  'Burgers',
  'Sea Food',
  'Steak',
  'Chicken',
  'Vegan',
  'Asian Food',
  'Grill',
];
const categoryIcons = [
  'pizza',
  'burger',
  'fish',
  'steak',
  'chicken',
  'vegan',
  'asian',
  'grill',
];
const categoryCounts = [12, 329, 13, 92, 76, 68, 65, 97];

void selectFood(BuildContext context, Food food, [int screen = 22]) {
  AppScope.of(context).selectedFood = food;
  go(context, screen);
}

class FoodTile extends StatelessWidget {
  final Food food;
  final bool card;
  const FoodTile(this.food, {super.key, this.card = false});
  @override
  Widget build(BuildContext context) {
    if (card) {
      return InkWell(
        onTap: () => selectFood(context, food),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Picture(
                food.image,
                width: double.infinity,
                height: 132,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              food.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Text(
              'Free Delivery',
              style: TextStyle(fontSize: 11, color: muted),
            ),
            const SizedBox(height: 5),
            Text(euro(food.price), style: const TextStyle(fontSize: 13)),
            const Stars(),
          ],
        ),
      );
    }
    return InkWell(
      onTap: () => selectFood(context, food),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Picture(food.image, width: 80, height: 80),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    food.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Price ${euro(food.price)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 17, color: muted),
          ],
        ),
      ),
    );
  }
}

class RestaurantTile extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantTile(this.restaurant, {super.key});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {
      AppScope.of(context).selectedRestaurant = restaurant.name;
      AppScope.of(context).menuCategory = null;
      go(context, restaurant.name == 'KFC' ? 18 : 17);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      child: Row(
        children: [
          Picture(restaurant.image, width: 76, height: 76),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  restaurant.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 5),
                Stars(rating: restaurant.rating),
                const SizedBox(height: 5),
                const Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: muted),
                    SizedBox(width: 4),
                    Text(
                      '30 – 40 Mins',
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Delivery 10 Mins',
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class BrowsePage extends StatefulWidget {
  final int screen;
  const BrowsePage(this.screen, {super.key});
  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  String query = '', activeCategory = 'Burger';
  int quantity = 1, cheese = 0, sauce = 1, menuTab = 0;
  final searchController = TextEditingController();
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      initialized = true;
      if (widget.screen == 60) {
        query = AppScope.of(context).searchQuery.isEmpty
            ? 'burger'
            : AppScope.of(context).searchQuery;
        searchController.text = query;
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.screen;
    if ([14, 15].contains(s)) return _discover(s);
    if ([16, 56].contains(s)) return _restaurantList(s);
    if ([17, 18, 21].contains(s)) return _restaurant(s);
    if (s == 22) return _foodDetails();
    if ([35, 39].contains(s)) return _mapRestaurant(s);
    if (s == 37) return _countries();
    if ([36, 38, 60].contains(s)) return _search(s);
    if (s == 42) return _find();
    if ([43, 46, 47].contains(s)) return _categories(s);
    if ([48, 49, 51, 52, 53].contains(s)) return _filter(s);
    return _menu(s);
  }

  Widget _filterBar() => Container(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: line),
        top: BorderSide(color: line),
      ),
    ),
    child: Row(
      children: [
        TextButton.icon(
          onPressed: () => go(context, 49),
          icon: const Icon(Icons.filter_alt_outlined, size: 19),
          label: const Text('Filter'),
        ),
        const SizedBox(height: 24, child: VerticalDivider()),
        TextButton.icon(
          onPressed: () => go(context, 51),
          icon: const Icon(Icons.swap_vert, size: 19),
          label: const Text('Sort'),
        ),
        const SizedBox(height: 24, child: VerticalDivider()),
        TextButton(
          onPressed: () => go(context, 54),
          child: const Text(
            'NEW',
            style: TextStyle(
              color: Color(0xFF101E52),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        const Icon(Icons.circle_outlined, size: 18, color: muted),
      ],
    ),
  );
  Widget _discover(int s) => PageFrame(
    title: s == 14 ? 'GUSTO' : 'Home',
    large: false,
    bottom: true,
    tab: s == 14 ? 1 : 0,
    actions: [
      IconButton(
        tooltip: 'Choose country',
        onPressed: () => go(context, 37),
        icon: const Text('🇫🇷', style: TextStyle(fontSize: 22)),
      ),
      IconButton(
        tooltip: 'Search',
        onPressed: () => go(context, 38),
        icon: const Icon(Icons.search, size: 22),
      ),
    ],
    body: Column(
      children: [
        _filterBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (s == 14) ...[
                const SizedBox(height: 16),
                SearchBox(
                  hint: 'Restaurant or food',
                  onTap: () => go(context, 38),
                ),
                const SectionTitle('Discovery New Places'),
                _roundFoods(),
              ] else ...[
                SectionTitle('Categories', onTap: () => go(context, 46)),
                _categoryStrip(colored: true),
              ],
              if (s == 15) ...[
                SectionTitle(
                  'Discover new place',
                  onTap: () => go(context, 16),
                ),
                _featured(),
                SectionTitle('Popular Food', onTap: () => go(context, 58)),
                _featured(second: true),
                SectionTitle('Best Food', onTap: () => go(context, 59)),
                _roundFoods(),
              ] else ...[
                SectionTitle('Categories', onTap: () => go(context, 46)),
                _categoryStrip(),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _featured({bool second = false}) => SizedBox(
    height: 225,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 2,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (context, i) {
        final image = second
            ? (i == 0 ? 'pizza-cheese' : 'kfc-hero')
            : (i == 0 ? 'pizza' : 'pizza-cheese');
        return SizedBox(
          width: MediaQuery.sizeOf(context).width * .52,
          child: InkWell(
            onTap: () => go(context, second && i == 1 ? 18 : 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Picture(
                    image,
                    height: 132,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  second
                      ? (i == 0 ? 'Pizza Hut' : 'KFC')
                      : (i == 0 ? 'Super Pizza' : 'Shrimp and delicious rice'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Free Delivery',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 7),
                Text(
                  i == 0 ? '€ 8.12' : '€ 6.00',
                  style: const TextStyle(fontSize: 13),
                ),
                const Stars(),
              ],
            ),
          ),
        );
      },
    ),
  );
  Widget _roundFoods() => SizedBox(
    height: 224,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (context, i) {
        final f = [foods[0], foods[1], foods[9]][i];
        return SizedBox(
          width: 145,
          child: InkWell(
            onTap: () => selectFood(context, f),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Picture(f.image, width: 145, height: 151),
                const SizedBox(height: 10),
                Text(
                  i == 0
                      ? 'Rice with peas'
                      : i == 1
                      ? "McDonald’s"
                      : 'Lentil soup',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                Text(
                  euro(f.price),
                  style: const TextStyle(fontSize: 13, color: muted),
                ),
                const Stars(),
              ],
            ),
          ),
        );
      },
    ),
  );
  Widget _categoryStrip({bool colored = false}) => SizedBox(
    height: 131,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 8,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (context, i) => InkWell(
        onTap: () => _categoryTap(i),
        child: SizedBox(
          width: 82,
          child: Column(
            children: [
              Container(
                height: 77,
                width: 82,
                decoration: BoxDecoration(
                  color: colored
                      ? [
                          yellow,
                          const Color(0xFFF9A889),
                          const Color(0xFFF67DAC),
                          const Color(0xFF81D6CE),
                        ][i % 4]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Picture(
                    'icon-${categoryIcons[i]}',
                    width: 43,
                    height: 43,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                categoryNames[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${categoryCounts[i]} Item',
                style: const TextStyle(fontSize: 10, color: muted),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  void _categoryTap(int i) {
    AppScope.of(context).menuCategory = categoryNames[i];
    AppScope.of(context).selectedRestaurant = categoryNames[i] == 'Chicken'
        ? 'KFC'
        : 'Roma restaurant';
    go(context, categoryNames[i] == 'Chicken' ? 18 : 58);
  }

  Widget _restaurantList(int s) {
    final store = AppScope.of(context);
    final list = store.filteredRestaurants
        .where((r) => s != 56 || store.favorites.contains(r.name))
        .toList();
    if (store.sort == 'Most Popular') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return PageFrame(
      title: s == 56 ? 'Favorit' : '59, rue Ernest Renan..',
      large: s == 56,
      bottom: true,
      tab: 1,
      actions: [
        IconButton(
          tooltip: 'Search',
          onPressed: () => go(context, 38),
          icon: const Icon(Icons.search),
        ),
      ],
      body: Column(
        children: [
          if (s == 56)
            _tabs(
              ['Restaurant', 'Dishes'],
              menuTab,
              (i) => setState(() => menuTab = i),
            )
          else
            _filterBar(),
          if (s != 56)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${list.length} Open restaurants',
                  style: TextStyle(color: muted, fontSize: 14),
                ),
              ),
            ),
          Expanded(
            child: s == 56 && menuTab == 1
                ? _favoriteFoods()
                : list.isEmpty
                ? EmptyState(
                    s == 56 ? 'No favorites yet' : 'No restaurants found',
                    subtitle: s == 56
                        ? 'Tap a heart on a restaurant or dish to save it.'
                        : 'Adjust the price, rating or cuisine filters.',
                    icon: Icons.favorite_border,
                    action: PrimaryButton(
                      'Discover restaurants',
                      onPressed: () => go(context, 16),
                    ),
                  )
                : ListView(children: list.map(RestaurantTile.new).toList()),
          ),
        ],
      ),
    );
  }

  Widget _favoriteFoods() {
    final store = AppScope.of(context);
    final list = foods.where((f) => store.favorites.contains(f.id)).toList();
    return list.isEmpty
        ? const EmptyState(
            'No favorite dishes',
            subtitle: 'Save your favorite dishes from Food Details.',
            icon: Icons.favorite_border,
          )
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: list.map(FoodTile.new).toList(),
          );
  }

  Widget _tabs(List<String> labels, int selected, ValueChanged<int> onTap) =>
      Row(
        children: List.generate(
          labels.length,
          (i) => Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == selected ? yellow : line,
                      width: i == selected ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: i == selected ? Colors.black : muted,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  Widget _restaurant(int s) {
    final store = AppScope.of(context);
    final kfc = s != 17;
    final favorite = store.favorites.contains(
      kfc ? 'KFC' : store.selectedRestaurant,
    );
    final page = Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Picture(
                  kfc ? 'kfc-hero' : 'restaurant-hero',
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .2),
                        const Color(0xFF080D22).withValues(alpha: .9),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => back(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Favorite restaurant',
                        onPressed: () => store.favorite(
                          kfc ? 'KFC' : store.selectedRestaurant,
                        ),
                        icon: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          color: favorite ? yellow : Colors.white,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Search menu',
                        onPressed: () => go(context, 38),
                        icon: const Icon(Icons.search, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 28,
                  left: 16,
                  right: 16,
                  child: kfc
                      ? Column(
                          children: [
                            const Picture('kfc-logo', width: 80, height: 80),
                            const SizedBox(height: 16),
                            const Text(
                              'Chicken - KFC',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Open',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Stars(),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Free delivery',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              store.selectedRestaurant,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '♧  431 France / Paris',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              children: [
                                Text(
                                  'Closed',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Stars(),
                              ],
                            ),
                            const SizedBox(height: 25),
                            const Row(
                              children: [
                                Icon(
                                  Icons.star_border,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '4.2\n210 Ratings',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 40),
                                Icon(
                                  Icons.room_service_outlined,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '265\nDishes',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: kfc
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delivery_dining,
                              size: 22,
                              color: muted,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '20 – 45 Mins',
                              style: TextStyle(color: muted),
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () => store.favorite('KFC'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: muted),
                              ),
                              child: Text(
                                favorite ? 'Favorited' : 'Add to favorite',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _tabs(
                        ['Menu Item', 'Most Selling', 'Salads', 'Burger'],
                        menuTab,
                        (i) => setState(() => menuTab = i),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SectionTitle(
                          'Featured Items',
                          onTap: () => go(context, 59),
                        ),
                        _featured(),
                        SectionTitle('Full menu', onTap: () => go(context, 58)),
                      ],
                    ),
                  ),
          ),
          if (kfc)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.list(
                children:
                    (menuTab == 2
                            ? [foods[4]]
                            : menuTab == 3
                            ? [foods[1]]
                            : foods.sublist(5, 8))
                        .map(
                          (f) =>
                              Column(children: [FoodTile(f), const Divider()]),
                        )
                        .toList(),
              ),
            )
          else
            SliverList.list(
              children: [
                MenuRow(
                  'Popular items',
                  trailing: '3',
                  onTap: () => go(context, 58),
                ),
                MenuRow('Salads', trailing: '6', onTap: () => go(context, 59)),
              ],
            ),
        ],
      ),
    );
    if (s != 21) return page;
    return Stack(
      children: [
        page,
        Container(color: Colors.black45),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: Picture('bucket', height: 130)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Italian Pasta',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(euro(32)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'QTY',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        QuantityControl(
                          quantity,
                          minus: () => setState(
                            () => quantity = quantity > 1 ? quantity - 1 : 1,
                          ),
                          plus: () => setState(() => quantity++),
                        ),
                      ],
                    ),
                    const Text(
                      'About This',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'KFC is the first restaurant in the United States with several branches around the world, Kentucky chicken pieces',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      'Add Items',
                      dark: true,
                      icon: Icons.add,
                      onPressed: () {
                        store.add(foods[5], quantity);
                        go(context, 19);
                      },
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => selectFood(context, foods[5]),
                        child: const Text(
                          'More details',
                          style: TextStyle(color: muted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _foodDetails() {
    final store = AppScope.of(context),
        food = AppScope.of(context).selectedFood;
    final price = food.price + cheese * 2 + [1.0, 1.0, 4.0, .5][sauce];
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Picture(
                  food.image,
                  height: 270,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 270,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black26, Colors.transparent],
                    ),
                  ),
                ),
                SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => back(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Favorite dish',
                        onPressed: () => store.favorite(food.id),
                        icon: Icon(
                          store.favorites.contains(food.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  food.description,
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Text(
                  euro(food.price),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SectionTitle('Extra Cheese'),
                const Text(
                  'Choose items from the list',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                ...List.generate(
                  3,
                  (i) => _option(
                    '${i + 1} Extra Cheese Slice',
                    euro((i + 1) * 2),
                    cheese == i + 1,
                    () => setState(() => cheese = cheese == i + 1 ? 0 : i + 1),
                  ),
                ),
                const SectionTitle('Extra Sauces'),
                const Text(
                  'Choose items from the list',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                ...List.generate(
                  4,
                  (i) => _option(
                    ['Maychip', 'Refundable', 'Thousand islands', 'Ketchup'][i],
                    euro([1, 1, 4, .5][i]),
                    sauce == i,
                    () => setState(() => sauce = i),
                  ),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Quantity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    QuantityControl(
                      quantity,
                      minus: () => setState(
                        () => quantity = quantity > 1 ? quantity - 1 : 1,
                      ),
                      plus: () => setState(() => quantity++),
                    ),
                  ],
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '$quantity Items',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    'Total ${euro(price * quantity)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                'Add to Order',
                key: const Key('add-to-order'),
                onPressed: () {
                  store.add(food, quantity, price - food.price);
                  go(context, 19);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(
    String title,
    String price,
    bool selected,
    VoidCallback onTap,
  ) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, color: muted),
            ),
          ),
          Text(price, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 14),
          Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            size: 21,
            color: selected ? yellow : line,
          ),
        ],
      ),
    ),
  );
  Widget _categories(int s) => PageFrame(
    title: s == 43
        ? 'Discover'
        : s == 46
        ? 'Food Categories'
        : 'Categories',
    large: s != 43,
    bottom: true,
    tab: 1,
    body: s == 47
        ? ListView(
            children: List.generate(
              8,
              (i) => MenuRow(
                categoryNames[i],
                trailing: '${categoryCounts[i]}',
                onTap: () => _categoryTap(i),
              ),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: s == 43 ? 2 : 3,
              mainAxisExtent: s == 43 ? 157 : 140,
              crossAxisSpacing: 18,
              mainAxisSpacing: 20,
            ),
            itemCount: s == 43 ? 6 : 8,
            itemBuilder: (context, i) => InkWell(
              onTap: () {
                if (s == 43) {
                  AppScope.of(context).menuCategory = [
                    'Asian Food',
                    'Grill',
                    'Vegan',
                    'Sea Food',
                    'Steak',
                    'Grill',
                  ][i];
                  go(context, 58);
                } else {
                  _categoryTap(i);
                }
              },
              child: Column(
                children: [
                  Container(
                    height: s == 43 ? 90 : 85,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: s == 43
                          ? []
                          : const [
                              BoxShadow(
                                color: Color(0x10000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Picture(
                        s == 43
                            ? 'discover-${['asian', 'dining', 'soup', 'fish', 'steak', 'grill'][i]}'
                            : 'icon-${categoryIcons[i]}',
                        height: s == 43 ? 70 : 48,
                        width: s == 43 ? 70 : 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    s == 43
                        ? [
                            'Asian Food',
                            'Fine Dining',
                            'Soups',
                            'Fish',
                            'Steak',
                            'Grills',
                          ][i]
                        : categoryNames[i],
                    maxLines: 1,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${s == 43 ? [4, 17, 56, 83, 34, 348][i] : categoryCounts[i]} Item',
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
          ),
  );
  Widget _menu(int s) => PageFrame(
    title: '59, rue Ernest Renan..',
    large: false,
    bottom: true,
    tab: 1,
    actions: [
      IconButton(
        tooltip: 'Change menu layout',
        onPressed: () => go(context, s == 58 ? 59 : 58),
        icon: Icon(
          s == 58 ? Icons.grid_view_outlined : Icons.view_list_outlined,
        ),
      ),
    ],
    body: Column(
      children: [
        _filterBar(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppScope.of(context).selectedRestaurant == 'Super Pizza'
                      ? 'Roma restaurant'
                      : AppScope.of(context).selectedRestaurant,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                color: const Color(0xFFFFF4D8),
                padding: const EdgeInsets.all(4),
                child: const Text('236 Dishes', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ),
        Expanded(
          child: s == 59
              ? ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final (image, food) in [
                      ('pizza-menu', foods[2]),
                      ('green-pasta', foods[3]),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: InkWell(
                          onTap: () => selectFood(context, food),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Picture(
                                  image,
                                  width: double.infinity,
                                  height: 185,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                food.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                food.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: muted,
                                ),
                              ),
                              Text(
                                'Price ${euro(food.price)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: AppScope.of(context).menuCategory == null
                      ? 5
                      : AppScope.of(context).menuFoods.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, i) => FoodTile(
                    (AppScope.of(context).menuCategory == null
                        ? [foods[3], foods[1], foods[2], foods[4], foods[5]]
                        : AppScope.of(context).menuFoods)[i],
                  ),
                ),
        ),
      ],
    ),
  );
  Widget _mapRestaurant(int s) => Scaffold(
    body: Stack(
      children: [
        const Positioned.fill(child: Picture('map', fit: BoxFit.cover)),
        SafeArea(
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => back(context),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  s == 35 ? 'Near You' : 'Restaurant Details',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        for (final (x, y, img) in [
          (.24, .24, 'kfc-logo'),
          (.65, .3, 'mcdonalds-logo'),
          (.8, .38, 'burger-king-logo'),
          (.3, .48, 'pizza-logo'),
        ])
          Positioned(
            left: MediaQuery.sizeOf(context).width * x,
            top: MediaQuery.sizeOf(context).height * y,
            child: InkWell(
              onTap: () => go(context, 39),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: yellow, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8),
                  ],
                ),
                child: Picture(img, width: 30, height: 30),
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: s == 35 ? 355 : 305,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: s == 35
                    ? Column(
                        children: [
                          SectionTitle(
                            'Restaurant Near you',
                            onTap: () => go(context, 16),
                          ),
                          Expanded(child: _featured()),
                        ],
                      )
                    : Column(
                        children: [
                          const Picture(
                            'mcdonalds-logo',
                            width: 60,
                            height: 60,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'McDonald’s',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Pizza hut, Marga pizza, Tasty food',
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                          const Stars(),
                          const SizedBox(height: 10),
                          const Text(
                            '◷  30 – 40 Mins     Delivery 10 Mins',
                            style: TextStyle(fontSize: 12, color: muted),
                          ),
                          const Spacer(),
                          PrimaryButton(
                            'Visit Restaurant',
                            onPressed: () {
                              AppScope.of(context).selectedRestaurant =
                                  'McDonald’s';
                              go(context, 17);
                            },
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _countries() {
    final store = AppScope.of(context);
    const names = [
      'USA',
      'UK',
      'France',
      'Italy',
      'Germany',
      'Greece',
      'KSA',
      'Canada',
      'Poland',
      'Belgium',
    ];
    const flags = [
      '🇺🇸',
      '🇬🇧',
      '🇫🇷',
      '🇮🇹',
      '🇩🇪',
      '🇬🇷',
      '🇸🇦',
      '🇨🇦',
      '🇵🇱',
      '🇧🇪',
    ];
    return PageFrame(
      title: 'Select your Country',
      actions: [
        TextButton(
          onPressed: () => back(context),
          child: const Text('Done', style: TextStyle(color: Colors.black)),
        ),
      ],
      body: ListView(
        children: List.generate(
          names.length,
          (i) => ListTile(
            leading: Text(flags[i]),
            title: Text(names[i]),
            trailing: store.country == names[i]
                ? const Icon(Icons.check, color: yellow)
                : null,
            onTap: () {
              store.country = names[i];
              store.changed();
            },
          ),
        ),
      ),
    );
  }

  Widget _search(int s) {
    final location = s == 36, result = s == 60;
    final list = foods
        .where(
          (f) => '${f.name} ${f.description}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    return PageFrame(
      title: location
          ? 'Find the nearest restaurants in your area'
          : result
          ? 'Search Result'
          : 'Search',
      large: location || result,
      actions: [
        TextButton(
          onPressed: () => location ? go(context, 35) : back(context),
          child: const Text('Done', style: TextStyle(color: Colors.black)),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBox(
              controller: searchController,
              hint: location ? 'Enter your location' : 'Restaurant or food',
              onChanged: (v) => setState(() => query = v),
              onSubmitted: (_) {
                if (location) {
                  go(context, 35);
                } else {
                  AppScope.of(context).searchQuery = query;
                  go(context, 60);
                }
              },
            ),
          ),
          if (location)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Please enter your location or allow access to your location to find restaurants near you.',
                style: TextStyle(color: muted, fontSize: 13),
              ),
            ),
          if (!location && !result)
            _tabs(
              ['Restaurant', 'Food'],
              menuTab,
              (i) => setState(() => menuTab = i),
            ),
          Expanded(
            child: location
                ? ListView(
                    children:
                        [
                              'France Street',
                              'Francesca Court',
                              'Francey Street',
                              'Francene Place',
                            ]
                            .where(
                              (n) =>
                                  n.toLowerCase().contains(query.toLowerCase()),
                            )
                            .map(
                              (n) => MenuRow(
                                n,
                                subtitle: 'Eastern Heights QLD, Australia',
                                icon: Icons.near_me_outlined,
                                onTap: () => go(context, 35),
                              ),
                            )
                            .toList(),
                  )
                : menuTab == 0 && !result
                ? ListView(
                    children: restaurants
                        .where(
                          (r) => r.name.toLowerCase().contains(
                            query.toLowerCase(),
                          ),
                        )
                        .map(RestaurantTile.new)
                        .toList(),
                  )
                : list.isEmpty
                ? const EmptyState(
                    'No results',
                    subtitle: 'Try pizza, burger, rice or chicken.',
                    icon: Icons.search,
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: list.map(FoodTile.new).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _find() => PageFrame(
    title: 'France, Paris',
    large: false,
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 15),
        const Icon(Icons.pin_drop_outlined, color: orange, size: 90),
        const SizedBox(height: 15),
        const Text(
          'Find Restaurant\nNear You',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        SearchBox(hint: 'Your location', onTap: () => go(context, 36)),
        const SectionTitle('Category'),
        ...[
          'Burger',
          'Italian',
          'French',
          'Asian',
          'Mexican',
          'Salads',
          'Vegan',
          'Pizza',
        ].map(
          (n) => _option(
            n,
            '',
            activeCategory == n,
            () => setState(() => activeCategory = n),
          ),
        ),
      ],
    ),
    footer: PrimaryButton(
      'Find',
      onPressed: () {
        final store = AppScope.of(context);
        store.cuisine = activeCategory;
        store.filterApplied = true;
        store.changed();
        go(context, 16);
      },
    ),
  );
  void _applyFilters() {
    final store = AppScope.of(context);
    store.filterApplied = true;
    store.changed();
    go(context, 16);
  }

  Widget _filter(int s) {
    final store = AppScope.of(context);
    final top = s >= 51;
    final active = s == 52
        ? 1
        : s == 53
        ? 2
        : 0;
    final panel = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(top ? 0 : 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!top)
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _applyFilters,
                    child: const Text(
                      'Show Results',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            if (top)
              _tabs(
                ['Sort', 'Price', 'Dietary'],
                active,
                (i) => go(context, [51, 52, 53][i]),
              ),
            if (active == 0)
              ...[
                'Picked for you (default)',
                'Most Popular',
                'Delivery time',
                if (!top) ...[
                  'Top Rated',
                  'Nearest Me',
                  'Cost Low to High',
                  'Cost High to Low',
                ],
              ].map(
                (n) => _option(n, '', store.sort == n, () {
                  store.sort = n;
                  store.changed();
                }),
              ),
            if (active == 1 || !top) ...[
              const SectionTitle('Price Range'),
              RangeSlider(
                values: store.priceRange,
                min: 0,
                max: 60,
                divisions: 12,
                labels: RangeLabels(
                  euro(store.priceRange.start),
                  euro(store.priceRange.end),
                ),
                activeColor: yellow,
                onChanged: (v) {
                  store.priceRange = v;
                  store.changed();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(euro(store.priceRange.start)),
                  Text(euro(store.priceRange.end)),
                ],
              ),
            ],
            if (active == 2)
              ...['Vegetarian', 'Vegan', 'Gluten-Free'].map(
                (n) => _option(n, '', store.dietary == n, () {
                  store.dietary = store.dietary == n ? '' : n;
                  store.changed();
                }),
              ),
            if (!top) ...[
              const SectionTitle('Category'),
              Wrap(
                spacing: 8,
                children:
                    [
                          'Asian',
                          'American',
                          'Pizza Hut',
                          'Burger',
                          'Pasta',
                          'Sea Food',
                          'Italian',
                          'Vegan',
                        ]
                        .map(
                          (n) => ChoiceChip(
                            label: Text(
                              n,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: store.cuisine == n,
                            selectedColor: yellow,
                            onSelected: (_) {
                              store.cuisine = store.cuisine == n ? null : n;
                              store.changed();
                            },
                          ),
                        )
                        .toList(),
              ),
            ],
            const SizedBox(height: 18),
            PrimaryButton('Done', outline: true, onPressed: _applyFilters),
          ],
        ),
      ),
    );
    if (s == 49) {
      return PageFrame(
        title: 'Filter',
        large: false,
        actions: [
          TextButton(
            onPressed: store.resetFilters,
            child: const Text('Reset', style: TextStyle(color: muted)),
          ),
          TextButton(
            onPressed: _applyFilters,
            child: const Text('Apply', style: TextStyle(color: Colors.black)),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionTitle('Category'),
            ...[
              'Burger',
              'Italian',
              'French',
              'Asian',
              'Mexican',
              'Salads',
              'Vegan',
              'Pizza',
            ].map(
              (n) => _option(n, '', store.cuisine == n, () {
                store.cuisine = store.cuisine == n ? null : n;
                store.changed();
              }),
            ),
            const SectionTitle('Filter'),
            ...['Open now', 'Credit Card', 'Free Delivery'].map(
              (n) => _option(n, '', store.filterFlags.contains(n), () {
                if (!store.filterFlags.add(n)) store.filterFlags.remove(n);
                store.changed();
              }),
            ),
            const SectionTitle('Rated'),
            ...['Rated 5', 'Rated 4+', 'Rated 3+'].map(
              (n) => _option(n, '', store.minRating == int.parse(n[6]), () {
                store.minRating = store.minRating == int.parse(n[6])
                    ? 0
                    : int.parse(n[6]);
                store.changed();
              }),
            ),
            const SectionTitle('Price'),
            RangeSlider(
              values: store.priceRange,
              min: 0,
              max: 60,
              onChanged: (v) {
                store.priceRange = v;
                store.changed();
              },
            ),
          ],
        ),
      );
    }
    return Stack(
      children: [
        s == 48 ? _discover(15) : _restaurantList(16),
        Container(color: Colors.black38),
        Align(
          alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
          child: SafeArea(
            top: top,
            bottom: !top,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .84,
              ),
              child: SingleChildScrollView(child: panel),
            ),
          ),
        ),
      ],
    );
  }
}
