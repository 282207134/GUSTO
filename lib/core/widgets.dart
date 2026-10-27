import 'package:flutter/material.dart';
import 'theme.dart';
import 'store.dart';

void go(BuildContext context, int screen) =>
    Navigator.of(context).pushNamed('/screen/$screen');
void home(BuildContext context) =>
    Navigator.of(context).pushNamedAndRemoveUntil('/screen/15', (r) => false);
void back(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    home(context);
  }
}

void notice(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
String euro(num value) => '€ ${value.toStringAsFixed(2)}';

class Picture extends StatelessWidget {
  final String name;
  final double? width, height;
  final BoxFit fit;
  const Picture(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/$name.png',
    width: width,
    height: height,
    fit: fit,
    filterQuality: FilterQuality.medium,
  );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool dark, outline;
  final IconData? icon;
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.dark = false,
    this.outline = false,
    this.icon,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 49,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: outline
            ? Colors.white
            : dark
            ? Colors.black
            : yellow,
        foregroundColor: outline ? Colors.black : Colors.white,
        disabledBackgroundColor: line,
        side: outline
            ? const BorderSide(color: Colors.black54)
            : BorderSide.none,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: const StadiumBorder(),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
          ),
        ],
      ),
    ),
  );
}

class PageFrame extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? footer;
  final List<Widget> actions;
  final bool large, bottom, showBack;
  final int tab;
  const PageFrame({
    super.key,
    required this.title,
    required this.body,
    this.footer,
    this.actions = const [],
    this.large = true,
    this.bottom = false,
    this.showBack = true,
    this.tab = 0,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 48,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              tooltip: 'Back',
              onPressed: () => back(context),
              icon: const Icon(Icons.arrow_back, size: 25),
            )
          : null,
      centerTitle: true,
      title: large
          ? null
          : Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
      actions: actions,
    ),
    body: SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (large)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          Expanded(child: body),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: footer!,
            ),
        ],
      ),
    ),
    bottomNavigationBar: bottom ? GustoNav(selected: tab) : null,
  );
}

class GustoNav extends StatelessWidget {
  final int selected;
  const GustoNav({super.key, required this.selected});
  @override
  Widget build(BuildContext context) {
    final count = AppScope.of(context).count;
    const icons = [
      Icons.home_rounded,
      Icons.room_service_rounded,
      Icons.shopping_bag_rounded,
      Icons.chat_bubble_rounded,
      Icons.more_horiz,
    ];
    const labels = ['Home', 'Discover', 'My Order', 'Delivery Chat', 'More'];
    const routes = [15, 43, 19, 26, 45];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(
              5,
              (i) => Expanded(
                child: Semantics(
                  selected: i == selected,
                  label: labels[i],
                  button: true,
                  child: InkResponse(
                    onTap: () {
                      if (i != selected) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/screen/${routes[i]}',
                          (route) => false,
                        );
                      }
                    },
                    child: SizedBox(
                      height: 58,
                      child: Center(
                        child: Badge(
                          isLabelVisible: i == 2 && count > 0,
                          label: Text('$count'),
                          backgroundColor: yellow,
                          child: Icon(
                            icons[i],
                            size: 27,
                            color: i == selected
                                ? yellow
                                : const Color(0xFFC7C7CC),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const SectionTitle(this.title, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        if (onTap != null)
          InkWell(
            onTap: onTap,
            child: const Row(
              children: [
                Text('View all', style: TextStyle(fontSize: 12)),
                SizedBox(width: 5),
                Icon(Icons.chevron_right, color: yellow, size: 18),
              ],
            ),
          ),
      ],
    ),
  );
}

class SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged, onSubmitted;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  const SearchBox({
    super.key,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.controller,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    readOnly: onTap != null,
    onTap: onTap,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: muted),
      prefixIcon: const Icon(Icons.search, color: muted, size: 20),
      filled: true,
      fillColor: const Color(0xFFF3F3F4),
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: yellow),
      ),
    ),
  );
}

class QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback? minus, plus;
  const QuantityControl(this.quantity, {super.key, this.minus, this.plus});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkResponse(
        onTap: minus,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.remove_circle_outline, size: 23, color: muted),
        ),
      ),
      Text('$quantity', style: const TextStyle(fontSize: 15)),
      InkResponse(
        onTap: plus,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.add_circle, size: 23, color: yellow),
        ),
      ),
    ],
  );
}

class Stars extends StatelessWidget {
  final double rating;
  const Stars({super.key, this.rating = 4.2});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '★★★★',
        style: const TextStyle(color: yellow, fontSize: 15, letterSpacing: -2),
      ),
      const Text('★', style: TextStyle(color: Color(0xFFD9D9DC), fontSize: 15)),
      const SizedBox(width: 6),
      Text('($rating)', style: const TextStyle(fontSize: 12, color: muted)),
    ],
  );
}

class EmptyState extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Widget? action;
  const EmptyState(
    this.title, {
    super.key,
    this.subtitle = '',
    this.icon = Icons.shopping_bag_outlined,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 65, color: const Color(0xFF343438)),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
      if (action != null)
        Padding(padding: const EdgeInsets.all(16), child: action!),
    ],
  );
}

class MenuRow extends StatelessWidget {
  final String title;
  final String? subtitle, trailing;
  final IconData? icon;
  final VoidCallback? onTap;
  const MenuRow(
    this.title, {
    super.key,
    this.subtitle,
    this.trailing,
    this.icon,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        leading: icon != null
            ? Icon(icon, size: 21, color: Colors.black)
            : null,
        title: Text(title, style: const TextStyle(fontSize: 16)),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(color: muted, fontSize: 12),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(color: muted, fontSize: 13),
              ),
            if (onTap != null)
              const Icon(Icons.chevron_right, size: 20, color: muted),
          ],
        ),
        onTap: onTap,
      ),
      const Divider(),
    ],
  );
}
