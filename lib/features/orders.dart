import 'package:flutter/material.dart';
import '../core/store.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class OrdersPage extends StatefulWidget {
  final int screen;
  const OrdersPage(this.screen, {super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int tab = 0;
  final message = TextEditingController();
  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.screen;
    if ([19, 20].contains(s)) return _cart(s);
    if (s == 23) return _history();
    if (s == 24) return _info();
    if ([25, 26, 27].contains(s)) return _chat(s);
    if (s == 31) return _tracking();
    if (s == 40) return _checkout();
    return _status();
  }

  Widget _cart(int s) {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'My Order',
      bottom: true,
      tab: 2,
      actions: [
        IconButton(
          tooltip: 'Order history',
          onPressed: () => go(context, 23),
          icon: const Icon(Icons.history),
        ),
        IconButton(
          tooltip: 'Search',
          onPressed: () => go(context, 38),
          icon: const Icon(Icons.search),
        ),
      ],
      body: Column(
        children: [
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: InkWell(
                  onTap: () => setState(() => tab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: tab == i ? yellow : line,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      ['All Dishes', 'Pending', 'Executed requests'][i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: tab == i ? Colors.black : muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: store.cart.isEmpty
                ? EmptyState(
                    'Your order is empty',
                    subtitle:
                        'Find something delicious and add it to your order.',
                    action: PrimaryButton(
                      'Discover restaurants',
                      onPressed: () => go(context, 16),
                    ),
                  )
                : tab == 2 && !store.delivered
                ? const EmptyState(
                    'No completed dishes',
                    subtitle: 'Your completed requests will appear here.',
                    icon: Icons.check_circle_outline,
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: store.cart.entries.map((e) {
                      final f = store.food(e.key);
                      final tile = Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Picture(f.image, width: 75, height: 80),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    f.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: muted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text(
                                        'Quantity',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: muted,
                                        ),
                                      ),
                                      const Spacer(),
                                      QuantityControl(
                                        e.value,
                                        minus: () => store.quantity(e.key, -1),
                                        plus: () => store.quantity(e.key, 1),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Price ${euro(store.unitPrice(e.key))}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: muted,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Total ${euro(store.unitPrice(e.key) * e.value)}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                      return Dismissible(
                        key: ValueKey(e.key),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          store.cart.remove(e.key);
                          store.changed();
                        },
                        background: Container(
                          color: const Color(0xFFF11D4B),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        child:
                            s == 20 &&
                                e.key ==
                                    store.cart.entries.skip(1).firstOrNull?.key
                            ? Row(
                                children: [
                                  Expanded(child: tile),
                                  IconButton(
                                    tooltip: 'Delete item',
                                    onPressed: () {
                                      store.cart.remove(e.key);
                                      store.changed();
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFFF11D4B),
                                      foregroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(),
                                    ),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                  IconButton(
                                    tooltip: 'Edit item',
                                    onPressed: () {
                                      store.selectedFood = f;
                                      go(context, 22);
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor: purple,
                                      foregroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(),
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                ],
                              )
                            : tile,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      footer: store.cart.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _money('Subtotal', store.subtotal),
                const SizedBox(height: 12),
                PrimaryButton(
                  'Go to Checkout',
                  key: const Key('checkout'),
                  onPressed: () => go(context, 40),
                ),
              ],
            ),
    );
  }

  Widget _history() {
    final store = AppScope.of(context);
    final orders = [
      if (store.ordered)
        (
          'u57j8',
          store.orderTotal,
          store.delivered ? 'Delivered' : 'On the way',
        ),
      '948994',
      '865544',
      '322134',
      '900879',
    ];
    return PageFrame(
      title: 'My Order',
      bottom: true,
      tab: 2,
      body: ListView.separated(
        itemCount: orders.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, i) {
          final record = orders[i];
          final custom = record is (String, double, String);
          final id = custom ? record.$1 : record as String;
          final price = custom
              ? record.$2
              : [490.0, 76.0, 23.0, 13.0][(i - (store.ordered ? 1 : 0)).clamp(
                  0,
                  3,
                )];
          final status = custom
              ? record.$3
              : [
                  'On the way',
                  'Delivered',
                  'Closed',
                  'Closed',
                ][(i - (store.ordered ? 1 : 0)).clamp(0, 3)];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            onTap: () {
              store.viewedOrder = id;
              go(context, custom ? 41 : 24);
            },
            title: Text(
              'Order #$id',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '● $status',
              style: TextStyle(
                color: status == 'Delivered'
                    ? Colors.green
                    : status == 'Closed'
                    ? Colors.red
                    : yellow,
                fontSize: 12,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  euro(price),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Jan 4, 2019',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _info() {
    final store = AppScope.of(context);
    final recent = store.viewedOrder == 'u57j8' && store.ordered;
    final items = recent ? store.lastOrder : store.cart;
    return PageFrame(
      title: 'Order #${recent ? 'u57j8' : store.viewedOrder}',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Picture('burger-king-logo', width: 70, height: 70),
            title: const Text(
              'Burger King',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              store.delivered ? 'Completed' : 'May 09, 2020   06:53 AM',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ),
          const SectionTitle('Order Details'),
          if (items.isNotEmpty)
            ...items.entries.map(
              (e) => _money(
                '${store.food(e.key).name} ×${e.value}',
                store.unitPrice(e.key) * e.value,
              ),
            )
          else ...[
            _money('Egg  ×2', 2),
            _money('Water', 1),
            _money('Cheese  ×3', 6),
            _money('Coca cola', 10),
          ],
          const Divider(),
          _money(
            'Subtotal',
            recent
                ? store.orderSubtotal
                : items.isEmpty
                ? 19
                : store.subtotal,
          ),
          _money(
            'Delivery',
            recent
                ? 2
                : items.isEmpty
                ? 2
                : store.delivery,
          ),
          if (recent && store.orderDiscount > 0)
            _money('Discount', -store.orderDiscount),
          _money(
            'Total',
            recent
                ? store.orderTotal
                : items.isEmpty
                ? 21
                : store.total,
            bold: true,
          ),
          const Divider(),
          MenuRow(
            'Payment Method',
            trailing: recent ? store.orderPayment : store.payment,
          ),
        ],
      ),
    );
  }

  Widget _money(String label, num value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              color: bold ? Colors.black : muted,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          euro(value),
          style: TextStyle(
            fontSize: bold ? 23 : 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
  Widget _checkout() {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'Checkout',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => go(context, 30),
                child: const Text(
                  'Change',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          Text(store.address.title, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          Text(
            '${store.address.detail}\n(+501) 425 906 4618\nZip code: 92053',
            style: const TextStyle(color: muted, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 14),
          const Divider(),
          _money('Order info', store.subtotal, bold: true),
          Text(
            '${store.count} items · Extra Cheese Slice, ketchup',
            style: const TextStyle(fontSize: 11, color: muted),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.eco_outlined),
            title: const Text('No Cutlery', style: TextStyle(fontSize: 15)),
            subtitle: const Text(
              'Make your order eco-friendly',
              style: TextStyle(fontSize: 11, color: muted),
            ),
            value: store.eco,
            onChanged: (v) {
              store.eco = v;
              store.changed();
            },
          ),
          const Divider(),
          const SectionTitle('Delivery Time'),
          Row(
            children: [
              _radio('Now', !store.preorder, () {
                store.preorder = false;
                store.changed();
              }),
              const SizedBox(width: 24),
              _radio('Pre-Order', store.preorder, () {
                store.preorder = true;
                store.changed();
              }),
            ],
          ),
          if (store.preorder)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Scheduled for tomorrow, 12:00 – 12:30',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ),
          const Divider(),
          const SectionTitle('Payment Method'),
          ...['Apple Pay', 'VISA Checkout', 'Credit Card', 'Cash'].map(
            (n) => InkWell(
              onTap: () {
                store.payment = n;
                store.changed();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    if (n == 'Apple Pay')
                      const Picture('apple-pay', width: 32, height: 20)
                    else if (n == 'VISA Checkout')
                      const Picture('visa', width: 32, height: 20)
                    else
                      Icon(
                        n == 'Cash'
                            ? Icons.payments_outlined
                            : Icons.credit_card,
                        color: n == 'Cash' ? Colors.green : yellow,
                        size: 26,
                      ),
                    const SizedBox(width: 15),
                    Expanded(child: Text(n)),
                    Icon(
                      store.payment == n
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: yellow,
                      size: 23,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          _money('Subtotal', store.subtotal),
          _money('Service Charge', store.delivery),
          if (store.promo) _money('Promo discount', -store.discount),
          _money('Total Amount', store.total, bold: true),
          const Text(
            'Demo checkout • no payment is charged',
            style: TextStyle(color: muted, fontSize: 11),
          ),
          const SizedBox(height: 12),
        ],
      ),
      footer: PrimaryButton(
        'Place Order',
        key: const Key('place-order'),
        onPressed: store.cart.isEmpty
            ? null
            : () {
                if (store.payment == 'Credit Card' && store.cards.isEmpty) {
                  notice(context, 'Add a demo card or choose Cash.');
                  go(context, 32);
                  return;
                }
                if (['Apple Pay', 'VISA Checkout'].contains(store.payment)) {
                  notice(
                    context,
                    'Wallet is not connected. Choose Cash or add a demo card.',
                  );
                  return;
                }
                store.placeOrder();
                go(context, 41);
              },
      ),
    );
  }

  Widget _radio(String title, bool selected, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          size: 22,
          color: yellow,
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
  Widget _status() {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'Invoice :u57j8',
      large: false,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 15),
          const Picture('order-bucket', height: 145),
          const SizedBox(height: 16),
          Text(
            'KFC ${euro(store.ordered
                ? store.orderTotal
                : store.cart.isEmpty
                ? 51
                : store.total)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 45),
          _step('Order Received', '06:12 AM, 12 Apr 2019', true),
          _step(
            'On the way',
            'Your courier is heading to you',
            !store.delivered,
            action: OutlinedButton.icon(
              onPressed: () => go(context, 31),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              icon: const Icon(Icons.navigation_outlined, size: 15),
              label: const Text('Tracking'),
            ),
          ),
          _step(
            store.delivered ? 'Delivered' : 'Delivery',
            store.delivered ? 'Delivery confirmed' : 'Finish in 35 minutes',
            store.delivered,
          ),
          const SizedBox(height: 24),
        ],
      ),
      footer: PrimaryButton(
        store.delivered ? 'Back to Home' : 'Confirm Delivery',
        dark: true,
        onPressed: () {
          if (store.delivered) {
            home(context);
          } else {
            store.confirmDelivery();
            notice(context, 'Delivery confirmed. Enjoy your meal!');
          }
        },
      ),
    );
  }

  Widget _step(String title, String subtitle, bool active, {Widget? action}) =>
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Icon(
                  active ? Icons.check_circle : Icons.circle_outlined,
                  size: 20,
                  color: active ? yellow : line,
                ),
                Expanded(child: Container(width: 2, color: line)),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                    ?action,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  Widget _tracking() => Scaffold(
    body: Stack(
      children: [
        const Positioned.fill(child: Picture('map', fit: BoxFit.cover)),
        const Positioned(
          top: 220,
          left: 100,
          child: Icon(Icons.route, size: 130, color: purple),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 5,
          left: 6,
          child: IconButton(
            tooltip: 'Back',
            onPressed: () => back(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        const Positioned(
          top: 300,
          left: 160,
          child: CircleAvatar(
            backgroundColor: purple,
            child: Icon(Icons.delivery_dining, color: Colors.white),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 305,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Order Status',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Invoice :u57j8',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Arrived in  ', style: TextStyle(color: muted)),
                        Text(
                          '06:13 ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'min',
                          style: TextStyle(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _trackingAction(
                          Icons.chat_bubble_outline,
                          'Chat',
                          () => go(context, 27),
                        ),
                        const SizedBox(width: 28),
                        _trackingAction(
                          Icons.call_outlined,
                          'Call',
                          () => notice(
                            context,
                            'Demo courier · +33 1 42 00 00 00',
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    PrimaryButton(
                      'Order Details',
                      dark: true,
                      onPressed: () {
                        AppScope.of(context).viewedOrder = 'u57j8';
                        go(context, 24);
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
  Widget _trackingAction(IconData icon, String text, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: muted),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(height: 5),
            Text(text, style: const TextStyle(fontSize: 11, color: muted)),
          ],
        ),
      );
  Widget _chat(int s) {
    final store = AppScope.of(context);
    if (s == 25) {
      return PageFrame(
        title: 'Delivery Chat',
        large: false,
        bottom: true,
        tab: 3,
        body: EmptyState(
          'Delivery Chat is empty',
          icon: Icons.forum_outlined,
          action: PrimaryButton(
            'Discover restaurants now',
            onPressed: () => go(context, 16),
          ),
        ),
      );
    }
    if (s == 26) {
      return PageFrame(
        title: 'Delivery Chat',
        large: false,
        bottom: true,
        tab: 3,
        body: ListView.separated(
          itemCount: 5,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, i) => ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFFF3D9),
              child: i == 0
                  ? const ClipOval(
                      child: Picture('avatar', width: 48, height: 48),
                    )
                  : Text(
                      ['J', 'A', 'M', 'P', 'H'][i],
                      style: const TextStyle(color: Colors.black),
                    ),
            ),
            title: Text(
              [
                'John requested your message to a Question',
                'Hi MR ASH_H\nHow are u? 😐',
                'I have received your request and now I am on my way to you',
                'Please! Where do you live?',
                'The request has now been received on my way to you',
              ][i],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              [
                'Mar 13, 4:55 PM',
                'Apr 22, 5:12 AM',
                'Jan 02, 4:16 AM',
                'Sep 02, 1:43 PM',
                'Aug 15, 7:07 AM',
              ][i],
              style: const TextStyle(color: muted, fontSize: 11),
            ),
            onTap: () => go(context, 27),
          ),
        ),
      );
    }
    return PageFrame(
      title: 'Delivery Chat',
      large: false,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _bubble('Hi Captain 👋', false),
                _bubble('Is everything okay?', false),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Yesterday  04:20',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ),
                _bubble(
                  'I have received your request and now I am on my way to you',
                  true,
                ),
                _bubble('Thank you very much 😋', false),
                ...store.messages.map((m) => _bubble(m, true)),
              ],
            ),
          ),
          const Divider(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  const Icon(Icons.mood, size: 24, color: muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      key: const Key('chat-input'),
                      controller: message,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Message text',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('send-message'),
                    tooltip: 'Send message',
                    onPressed: _send,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_upward, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    if (message.text.trim().isEmpty) return;
    final store = AppScope.of(context);
    store.messages.add(message.text.trim());
    message.clear();
    store.changed();
    FocusScope.of(context).unfocus();
  }

  Widget _bubble(String text, bool own) => Align(
    alignment: own ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 260),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: own ? purple : const Color(0xFFF2F2F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: own ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      ),
    ),
  );
}
