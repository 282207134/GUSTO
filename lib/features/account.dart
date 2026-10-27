import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/store.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class AccountPage extends StatefulWidget {
  final int screen;
  const AccountPage(this.screen, {super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final address = TextEditingController(),
      title = TextEditingController(),
      number = TextEditingController(),
      month = TextEditingController(),
      year = TextEditingController(),
      cvv = TextEditingController(),
      promo = TextEditingController();
  bool invalid = false, defaultAddress = true, initialized = false;
  int paymentTab = 1;
  Offset pin = const Offset(.5, .4);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      initialized = true;
      final store = AppScope.of(context);
      if (store.editingAddress != null) {
        final a = store.addresses[store.editingAddress!];
        address.text = a.detail;
        title.text = a.title;
      }
    }
  }

  @override
  void dispose() {
    for (final c in [address, title, number, month, year, cvv, promo]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.screen;
    if (s == 28) return _mapAddress();
    if (s == 29) return _manualAddress();
    if (s == 30) return _addresses();
    if ([32, 33, 34].contains(s)) return _payment(s);
    if (s == 45) return _more();
    if (s == 50) return _notifications();
    if (s == 54) return _promos();
    if (s == 55) return _settings();
    return _profile();
  }

  Widget _more() {
    const rows = [
      ('My profile', Icons.person, 57),
      ('My address', Icons.map, 30),
      ('My payment methods', Icons.monetization_on, 32),
      ('Settings', Icons.settings, 55),
      ('Discover', Icons.explore, 43),
      ('Offer & Promos', Icons.local_offer_outlined, 54),
      ('Categories', Icons.room_service, 46),
      ('Find the nearest restaurants', Icons.near_me, 42),
      ('Favorites', Icons.favorite_border, 56),
      ('Orders history', Icons.history, 23),
      ('Notification', Icons.notifications_outlined, 50),
      ('Welcome & Sign In', Icons.login, 3),
    ];
    return PageFrame(
      title: 'More screen',
      bottom: true,
      tab: 4,
      actions: [
        IconButton(
          tooltip: 'All 60 screens',
          onPressed: () => Navigator.pushNamed(context, '/screens'),
          icon: const Icon(Icons.grid_view_outlined, size: 21),
        ),
      ],
      body: ListView(
        children: [
          ...rows.map(
            (r) => MenuRow(r.$1, icon: r.$2, onTap: () => go(context, r.$3)),
          ),
          MenuRow(
            'All 60 Pixso screens',
            icon: Icons.dashboard_outlined,
            onTap: () => Navigator.pushNamed(context, '/screens'),
          ),
          MenuRow(
            'Sign out',
            icon: Icons.logout,
            onTap: () {
              final store = AppScope.of(context);
              store.signedIn = false;
              store.changed();
              go(context, 3);
            },
          ),
        ],
      ),
    );
  }

  Widget _mapAddress() => Scaffold(
    body: Stack(
      children: [
        const Positioned.fill(child: Picture('map', fit: BoxFit.cover)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => back(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => go(context, 29),
                      icon: const Icon(
                        Icons.edit_location_alt_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                      label: const Text(
                        'Manually',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Add Address',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: MediaQuery.sizeOf(context).width * pin.dx - 24,
          top: MediaQuery.sizeOf(context).height * pin.dy - 24,
          child: GestureDetector(
            onPanUpdate: (d) => setState(
              () => pin = Offset(
                (pin.dx + d.delta.dx / MediaQuery.sizeOf(context).width).clamp(
                  .1,
                  .9,
                ),
                (pin.dy + d.delta.dy / MediaQuery.sizeOf(context).height).clamp(
                  .2,
                  .6,
                ),
              ),
            ),
            child: const Icon(Icons.location_on, color: yellow, size: 64),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 280,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select your location\nfrom the map',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Drag the map pin to find your location and select the delivery address.',
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.near_me, size: 16),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '87 boulevard de la Liberation, MARSEILLE',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    PrimaryButton('Next', onPressed: () => go(context, 29)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _manualAddress() {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'Add Address',
      actions: [
        IconButton(
          tooltip: 'Select on map',
          onPressed: () => go(context, 28),
          icon: const Icon(Icons.map_outlined),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          TextField(
            controller: title,
            decoration: const InputDecoration(
              labelText: 'Address label',
              hintText: 'Home, Work…',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('address-input'),
            controller: address,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Address',
              hintText: 'Street, number, city, country',
              errorText: invalid
                  ? 'Enter a full address (at least 8 characters)'
                  : null,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Make this my default address',
              style: TextStyle(fontSize: 14),
            ),
            value: defaultAddress,
            onChanged: (v) => setState(() => defaultAddress = v),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            'Save address',
            onPressed: () {
              if (address.text.trim().length < 8) {
                setState(() => invalid = true);
                return;
              }
              final a = Address(
                title.text.trim().isEmpty ? 'Home' : title.text.trim(),
                address.text.trim(),
              );
              if (store.editingAddress != null) {
                store.addresses[store.editingAddress!] = a;
                if (defaultAddress) store.addressIndex = store.editingAddress!;
                store.editingAddress = null;
              } else {
                store.addresses.add(a);
                if (defaultAddress) {
                  store.addressIndex = store.addresses.length - 1;
                }
              }
              store.changed();
              go(context, 30);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Map preview uses the original design asset. Enter the full delivery address manually.',
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _addresses() {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'Delivery Address',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: List.generate(store.addresses.length, (i) {
          final a = store.addresses[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        a.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        store.editingAddress = i;
                        go(context, 29);
                      },
                      child: const Text(
                        'EDIT',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${a.detail}\n(+501) 425 906 4618\nZip code: 92053',
                  style: const TextStyle(
                    fontSize: 13,
                    color: muted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    store.addressIndex = i;
                    store.changed();
                  },
                  child: Row(
                    children: [
                      Icon(
                        store.addressIndex == i
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: yellow,
                        size: 21,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        store.addressIndex == i
                            ? 'Default address'
                            : 'Set as default address',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      footer: PrimaryButton(
        'Add new address',
        icon: Icons.add,
        onPressed: () {
          store.editingAddress = null;
          go(context, 28);
        },
      ),
    );
  }

  Widget _payment(int s) {
    final store = AppScope.of(context);
    if (s == 32) {
      return PageFrame(
        title: store.cards.isEmpty ? '' : 'My payment methods',
        actions: [
          TextButton(
            onPressed: () => back(context),
            child: const Text('Done', style: TextStyle(color: Colors.black)),
          ),
        ],
        body: store.cards.isEmpty
            ? const EmptyState(
                'No Payment',
                subtitle:
                    'Please add your payment method for\nshopping now. A few minutes.',
                icon: Icons.credit_card_outlined,
              )
            : ListView(
                children: store.cards
                    .map(
                      (last4) => MenuRow(
                        'Master Card •••• $last4',
                        subtitle: 'Demo card · ready to use',
                        icon: Icons.credit_card,
                        onTap: () {
                          store.payment = 'Credit Card';
                          store.changed();
                          back(context);
                        },
                      ),
                    )
                    .toList(),
              ),
        footer: PrimaryButton(
          'Add your Payment',
          dark: true,
          icon: Icons.add,
          onPressed: () => go(context, 33),
        ),
      );
    }
    return PageFrame(
      title: s == 34 ? 'Payment Method' : 'Add New Payment',
      large: s != 34,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (s == 34) ...[
            const Text(
              'Available € 365',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select your Payment Method',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              height: 185,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'CREDIT CARD',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Picture('visa', width: 42, height: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('YOUR NAME HERE', style: TextStyle(fontSize: 11)),
                  Text(
                    number.text.isEmpty ? 'CARD NUMBER' : number.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'EXPIRES DATE                         CVC',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ] else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Text(
                'PayPal',
                style: TextStyle(
                  color: Color(0xFF003087),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              title: const Text('Paypal'),
              subtitle: const Text(
                'Not connected in demo',
                style: TextStyle(fontSize: 11, color: muted),
              ),
              trailing: const Icon(Icons.circle_outlined, color: line),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.credit_card, color: orange),
              title: const Text('Master Card'),
              subtitle: const Text(
                'Demo payment method',
                style: TextStyle(fontSize: 11, color: muted),
              ),
              trailing: const Icon(Icons.check_circle, color: yellow),
            ),
            const Divider(),
          ],
          TextField(
            key: const Key('card-number'),
            controller: number,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '4242 4242 4242 4242',
              errorText: invalid
                  ? 'Enter 16 digits, a valid expiry date and 3-digit CVV'
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: month,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'EXP. Month',
                    hintText: 'MM',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: year,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'EXP. Year',
                    hintText: 'YY',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: cvv,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(labelText: 'CVV'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.check_circle, color: yellow, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Set as default payment',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Demo only. Use 4242424242424242 with a future expiry and any 3-digit CVV. Only the last four digits are saved; no charge is made.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          if (s == 33)
            Center(
              child: TextButton(
                onPressed: () => go(context, 34),
                child: const Text(
                  'Preview card',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
        ],
      ),
      footer: PrimaryButton(
        s == 34 ? 'Save my credentials' : 'Add new card',
        icon: Icons.add,
        onPressed: _saveCard,
      ),
    );
  }

  void _saveCard() {
    final m = int.tryParse(month.text) ?? 0, y = int.tryParse(year.text) ?? 0;
    final now = DateTime.now();
    if (number.text.length != 16 ||
        m < 1 ||
        m > 12 ||
        y < now.year % 100 ||
        (y == now.year % 100 && m < now.month) ||
        cvv.text.length != 3) {
      setState(() => invalid = true);
      return;
    }
    final store = AppScope.of(context);
    final last4 = number.text.substring(12);
    if (!store.cards.contains(last4)) store.cards.add(last4);
    store.payment = 'Credit Card';
    store.changed();
    number.clear();
    cvv.clear();
    go(context, 32);
  }

  Widget _notifications() => PageFrame(
    title: 'Notification',
    body: ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) => ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: [
              purple,
              const Color(0xFFF11D4B),
              const Color(0xFF74D597),
              yellow,
            ][i],
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            [
              Icons.local_shipping,
              Icons.cake,
              Icons.card_giftcard,
              Icons.shopping_bag,
            ][i],
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          [
            'Your order #IB136928 has been shipped!',
            'Happy Birth Day To You! Gift a 15% to you!',
            'Special Offer 25% all products today.',
            'Your order #IB136928 has been shipped!',
          ][i],
          style: const TextStyle(fontSize: 15),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            '20 mins ago',
            style: TextStyle(fontSize: 12, color: muted),
          ),
        ),
        onTap: () => go(context, i == 1 || i == 2 ? 54 : 41),
      ),
    ),
  );
  Widget _promos() {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'Offer & Promos',
      actions: [
        TextButton(
          onPressed: _applyPromo,
          child: const Text('Done', style: TextStyle(color: Colors.black)),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const Text(
            'Enter your promo code and get Discount',
            style: TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('promo-input'),
            controller: promo,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _applyPromo(),
            decoration: InputDecoration(
              labelText: 'Promo code',
              suffixIcon: const Icon(Icons.confirmation_number_outlined),
              errorText: invalid ? 'Try the demo code GUSTO15' : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            store.promo
                ? 'GUSTO15 applied · 15% off your next order'
                : 'Demo offer: use GUSTO15 for 15% off.',
            style: TextStyle(
              color: store.promo ? Colors.green : muted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _applyPromo() {
    if (promo.text.trim().toUpperCase() != 'GUSTO15') {
      setState(() => invalid = true);
      return;
    }
    final store = AppScope.of(context);
    store.promo = true;
    store.changed();
    setState(() => invalid = false);
    notice(context, '15% discount applied to checkout');
  }

  Widget _settings() {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'Settings',
      body: ListView(
        children: [
          MenuRow(
            'Language',
            trailing: '${store.country}  Change',
            onTap: () => go(context, 37),
          ),
          MenuRow('Password', trailing: 'Change', onTap: () => go(context, 11)),
          MenuRow('Location', trailing: 'Edit', onTap: () => go(context, 30)),
          SwitchListTile(
            title: const Text(
              'Receive Notification',
              style: TextStyle(fontSize: 15),
            ),
            value: store.notifications,
            onChanged: (v) {
              store.notifications = v;
              store.changed();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text(
              'Receive Newsletter',
              style: TextStyle(fontSize: 15),
            ),
            value: store.newsletter,
            onChanged: (v) {
              store.newsletter = v;
              store.changed();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text(
              'Receive special offers',
              style: TextStyle(fontSize: 15),
            ),
            value: store.offers,
            onChanged: (v) {
              store.offers = v;
              store.changed();
            },
          ),
        ],
      ),
    );
  }

  Widget _profile() {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'My Account',
      actions: [
        IconButton(
          tooltip: 'Edit profile',
          onPressed: _editProfile,
          icon: const Icon(Icons.edit_outlined, size: 20),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const ClipOval(child: Picture('avatar', width: 60, height: 60)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'I love traveling, restaurants, friendship and everything that is beautiful on the globe.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SectionTitle('My Addresses', onTap: () => go(context, 30)),
          InkWell(
            onTap: () => go(context, 30),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: yellow),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${store.country}, Paris',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          store.address.detail,
                          style: const TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: yellow),
                ],
              ),
            ),
          ),
          const SectionTitle('My account'),
          MenuRow('Orders history', onTap: () => go(context, 23)),
          MenuRow('Details & password', onTap: _editProfile),
          MenuRow(
            'My devices',
            onTap: () => _details(
              'My devices',
              'This device\nGusto Flutter demo · Active now',
            ),
          ),
          const SectionTitle('Services'),
          MenuRow('Support', onTap: () => go(context, 27)),
          MenuRow('Favorites', onTap: () => go(context, 56)),
        ],
      ),
    );
  }

  Future<void> _details(String title, String detail) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(detail),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    ),
  );
  Future<void> _editProfile() async {
    final store = AppScope.of(context);
    final controller = TextEditingController(text: store.name);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Your name'),
          maxLength: 40,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              store.name = controller.text.trim();
              store.changed();
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}
