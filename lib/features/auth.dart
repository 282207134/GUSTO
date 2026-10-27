import 'package:flutter/material.dart';
import '../core/store.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class AuthPage extends StatefulWidget {
  final int screen;
  const AuthPage(this.screen, {super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final name = TextEditingController(),
      mobile = TextEditingController(),
      password = TextEditingController(),
      code = TextEditingController();
  bool invalid = false, hidden = true;
  @override
  void dispose() {
    name.dispose();
    mobile.dispose();
    password.dispose();
    code.dispose();
    super.dispose();
  }

  void submit(bool signup) {
    if (mobile.text.trim().length < 6 ||
        password.text.length < 4 ||
        (signup && name.text.trim().isEmpty)) {
      setState(() => invalid = true);
      return;
    }
    final store = AppScope.of(context);
    if (signup) store.name = name.text.trim();
    store.signedIn = true;
    store.changed();
    home(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.screen;
    if (s <= 3 || s == 44) return _onboarding(s);
    if (s >= 11 && s <= 13) return _recovery(s);
    final signup = [7, 10].contains(s), photo = [7, 8].contains(s);
    final form = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photo) ...[
            const Center(
              child: SizedBox(width: 28, child: Divider(thickness: 3)),
            ),
            const SizedBox(height: 18),
          ],
          Text(
            photo
                ? 'Welcome back'
                : signup
                ? 'Create New Account'
                : 'Login your account',
            style: TextStyle(
              fontSize: photo ? 30 : 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            photo
                ? signup
                      ? 'Register to your account'
                      : 'Login to your account'
                : signup
                ? 'Enter your Name, Mobile & Password for Sign Up'
                : 'Enter your Mobile Number & Password for Sign In',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 30),
          if (!photo) ...[
            const Picture('logo', width: 114, height: 28),
            const SizedBox(height: 22),
          ],
          if (signup || s == 8)
            TextField(
              controller: name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
          TextField(
            key: const Key('mobile'),
            controller: mobile,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              errorText: invalid || s == 6
                  ? 'Enter a valid mobile number'
                  : null,
            ),
          ),
          TextField(
            key: const Key('password'),
            controller: password,
            obscureText: hidden,
            onSubmitted: (_) => submit(signup),
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: invalid || s == 6
                  ? 'Invalid credentials, please try again'
                  : null,
              suffixIcon: IconButton(
                tooltip: hidden ? 'Show password' : 'Hide password',
                icon: Icon(
                  hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 19,
                  color: muted,
                ),
                onPressed: () => setState(() => hidden = !hidden),
              ),
            ),
          ),
          if (!signup)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => go(context, 11),
                child: const Text(
                  'Forgot Password',
                  style: TextStyle(color: Colors.black, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 18),
          PrimaryButton(
            signup ? 'SIGN UP' : 'SIGN IN',
            key: const Key('auth-submit'),
            onPressed: () => submit(signup),
          ),
          if (s == 10) ...[
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'By signing up you agree to our terms and conditions',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
          if (s != 10) ...[
            const SizedBox(height: 18),
            const Center(child: Text('Or', style: TextStyle(fontSize: 13))),
            const SizedBox(height: 18),
            if (s == 4)
              Row(
                children: [
                  Expanded(child: _social('Twitter', const Color(0xFF00ACEE))),
                  const SizedBox(width: 10),
                  Expanded(child: _social('Facebook', const Color(0xFF395899))),
                ],
              )
            else if (s == 9)
              PrimaryButton(
                'SIGN UP',
                onPressed: () => go(context, 10),
                outline: true,
              )
            else
              Center(
                child: InkWell(
                  onTap: () => notice(
                    context,
                    'Social sign-in is not connected in this demo.',
                  ),
                  child: const Picture('social-icons', width: 115, height: 27),
                ),
              ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
    if (photo) {
      return Scaffold(
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Picture(
                      s == 7 ? 'salad-hero' : 'pasta-hero',
                      width: double.infinity,
                      height: 275,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 16,
                      top: MediaQuery.paddingOf(context).top + 10,
                      child: ActionChip(
                        label: Text(signup ? 'SIGN IN' : 'SIGN UP'),
                        onPressed: () => go(context, signup ? 8 : 7),
                      ),
                    ),
                  ],
                ),
                Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: form,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return PageFrame(
      title: signup ? 'Sign Up' : 'Sign In',
      large: false,
      actions: [
        TextButton(
          onPressed: () => go(context, signup ? 4 : 10),
          child: Text(
            signup ? 'SIGN IN' : 'SIGN UP',
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
      ],
      body: SingleChildScrollView(child: form),
    );
  }

  Widget _social(String text, Color color) => FilledButton(
    onPressed: () =>
        notice(context, '$text sign-in is not connected in this demo.'),
    style: FilledButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
    ),
    child: Text(text),
  );
  Widget _onboarding(int s) {
    final store = AppScope.of(context);
    if (s == 44) {
      return PageFrame(
        title: '',
        actions: [
          TextButton(
            onPressed: () => home(context),
            child: const Text('Skip', style: TextStyle(color: Colors.black)),
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Turn on\nNotification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'This way you will see when someone\nmessages you instantly',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Turn on notification'),
                value: store.notifications,
                onChanged: (v) {
                  store.notifications = v;
                  store.changed();
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Alerts will be displayed if the phone is locked or unlocked. Show alerts on the screen or in the notification center.',
                style: TextStyle(fontSize: 13, color: muted),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: s == 3
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        const Picture('welcome', fit: BoxFit.cover),
                        Positioned(
                          top: 6,
                          right: 12,
                          child: TextButton(
                            onPressed: () => home(context),
                            child: const Text(
                              'Skip',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    )
                  : s == 2
                  ? const Center(
                      child: Icon(
                        Icons.pin_drop_outlined,
                        color: yellow,
                        size: 130,
                      ),
                    )
                  : Stack(
                      children: [
                        Positioned(
                          left: -80,
                          top: 60,
                          child: const Picture('onboard-burger', width: 230),
                        ),
                        Positioned(
                          right: -90,
                          top: 60,
                          child: const Picture('onboard-sushi', width: 230),
                        ),
                      ],
                    ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      s == 1
                          ? 'Notifications'
                          : s == 2
                          ? 'Activate the Place'
                          : 'Welcome',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        s == 1
                            ? 'Allow notifications to explore deals from your favorite eateries and new restaurants delivering to your area'
                            : s == 2
                            ? 'You can now specify your address to deliver your orders and see which payment method is right for you'
                            : 'Welcome to the best app to order fast food in the world',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: muted, fontSize: 14),
                      ),
                    ),
                    const Spacer(),
                    if (s == 1)
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              'Not now',
                              outline: true,
                              onPressed: () => go(context, 2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PrimaryButton(
                              'Notify me',
                              dark: true,
                              onPressed: () {
                                store.notifications = true;
                                store.changed();
                                go(context, 2);
                              },
                            ),
                          ),
                        ],
                      )
                    else if (s == 2) ...[
                      PrimaryButton(
                        'Activate',
                        dark: true,
                        onPressed: () => go(context, 28),
                      ),
                      TextButton(
                        onPressed: () => go(context, 3),
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ] else ...[
                      PrimaryButton('SIGN IN', onPressed: () => go(context, 4)),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        'SIGN UP',
                        outline: true,
                        onPressed: () => go(context, 10),
                      ),
                    ],
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recovery(int s) {
    return PageFrame(
      title: s == 11 ? 'Forgot Password' : '',
      large: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            if (s != 11)
              Text(
                s == 12 ? 'Has been sent' : 'Enter the verify code',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 10),
            Text(
              s == 11
                  ? "Enter your mobile number and we’ll send you the reset instructions by text message"
                  : s == 12
                  ? 'We will send you the new password by text message on the number listed'
                  : 'We have sent you an SMS with a code to the number',
              style: const TextStyle(color: muted, fontSize: 14),
            ),
            if (s != 11) ...[
              const SizedBox(height: 14),
              const Text(
                '+10 876 777 3898',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 24),
            if (s == 11)
              TextField(
                controller: mobile,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+33 498',
                  errorText: invalid ? 'Enter a valid mobile number' : null,
                ),
              ),
            if (s == 13)
              TextField(
                controller: code,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30, letterSpacing: 24),
                decoration: InputDecoration(
                  hintText: '7 5 — —',
                  errorText: invalid ? 'Enter a 4 digit code' : null,
                  counterText: '',
                ),
              ),
            const SizedBox(height: 24),
            PrimaryButton(
              s == 11
                  ? 'Reset Password'
                  : s == 12
                  ? 'Go to home'
                  : 'Verify',
              onPressed: () {
                if (s == 11) {
                  if (mobile.text.length < 6) {
                    setState(() => invalid = true);
                    return;
                  }
                  go(context, 12);
                } else if (s == 12) {
                  go(context, 13);
                } else {
                  if (code.text.length != 4) {
                    setState(() => invalid = true);
                    return;
                  }
                  notice(context, 'Demo verification completed');
                  home(context);
                }
              },
            ),
            if (s != 11) ...[
              const SizedBox(height: 22),
              const Center(
                child: Text(
                  'I haven’t received my password',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => notice(
                    context,
                    'Demo code: enter any 4 digits. No SMS is sent.',
                  ),
                  child: const Text(
                    'Resend a new code',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Demo account • no SMS service connected',
              style: TextStyle(fontSize: 11, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
